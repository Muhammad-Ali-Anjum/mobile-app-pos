const mongoose = require('mongoose');

const auditLogSchema = new mongoose.Schema(
  {
    shopId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Shop',
      default: null, // null for platform-level audit actions
      index: true
    },
    branchId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Branch',
      default: null,
      index: true
    },
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true
    },
    action: {
      type: String,
      required: true,
      trim: true
    },
    module: {
      type: String,
      required: true,
      trim: true,
      index: true
    },
    recordId: {
      type: String,
      default: null,
      index: true
    },
    oldValues: {
      type: mongoose.Schema.Types.Mixed,
      default: null
    },
    newValues: {
      type: mongoose.Schema.Types.Mixed,
      default: null
    },
    ipAddress: {
      type: String,
      default: ''
    },
    userAgent: {
      type: String,
      default: ''
    },
    requestId: {
      type: String,
      default: ''
    },
    approvalReference: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'ApprovalRequest',
      default: null
    }
  },
  {
    timestamps: { createdAt: true, updatedAt: false } // Immutable / append-only
  }
);

auditLogSchema.index({ shopId: 1, createdAt: -1 });

module.exports = mongoose.model('AuditLog', auditLogSchema);
