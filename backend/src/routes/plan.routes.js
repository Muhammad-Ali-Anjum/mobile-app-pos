const express = require('express');
const router = express.Router();
const planController = require('../controllers/plan.controller');

router.get('/', planController.getPlans);
router.post('/', planController.createPlan);
router.patch('/:slug', planController.updatePlan);
router.post('/:slug/duplicate', planController.duplicatePlan);
router.patch('/:slug/status', planController.togglePlanStatus);

module.exports = router;
