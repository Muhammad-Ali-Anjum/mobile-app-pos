const mongoose = require('mongoose');

const couponSchema = new mongoose.Schema(
  {
    code: {
      type: String,
      required: true,
      unique: true,
      uppercase: true,
      trim: true
    },
    discountType: {
      type: String,
      enum: ['PERCENTAGE', 'FIXED'],
      default: 'PERCENTAGE'
    },
    value: {
      type: Number,
      required: true,
      default: 10
    },
    expiresAt: {
      type: Date,
      default: () => new Date(Date.now() + 30 * 86400000)
    },
    usageLimit: {
      type: Number,
      default: 100
    },
    usedCount: {
      type: Number,
      default: 0
    },
    applicablePlans: {
      type: [String],
      default: ['BASIC', 'STANDARD', 'PREMIUM']
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

module.exports = mongoose.model('Coupon', couponSchema);
