const mongoose = require('mongoose');

const invoiceSchema = new mongoose.Schema(
  {
    invoiceNumber: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      uppercase: true
    },
    shopId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Shop',
      required: true,
      index: true
    },
    shopName: {
      type: String,
      required: true,
      trim: true
    },
    planSlug: {
      type: String,
      trim: true,
      uppercase: true,
      default: 'STANDARD'
    },
    totalAmount: {
      type: Number,
      required: true,
      default: 0
    },
    discount: {
      type: Number,
      default: 0
    },
    paidAmount: {
      type: Number,
      default: 0
    },
    remainingAmount: {
      type: Number,
      default: 0
    },
    paymentMethod: {
      type: String,
      enum: ['CASH', 'BANK_TRANSFER', 'EASYPAISA', 'JAZZCASH', 'ONLINE'],
      default: 'BANK_TRANSFER'
    },
    paymentStatus: {
      type: String,
      enum: ['PAID', 'PARTIAL', 'UNPAID', 'PENDING_VERIFICATION', 'REFUNDED'],
      default: 'UNPAID',
      index: true
    },
    paymentDate: {
      type: Date,
      default: null
    },
    dueDate: {
      type: Date,
      default: () => new Date(Date.now() + 7 * 86400000)
    },
    notes: {
      type: String,
      trim: true,
      default: ''
    }
  },
  {
    timestamps: true
  }
);

module.exports = mongoose.model('Invoice', invoiceSchema);
