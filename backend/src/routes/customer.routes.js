const express = require('express');
const router = express.Router();
const customerController = require('../controllers/customer.controller');
const { authenticate } = require('../middleware/auth.middleware');
const { requireTenant } = require('../middleware/tenant.middleware');
const { requirePermission } = require('../middleware/authorization.middleware');
const { PERMISSIONS } = require('../permissions/permission.constants');

router.use(authenticate, requireTenant);

router.get('/', requirePermission(PERMISSIONS.CUSTOMERS_VIEW), (req, res) => customerController.listCustomers(req, res));
router.post('/', requirePermission(PERMISSIONS.CUSTOMERS_CREATE), (req, res) => customerController.createCustomer(req, res));

module.exports = router;

