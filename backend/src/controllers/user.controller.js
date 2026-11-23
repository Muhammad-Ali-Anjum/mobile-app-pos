const { User, UserRole, Role, UserBranchAccess, UserPermissionOverride, Branch } = require('../models');
const permissionService = require('../services/permission.service');
const auditService = require('../services/audit.service');

class UserController {
  /**
   * List all employees in the current shop tenant
   */
  async listEmployees(req, res) {
    try {
      const userRoles = await UserRole.find({ shopId: req.shopId })
        .populate('userId', '-passwordHash')
        .populate('roleId')
        .lean();

      // Aggregate employees
      const employeeMap = new Map();

      for (const ur of userRoles) {
        if (!ur.userId) continue;
        const uid = ur.userId._id.toString();

        if (!employeeMap.has(uid)) {
          employeeMap.set(uid, {
            ...ur.userId,
            roles: [],
            branches: []
          });
        }

        if (ur.roleId) {
          employeeMap.get(uid).roles.push({
            assignmentId: ur._id,
            roleId: ur.roleId._id,
            name: ur.roleId.name,
            slug: ur.roleId.slug,
            status: ur.status,
            expiresAt: ur.expiresAt
          });
        }
      }

      // Populate branches
      const branchAccesses = await UserBranchAccess.find({ shopId: req.shopId })
        .populate('branchId', 'name code city')
        .lean();

      for (const ba of branchAccesses) {
        const uid = ba.userId.toString();
        if (employeeMap.has(uid)) {
          employeeMap.get(uid).branches.push({
            accessType: ba.accessType,
            branch: ba.branchId
          });
        }
      }

      return res.status(200).json({
        success: true,
        data: Array.from(employeeMap.values())
      });
    } catch (error) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  /**
   * Create a new employee under this shop
   */
  async createEmployee(req, res) {
    try {
      const {
        fullName,
        email,
        username,
        phone,
        employeeId,
        password,
        roleId,
        branchIds = [],
        branchAccessType = 'ASSIGNED_BRANCH'
      } = req.body;

      if (!fullName || !email || !password || !roleId) {
        return res.status(400).json({
          success: false,
          message: 'Full name, email, password, and assigned role are required.'
        });
      }

      // Check email uniqueness
      const existing = await User.findOne({ email: email.toLowerCase().trim() });
      if (existing) {
        return res.status(400).json({
          success: false,
          message: 'An account with this email address already exists.'
        });
      }

      const role = await Role.findOne({
        _id: roleId,
        $or: [{ shopId: req.shopId }, { isSystemRole: true }]
      });
      if (!role) {
        return res.status(404).json({ success: false, message: 'Assigned role does not exist.' });
      }

      const passwordHash = await User.hashPassword(password);
      const user = new User({
        fullName: fullName.trim(),
        email: email.toLowerCase().trim(),
        username: (username || email.split('@')[0]).toLowerCase().trim(),
        phone: phone || '',
        employeeId: employeeId || '',
        passwordHash,
        defaultShopId: req.shopId,
        status: 'ACTIVE'
      });

      const savedUser = await user.save();

      // Assign Role
      await UserRole.create({
        userId: savedUser._id,
        shopId: req.shopId,
        roleId: role._id,
        assignedBy: req.user._id,
        status: 'ACTIVE'
      });

      // Assign Branch Access
      if (branchAccessType === 'ALL_BRANCHES') {
        await UserBranchAccess.create({
          userId: savedUser._id,
          shopId: req.shopId,
          branchId: null,
          accessType: 'ALL_BRANCHES',
          assignedBy: req.user._id
        });
      } else {
        for (const bid of branchIds) {
          await UserBranchAccess.create({
            userId: savedUser._id,
            shopId: req.shopId,
            branchId: bid,
            accessType: branchAccessType,
            assignedBy: req.user._id
          });
        }
      }

      await auditService.log({
        shopId: req.shopId,
        userId: req.user._id,
        action: 'EMPLOYEE_CREATED',
        module: 'users',
        recordId: savedUser._id.toString(),
        newValues: { fullName, email, role: role.name },
        req
      });

      return res.status(201).json({
        success: true,
        message: 'Employee created successfully.',
        data: {
          id: savedUser._id,
          fullName: savedUser.fullName,
          email: savedUser.email,
          role: role.name
        }
      });
    } catch (error) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  /**
   * Assign additional role
   */
  async assignRole(req, res) {
    try {
      const { id } = req.params;
      const { roleId, expiresAt } = req.body;

      const role = await Role.findOne({
        _id: roleId,
        $or: [{ shopId: req.shopId }, { isSystemRole: true }]
      });
      if (!role) {
        return res.status(404).json({ success: false, message: 'Role not found.' });
      }

      const assignment = await UserRole.findOneAndUpdate(
        { userId: id, shopId: req.shopId, roleId: role._id },
        {
          assignedBy: req.user._id,
          status: 'ACTIVE',
          expiresAt: expiresAt ? new Date(expiresAt) : null
        },
        { upsert: true, new: true }
      );

      await auditService.log({
        shopId: req.shopId,
        userId: req.user._id,
        action: 'USER_ROLE_ASSIGNED',
        module: 'users',
        recordId: id,
        newValues: { roleId: role._id, roleName: role.name, expiresAt },
        req
      });

      return res.status(200).json({
        success: true,
        message: `Role ${role.name} assigned successfully.`,
        data: assignment
      });
    } catch (error) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  /**
   * Revoke role
   */
  async revokeRole(req, res) {
    try {
      const { id } = req.params;
      const { roleId } = req.body;

      await UserRole.findOneAndUpdate(
        { userId: id, shopId: req.shopId, roleId },
        { status: 'REVOKED' }
      );

      await auditService.log({
        shopId: req.shopId,
        userId: req.user._id,
        action: 'USER_ROLE_REVOKED',
        module: 'users',
        recordId: id,
        newValues: { roleId },
        req
      });

      return res.status(200).json({
        success: true,
        message: 'Role revoked successfully.'
      });
    } catch (error) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  /**
   * Manage user branch access
   */
  async updateBranchAccess(req, res) {
    try {
      const { id } = req.params;
      const { accessType, branchIds = [] } = req.body;

      await UserBranchAccess.deleteMany({ userId: id, shopId: req.shopId });

      if (accessType === 'ALL_BRANCHES') {
        await UserBranchAccess.create({
          userId: id,
          shopId: req.shopId,
          branchId: null,
          accessType: 'ALL_BRANCHES',
          assignedBy: req.user._id
        });
      } else {
        const mappings = branchIds.map((bId) => ({
          userId: id,
          shopId: req.shopId,
          branchId: bId,
          accessType: accessType || 'ASSIGNED_BRANCH',
          assignedBy: req.user._id
        }));
        if (mappings.length > 0) {
          await UserBranchAccess.insertMany(mappings);
        }
      }

      await auditService.log({
        shopId: req.shopId,
        userId: req.user._id,
        action: 'USER_BRANCH_ACCESS_UPDATED',
        module: 'users',
        recordId: id,
        newValues: { accessType, branchIds },
        req
      });

      return res.status(200).json({
        success: true,
        message: 'Branch access updated successfully.'
      });
    } catch (error) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  /**
   * Get effective permissions for user
   */
  async getEffectivePermissions(req, res) {
    try {
      const { id } = req.params;
      const permissionsSet = await permissionService.resolveUserPermissions(id, req.shopId);

      return res.status(200).json({
        success: true,
        data: Array.from(permissionsSet)
      });
    } catch (error) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  /**
   * Add individual permission override (ALLOW or DENY)
   */
  async addPermissionOverride(req, res) {
    try {
      const { id } = req.params;
      const { permissionKey, effect, reason, expiresAt } = req.body;

      if (!['ALLOW', 'DENY'].includes(effect)) {
        return res.status(400).json({ success: false, message: 'Effect must be ALLOW or DENY.' });
      }

      // Check delegator authority if granting
      if (effect === 'ALLOW') {
        const canDelegate = await permissionService.canDelegatePermissions(
          req.user._id,
          req.shopId,
          [permissionKey]
        );
        if (!canDelegate) {
          return res.status(403).json({
            success: false,
            message: 'Cannot grant a permission override you do not possess yourself.'
          });
        }
      }

      const override = await UserPermissionOverride.findOneAndUpdate(
        { userId: id, shopId: req.shopId, permissionKey },
        {
          effect,
          reason: reason || '',
          grantedBy: req.user._id,
          expiresAt: expiresAt ? new Date(expiresAt) : null
        },
        { upsert: true, new: true }
      );

      await auditService.log({
        shopId: req.shopId,
        userId: req.user._id,
        action: `USER_OVERRIDE_${effect}`,
        module: 'users',
        recordId: id,
        newValues: { permissionKey, effect, reason, expiresAt },
        req
      });

      return res.status(200).json({
        success: true,
        message: `Permission override (${effect}) applied.`,
        data: override
      });
    } catch (error) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  /**
   * Remove permission override
   */
  async removePermissionOverride(req, res) {
    try {
      const { id, permissionKey } = req.params;

      await UserPermissionOverride.deleteOne({
        userId: id,
        shopId: req.shopId,
        permissionKey
      });

      await auditService.log({
        shopId: req.shopId,
        userId: req.user._id,
        action: 'USER_OVERRIDE_REMOVED',
        module: 'users',
        recordId: id,
        oldValues: { permissionKey },
        req
      });

      return res.status(200).json({
        success: true,
        message: 'Permission override removed successfully.'
      });
    } catch (error) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  /**
   * Suspend employee account
   */
  async suspendUser(req, res) {
    try {
      const { id } = req.params;
      const user = await User.findById(id);
      if (!user) {
        return res.status(404).json({ success: false, message: 'User not found.' });
      }

      user.status = 'SUSPENDED';
      await user.save();

      await auditService.log({
        shopId: req.shopId,
        userId: req.user._id,
        action: 'USER_SUSPENDED',
        module: 'users',
        recordId: id,
        newValues: { status: 'SUSPENDED' },
        req
      });

      return res.status(200).json({
        success: true,
        message: 'User account has been suspended.'
      });
    } catch (error) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  /**
   * Activate employee account
   */
  async activateUser(req, res) {
    try {
      const { id } = req.params;
      const user = await User.findById(id);
      if (!user) {
        return res.status(404).json({ success: false, message: 'User not found.' });
      }

      user.status = 'ACTIVE';
      await user.save();

      await auditService.log({
        shopId: req.shopId,
        userId: req.user._id,
        action: 'USER_ACTIVATED',
        module: 'users',
        newValues: { status: 'ACTIVE' },
        req
      });

      return res.status(200).json({
        success: true,
        message: 'User account has been activated.'
      });
    } catch (error) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }
}

module.exports = new UserController();
