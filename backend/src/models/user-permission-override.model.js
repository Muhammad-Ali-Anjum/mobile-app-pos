const mongoose = require('mongoose');

const userPermissionOverrideSchema = new mongoose.Schema(
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
    permissionKey: {
      type: String,
      required: true,
      trim: true,
      lowercase: true,
      index: true
    },
    effect: {
      type: String,
      enum: ['ALLOW', 'DENY'],
      required: true
    },
    reason: {
      type: String,
      trim: true,
      default: ''
    },
    grantedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    expiresAt: {
      type: Date,
      default: null
    }
  },
  {
    timestamps: true
  }
);

userPermissionOverrideSchema.index({ userId: 1, shopId: 1, permissionKey: 1 }, { unique: true });

module.exports = mongoose.model('UserPermissionOverride', userPermissionOverrideSchema);
