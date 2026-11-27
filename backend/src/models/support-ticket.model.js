const mongoose = require('mongoose');

const supportTicketSchema = new mongoose.Schema(
  {
    ticketNumber: { type: String, required: true, unique: true, uppercase: true, trim: true },
    shopId: { type: mongoose.Schema.Types.ObjectId, ref: 'Shop', default: null },
    shopName: { type: String, default: 'General' },
    subject: { type: String, required: true, trim: true },
    category: { type: String, default: 'General' },
    priority: { type: String, enum: ['LOW', 'MEDIUM', 'HIGH', 'URGENT'], default: 'MEDIUM' },
    description: { type: String, required: true, trim: true },
    assignedAgent: { type: String, default: 'Unassigned' },
    status: { type: String, enum: ['OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED'], default: 'OPEN', index: true },
    replies: [
      {
        sender: { type: String, default: 'Super Admin' },
        message: { type: String, required: true },
        createdAt: { type: Date, default: Date.now }
      }
    ]
  },
  { timestamps: true }
);

module.exports = mongoose.model('SupportTicket', supportTicketSchema);
