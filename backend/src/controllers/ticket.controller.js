const SupportTicket = require('../models/support-ticket.model');
const Shop = require('../models/shop.model');

exports.getTickets = async (req, res, next) => {
  try {
    const filter = {};
    if (req.query.status && req.query.status !== 'ALL') {
      filter.status = String(req.query.status).toUpperCase();
    }
    const list = await SupportTicket.find(filter).sort({ createdAt: -1 });
    res.status(200).json(list);
  } catch (err) {
    next(err);
  }
};

exports.createTicket = async (req, res, next) => {
  try {
    const { shopId, subject, category = 'General', priority = 'MEDIUM', description } = req.body;
    if (!subject || !description) {
      return res.status(400).json({ success: false, message: 'Subject and description are required.' });
    }
    let shopName = 'General';
    if (shopId) {
      const s = await Shop.findById(shopId);
      if (s) shopName = s.name;
    }
    const ticketNumber = `TKT-${Date.now().toString().slice(-5)}`;
    const ticket = await SupportTicket.create({
      ticketNumber,
      shopId: shopId || null,
      shopName,
      subject: String(subject).trim(),
      category: String(category).trim(),
      priority: String(priority).toUpperCase(),
      description: String(description).trim(),
      status: 'OPEN'
    });
    res.status(201).json(ticket);
  } catch (err) {
    next(err);
  }
};

exports.replyTicket = async (req, res, next) => {
  try {
    const ticket = await SupportTicket.findById(req.params.id);
    if (!ticket) return res.status(404).json({ success: false, message: 'Ticket not found.' });
    const { sender = 'Super Admin', message } = req.body;
    if (!message) return res.status(400).json({ success: false, message: 'Reply message is required.' });
    ticket.replies.push({ sender, message: String(message).trim() });
    if (ticket.status === 'OPEN') ticket.status = 'IN_PROGRESS';
    await ticket.save();
    res.status(200).json(ticket);
  } catch (err) {
    next(err);
  }
};

exports.updateTicket = async (req, res, next) => {
  try {
    const ticket = await SupportTicket.findById(req.params.id);
    if (!ticket) return res.status(404).json({ success: false, message: 'Ticket not found.' });
    const { status, priority, assignedAgent } = req.body;
    if (status) ticket.status = String(status).toUpperCase();
    if (priority) ticket.priority = String(priority).toUpperCase();
    if (assignedAgent !== undefined) ticket.assignedAgent = String(assignedAgent).trim();
    await ticket.save();
    res.status(200).json(ticket);
  } catch (err) {
    next(err);
  }
};
