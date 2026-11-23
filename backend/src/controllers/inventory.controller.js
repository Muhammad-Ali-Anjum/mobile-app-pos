const { Product, InventoryMovement } = require('../models');
const auditService = require('../services/audit.service');

class InventoryController {
  /**
   * Record stock adjustment (requires inventory.adjust)
   */
  async adjustStock(req, res) {
    try {
      const { productId, newStock, reason, branchId } = req.body;

      if (!productId || newStock === undefined) {
        return res.status(400).json({ success: false, message: 'Product ID and new stock level required.' });
      }

      const product = await Product.findOne({ _id: productId, shopId: req.shopId });
      if (!product) {
        return res.status(404).json({ success: false, message: 'Product not found.' });
      }

      const previousStock = product.currentStock;
      const difference = newStock - previousStock;
      product.currentStock = newStock;

      if (product.currentStock <= 0) product.status = 'OUT_OF_STOCK';
      else if (product.currentStock <= product.lowStockThreshold) product.status = 'LOW_STOCK';
      else product.status = 'ACTIVE';

      await product.save();

      const movement = await InventoryMovement.create({
        shopId: req.shopId,
        branchId: branchId || req.branchId || null,
        productId: product._id,
        movementType: 'ADJUSTMENT',
        quantity: difference,
        previousStock,
        newStock,
        reason: reason || 'Manual Stock Count Adjustment',
        performedBy: req.user._id
      });

      await auditService.log({
        shopId: req.shopId,
        userId: req.user._id,
        action: 'INVENTORY_ADJUSTED',
        module: 'inventory',
        recordId: product._id.toString(),
        oldValues: { stock: previousStock },
        newValues: { stock: newStock, reason },
        req
      });

      return res.status(200).json({
        success: true,
        message: 'Stock adjusted successfully.',
        data: { product, movement }
      });
    } catch (error) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  /**
   * View recent inventory movements
   */
  async listMovements(req, res) {
    try {
      const movements = await InventoryMovement.find({ shopId: req.shopId })
        .populate('productId', 'name sku unit')
        .populate('performedBy', 'fullName username')
        .sort({ createdAt: -1 })
        .limit(50)
        .lean();

      return res.status(200).json({
        success: true,
        data: movements
      });
    } catch (error) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }
}

module.exports = new InventoryController();

