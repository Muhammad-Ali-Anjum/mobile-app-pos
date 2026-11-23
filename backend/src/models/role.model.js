const mongoose = require('mongoose');

const roleSchema = new mongoose.Schema(
  {
    shopId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Shop',
      default: null, // null for platform system roles (e.g. super_admin)
      index: true
    },
    name: {
      type: String,
      required: true,
      trim: true
    },
    slug: {
      type: String,
      required: true,
      trim: true,
      lowercase: true
    },
    description: {
      type: String,
      trim: true,
      default: ''
    },
    roleType: {
      type: String,
      enum: ['PLATFORM', 'DEFAULT_SHOP', 'CUSTOM_SHOP'],
      default: 'CUSTOM_SHOP'
    },
    isSystemRole: {
      type: Boolean,
      default: false
    },
    isActive: {
      type: Boolean,
      default: true
    },
    createdBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      default: null
    }
  },
  {
    timestamps: true
  }
);

// Compound index: A shop cannot have two roles with the same slug. System roles have shopId = null.
roleSchema.index({ shopId: 1, slug: 1 }, { unique: true });

module.exports = mongoose.model('Role', roleSchema);
