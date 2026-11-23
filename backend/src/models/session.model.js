const mongoose = require('mongoose');

const sessionSchema = new mongoose.Schema(
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
      default: null,
      index: true
    },
    refreshTokenHash: {
      type: String,
      required: true
    },
    deviceId: {
      type: String,
      default: ''
    },
    deviceName: {
      type: String,
      default: ''
    },
    ipAddress: {
      type: String,
      default: ''
    },
    expiresAt: {
      type: Date,
      required: true
    },
    revokedAt: {
      type: Date,
      default: null
    }
  },
  {
    timestamps: true
  }
);

sessionSchema.index({ userId: 1, revokedAt: 1 });

module.exports = mongoose.model('Session', sessionSchema);
