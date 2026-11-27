const express = require('express');
const router = express.Router();
const subscriptionController = require('../controllers/subscription.controller');

router.get('/', subscriptionController.getSubscriptions);
router.get('/shop/:shopId', subscriptionController.getShopSubscriptions);
router.post('/', subscriptionController.assignSubscription);
router.patch('/:id/lifecycle', subscriptionController.updateLifecycle);

module.exports = router;
