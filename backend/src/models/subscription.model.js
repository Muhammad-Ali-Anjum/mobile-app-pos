const mongoose = require('mongoose');

const subscriptionSchema = new mongoose.Schema(
  {
    shopId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Shop',
      required: true,
      index: true
    },
    planSlug: {
      type: String,
      required: true,
      uppercase: true,
      trim: true
    },
    planName: {
      type: String,
      trim: true,
      default: ''
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
      type: Date,
      required: true
    },
    amount: {
      type: Number,
      default: 0
    },
    discount: {
      type: Number,
      default: 0
    },
    paymentStatus: {
      type: String,
      enum: ['PAID', 'PARTIAL', 'UNPAID', 'PENDING', 'REFUNDED'],
      default: 'PAID'
    },
    status: {
      type: String,
      enum: ['ACTIVE', 'TRIAL', 'PENDING', 'EXPIRED', 'SUSPENDED', 'CANCELLED'],
      default: 'ACTIVE',
      index: true
    },
    autoRenew: {
      type: Boolean,
      default: true
    },
    gracePeriodDays: {
      type: Number,
      default: 3
    },
    notes: {
      type: String,
      trim: true,
      default: ''
    }
  },
  {
    timestamps: true
  }
);

module.exports = mongoose.model('Subscription', subscriptionSchema);
