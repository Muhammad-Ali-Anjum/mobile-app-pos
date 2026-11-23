const express = require('express');
const router = express.Router();
const auditController = require('../controllers/audit.controller');
const { authenticate } = require('../middleware/auth.middleware');
const { requireTenant } = require('../middleware/tenant.middleware');
const { requirePermission } = require('../middleware/authorization.middleware');
const { PERMISSIONS } = require('../permissions/permission.constants');

router.use(authenticate, requireTenant);

// Immutable audit trails - GET only!
router.get('/', requirePermission(PERMISSIONS.AUDIT_VIEW), (req, res) => auditController.listLogs(req, res));

module.exports = router;
