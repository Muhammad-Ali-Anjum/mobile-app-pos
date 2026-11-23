const { User, UserRole, Role, RolePermission, UserPermissionOverride, UserBranchAccess } = require('../models');
const { ROLES, DEFAULT_ROLE_PERMISSIONS } = require('../permissions/permission.constants');

class PermissionService {
  /**
   * Resolves the complete set of effective permissions for a user within a shop
   * Follows resolution order:
   * 1. User Account Status check (Suspended users get 0 permissions)
   * 2. Active Non-Expired User Roles
   * 3. Role-Permission mappings
   * 4. User-Level Overrides (ALLOW adds, DENY explicitly removes)
   */
  async resolveUserPermissions(userId, shopId) {
    const user = await User.findById(userId).lean();
    if (!user || user.status !== 'ACTIVE') {
      return new Set();
    }

    // Platform Super Admin has master access
    if (user.isPlatformUser && user.platformRole === ROLES.SUPER_ADMIN) {
      // Super admin has platform privileges
      return new Set(['*']);
    }

    const now = new Date();

    // 1. Fetch user's active role assignments in this shop
    const userRoles = await UserRole.find({
      userId,
      shopId,
      status: 'ACTIVE',
      $or: [{ expiresAt: null }, { expiresAt: { $gt: now } }]
    }).populate('roleId').lean();

    if (!userRoles || userRoles.length === 0) {
      return new Set();
    }

    const permissionSet = new Set();

    // 2. Aggregate permissions from all active roles
    for (const assignment of userRoles) {
      const role = assignment.roleId;
      if (!role || !role.isActive) continue;

      // If it's a predefined system role with default mappings
      if (role.slug && DEFAULT_ROLE_PERMISSIONS[role.slug]) {
        for (const p of DEFAULT_ROLE_PERMISSIONS[role.slug]) {
          permissionSet.add(p);
        }
      }

      // Also query custom mappings from RolePermission
      const mappings = await RolePermission.find({ roleId: role._id }).lean();
      for (const m of mappings) {
        permissionSet.add(m.permissionKey);
      }
    }

    // 3. Apply User-level permission overrides
    const overrides = await UserPermissionOverride.find({
      userId,
      shopId,
      $or: [{ expiresAt: null }, { expiresAt: { $gt: now } }]
    }).lean();

    for (const ov of overrides) {
      if (ov.effect === 'ALLOW') {
        permissionSet.add(ov.permissionKey);
      } else if (ov.effect === 'DENY') {
        // Explicit DENY overrides any grant
        permissionSet.delete(ov.permissionKey);
      }
    }

    return permissionSet;
  }

  /**
   * Check if a user possesses a specific permission
   */
  async hasPermission(userId, shopId, requiredPermission) {
    const permissions = await this.resolveUserPermissions(userId, shopId);
    if (permissions.has('*') || permissions.has(requiredPermission)) {
      return true;
    }
    return false;
  }

  /**
   * Verifies if a user has access to a specific branch within the shop
   */
  async checkBranchAccess(userId, shopId, targetBranchId) {
    const user = await User.findById(userId).lean();
    if (!user || user.status !== 'ACTIVE') return false;

    // Platform Super Admin
    if (user.isPlatformUser && user.platformRole === ROLES.SUPER_ADMIN) return true;

    // Check if user is shop owner
    const userRoles = await UserRole.find({ userId, shopId, status: 'ACTIVE' }).populate('roleId').lean();
    const isOwner = userRoles.some((ur) => ur.roleId && ur.roleId.slug === ROLES.SHOP_OWNER);
    if (isOwner) return true;

    // Check explicit user branch access
    const branchAccess = await UserBranchAccess.find({ userId, shopId }).lean();
    if (!branchAccess || branchAccess.length === 0) return false;

    for (const access of branchAccess) {
      if (access.accessType === 'ALL_BRANCHES') return true;
      if (
        (access.accessType === 'ASSIGNED_BRANCH' || access.accessType === 'SPECIFIC_BRANCH' || access.accessType === 'OWN_BRANCH_ONLY') &&
        access.branchId &&
        access.branchId.toString() === targetBranchId.toString()
      ) {
        return true;
      }
    }

    return false;
  }

  /**
   * Enforces delegation authority: a user cannot delegate permissions they do not possess
   */
  async canDelegatePermissions(delegatorUserId, shopId, requestedPermissions) {
    const delegatorPerms = await this.resolveUserPermissions(delegatorUserId, shopId);
    if (delegatorPerms.has('*')) return true;

    for (const perm of requestedPermissions) {
      if (!delegatorPerms.has(perm)) {
        return false;
      }
    }
    return true;
  }
}

module.exports = new PermissionService();
