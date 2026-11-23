const permissionService = require('../services/permission.service');
const { Branch } = require('../models');

/**
 * Branch Isolation Middleware
 * Ensures the user only accesses records belonging to authorized branches
 */
const requireBranchAccess = async (req, res, next) => {
  try {
    const branchId =
      req.headers['x-branch-id'] ||
      req.query.branchId ||
      req.body?.branchId ||
      req.params?.branchId;

    if (!branchId) {
      // If branchId is not strictly required for the endpoint, proceed
      return next();
    }

    const branch = await Branch.findOne({ _id: branchId, shopId: req.shopId });
    if (!branch) {
      return res.status(404).json({
        success: false,
        message: 'Branch not found or does not belong to this shop.'
      });
    }

    const hasAccess = await permissionService.checkBranchAccess(
      req.user._id,
      req.shopId,
      branch._id
    );

    if (!hasAccess) {
      return res.status(403).json({
        success: false,
        message: 'Access denied: You do not have permission to access this branch.'
      });
    }

    req.branch = branch;
    req.branchId = branch._id;
    next();
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: 'Failed to evaluate branch authorization.',
      error: error.message
    });
  }
};

module.exports = {
  requireBranchAccess
};
