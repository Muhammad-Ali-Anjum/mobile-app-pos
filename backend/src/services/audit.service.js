const { AuditLog } = require('../models');

class AuditService {
  /**
   * Records an immutable audit log entry for security and compliance
   */
  async log({
    shopId = null,
    branchId = null,
    userId,
    action,
    module,
    recordId = null,
    oldValues = null,
    newValues = null,
    req = null,
    approvalReference = null
  }) {
    try {
      const ipAddress = req
        ? req.headers['x-forwarded-for'] || req.socket?.remoteAddress || req.ip || ''
        : '';
      const userAgent = req ? req.headers['user-agent'] || '' : '';
      const requestId = req ? req.id || req.headers['x-request-id'] || '' : '';

      const logEntry = new AuditLog({
        shopId,
        branchId,
        userId,
        action,
        module,
        recordId: recordId ? String(recordId) : null,
        oldValues,
        newValues,
        ipAddress,
        userAgent,
        requestId,
        approvalReference
      });

      return await logEntry.save();
    } catch (error) {
      console.error('Audit logging failed:', error);
      // Fail safely to not block the main transaction, or alert
      return null;
    }
  }

  /**
   * Query filtered audit trails
   */
  async queryLogs({ shopId, branchId, userId, module, startDate, endDate, limit = 50, skip = 0 }) {
    const filter = {};
    if (shopId) filter.shopId = shopId;
    if (branchId) filter.branchId = branchId;
    if (userId) filter.userId = userId;
    if (module) filter.module = module;
    if (startDate || endDate) {
      filter.createdAt = {};
      if (startDate) filter.createdAt.$gte = new Date(startDate);
      if (endDate) filter.createdAt.$lte = new Date(endDate);
    }

    const [logs, total] = await Promise.all([
      AuditLog.find(filter)
        .populate('userId', 'fullName username email employeeId')
        .populate('branchId', 'name code')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .lean(),
      AuditLog.countDocuments(filter)
    ]);

    return { logs, total, limit, skip };
  }
}

module.exports = new AuditService();
