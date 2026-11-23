const mongoose = require('mongoose');

const productSchema = new mongoose.Schema(
  {
    shopId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Shop',
      required: true,
      index: true
    },
    name: {
      type: String,
      required: true,
      trim: true
    },
    sku: {
      type: String,
      required: true,
      trim: true,
      uppercase: true
    },
    barcode: {
      type: String,
      trim: true,
      default: ''
    },
    category: {
      type: String,
      required: true,
      trim: true,
      default: 'General'
    },
    brand: {
      type: String,
      trim: true,
      default: 'Generic'
    },
    purchasePrice: {
      type: Number,
      required: true,
      min: 0,
      default: 0
    },
    sellingPrice: {
      type: Number,
      required: true,
      min: 0
    },
    currentStock: {
      type: Number,
      default: 0
    },
    lowStockThreshold: {
      type: Number,
      default: 10
    },
    unit: {
      type: String,
      default: 'pcs'
    },
    imageUrl: {
      type: String,
      default: ''
    },
    status: {
      type: String,
      enum: ['ACTIVE', 'LOW_STOCK', 'OUT_OF_STOCK', 'ARCHIVED'],
      default: 'ACTIVE',
      index: true
    }
  },
  {
    timestamps: true
  }
);

productSchema.index({ shopId: 1, sku: 1 }, { unique: true });
productSchema.index({ shopId: 1, category: 1 });

module.exports = mongoose.model('Product', productSchema);

