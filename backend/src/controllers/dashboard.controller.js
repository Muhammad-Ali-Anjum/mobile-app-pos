const { Sale, Product, Expense } = require('../models');
const permissionService = require('../services/permission.service');
const { PERMISSIONS } = require('../permissions/permission.constants');

class DashboardController {
  async getDashboardMetrics(req, res) {
    try {
      const today = new Date();
      today.setHours(0, 0, 0, 0);

      // Today's Sales
      const todaySales = await Sale.find({
        shopId: req.shopId,
        createdAt: { $gte: today },
        status: 'COMPLETED'
      }).lean();

      const todayTotal = todaySales.reduce((acc, curr) => acc + (curr.grandTotal || 0), 0);

      // Total Revenue
      const allCompletedSales = await Sale.find({
        shopId: req.shopId,
        status: 'COMPLETED'
      }).lean();

      const totalRevenue = allCompletedSales.reduce((acc, curr) => acc + (curr.grandTotal || 0), 0);
      const totalOrders = allCompletedSales.length;

      // Expenses
      const allExpenses = await Expense.find({ shopId: req.shopId, status: 'APPROVED' }).lean();
      const totalExpenses = allExpenses.reduce((acc, curr) => acc + (curr.amount || 0), 0);

      // RBAC Permission Check for Profit: If user lacks dashboard.view_profit, redact profit figures!
      const canViewProfit = await permissionService.hasPermission(
        req.user._id,
        req.shopId,
        PERMISSIONS.DASHBOARD_VIEW_PROFIT
      );

      // Estimated Profit = (Total Revenue - Expenses) * margin
      const netProfit = canViewProfit ? Math.max(0, Math.round(totalRevenue * 0.4 - totalExpenses)) : null;

      // Low Stock Alerts
      const lowStockProducts = await Product.find({
        shopId: req.shopId,
        status: { $in: ['LOW_STOCK', 'OUT_OF_STOCK'] }
      })
        .limit(5)
        .lean();

      // Recent 5 Sales
      const recentSales = await Sale.find({ shopId: req.shopId, status: 'COMPLETED' })
        .sort({ createdAt: -1 })
        .limit(5)
        .lean();

      return res.status(200).json({
        success: true,
        data: {
          todaySales: todayTotal,
          totalRevenue: totalRevenue,
          totalOrders: totalOrders,
          profit: netProfit,
          recentSales,
          lowStockAlerts: lowStockProducts
        }
      });
    } catch (error) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }
}

module.exports = new DashboardController();

