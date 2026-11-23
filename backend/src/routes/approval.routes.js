const express = require('express');
const router = express.Router();
const approvalController = require('../controllers/approval.controller');
const { authenticate } = require('../middleware/auth.middleware');
const { requireTenant } = require('../middleware/tenant.middleware');
const { requirePermission } = require('../middleware/authorization.middleware');
const { PERMISSIONS } = require('../permissions/permission.constants');

router.use(authenticate, requireTenant);

router.get('/', requirePermission(PERMISSIONS.APPROVALS_VIEW), (req, res) => approvalController.listApprovals(req, res));
router.post('/', (req, res) => approvalController.submitRequest(req, res));
router.post('/:id/approve', requirePermission(PERMISSIONS.APPROVALS_MANAGE), (req, res) => approvalController.approveRequest(req, res));
router.post('/:id/reject', requirePermission(PERMISSIONS.APPROVALS_MANAGE), (req, res) => approvalController.rejectRequest(req, res));

module.exports = router;
