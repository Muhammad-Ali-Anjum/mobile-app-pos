const { Sale, Product, InventoryMovement, Customer } = require('../models');
const approvalService = require('../services/approval.service');
const auditService = require('../services/audit.service');
const permissionService = require('../services/permission.service');
const { PERMISSIONS } = require('../permissions/permission.constants');

class PosController {
  /**
   * Process a checkout / complete sale
   */
  async completeSale(req, res) {
    try {
      const {
        branchId,
        customerId,
        customerName = 'Walk-in Customer',
        items = [],
        subtotal,
        discountPercent = 0,
        discountAmount = 0,
        taxPercent = 0,
        taxAmount = 0,
        grandTotal,
        paymentMethod = 'CASH'
      } = req.body;

      if (!items || items.length === 0) {
        return res.status(400).json({ success: false, message: 'Cart items cannot be empty.' });
      }

      let activeBranchId = branchId || req.branchId;
      if (!activeBranchId) {
        const Branch = require('../models/branch.model');
        const mainBranch = await Branch.findOne({ shopId: req.shopId }).sort({ isMainBranch: -1, createdAt: 1 });
        activeBranchId = mainBranch?._id;
      }
      if (!activeBranchId) {
        return res.status(400).json({ success: false, message: 'Branch ID context is required.' });
      }

      // 1. Approval Threshold Check: Discount above max allowed percentage (e.g. > 10%)
      const requiresApproval = await approvalService.checkRequiresApproval(
        req.shopId,
        'DISCOUNT_OVERRIDE',
        { discountPercent }
      );

      if (requiresApproval) {
        // Create pending approval request instead of directly fulfilling
        const pendingRequest = await approvalService.createRequest({
          shopId: req.shopId,
          branchId: activeBranchId,
          userId: req.user._id,
          actionType: 'DISCOUNT_OVERRIDE',
          module: 'pos',
          requestData: {
            subtotal,
            discountPercent,
            discountAmount,
            grandTotal,
            itemsCount: items.length
          },
          reason: `Cashier applied ${discountPercent}% discount exceeding shop limit.`,
          req
        });

        return res.status(202).json({
          success: false,
          requiresApproval: true,
          message: `Discount of ${discountPercent}% exceeds cashier limit. Approval request sent to manager.`,
          approvalRequestId: pendingRequest._id
        });
      }

      // Generate Invoice Number (e.g. INV-1001)
      const saleCount = await Sale.countDocuments({ shopId: req.shopId });
      const invoiceNumber = `INV-${1000 + saleCount + 1}`;

      // 2. Create Sale Record
      const sale = new Sale({
        shopId: req.shopId,
        branchId: activeBranchId,
        cashierId: req.user._id,
        customerId: customerId || null,
        customerName,
        invoiceNumber,
        items,
        subtotal,
        discountPercent,
        discountAmount,
        taxPercent,
        taxAmount,
        grandTotal,
        paymentMethod,
        status: 'COMPLETED'
      });

      const savedSale = await sale.save();

      // 3. Deduct Inventory & Record Movement
      for (const item of items) {
        const prod = await Product.findById(item.productId);
        if (prod) {
          const oldStock = prod.currentStock;
          prod.currentStock = Math.max(0, prod.currentStock - item.quantity);
          if (prod.currentStock <= 0) prod.status = 'OUT_OF_STOCK';
          else if (prod.currentStock <= prod.lowStockThreshold) prod.status = 'LOW_STOCK';
          await prod.save();

          await InventoryMovement.create({
            shopId: req.shopId,
            branchId: activeBranchId,
            productId: prod._id,
            movementType: 'SALE',
            quantity: -item.quantity,
            previousStock: oldStock,
            newStock: prod.currentStock,
            reason: `POS Sale: ${invoiceNumber}`,
            performedBy: req.user._id
          });
        }
      }

      // 4. Update Customer Balance if applicable
      if (customerId && paymentMethod === 'CREDIT') {
        await Customer.findByIdAndUpdate(customerId, {
          $inc: { currentBalance: grandTotal }
        });
      }

      await auditService.log({
        shopId: req.shopId,
        branchId: activeBranchId,
        userId: req.user._id,
        action: 'SALE_COMPLETED',
        module: 'pos',
        recordId: savedSale._id.toString(),
        newValues: { invoiceNumber, grandTotal, itemsCount: items.length },
        req
      });

      return res.status(201).json({
        success: true,
        message: 'Sale completed successfully.',
        data: savedSale
      });
    } catch (error) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  /**
   * List sales with Role-Based Scoping
   * Cashiers only see their own sales unless they possess pos.view_all_sales
   */
  async listSales(req, res) {
    try {
      const query = { shopId: req.shopId };

      const canViewAll = await permissionService.hasPermission(
        req.user._id,
        req.shopId,
        PERMISSIONS.POS_VIEW_ALL_SALES
      );

      if (!canViewAll) {
        // Restricted to cashier's own sales
        query.cashierId = req.user._id;
      }

      const sales = await Sale.find(query)
        .populate('cashierId', 'fullName username')
        .populate('branchId', 'name code')
        .sort({ createdAt: -1 })
        .limit(100)
        .lean();

      return res.status(200).json({
        success: true,
        data: sales
      });
    } catch (error) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }
}

module.exports = new PosController();

