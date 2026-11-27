const { Shop, UserRole } = require('../models');

/**
 * Tenant Isolation Middleware
 * Enforces multi-tenant data boundaries by verifying the shopId
 */
const requireTenant = async (req, res, next) => {
  try {
    const shopId =
      req.headers['x-shop-id'] ||
      req.query.shopId ||
      req.body?.shopId ||
      req.user?.defaultShopId;

    if (!shopId) {
      return res.status(400).json({
        success: false,
        message: 'Tenant context (x-shop-id header or shopId) is required.'
      });
    }

    const shop = await Shop.findById(shopId);
    if (!shop) {
      return res.status(404).json({
        success: false,
        message: 'Shop / Tenant not found.'
      });
    }

    if (!shop.isActive) {
      return res.status(403).json({
        success: false,
        message: 'This shop account is currently deactivated.'
      });
    }

    // Verify subscription status & expiry (with grace period)
    if (shop.subscription) {
      const subStatus = (shop.subscription.status || 'ACTIVE').toUpperCase();
      if (subStatus === 'SUSPENDED' || subStatus === 'CANCELLED') {
        return res.status(402).json({
          success: false,
          message: `Shop subscription is ${subStatus.toLowerCase()}. Please renew subscription.`
        });
      }
      if (subStatus === 'EXPIRED') {
        return res.status(402).json({
          success: false,
          message: 'Shop subscription has expired. Please renew to restore access.'
        });
      }
      if (shop.subscription.expiresAt) {
        const graceDays = 3;
        const cutoff = new Date(new Date(shop.subscription.expiresAt).getTime() + graceDays * 86400000);
        if (Date.now() > cutoff.getTime() && !(req.user?.isPlatformUser && req.user?.platformRole === 'super_admin')) {
          return res.status(402).json({
            success: false,
            message: 'Shop subscription and grace period have expired. Please renew subscription.'
          });
        }
      }
    }

    // Platform Super Admin has access across shops
    if (req.user.isPlatformUser && req.user.platformRole === 'super_admin') {
      req.shop = shop;
      req.shopId = shop._id;
      return next();
    }

    // Shop Owner always has access to their own shop
    if (String(shop.ownerId) === String(req.user._id)) {
      req.shop = shop;
      req.shopId = shop._id;
      return next();
    }

    // Verify user is an active employee / member of this shop
    const userRole = await UserRole.findOne({
      userId: req.user._id,
      shopId: shop._id,
      status: 'ACTIVE'
    });

    if (!userRole) {
      return res.status(403).json({
        success: false,
        message: 'Access denied: You are not authorized as an active member of this shop.'
      });
    }

    req.shop = shop;
    req.shopId = shop._id;
    next();
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: 'Failed to establish tenant context.',
      error: error.message
    });
  }
};

module.exports = {
  requireTenant
};
