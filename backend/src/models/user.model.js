const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema(
  {
    fullName: {
      type: String,
      required: true,
      trim: true
    },
    email: {
      type: String,
      required: true,
      trim: true,
      lowercase: true,
      index: true
    },
    username: {
      type: String,
      required: true,
      trim: true,
      lowercase: true
    },
    phone: {
      type: String,
      trim: true
    },
    employeeId: {
      type: String,
      trim: true
    },
    passwordHash: {
      type: String,
      required: true
    },
    isPlatformUser: {
      type: Boolean,
      default: false
    },
    platformRole: {
      type: String,
      enum: ['super_admin', 'admin', 'accountant', 'support_agent', 'sales_manager', 'viewer', 'support_admin', null],
      default: null
    },
    platformPermissions: {
      type: [String],
      default: []
    },
    status: {
      type: String,
      enum: ['ACTIVE', 'SUSPENDED', 'INVITED'],
      default: 'ACTIVE',
      index: true
    },
    defaultShopId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Shop',
      default: null
    },
    lastLoginAt: {
      type: Date
    }
  },
  {
    timestamps: true
  }
);

// Password helper methods
userSchema.methods.comparePassword = async function (plainPassword) {
  return bcrypt.compare(plainPassword, this.passwordHash);
};

userSchema.statics.hashPassword = async function (plainPassword) {
  const salt = await bcrypt.genSalt(10);
  return bcrypt.hash(plainPassword, salt);
};

module.exports = mongoose.model('User', userSchema);
