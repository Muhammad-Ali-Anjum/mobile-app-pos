const express = require('express');
const router = express.Router();
const productController = require('../controllers/product.controller');
const { authenticate } = require('../middleware/auth.middleware');
const { requireTenant } = require('../middleware/tenant.middleware');
const { requirePermission } = require('../middleware/authorization.middleware');
const { PERMISSIONS } = require('../permissions/permission.constants');

router.use(authenticate, requireTenant);

router.get('/', requirePermission(PERMISSIONS.PRODUCTS_VIEW), (req, res) => productController.listProducts(req, res));
router.post('/', requirePermission(PERMISSIONS.PRODUCTS_CREATE), (req, res) => productController.createProduct(req, res));
router.put('/:id', requirePermission(PERMISSIONS.PRODUCTS_EDIT), (req, res) => productController.updateProduct(req, res));

module.exports = router;

