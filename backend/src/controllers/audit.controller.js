const auditService = require('../services/audit.service');

class AuditController {
  /**
   * View immutable audit trail
   */
  async listLogs(req, res) {
    try {
      const { branchId, userId, module, startDate, endDate, limit = 50, skip = 0 } = req.query;

      const result = await auditService.queryLogs({
        shopId: req.shopId,
        branchId,
        userId,
        module,
        startDate,
        endDate,
        limit: parseInt(limit, 10),
        skip: parseInt(skip, 10)
      });

      return res.status(200).json({
        success: true,
        ...result
      });
    } catch (error) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }
}

module.exports = new AuditController();
