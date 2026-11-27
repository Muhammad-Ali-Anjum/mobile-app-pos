const express = require('express');
const router = express.Router();
const userController = require('../controllers/user.controller');
const { authenticate } = require('../middleware/auth.middleware');
const { requireTenant } = require('../middleware/tenant.middleware');
const { requirePermission } = require('../middleware/authorization.middleware');
const { enforceQuota } = require('../middleware/quota.middleware');
const { PERMISSIONS } = require('../permissions/permission.constants');

router.use(authenticate, requireTenant);

// Users list & creation
router.get('/', requirePermission(PERMISSIONS.USERS_VIEW), (req, res) => userController.listEmployees(req, res));
router.post('/', requirePermission(PERMISSIONS.USERS_CREATE), enforceQuota('USER'), (req, res) => userController.createEmployee(req, res));

// Role & Branch assignments
router.post('/:id/assign-role', requirePermission(PERMISSIONS.USERS_ASSIGN_ROLE), (req, res) => userController.assignRole(req, res));
router.post('/:id/revoke-role', requirePermission(PERMISSIONS.USERS_REVOKE_ROLE), (req, res) => userController.revokeRole(req, res));
router.put('/:id/branch-access', requirePermission(PERMISSIONS.USERS_MANAGE_BRANCH_ACCESS), (req, res) => userController.updateBranchAccess(req, res));

// Effective permissions and user-level overrides
router.get('/:id/permissions', requirePermission(PERMISSIONS.USERS_VIEW), (req, res) => userController.getEffectivePermissions(req, res));
router.post('/:id/permission-overrides', requirePermission(PERMISSIONS.ROLES_MANAGE_PERMISSIONS), (req, res) => userController.addPermissionOverride(req, res));
router.delete('/:id/permission-overrides/:permissionKey', requirePermission(PERMISSIONS.ROLES_MANAGE_PERMISSIONS), (req, res) => userController.removePermissionOverride(req, res));

// Suspension and activation
router.post('/:id/suspend', requirePermission(PERMISSIONS.USERS_SUSPEND), (req, res) => userController.suspendUser(req, res));
router.post('/:id/activate', requirePermission(PERMISSIONS.USERS_ACTIVATE), (req, res) => userController.activateUser(req, res));

module.exports = router;
