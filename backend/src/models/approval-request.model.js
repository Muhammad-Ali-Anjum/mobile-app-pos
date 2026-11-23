const mongoose = require('mongoose');

const approvalRequestSchema = new mongoose.Schema(
  {
    shopId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Shop',
      required: true,
      index: true
    },
    branchId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Branch',
      default: null,
      index: true
    },
    requestedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true
    },
    actionType: {
      type: String,
      required: true,
      enum: [
        'DISCOUNT_OVERRIDE',
        'HIGH_VALUE_REFUND',
        'STOCK_ADJUSTMENT',
        'HIGH_VALUE_PURCHASE',
        'EXPENSE_APPROVAL',
        'PRODUCT_COST_CHANGE',
        'CASH_DRAWER_DISCREPANCY'
      ],
      index: true
    },
    module: {
      type: String,
      required: true,
      trim: true
    },
    recordId: {
      type: String,
      default: null
    },
    requestData: {
      type: mongoose.Schema.Types.Mixed,
      required: true
    },
    reason: {
      type: String,
      trim: true,
      default: ''
    },
    status: {
      type: String,
      enum: ['PENDING', 'APPROVED', 'REJECTED', 'CANCELLED'],
      default: 'PENDING',
      index: true
    },
    reviewedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      default: null
    },
    reviewedAt: {
      type: Date,
      default: null
    },
    reviewNotes: {
      type: String,
      trim: true,
      default: ''
    }
  },
  {
    timestamps: true
  }
);

approvalRequestSchema.index({ shopId: 1, status: 1, createdAt: -1 });

module.exports = mongoose.model('ApprovalRequest', approvalRequestSchema);
