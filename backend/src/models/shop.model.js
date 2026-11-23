const mongoose = require('mongoose');

const shopSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true
    },
    code: {
      type: String,
      unique: true,
      trim: true,
      uppercase: true
    },
    ownerId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    subscription: {
      plan: {
        type: String,
        enum: ['TRIAL', 'BASIC', 'STANDARD', 'PREMIUM', 'ENTERPRISE'],
        default: 'TRIAL'
      },
      status: {
        type: String,
        enum: ['ACTIVE', 'SUSPENDED', 'EXPIRED'],
        default: 'ACTIVE'
      },
      maxBranches: {
        type: Number,
        default: 1
      },
      maxUsers: {
        type: Number,
        default: 5
      },
      expiresAt: {
        type: Date
      }
    },
    settings: {
      currency: { type: String, default: 'PKR' },
      currencySymbol: { type: String, default: 'Rs.' },
      taxPercentage: { type: Number, default: 0 },
      maxCashierDiscountPercent: { type: Number, default: 10 },
      requireRefundApprovalAbove: { type: Number, default: 5000 },
      requirePurchaseApprovalAbove: { type: Number, default: 100000 },
      requireExpenseApprovalAbove: { type: Number, default: 15000 }
    },
    isActive: {
      type: Boolean,
      default: true
    }
  },
  {
    timestamps: true
  }
);

module.exports = mongoose.model('Shop', shopSchema);
