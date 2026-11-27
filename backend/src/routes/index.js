const express = require('express');
const router = express.Router();

const authRoutes = require('./auth.routes');
const roleRoutes = require('./role.routes');
const userRoutes = require('./user.routes');
const approvalRoutes = require('./approval.routes');
const auditRoutes = require('./audit.routes');
const productRoutes = require('./product.routes');
const posRoutes = require('./pos.routes');
const inventoryRoutes = require('./inventory.routes');
const customerRoutes = require('./customer.routes');
const dashboardRoutes = require('./dashboard.routes');

router.use('/auth', authRoutes);
router.use('/roles', roleRoutes);
router.use('/users', userRoutes);
router.use('/approvals', approvalRoutes);
router.use('/audit-logs', auditRoutes);
router.use('/products', productRoutes);
router.use('/pos', posRoutes);
router.use('/inventory', inventoryRoutes);
router.use('/customers', customerRoutes);
router.use('/dashboard', dashboardRoutes);
const { authenticate, requirePlatformAdmin } = require('../middleware/auth.middleware');

router.use('/shops', authenticate, requirePlatformAdmin, require('./shop.routes'));
router.use('/shop', authenticate, requirePlatformAdmin, require('./shop.routes'));
router.use('/plans', authenticate, requirePlatformAdmin, require('./plan.routes'));
router.use('/subscriptions', authenticate, requirePlatformAdmin, require('./subscription.routes'));
router.use('/billing', authenticate, requirePlatformAdmin, require('./billing.routes'));
router.use('/platform-users', authenticate, requirePlatformAdmin, require('./platform-user.routes'));
router.use('/tickets', authenticate, requirePlatformAdmin, require('./ticket.routes'));
router.use('/system', authenticate, requirePlatformAdmin, require('./system.routes'));


module.exports = router;
