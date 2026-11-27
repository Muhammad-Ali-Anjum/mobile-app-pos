const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/ticket.controller');

router.get('/', ctrl.getTickets);
router.post('/', ctrl.createTicket);
router.post('/:id/reply', ctrl.replyTicket);
router.patch('/:id', ctrl.updateTicket);

module.exports = router;
