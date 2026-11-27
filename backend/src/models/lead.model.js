const mongoose = require('mongoose');

const leadSchema = new mongoose.Schema(
  {
    businessName: { type: String, required: true, trim: true },
    contactName: { type: String, required: true, trim: true },
    email: { type: String, trim: true, default: '' },
    phone: { type: String, trim: true, default: '' },
    status: {
      type: String,
      enum: ['NEW', 'CONTACTED', 'DEMO_SCHEDULED', 'CONVERTED', 'LOST'],
      default: 'NEW'
    },
    followUpDate: { type: Date, default: null },
    notes: { type: String, trim: true, default: '' }
  },
  { timestamps: true }
);

module.exports = mongoose.model('Lead', leadSchema);
