const { ApprovalRequest, Shop } = require('../models');
const auditService = require('./audit.service');

class ApprovalService {
  /**
   * Determine if an operation requires management approval based on shop policy
   */
  async checkRequiresApproval(shopId, actionType, payload) {
    const shop = await Shop.findById(shopId).lean();
    const settings = shop?.settings || {};

    switch (actionType) {
      case 'DISCOUNT_OVERRIDE': {
        const discountPercent = payload.discountPercent || 0;
        const maxAllowed = settings.maxCashierDiscountPercent || 10;
        return discountPercent > maxAllowed;
      }
      case 'HIGH_VALUE_REFUND': {
        const refundAmount = payload.amount || 0;
        const threshold = settings.requireRefundApprovalAbove || 5000;
        return refundAmount > threshold;
      }
      case 'HIGH_VALUE_PURCHASE': {
        const purchaseTotal = payload.totalAmount || 0;
        const threshold = settings.requirePurchaseApprovalAbove || 100000;
        return purchaseTotal > threshold;
      }
      case 'EXPENSE_APPROVAL': {
        const expenseAmount = payload.amount || 0;
        const threshold = settings.requireExpenseApprovalAbove || 15000;
        return expenseAmount > threshold;
      }
      case 'STOCK_ADJUSTMENT':
        return true; // Stock write-offs always require managerial authorization
      case 'PRODUCT_COST_CHANGE':
        return true;
      default:
        return false;
    }
  }

  /**
   * Create an approval request
   */
  async createRequest({ shopId, branchId, userId, actionType, module, recordId, requestData, reason, req }) {
    const request = new ApprovalRequest({
      shopId,
      branchId,
      requestedBy: userId,
      actionType,
      module,
      recordId,
      requestData,
      reason,
      status: 'PENDING'
    });

    const saved = await request.save();

    await auditService.log({
      shopId,
      branchId,
      userId,
      action: `APPROVAL_REQUESTED_${actionType}`,
      module,
      recordId: saved._id.toString(),
      newValues: { actionType, requestData, reason },
      req
    });

    return saved;
  }

  /**
   * Approves or rejects a pending request.
   * STRICT SECURITY RULE: Requester cannot approve their own request!
   */
  async reviewRequest({ requestId, approverId, decision, reviewNotes, req }) {
    const request = await ApprovalRequest.findById(requestId);
    if (!request) {
      throw new Error('Approval request not found');
    }

    if (request.status !== 'PENDING') {
      throw new Error(`Request has already been processed with status: ${request.status}`);
    }

    // Security rule: Requester cannot self-approve
    if (request.requestedBy.toString() === approverId.toString()) {
      throw new Error('Security policy violation: Requesters cannot approve their own requests.');
    }

    const previousStatus = request.status;
    request.status = decision; // 'APPROVED' or 'REJECTED'
    request.reviewedBy = approverId;
    request.reviewedAt = new Date();
    request.reviewNotes = reviewNotes || '';

    const updated = await request.save();

    await auditService.log({
      shopId: request.shopId,
      branchId: request.branchId,
      userId: approverId,
      action: `APPROVAL_${decision}`,
      module: request.module,
      recordId: request._id.toString(),
      oldValues: { status: previousStatus },
      newValues: { status: decision, reviewNotes },
      req,
      approvalReference: request._id
    });

    return updated;
  }
}

module.exports = new ApprovalService();
