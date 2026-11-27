const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/system.controller');

router.get('/settings', ctrl.getSettings);
router.put('/settings', ctrl.updateSettings);
router.post('/backup', ctrl.triggerBackup);

module.exports = router;
