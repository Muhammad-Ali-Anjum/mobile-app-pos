const mongoose = require('mongoose');

const userBranchAccessSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true
    },
    shopId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Shop',
      required: true,
      index: true
    },
    branchId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Branch',
      default: null, // null if accessType is ALL
      index: true
    },
    accessType: {
      type: String,
      enum: ['ALL_BRANCHES', 'ASSIGNED_BRANCH', 'SPECIFIC_BRANCH', 'OWN_BRANCH_ONLY'],
      default: 'ASSIGNED_BRANCH'
    },
    assignedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      default: null
    }
  },
  {
    timestamps: true
  }
);

userBranchAccessSchema.index({ userId: 1, shopId: 1, branchId: 1 }, { unique: true });

module.exports = mongoose.model('UserBranchAccess', userBranchAccessSchema);
