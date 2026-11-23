const { Product } = require('../models');
const permissionService = require('../services/permission.service');
const auditService = require('../services/audit.service');
const { PERMISSIONS } = require('../permissions/permission.constants');

class ProductController {
  /**
   * List all products with dynamic RBAC data masking
   */
  async listProducts(req, res) {
    try {
      const { category, search, status } = req.query;
      const query = { shopId: req.shopId };

      if (category && category !== 'All') {
        query.category = category;
      }
      if (status) {
        query.status = status;
      }
      if (search) {
        query.$or = [
          { name: { $regex: search, $options: 'i' } },
          { sku: { $regex: search, $options: 'i' } },
          { barcode: { $regex: search, $options: 'i' } }
        ];
      }

      const products = await Product.find(query).sort({ createdAt: -1 }).lean();

      // RBAC Data Masking: Check if user has permission to see purchase costs
      const canViewPurchasePrice = await permissionService.hasPermission(
        req.user._id,
        req.shopId,
        PERMISSIONS.PRODUCTS_VIEW_PURCHASE_PRICE
      );

      const sanitizedProducts = products.map((prod) => {
        if (!canViewPurchasePrice) {
          const { purchasePrice, ...rest } = prod;
          return { ...rest, purchasePrice: null };
        }
        return prod;
      });

      // Quick inventory KPI metrics
      const totalCount = await Product.countDocuments({ shopId: req.shopId });
      const activeCount = await Product.countDocuments({ shopId: req.shopId, status: 'ACTIVE' });
      const lowStockCount = await Product.countDocuments({ shopId: req.shopId, status: 'LOW_STOCK' });
      const outOfStockCount = await Product.countDocuments({ shopId: req.shopId, status: 'OUT_OF_STOCK' });

      return res.status(200).json({
        success: true,
        data: sanitizedProducts,
        summary: {
          totalProducts: totalCount,
          activeProducts: activeCount,
          lowStock: lowStockCount,
          outOfStock: outOfStockCount
        }
      });
    } catch (error) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  /**
   * Create new product
   */
  async createProduct(req, res) {
    try {
      const {
        name,
        sku,
        barcode,
        category,
        brand,
        purchasePrice = 0,
        sellingPrice,
        currentStock = 0,
        lowStockThreshold = 10,
        unit = 'pcs'
      } = req.body;

      if (!name || !sku || sellingPrice === undefined) {
        return res.status(400).json({
          success: false,
          message: 'Product name, SKU, and selling price are required.'
        });
      }

      const existing = await Product.findOne({ shopId: req.shopId, sku: sku.toUpperCase() });
      if (existing) {
        return res.status(400).json({
          success: false,
          message: `Product with SKU ${sku} already exists.`
        });
      }

      let status = 'ACTIVE';
      if (currentStock <= 0) status = 'OUT_OF_STOCK';
      else if (currentStock <= lowStockThreshold) status = 'LOW_STOCK';

      const product = new Product({
        shopId: req.shopId,
        name: name.trim(),
        sku: sku.toUpperCase().trim(),
        barcode: barcode || '',
        category: category || 'General',
        brand: brand || 'Generic',
        purchasePrice,
        sellingPrice,
        currentStock,
        lowStockThreshold,
        unit,
        status
      });

      const saved = await product.save();

      await auditService.log({
        shopId: req.shopId,
        userId: req.user._id,
        action: 'PRODUCT_CREATED',
        module: 'products',
        recordId: saved._id.toString(),
        newValues: { name, sku, sellingPrice, currentStock },
        req
      });

      return res.status(201).json({
        success: true,
        message: 'Product created successfully.',
        data: saved
      });
    } catch (error) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  /**
   * Update product
   */
  async updateProduct(req, res) {
    try {
      const { id } = req.params;
      const updates = req.body;

      const product = await Product.findOne({ _id: id, shopId: req.shopId });
      if (!product) {
        return res.status(404).json({ success: false, message: 'Product not found.' });
      }

      // Check permission if updating purchase price
      if (updates.purchasePrice !== undefined && updates.purchasePrice !== product.purchasePrice) {
        const canEditCost = await permissionService.hasPermission(
          req.user._id,
          req.shopId,
          PERMISSIONS.PRODUCTS_EDIT_PURCHASE_PRICE
        );
        if (!canEditCost) {
          return res.status(403).json({
            success: false,
            message: 'You are not authorized to modify product purchase prices.'
          });
        }
      }

      const oldValues = { ...product.toObject() };
      Object.assign(product, updates);

      if (product.currentStock <= 0) product.status = 'OUT_OF_STOCK';
      else if (product.currentStock <= product.lowStockThreshold) product.status = 'LOW_STOCK';
      else product.status = 'ACTIVE';

      await product.save();

      await auditService.log({
        shopId: req.shopId,
        userId: req.user._id,
        action: 'PRODUCT_UPDATED',
        module: 'products',
        recordId: product._id.toString(),
        oldValues: { sellingPrice: oldValues.sellingPrice, stock: oldValues.currentStock },
        newValues: { sellingPrice: product.sellingPrice, stock: product.currentStock },
        req
      });

      return res.status(200).json({
        success: true,
        message: 'Product updated successfully.',
        data: product
      });
    } catch (error) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }
}

module.exports = new ProductController();

