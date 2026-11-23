const { Role, RolePermission, UserRole } = require('../models');
const { PERMISSIONS, DEFAULT_ROLE_PERMISSIONS, MODULES } = require('../permissions/permission.constants');
const permissionService = require('../services/permission.service');
const auditService = require('../services/audit.service');

class RoleController {
  /**
   * List all system default roles and tenant custom roles
   */
  async listRoles(req, res) {
    try {
      const roles = await Role.find({
        $or: [{ shopId: req.shopId }, { isSystemRole: true }]
      }).sort({ isSystemRole: -1, name: 1 }).lean();

      // Attach permission counts to each role
      const enrichedRoles = await Promise.all(
        roles.map(async (role) => {
          let permissions = [];
          if (role.isSystemRole && DEFAULT_ROLE_PERMISSIONS[role.slug]) {
            permissions = DEFAULT_ROLE_PERMISSIONS[role.slug];
          } else {
            const mappings = await RolePermission.find({ roleId: role._id }).lean();
            permissions = mappings.map((m) => m.permissionKey);
          }
          return {
            ...role,
            permissionCount: permissions.length,
            permissions
          };
        })
      );

      return res.status(200).json({
        success: true,
        data: enrichedRoles
      });
    } catch (error) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  /**
   * Create a custom role for the shop
   */
  async createRole(req, res) {
    try {
      const { name, description, permissions = [] } = req.body;

      if (!name || !name.trim()) {
        return res.status(400).json({ success: false, message: 'Role name is required.' });
      }

      const slug = name.toLowerCase().replace(/[^a-z0-9]/g, '_');

      // Check if role name already exists in this shop
      const existing = await Role.findOne({ shopId: req.shopId, slug });
      if (existing) {
        return res.status(400).json({ success: false, message: 'A role with this name already exists in your shop.' });
      }

      // Delegation Security: Creator cannot grant permissions they do not possess
      const canDelegate = await permissionService.canDelegatePermissions(
        req.user._id,
        req.shopId,
        permissions
      );
      if (!canDelegate) {
        return res.status(403).json({
          success: false,
          message: 'Security policy violation: You cannot assign permissions that exceed your own authority.'
        });
      }

      const newRole = new Role({
        shopId: req.shopId,
        name: name.trim(),
        slug,
        description: description || '',
        roleType: 'CUSTOM_SHOP',
        isSystemRole: false,
        createdBy: req.user._id
      });

      const savedRole = await newRole.save();

      // Create role-permission mappings
      if (permissions.length > 0) {
        const mappings = permissions.map((key) => ({
          roleId: savedRole._id,
          permissionKey: key
        }));
        await RolePermission.insertMany(mappings);
      }

      await auditService.log({
        shopId: req.shopId,
        userId: req.user._id,
        action: 'ROLE_CREATED',
        module: 'roles',
        recordId: savedRole._id.toString(),
        newValues: { name, slug, permissionsCount: permissions.length },
        req
      });

      return res.status(201).json({
        success: true,
        message: 'Custom role created successfully.',
        data: savedRole
      });
    } catch (error) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  /**
   * Update a custom role
   */
  async updateRole(req, res) {
    try {
      const { id } = req.params;
      const { name, description, permissions } = req.body;

      const role = await Role.findOne({ _id: id, shopId: req.shopId });
      if (!role) {
        return res.status(404).json({ success: false, message: 'Role not found or cannot be modified.' });
      }

      if (role.isSystemRole) {
        return res.status(403).json({ success: false, message: 'System default roles cannot be edited.' });
      }

      const oldValues = { name: role.name, description: role.description };

      if (name) role.name = name.trim();
      if (description !== undefined) role.description = description;

      if (permissions && Array.isArray(permissions)) {
        // Enforce delegation check
        const canDelegate = await permissionService.canDelegatePermissions(
          req.user._id,
          req.shopId,
          permissions
        );
        if (!canDelegate) {
          return res.status(403).json({
            success: false,
            message: 'You cannot assign permissions you do not possess.'
          });
        }

        // Replace role permissions
        await RolePermission.deleteMany({ roleId: role._id });
        const mappings = permissions.map((key) => ({
          roleId: role._id,
          permissionKey: key
        }));
        await RolePermission.insertMany(mappings);
      }

      await role.save();

      await auditService.log({
        shopId: req.shopId,
        userId: req.user._id,
        action: 'ROLE_UPDATED',
        module: 'roles',
        recordId: role._id.toString(),
        oldValues,
        newValues: { name: role.name, description: role.description },
        req
      });

      return res.status(200).json({
        success: true,
        message: 'Role updated successfully.',
        data: role
      });
    } catch (error) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  /**
   * Delete custom role
   */
  async deleteRole(req, res) {
    try {
      const { id } = req.params;
      const role = await Role.findOne({ _id: id, shopId: req.shopId });
      if (!role) {
        return res.status(404).json({ success: false, message: 'Role not found.' });
      }

      if (role.isSystemRole) {
        return res.status(403).json({ success: false, message: 'System roles cannot be deleted.' });
      }

      // Check if any employees currently hold this role
      const activeAssignments = await UserRole.countDocuments({ roleId: role._id, status: 'ACTIVE' });
      if (activeAssignments > 0) {
        return res.status(400).json({
          success: false,
          message: `Cannot delete role: Assigned to ${activeAssignments} active employee(s). Reassign them first.`
        });
      }

      await RolePermission.deleteMany({ roleId: role._id });
      await Role.deleteOne({ _id: role._id });

      await auditService.log({
        shopId: req.shopId,
        userId: req.user._id,
        action: 'ROLE_DELETED',
        module: 'roles',
        recordId: role._id.toString(),
        oldValues: { name: role.name, slug: role.slug },
        req
      });

      return res.status(200).json({
        success: true,
        message: 'Role deleted successfully.'
      });
    } catch (error) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  /**
   * Return complete grouped permission catalog
   */
  async getGroupedPermissions(req, res) {
    try {
      const grouped = {};
      for (const mod of MODULES) {
        grouped[mod] = Object.values(PERMISSIONS).filter((p) => p.startsWith(`${mod}.`));
      }

      return res.status(200).json({
        success: true,
        data: grouped
      });
    } catch (error) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }
}

module.exports = new RoleController();
