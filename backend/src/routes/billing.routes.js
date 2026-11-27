const express = require('express');
const router = express.Router();
const billingController = require('../controllers/billing.controller');

router.get('/invoices', billingController.getInvoices);
router.post('/invoices', billingController.createInvoice);
router.patch('/invoices/:id/pay', billingController.recordPayment);
router.patch('/invoices/:id/verify', billingController.verifyPayment);
router.patch('/invoices/:id/refund', billingController.refundInvoice);
router.get('/reports', billingController.getRevenueReports);

router.get('/coupons', billingController.getCoupons);
router.post('/coupons', billingController.createCoupon);
router.patch('/coupons/:id/toggle', billingController.toggleCoupon);
router.delete('/coupons/:id', billingController.deleteCoupon);

module.exports = router;
