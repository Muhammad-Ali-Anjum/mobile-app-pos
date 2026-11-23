/**
 * Next Planners POS - Enterprise RBAC Permission Catalog & Role Constants
 * Company: Next Planners Tech Solution (NPTS)
 */

// 1. All standard module-wise permissions (17 Modules)
const PERMISSIONS = Object.freeze({
  // 6.1 Dashboard
  DASHBOARD_VIEW: 'dashboard.view',
  DASHBOARD_VIEW_SALES: 'dashboard.view_sales',
  DASHBOARD_VIEW_PROFIT: 'dashboard.view_profit',
  DASHBOARD_VIEW_EXPENSES: 'dashboard.view_expenses',
  DASHBOARD_VIEW_INVENTORY: 'dashboard.view_inventory',
  DASHBOARD_VIEW_BRANCH: 'dashboard.view_branch',
  DASHBOARD_VIEW_ALL_BRANCHES: 'dashboard.view_all_branches',

  // 6.2 POS
  POS_VIEW: 'pos.view',
  POS_CREATE: 'pos.create',
  POS_EDIT_CART: 'pos.edit_cart',
  POS_REMOVE_ITEM: 'pos.remove_item',
  POS_APPLY_DISCOUNT: 'pos.apply_discount',
  POS_OVERRIDE_PRICE: 'pos.override_price',
  POS_HOLD_ORDER: 'pos.hold_order',
  POS_RESUME_ORDER: 'pos.resume_order',
  POS_COMPLETE_SALE: 'pos.complete_sale',
  POS_CANCEL_SALE: 'pos.cancel_sale',
  POS_RETURN_SALE: 'pos.return_sale',
  POS_REFUND: 'pos.refund',
  POS_SPLIT_PAYMENT: 'pos.split_payment',
  POS_VIEW_OWN_SALES: 'pos.view_own_sales',
  POS_VIEW_ALL_SALES: 'pos.view_all_sales',
  POS_PRINT_RECEIPT: 'pos.print_receipt',

  // 6.3 Products
  PRODUCTS_VIEW: 'products.view',
  PRODUCTS_CREATE: 'products.create',
  PRODUCTS_EDIT: 'products.edit',
  PRODUCTS_ARCHIVE: 'products.archive',
  PRODUCTS_DELETE: 'products.delete',
  PRODUCTS_IMPORT: 'products.import',
  PRODUCTS_EXPORT: 'products.export',
  PRODUCTS_VIEW_PURCHASE_PRICE: 'products.view_purchase_price',
  PRODUCTS_EDIT_PURCHASE_PRICE: 'products.edit_purchase_price',
  PRODUCTS_EDIT_SELLING_PRICE: 'products.edit_selling_price',
  PRODUCTS_MANAGE_BARCODE: 'products.manage_barcode',

  // 6.4 Categories and Brands
  CATEGORIES_VIEW: 'categories.view',
  CATEGORIES_CREATE: 'categories.create',
  CATEGORIES_EDIT: 'categories.edit',
  CATEGORIES_DELETE: 'categories.delete',
  BRANDS_VIEW: 'brands.view',
  BRANDS_CREATE: 'brands.create',
  BRANDS_EDIT: 'brands.edit',
  BRANDS_DELETE: 'brands.delete',

  // 6.5 Inventory
  INVENTORY_VIEW: 'inventory.view',
  INVENTORY_STOCK_IN: 'inventory.stock_in',
  INVENTORY_STOCK_OUT: 'inventory.stock_out',
  INVENTORY_ADJUST: 'inventory.adjust',
  INVENTORY_APPROVE_ADJUSTMENT: 'inventory.approve_adjustment',
  INVENTORY_TRANSFER: 'inventory.transfer',
  INVENTORY_APPROVE_TRANSFER: 'inventory.approve_transfer',
  INVENTORY_STOCK_COUNT: 'inventory.stock_count',
  INVENTORY_VIEW_HISTORY: 'inventory.view_history',
  INVENTORY_EXPORT: 'inventory.export',

  // 6.6 Purchases
  PURCHASES_VIEW: 'purchases.view',
  PURCHASES_CREATE: 'purchases.create',
  PURCHASES_EDIT: 'purchases.edit',
  PURCHASES_SUBMIT: 'purchases.submit',
  PURCHASES_APPROVE: 'purchases.approve',
  PURCHASES_RECEIVE: 'purchases.receive',
  PURCHASES_CANCEL: 'purchases.cancel',
  PURCHASES_VIEW_COST: 'purchases.view_cost',
  PURCHASES_RECORD_PAYMENT: 'purchases.record_payment',
  PURCHASES_EXPORT: 'purchases.export',
  PURCHASES_PRINT: 'purchases.print',

  // 6.7 Sales
  SALES_VIEW: 'sales.view',
  SALES_VIEW_OWN: 'sales.view_own',
  SALES_VIEW_ALL: 'sales.view_all',
  SALES_CREATE: 'sales.create',
  SALES_EDIT_DRAFT: 'sales.edit_draft',
  SALES_CANCEL: 'sales.cancel',
  SALES_RETURN: 'sales.return',
  SALES_REFUND: 'sales.refund',
  SALES_APPROVE_REFUND: 'sales.approve_refund',
  SALES_EXPORT: 'sales.export',
  SALES_PRINT: 'sales.print',

  // 6.8 Customers
  CUSTOMERS_VIEW: 'customers.view',
  CUSTOMERS_CREATE: 'customers.create',
  CUSTOMERS_EDIT: 'customers.edit',
  CUSTOMERS_ARCHIVE: 'customers.archive',
  CUSTOMERS_VIEW_BALANCE: 'customers.view_balance',
  CUSTOMERS_MANAGE_CREDIT: 'customers.manage_credit',
  CUSTOMERS_RECORD_PAYMENT: 'customers.record_payment',
  CUSTOMERS_VIEW_LEDGER: 'customers.view_ledger',
  CUSTOMERS_EXPORT: 'customers.export',

  // 6.9 Suppliers
  SUPPLIERS_VIEW: 'suppliers.view',
  SUPPLIERS_CREATE: 'suppliers.create',
  SUPPLIERS_EDIT: 'suppliers.edit',
  SUPPLIERS_ARCHIVE: 'suppliers.archive',
  SUPPLIERS_VIEW_BALANCE: 'suppliers.view_balance',
  SUPPLIERS_RECORD_PAYMENT: 'suppliers.record_payment',
  SUPPLIERS_VIEW_LEDGER: 'suppliers.view_ledger',
  SUPPLIERS_EXPORT: 'suppliers.export',

  // 6.10 Expenses
  EXPENSES_VIEW: 'expenses.view',
  EXPENSES_CREATE: 'expenses.create',
  EXPENSES_EDIT: 'expenses.edit',
  EXPENSES_DELETE: 'expenses.delete',
  EXPENSES_SUBMIT: 'expenses.submit',
  EXPENSES_APPROVE: 'expenses.approve',
  EXPENSES_EXPORT: 'expenses.export',
  EXPENSES_PRINT: 'expenses.print',

  // 6.11 Accounts
  ACCOUNTS_VIEW: 'accounts.view',
  ACCOUNTS_VIEW_CASHBOOK: 'accounts.view_cashbook',
  ACCOUNTS_MANAGE_CASHBOOK: 'accounts.manage_cashbook',
  ACCOUNTS_CASH_IN: 'accounts.cash_in',
  ACCOUNTS_CASH_OUT: 'accounts.cash_out',
  ACCOUNTS_CASH_CLOSING: 'accounts.cash_closing',
  ACCOUNTS_RECONCILE: 'accounts.reconcile',
  ACCOUNTS_VIEW_RECEIVABLES: 'accounts.view_receivables',
  ACCOUNTS_VIEW_PAYABLES: 'accounts.view_payables',
  ACCOUNTS_MANAGE_PAYMENTS: 'accounts.manage_payments',
  ACCOUNTS_VIEW_PROFIT_LOSS: 'accounts.view_profit_loss',
  ACCOUNTS_EXPORT: 'accounts.export',

  // 6.12 Employees and Users
  USERS_VIEW: 'users.view',
  USERS_CREATE: 'users.create',
  USERS_EDIT: 'users.edit',
  USERS_SUSPEND: 'users.suspend',
  USERS_ACTIVATE: 'users.activate',
  USERS_ASSIGN_ROLE: 'users.assign_role',
  USERS_REVOKE_ROLE: 'users.revoke_role',
  USERS_MANAGE_BRANCH_ACCESS: 'users.manage_branch_access',
  USERS_VIEW_ACTIVITY: 'users.view_activity',

  // 6.13 Roles and Permissions
  ROLES_VIEW: 'roles.view',
  ROLES_CREATE: 'roles.create',
  ROLES_EDIT: 'roles.edit',
  ROLES_DELETE: 'roles.delete',
  ROLES_ASSIGN: 'roles.assign',
  ROLES_MANAGE_PERMISSIONS: 'roles.manage_permissions',

  // 6.14 Reports
  REPORTS_VIEW: 'reports.view',
  REPORTS_SALES: 'reports.sales',
  REPORTS_PURCHASES: 'reports.purchases',
  REPORTS_INVENTORY: 'reports.inventory',
  REPORTS_EXPENSES: 'reports.expenses',
  REPORTS_FINANCIAL: 'reports.financial',
  REPORTS_EMPLOYEE: 'reports.employee',
  REPORTS_BRANCH: 'reports.branch',
  REPORTS_EXPORT: 'reports.export',
  REPORTS_PRINT: 'reports.print',

  // 6.15 Branches
  BRANCHES_VIEW: 'branches.view',
  BRANCHES_CREATE: 'branches.create',
  BRANCHES_EDIT: 'branches.edit',
  BRANCHES_ARCHIVE: 'branches.archive',
  BRANCHES_ASSIGN_MANAGER: 'branches.assign_manager',
  BRANCHES_MANAGE_STOCK: 'branches.manage_stock',
  BRANCHES_VIEW_REPORTS: 'branches.view_reports',

  // 6.16 Settings
  SETTINGS_VIEW: 'settings.view',
  SETTINGS_SHOP_PROFILE: 'settings.shop_profile',
  SETTINGS_TAX: 'settings.tax',
  SETTINGS_CURRENCY: 'settings.currency',
  SETTINGS_INVOICE: 'settings.invoice',
  SETTINGS_RECEIPT: 'settings.receipt',
  SETTINGS_PRINTER: 'settings.printer',
  SETTINGS_PAYMENT_METHODS: 'settings.payment_methods',
  SETTINGS_BACKUP: 'settings.backup',
  SETTINGS_RESTORE: 'settings.restore',

  // 6.17 Subscription Management
  SUBSCRIPTION_VIEW: 'subscription.view',
  SUBSCRIPTION_UPGRADE: 'subscription.upgrade',
  SUBSCRIPTION_RENEW: 'subscription.renew',
  SUBSCRIPTION_PAYMENT_HISTORY: 'subscription.payment_history',
  SUBSCRIPTION_MANAGE_PLANS: 'subscription.manage_plans',

  // Approvals & Audit
  APPROVALS_VIEW: 'approvals.view',
  APPROVALS_MANAGE: 'approvals.manage',
  AUDIT_VIEW: 'audit.view',
  AUDIT_EXPORT: 'audit.export'
});

// 2. Predefined Platform & Shop Roles
const ROLES = Object.freeze({
  // Platform-level
  SUPER_ADMIN: 'super_admin',
  SUPPORT_ADMIN: 'support_admin',

  // Shop-level
  SHOP_OWNER: 'shop_owner',
  SHOP_ADMIN: 'shop_admin',
  BRANCH_MANAGER: 'branch_manager',
  SALES_MANAGER: 'sales_manager',
  CASHIER: 'cashier',
  INVENTORY_MANAGER: 'inventory_manager',
  PURCHASE_OFFICER: 'purchase_officer',
  ACCOUNTANT: 'accountant',
  AUDITOR: 'auditor'
});

// 3. Modules list
const MODULES = [
  'dashboard', 'pos', 'products', 'categories', 'brands', 'inventory',
  'purchases', 'sales', 'customers', 'suppliers', 'expenses', 'accounts',
  'users', 'roles', 'reports', 'branches', 'settings', 'subscription',
  'approvals', 'audit'
];

// Helper to filter all permissions by module
const getPermissionsByModule = (mod) => {
  return Object.values(PERMISSIONS).filter((p) => p.startsWith(`${mod}.`));
};

// 4. Default Role Permissions Matrix Mapping
const DEFAULT_ROLE_PERMISSIONS = {
  [ROLES.SHOP_OWNER]: Object.values(PERMISSIONS), // Full system access within their tenant shop

  [ROLES.SHOP_ADMIN]: [
    ...getPermissionsByModule('dashboard'),
    ...getPermissionsByModule('pos'),
    ...getPermissionsByModule('products'),
    ...getPermissionsByModule('categories'),
    ...getPermissionsByModule('brands'),
    ...getPermissionsByModule('inventory'),
    ...getPermissionsByModule('purchases'),
    ...getPermissionsByModule('sales'),
    ...getPermissionsByModule('customers'),
    ...getPermissionsByModule('suppliers'),
    ...getPermissionsByModule('expenses'),
    ...getPermissionsByModule('users'),
    ...getPermissionsByModule('roles'),
    ...getPermissionsByModule('reports'),
    PERMISSIONS.BRANCHES_VIEW,
    PERMISSIONS.BRANCHES_MANAGE_STOCK,
    PERMISSIONS.BRANCHES_VIEW_REPORTS,
    PERMISSIONS.SETTINGS_VIEW,
    PERMISSIONS.SETTINGS_SHOP_PROFILE,
    PERMISSIONS.SETTINGS_TAX,
    PERMISSIONS.SETTINGS_CURRENCY,
    PERMISSIONS.SETTINGS_INVOICE,
    PERMISSIONS.SETTINGS_RECEIPT,
    PERMISSIONS.SETTINGS_PRINTER,
    PERMISSIONS.SETTINGS_PAYMENT_METHODS,
    PERMISSIONS.APPROVALS_VIEW,
    PERMISSIONS.APPROVALS_MANAGE,
    PERMISSIONS.AUDIT_VIEW
  ],

  [ROLES.BRANCH_MANAGER]: [
    PERMISSIONS.DASHBOARD_VIEW,
    PERMISSIONS.DASHBOARD_VIEW_SALES,
    PERMISSIONS.DASHBOARD_VIEW_EXPENSES,
    PERMISSIONS.DASHBOARD_VIEW_INVENTORY,
    PERMISSIONS.DASHBOARD_VIEW_BRANCH,
    ...getPermissionsByModule('pos'),
    PERMISSIONS.PRODUCTS_VIEW,
    PERMISSIONS.CATEGORIES_VIEW,
    PERMISSIONS.BRANDS_VIEW,
    ...getPermissionsByModule('inventory'),
    ...getPermissionsByModule('sales'),
    ...getPermissionsByModule('customers'),
    PERMISSIONS.SUPPLIERS_VIEW,
    PERMISSIONS.EXPENSES_VIEW,
    PERMISSIONS.EXPENSES_CREATE,
    PERMISSIONS.EXPENSES_SUBMIT,
    PERMISSIONS.USERS_VIEW,
    PERMISSIONS.REPORTS_VIEW,
    PERMISSIONS.REPORTS_SALES,
    PERMISSIONS.REPORTS_INVENTORY,
    PERMISSIONS.REPORTS_BRANCH,
    PERMISSIONS.BRANCHES_VIEW,
    PERMISSIONS.APPROVALS_VIEW,
    PERMISSIONS.AUDIT_VIEW
  ],

  [ROLES.SALES_MANAGER]: [
    PERMISSIONS.DASHBOARD_VIEW,
    PERMISSIONS.DASHBOARD_VIEW_SALES,
    ...getPermissionsByModule('pos'),
    PERMISSIONS.PRODUCTS_VIEW,
    ...getPermissionsByModule('sales'),
    ...getPermissionsByModule('customers'),
    PERMISSIONS.SUPPLIERS_VIEW,
    PERMISSIONS.USERS_VIEW,
    PERMISSIONS.REPORTS_VIEW,
    PERMISSIONS.REPORTS_SALES,
    PERMISSIONS.APPROVALS_VIEW
  ],

  [ROLES.CASHIER]: [
    PERMISSIONS.DASHBOARD_VIEW,
    PERMISSIONS.POS_VIEW,
    PERMISSIONS.POS_CREATE,
    PERMISSIONS.POS_EDIT_CART,
    PERMISSIONS.POS_REMOVE_ITEM,
    PERMISSIONS.POS_APPLY_DISCOUNT,
    PERMISSIONS.POS_HOLD_ORDER,
    PERMISSIONS.POS_RESUME_ORDER,
    PERMISSIONS.POS_COMPLETE_SALE,
    PERMISSIONS.POS_VIEW_OWN_SALES,
    PERMISSIONS.POS_PRINT_RECEIPT,
    PERMISSIONS.PRODUCTS_VIEW,
    PERMISSIONS.SALES_VIEW_OWN,
    PERMISSIONS.SALES_CREATE,
    PERMISSIONS.SALES_PRINT,
    PERMISSIONS.CUSTOMERS_VIEW,
    PERMISSIONS.CUSTOMERS_CREATE
  ],

  [ROLES.INVENTORY_MANAGER]: [
    PERMISSIONS.DASHBOARD_VIEW,
    PERMISSIONS.DASHBOARD_VIEW_INVENTORY,
    ...getPermissionsByModule('products'),
    ...getPermissionsByModule('categories'),
    ...getPermissionsByModule('brands'),
    ...getPermissionsByModule('inventory'),
    PERMISSIONS.PURCHASES_VIEW,
    PERMISSIONS.PURCHASES_RECEIVE,
    PERMISSIONS.SUPPLIERS_VIEW,
    PERMISSIONS.REPORTS_VIEW,
    PERMISSIONS.REPORTS_INVENTORY,
    PERMISSIONS.BRANCHES_VIEW
  ],

  [ROLES.PURCHASE_OFFICER]: [
    PERMISSIONS.DASHBOARD_VIEW,
    PERMISSIONS.PRODUCTS_VIEW,
    PERMISSIONS.INVENTORY_VIEW,
    ...getPermissionsByModule('purchases'),
    ...getPermissionsByModule('suppliers'),
    PERMISSIONS.REPORTS_VIEW,
    PERMISSIONS.REPORTS_PURCHASES
  ],

  [ROLES.ACCOUNTANT]: [
    PERMISSIONS.DASHBOARD_VIEW,
    PERMISSIONS.DASHBOARD_VIEW_SALES,
    PERMISSIONS.DASHBOARD_VIEW_PROFIT,
    PERMISSIONS.DASHBOARD_VIEW_EXPENSES,
    PERMISSIONS.PRODUCTS_VIEW,
    PERMISSIONS.SALES_VIEW,
    PERMISSIONS.SALES_VIEW_ALL,
    PERMISSIONS.PURCHASES_VIEW,
    ...getPermissionsByModule('customers'),
    ...getPermissionsByModule('suppliers'),
    ...getPermissionsByModule('expenses'),
    ...getPermissionsByModule('accounts'),
    PERMISSIONS.REPORTS_VIEW,
    PERMISSIONS.REPORTS_SALES,
    PERMISSIONS.REPORTS_PURCHASES,
    PERMISSIONS.REPORTS_EXPENSES,
    PERMISSIONS.REPORTS_FINANCIAL,
    PERMISSIONS.APPROVALS_VIEW
  ],

  [ROLES.AUDITOR]: [
    PERMISSIONS.DASHBOARD_VIEW,
    PERMISSIONS.DASHBOARD_VIEW_SALES,
    PERMISSIONS.DASHBOARD_VIEW_EXPENSES,
    PERMISSIONS.DASHBOARD_VIEW_INVENTORY,
    PERMISSIONS.POS_VIEW,
    PERMISSIONS.PRODUCTS_VIEW,
    PERMISSIONS.INVENTORY_VIEW,
    PERMISSIONS.PURCHASES_VIEW,
    PERMISSIONS.SALES_VIEW,
    PERMISSIONS.SALES_VIEW_ALL,
    PERMISSIONS.CUSTOMERS_VIEW,
    PERMISSIONS.SUPPLIERS_VIEW,
    PERMISSIONS.EXPENSES_VIEW,
    PERMISSIONS.ACCOUNTS_VIEW,
    PERMISSIONS.ACCOUNTS_VIEW_CASHBOOK,
    PERMISSIONS.USERS_VIEW,
    PERMISSIONS.REPORTS_VIEW,
    PERMISSIONS.REPORTS_SALES,
    PERMISSIONS.REPORTS_PURCHASES,
    PERMISSIONS.REPORTS_INVENTORY,
    PERMISSIONS.REPORTS_EXPENSES,
    PERMISSIONS.REPORTS_FINANCIAL,
    PERMISSIONS.REPORTS_EXPORT,
    PERMISSIONS.AUDIT_VIEW,
    PERMISSIONS.AUDIT_EXPORT
  ]
};

module.exports = {
  PERMISSIONS,
  ROLES,
  MODULES,
  DEFAULT_ROLE_PERMISSIONS,
  getPermissionsByModule
};
