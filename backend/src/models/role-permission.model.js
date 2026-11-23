const mongoose = require('mongoose');

const rolePermissionSchema = new mongoose.Schema(
  {
    roleId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Role',
      required: true,
      index: true
    },
    permissionKey: {
      type: String,
      required: true,
      trim: true,
      lowercase: true,
      index: true
    }
  },
  {
    timestamps: true
  }
);

// Unique compound index: a role can only have a permission key mapped once
rolePermissionSchema.index({ roleId: 1, permissionKey: 1 }, { unique: true });

module.exports = mongoose.model('RolePermission', rolePermissionSchema);
