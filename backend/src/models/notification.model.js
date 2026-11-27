const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema(
  {
    title: { type: String, required: true, trim: true },
    message: { type: String, required: true, trim: true },
    type: {
      type: String,
      enum: [
        'NEW_SHOP',
        'NEW_SUBSCRIPTION',
        'PAYMENT_RECEIVED',
        'PAYMENT_PENDING',
        'SUBSCRIPTION_EXPIRING',
        'SUBSCRIPTION_EXPIRED',
        'SHOP_SUSPENDED',
        'SHOP_REACTIVATED',
        'QUOTA_REACHED',
        'NEW_TICKET',
        'SECURITY_ALERT'
      ],
      default: 'NEW_SHOP'
    },
    channel: {
      type: String,
      enum: ['IN_APP', 'EMAIL', 'SMS', 'WHATSAPP'],
      default: 'IN_APP'
    },
    shopId: { type: mongoose.Schema.Types.ObjectId, ref: 'Shop', default: null },
    shopName: { type: String, default: '' },
    isRead: { type: Boolean, default: false }
  },
  { timestamps: true }
);

module.exports = mongoose.model('Notification', notificationSchema);
