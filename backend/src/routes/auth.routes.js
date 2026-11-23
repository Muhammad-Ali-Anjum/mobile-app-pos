const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');
const { authenticate } = require('../middleware/auth.middleware');
const { requireTenant } = require('../middleware/tenant.middleware');

router.post('/login', (req, res) => authController.login(req, res));
// Strictly restricted to Platform Super Admin
router.post('/register', authenticate, (req, res) => authController.registerShop(req, res));
router.get('/profile', authenticate, requireTenant, (req, res) => authController.getProfile(req, res));

module.exports = router;
