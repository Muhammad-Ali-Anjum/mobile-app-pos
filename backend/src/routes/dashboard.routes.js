const express = require('express');
const router = express.Router();
const dashboardController = require('../controllers/dashboard.controller');
const { authenticate } = require('../middleware/auth.middleware');
const { requireTenant } = require('../middleware/tenant.middleware');
const { requirePermission } = require('../middleware/authorization.middleware');
const { PERMISSIONS } = require('../permissions/permission.constants');

router.use(authenticate, requireTenant);

router.get('/metrics', requirePermission(PERMISSIONS.DASHBOARD_VIEW), (req, res) => dashboardController.getDashboardMetrics(req, res));

module.exports = router;

