const mongoose = require('mongoose');

const shopSchema = new mongoose.Schema(
  {
    tenantId: {
      type: String,
      unique: true,
      sparse: true,
      trim: true,
      uppercase: true
    },
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
    shopType: {
      type: String,
      trim: true,
      default: 'Retail'
    },
    logoUrl: {
      type: String,
      trim: true,
      default: ''
    },
    email: {
      type: String,
      trim: true,
      lowercase: true,
      default: ''
    },
    phone: {
      type: String,
      trim: true,
      default: ''
    },
    address: {
      type: String,
      trim: true,
      default: ''
    },
    city: {
      type: String,
      trim: true,
      default: ''
    },
    country: {
      type: String,
      trim: true,
      default: 'Pakistan'
    },
    ownerId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    subscription: {
      plan: {
        type: String,
        default: 'TRIAL'
      },
      status: {
        type: String,
        enum: ['ACTIVE', 'TRIAL', 'PENDING', 'SUSPENDED', 'EXPIRED', 'CANCELLED'],
        default: 'ACTIVE'
      },
      billingCycle: {
        type: String,
        enum: ['MONTHLY', 'YEARLY'],
        default: 'MONTHLY'
      },
      startDate: {
        type: Date,
        default: Date.now
      },
      expiresAt: {
        type: Date
      },
      discount: {
        type: Number,
        default: 0
      },
      initialPayment: {
        type: Number,
        default: 0
      },
      maxBranches: {
        type: Number,
        default: 1
      },
      maxUsers: {
        type: Number,
        default: 5
      },
      maxPosTerminals: {
        type: Number,
        default: 1
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
