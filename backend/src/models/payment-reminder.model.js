const mongoose = require('mongoose');

const paymentReminderSchema = new mongoose.Schema(
  {
    shopId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Shop',
      required: true
    },
    shopName: {
      type: String,
      required: true,
      trim: true
    },
    ownerName: {
      type: String,
      trim: true,
      default: ''
    },
    channel: {
      type: String,
      enum: ['EMAIL', 'SMS', 'WHATSAPP'],
      default: 'EMAIL'
    },
    recipient: {
      type: String,
      required: true,
      trim: true
    },
    subject: {
      type: String,
      trim: true,
      default: 'Subscription Payment Reminder'
    },
    message: {
      type: String,
      required: true,
      trim: true
    },
    status: {
      type: String,
      enum: ['SENT', 'LOGGED'],
      default: 'SENT'
    }
  },
  {
    timestamps: true
  }
);

module.exports = mongoose.model('PaymentReminder', paymentReminderSchema);
