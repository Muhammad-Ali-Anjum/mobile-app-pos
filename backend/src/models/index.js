const Permission = require('./permission.model');
const Role = require('./role.model');
const RolePermission = require('./role-permission.model');
const User = require('./user.model');
const UserRole = require('./user-role.model');
const UserBranchAccess = require('./user-branch-access.model');
const UserPermissionOverride = require('./user-permission-override.model');
const ApprovalRequest = require('./approval-request.model');
const AuditLog = require('./audit-log.model');
const Session = require('./session.model');
const Shop = require('./shop.model');
const Branch = require('./branch.model');
const Product = require('./product.model');
const Customer = require('./customer.model');
const Sale = require('./sale.model');
const InventoryMovement = require('./inventory-movement.model');
const Expense = require('./expense.model');

module.exports = {
  Permission,
  Role,
  RolePermission,
  User,
  UserRole,
  UserBranchAccess,
  UserPermissionOverride,
  ApprovalRequest,
  AuditLog,
  Session,
  Shop,
  Branch,
  Product,
  Customer,
  Sale,
  InventoryMovement,
  Expense
};
