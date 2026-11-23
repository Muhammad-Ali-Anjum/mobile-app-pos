const express = require('express');
const router = express.Router();
const inventoryController = require('../controllers/inventory.controller');
const { authenticate } = require('../middleware/auth.middleware');
const { requireTenant } = require('../middleware/tenant.middleware');
const { requirePermission } = require('../middleware/authorization.middleware');
const { PERMISSIONS } = require('../permissions/permission.constants');

router.use(authenticate, requireTenant);

router.post('/adjust', requirePermission(PERMISSIONS.INVENTORY_ADJUST), (req, res) => inventoryController.adjustStock(req, res));
router.get('/movements', requirePermission(PERMISSIONS.INVENTORY_VIEW), (req, res) => inventoryController.listMovements(req, res));

module.exports = router;

