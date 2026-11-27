// File: backend/src/routes/shop.routes.js
// ---------------------------------------------------
// Express router for shop endpoints – wired to shop.controller.
// ---------------------------------------------------
const express = require('express');
const router = express.Router();
const shopController = require('../controllers/shop.controller');

router.get('/reminders', shopController.getReminders);
router.get('/', shopController.getAllShops);
router.get('/:id/details', shopController.getShopDetails);
router.post('/', shopController.createShop);
router.put('/:id', shopController.updateShop);
router.patch('/:id/status', shopController.updateShopStatus);
router.patch('/:id/plan', shopController.updateShopPlan);
router.patch('/:id/reset-password', shopController.resetOwnerPassword);
router.post('/:id/reminder', shopController.sendPaymentReminder);
router.post('/:id/impersonate', shopController.impersonateShopAdmin);
router.delete('/:id', shopController.deleteShop);

module.exports = router;
