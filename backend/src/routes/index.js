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

module.exports = router;
