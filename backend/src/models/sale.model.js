const mongoose = require('mongoose');

const saleItemSchema = new mongoose.Schema({
  productId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Product',
    required: true
  },
  productName: {
    type: String,
    required: true
  },
  sku: String,
  unitPrice: {
    type: Number,
    required: true
  },
  costPrice: {
    type: Number,
    default: 0
  },
  quantity: {
    type: Number,
    required: true,
    min: 1
  },
  total: {
    type: Number,
    required: true
  }
});

const saleSchema = new mongoose.Schema(
  {
    shopId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Shop',
      required: true,
      index: true
    },
    branchId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Branch',
      required: true,
      index: true
    },
    cashierId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true
    },
    customerId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Customer',
      default: null
    },
    customerName: {
      type: String,
      default: 'Walk-in Customer'
    },
    invoiceNumber: {
      type: String,
      required: true,
      unique: true,
      trim: true
    },
    items: [saleItemSchema],
    subtotal: {
      type: Number,
      required: true,
      min: 0
    },
    discountPercent: {
      type: Number,
      default: 0
    },
    discountAmount: {
      type: Number,
      default: 0
    },
    taxPercent: {
      type: Number,
      default: 0
    },
    taxAmount: {
      type: Number,
      default: 0
    },
    grandTotal: {
      type: Number,
      required: true,
      min: 0
    },
    paymentMethod: {
      type: String,
      enum: ['CASH', 'CARD', 'BANK_TRANSFER', 'UPI', 'SPLIT'],
      default: 'CASH'
    },
    status: {
      type: String,
      enum: ['COMPLETED', 'HELD', 'RETURNED', 'CANCELLED'],
      default: 'COMPLETED',
      index: true
    },
    approvalReference: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'ApprovalRequest',
      default: null
    }
  },
  {
    timestamps: true
  }
);

saleSchema.index({ shopId: 1, createdAt: -1 });
saleSchema.index({ shopId: 1, branchId: 1, createdAt: -1 });

module.exports = mongoose.model('Sale', saleSchema);

