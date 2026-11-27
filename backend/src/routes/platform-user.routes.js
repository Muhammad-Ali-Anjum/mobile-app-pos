const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/platform-user.controller');

router.get('/', ctrl.getPlatformUsers);
router.post('/', ctrl.createPlatformUser);
router.patch('/:id', ctrl.updatePlatformUser);
router.patch('/:id/status', ctrl.toggleUserStatus);
router.patch('/:id/reset-password', ctrl.resetUserPassword);
router.get('/notifications', ctrl.getNotifications);
router.patch('/notifications/:id/read', ctrl.markNotificationRead);
router.post('/notifications/check-expiring', ctrl.checkExpiringSubscriptions);
router.get('/audit-logs', ctrl.getPlatformAuditLogs);
router.get('/leads', ctrl.getLeads);
router.post('/leads', ctrl.createLead);
router.patch('/leads/:id', ctrl.updateLead);
router.delete('/leads/:id', ctrl.deleteLead);
router.get('/analytics', ctrl.getPlatformAnalytics);
router.get('/branches', ctrl.getAllBranches);
router.get('/tenant-users', ctrl.getAllTenantUsers);

module.exports = router;
