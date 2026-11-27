const Branch = require('../models/branch.model');
const UserRole = require('../models/user-role.model');
const Product = require('../models/product.model');
const Plan = require('../models/plan.model');

/**
 * Enforces plan quota limits per tenant before creating resources.
 * Supported resources: 'BRANCH', 'USER', 'PRODUCT'
 */
const enforceQuota = (resourceType) => {
  return async (req, res, next) => {
    try {
      const shop = req.shop;
      if (!shop) {
        return res.status(400).json({ success: false, message: 'Tenant context is required for quota check.' });
      }

      // Super Admin bypasses tenant quota blocks if needed
      if (req.user?.isPlatformUser && req.user?.platformRole === 'super_admin') {
        return next();
      }

      const sub = shop.subscription || {};
      const planDoc = await Plan.findOne({ slug: (sub.plan || 'TRIAL').toUpperCase() });

      if (resourceType === 'BRANCH') {
        const limit = sub.maxBranches ?? planDoc?.maxBranches ?? 1;
        const count = await Branch.countDocuments({ shopId: shop._id, isActive: true });
        if (count >= limit) {
          return res.status(403).json({
            success: false,
            code: 'QUOTA_EXCEEDED',
            message: `Your plan allows only ${limit} branch${limit === 1 ? '' : 'es'}. Please upgrade your subscription to add more branches.`
          });
        }
      } else if (resourceType === 'USER') {
        const limit = sub.maxUsers ?? planDoc?.maxUsers ?? 3;
        const count = await UserRole.countDocuments({ shopId: shop._id, status: 'ACTIVE' });
        if (count >= limit) {
          return res.status(403).json({
            success: false,
            code: 'QUOTA_EXCEEDED',
            message: `User limit reached (${limit} users). Upgrade your subscription to add more users.`
          });
        }
      } else if (resourceType === 'PRODUCT') {
        const limit = planDoc?.maxProducts ?? 1000;
        const count = await Product.countDocuments({ shopId: shop._id });
        if (count >= limit) {
          return res.status(403).json({
            success: false,
            code: 'QUOTA_EXCEEDED',
            message: `Product limit reached (${limit} products). Upgrade your subscription to add more products.`
          });
        }
      }

      return next();
    } catch (err) {
      return next(err);
    }
  };
};

module.exports = { enforceQuota };
