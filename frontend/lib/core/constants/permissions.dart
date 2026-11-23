/// Next Planners POS - Frontend Permission Catalog
class AppPermissions {
  AppPermissions._();

  // Dashboard
  static const String dashboardView = 'dashboard.view';
  static const String dashboardViewSales = 'dashboard.view_sales';
  static const String dashboardViewProfit = 'dashboard.view_profit';
  static const String dashboardViewExpenses = 'dashboard.view_expenses';
  static const String dashboardViewInventory = 'dashboard.view_inventory';

  // POS
  static const String posView = 'pos.view';
  static const String posCreate = 'pos.create';
  static const String posEditCart = 'pos.edit_cart';
  static const String posApplyDiscount = 'pos.apply_discount';
  static const String posHoldOrder = 'pos.hold_order';
  static const String posCompleteSale = 'pos.complete_sale';
  static const String posCancelSale = 'pos.cancel_sale';
  static const String posRefund = 'pos.refund';
  static const String posPrintReceipt = 'pos.print_receipt';

  // Products
  static const String productsView = 'products.view';
  static const String productsCreate = 'products.create';
  static const String productsEdit = 'products.edit';
  static const String productsDelete = 'products.delete';
  static const String productsViewPurchasePrice = 'products.view_purchase_price';
  static const String productsEditPurchasePrice = 'products.edit_purchase_price';

  // Inventory
  static const String inventoryView = 'inventory.view';
  static const String inventoryAdjust = 'inventory.adjust';
  static const String inventoryTransfer = 'inventory.transfer';

  // Roles & Users
  static const String rolesView = 'roles.view';
  static const String rolesCreate = 'roles.create';
  static const String rolesEdit = 'roles.edit';
  static const String rolesDelete = 'roles.delete';
  static const String usersView = 'users.view';
  static const String usersCreate = 'users.create';
  static const String usersSuspend = 'users.suspend';

  // Approvals & Audit
  static const String approvalsView = 'approvals.view';
  static const String approvalsManage = 'approvals.manage';
  static const String auditView = 'audit.view';
}

