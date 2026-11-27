const mongoose = require('mongoose');

const planSchema = new mongoose.Schema(
  {
    slug: {
      type: String,
      required: true,
      unique: true,
      uppercase: true,
      trim: true
    },
    name: {
      type: String,
      required: true,
      trim: true
    },
    monthlyPrice: {
      type: Number,
      required: true,
      default: 0
    },
    yearlyPrice: {
      type: Number,
      default: 0
    },
    maxBranches: {
      type: Number,
      required: true,
      default: 1
    },
    maxUsers: {
      type: Number,
      required: true,
      default: 3
    },
    maxPosTerminals: {
      type: Number,
      default: 1
    },
    maxProducts: {
      type: Number,
      default: 1000
    },
    storageLimitMb: {
      type: Number,
      default: 500
    },
    trialDays: {
      type: Number,
      default: 0
    },
    dedicatedSupport: {
      type: Boolean,
      default: false
    },
    features: {
      inventory: { type: Boolean, default: true },
      barcode: { type: Boolean, default: true },
      reports: { type: Boolean, default: true },
      multiBranch: { type: Boolean, default: false }
    },
    isActive: {
      type: Boolean,
      default: true
    },
    customForShopId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Shop',
      default: null
    },
    description: {
      type: String,
      trim: true,
      default: ''
    }
  },
  {
    timestamps: true
  }
);

module.exports = mongoose.model('Plan', planSchema);
