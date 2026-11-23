const express = require('express');
const router = express.Router();
const posController = require('../controllers/pos.controller');
const { authenticate } = require('../middleware/auth.middleware');
const { requireTenant } = require('../middleware/tenant.middleware');
const { requirePermission } = require('../middleware/authorization.middleware');
const { PERMISSIONS } = require('../permissions/permission.constants');

router.use(authenticate, requireTenant);

router.post('/checkout', requirePermission(PERMISSIONS.POS_CREATE), (req, res) => posController.completeSale(req, res));
router.get('/sales', requirePermission(PERMISSIONS.POS_VIEW_OWN_SALES), (req, res) => posController.listSales(req, res));

module.exports = router;

