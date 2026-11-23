const express = require('express');
const router = express.Router();
const roleController = require('../controllers/role.controller');
const { authenticate } = require('../middleware/auth.middleware');
const { requireTenant } = require('../middleware/tenant.middleware');
const { requirePermission } = require('../middleware/authorization.middleware');
const { PERMISSIONS } = require('../permissions/permission.constants');

router.use(authenticate, requireTenant);

// Grouped permissions catalog
router.get('/permissions/grouped', (req, res) => roleController.getGroupedPermissions(req, res));

// Roles CRUD
router.get('/', requirePermission(PERMISSIONS.ROLES_VIEW), (req, res) => roleController.listRoles(req, res));
router.post('/', requirePermission(PERMISSIONS.ROLES_CREATE), (req, res) => roleController.createRole(req, res));
router.put('/:id', requirePermission(PERMISSIONS.ROLES_EDIT), (req, res) => roleController.updateRole(req, res));
router.delete('/:id', requirePermission(PERMISSIONS.ROLES_DELETE), (req, res) => roleController.deleteRole(req, res));

module.exports = router;
