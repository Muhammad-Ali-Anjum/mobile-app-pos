const { ApprovalRequest } = require('../models');
const approvalService = require('../services/approval.service');

class ApprovalController {
  /**
   * List approval requests for shop
   */
  async listApprovals(req, res) {
    try {
      const { status = 'PENDING', branchId } = req.query;
      const filter = { shopId: req.shopId };
      if (status && status !== 'ALL') filter.status = status;
      if (branchId) filter.branchId = branchId;

      const requests = await ApprovalRequest.find(filter)
        .populate('requestedBy', 'fullName username email employeeId')
        .populate('reviewedBy', 'fullName username')
        .populate('branchId', 'name code')
        .sort({ createdAt: -1 })
        .lean();

      return res.status(200).json({
        success: true,
        data: requests
      });
    } catch (error) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  /**
   * Submit an operation requiring approval
   */
  async submitRequest(req, res) {
    try {
      const { branchId, actionType, module, recordId, requestData, reason } = req.body;

      if (!actionType || !module || !requestData) {
        return res.status(400).json({
          success: false,
          message: 'actionType, module, and requestData are required.'
        });
      }

      const request = await approvalService.createRequest({
        shopId: req.shopId,
        branchId: branchId || req.branchId || null,
        userId: req.user._id,
        actionType,
        module,
        recordId,
        requestData,
        reason,
        req
      });

      return res.status(201).json({
        success: true,
        message: 'Approval request submitted successfully.',
        data: request
      });
    } catch (error) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  /**
   * Approve a request (requester cannot self-approve!)
   */
  async approveRequest(req, res) {
    try {
      const { id } = req.params;
      const { reviewNotes } = req.body;

      const updated = await approvalService.reviewRequest({
        requestId: id,
        approverId: req.user._id,
        decision: 'APPROVED',
        reviewNotes,
        req
      });

      return res.status(200).json({
        success: true,
        message: 'Request approved successfully.',
        data: updated
      });
    } catch (error) {
      return res.status(400).json({ success: false, message: error.message });
    }
  }

  /**
   * Reject a request
   */
  async rejectRequest(req, res) {
    try {
      const { id } = req.params;
      const { reviewNotes } = req.body;

      const updated = await approvalService.reviewRequest({
        requestId: id,
        approverId: req.user._id,
        decision: 'REJECTED',
        reviewNotes,
        req
      });

      return res.status(200).json({
        success: true,
        message: 'Request rejected.',
        data: updated
      });
    } catch (error) {
      return res.status(400).json({ success: false, message: error.message });
    }
  }
}

module.exports = new ApprovalController();
