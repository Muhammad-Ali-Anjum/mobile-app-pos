const permissionService = require('../services/permission.service');

/**
 * Enterprise Authorization Middleware
 * Enforces granular module.action permissions via permissionService
 */
const requirePermission = (requiredPermission) => {
  return async (req, res, next) => {
    try {
      if (!req.user) {
        return res.status(401).json({
          success: false,
          message: 'Unauthorized: User authentication is required.'
        });
      }

      // If user is Platform Super Admin, grant all access
      if (req.user.isPlatformUser && req.user.platformRole === 'super_admin') {
        return next();
      }

      if (!req.shopId) {
        return res.status(400).json({
          success: false,
          message: 'Tenant context (shopId) is missing for permission verification.'
        });
      }

      const hasPerm = await permissionService.hasPermission(
        req.user._id,
        req.shopId,
        requiredPermission
      );

      if (!hasPerm) {
        return res.status(403).json({
          success: false,
          message: `Forbidden: You do not possess the required permission [${requiredPermission}].`
        });
      }

      next();
    } catch (error) {
      return res.status(500).json({
        success: false,
        message: 'Internal authorization error.',
        error: error.message
      });
    }
  };
};

/**
 * Allows access if the user has AT LEAST ONE of the specified permissions
 */
const requireAnyPermission = (permissions = []) => {
  return async (req, res, next) => {
    try {
      if (!req.user) {
        return res.status(401).json({
          success: false,
          message: 'Unauthorized: User authentication is required.'
        });
      }

      if (req.user.isPlatformUser && req.user.platformRole === 'super_admin') {
        return next();
      }

      if (!req.shopId) {
        return res.status(400).json({
          success: false,
          message: 'Tenant context (shopId) is missing for permission verification.'
        });
      }

      const userPerms = await permissionService.resolveUserPermissions(req.user._id, req.shopId);
      if (userPerms.has('*')) {
        return next();
      }

      const hasAny = permissions.some((p) => userPerms.has(p));
      if (!hasAny) {
        return res.status(403).json({
          success: false,
          message: `Forbidden: Requires one of [${permissions.join(', ')}].`
        });
      }

      next();
    } catch (error) {
      return res.status(500).json({
        success: false,
        message: 'Internal authorization error.',
        error: error.message
      });
    }
  };
};

module.exports = {
  requirePermission,
  requireAnyPermission
};
