const express = require('express');
const router = express.Router();
const productController = require('../controllers/product.controller');
const { authenticate } = require('../middleware/auth.middleware');
const { requireTenant } = require('../middleware/tenant.middleware');
const { requirePermission } = require('../middleware/authorization.middleware');
const { enforceQuota } = require('../middleware/quota.middleware');
const { PERMISSIONS } = require('../permissions/permission.constants');

router.use(authenticate, requireTenant);

router.get('/categories', requirePermission(PERMISSIONS.PRODUCTS_VIEW), (req, res) => productController.listCategories(req, res));
router.post('/categories', requirePermission(PERMISSIONS.PRODUCTS_CREATE), (req, res) => productController.createCategory(req, res));
router.put('/categories/:id', requirePermission(PERMISSIONS.PRODUCTS_EDIT), (req, res) => productController.updateCategory(req, res));
router.delete('/categories/:id', requirePermission(PERMISSIONS.PRODUCTS_DELETE), (req, res) => productController.deleteCategory(req, res));

router.get('/', requirePermission(PERMISSIONS.PRODUCTS_VIEW), (req, res) => productController.listProducts(req, res));
router.post('/', requirePermission(PERMISSIONS.PRODUCTS_CREATE), enforceQuota('PRODUCT'), (req, res) => productController.createProduct(req, res));
router.put('/:id', requirePermission(PERMISSIONS.PRODUCTS_EDIT), (req, res) => productController.updateProduct(req, res));
router.delete('/:id', requirePermission(PERMISSIONS.PRODUCTS_DELETE), (req, res) => productController.deleteProduct(req, res));

module.exports = router;

