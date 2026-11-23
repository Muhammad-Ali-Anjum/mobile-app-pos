const {
  PERMISSIONS,
  ROLES,
  DEFAULT_ROLE_PERMISSIONS
} = require('../src/permissions/permission.constants');
const permissionService = require('../src/services/permission.service');
const approvalService = require('../src/services/approval.service');
const {
  User,
  UserRole,
  Role,
  RolePermission,
  UserPermissionOverride,
  ApprovalRequest
} = require('../src/models');

describe('Next Planners POS - RBAC & Security Test Suite', () => {
  afterEach(() => {
    jest.restoreAllMocks();
  });

  test('1. Role constants & module counts are correctly configured for production', () => {
    expect(Object.keys(DEFAULT_ROLE_PERMISSIONS)).toContain(ROLES.SHOP_OWNER);
    expect(Object.keys(DEFAULT_ROLE_PERMISSIONS)).toContain(ROLES.CASHIER);
    expect(Object.keys(DEFAULT_ROLE_PERMISSIONS)).toContain(ROLES.INVENTORY_MANAGER);
    expect(Object.keys(DEFAULT_ROLE_PERMISSIONS)).toContain(ROLES.ACCOUNTANT);
    expect(Object.keys(DEFAULT_ROLE_PERMISSIONS)).toContain(ROLES.AUDITOR);

    // Cashier must have pos.create and pos.view_own_sales
    const cashierPerms = DEFAULT_ROLE_PERMISSIONS[ROLES.CASHIER];
    expect(cashierPerms).toContain(PERMISSIONS.POS_CREATE);
    expect(cashierPerms).toContain(PERMISSIONS.POS_VIEW_OWN_SALES);

    // Cashier must NOT have profit or cost editing permissions
    expect(cashierPerms).not.toContain(PERMISSIONS.DASHBOARD_VIEW_PROFIT);
    expect(cashierPerms).not.toContain(PERMISSIONS.PRODUCTS_EDIT_PURCHASE_PRICE);
    expect(cashierPerms).not.toContain(PERMISSIONS.SALES_CANCEL);
  });

  test('2. Suspended user produces empty permission set (0 permissions)', async () => {
    jest.spyOn(User, 'findById').mockReturnValue({
      lean: jest.fn().mockResolvedValue({
        _id: 'user_suspended_1',
        fullName: 'Suspended Employee',
        status: 'SUSPENDED'
      })
    });

    const perms = await permissionService.resolveUserPermissions('user_suspended_1', 'shop_1');
    expect(perms.size).toBe(0);
  });

  test('3. Resolves standard permissions for Cashier role with overrides applied', async () => {
    // Mock Active User
    jest.spyOn(User, 'findById').mockReturnValue({
      lean: jest.fn().mockResolvedValue({
        _id: 'user_cashier_1',
        fullName: 'Ali Cashier',
        status: 'ACTIVE'
      })
    });

    // Mock UserRole assignment
    jest.spyOn(UserRole, 'find').mockReturnValue({
      populate: jest.fn().mockReturnValue({
        lean: jest.fn().mockResolvedValue([
          {
            userId: 'user_cashier_1',
            shopId: 'shop_1',
            status: 'ACTIVE',
            roleId: {
              _id: 'role_cashier_1',
              slug: ROLES.CASHIER,
              isActive: true
            }
          }
        ])
      })
    });

    // Mock RolePermission empty custom queries
    jest.spyOn(RolePermission, 'find').mockReturnValue({
      lean: jest.fn().mockResolvedValue([])
    });

    // Mock an explicit DENY override on POS_APPLY_DISCOUNT
    jest.spyOn(UserPermissionOverride, 'find').mockReturnValue({
      lean: jest.fn().mockResolvedValue([
        {
          userId: 'user_cashier_1',
          shopId: 'shop_1',
          permissionKey: PERMISSIONS.POS_APPLY_DISCOUNT,
          effect: 'DENY'
        }
      ])
    });

    const perms = await permissionService.resolveUserPermissions('user_cashier_1', 'shop_1');

    // Verified: Cashier has POS create
    expect(perms.has(PERMISSIONS.POS_CREATE)).toBe(true);

    // Verified: The explicit DENY override revoked POS_APPLY_DISCOUNT
    expect(perms.has(PERMISSIONS.POS_APPLY_DISCOUNT)).toBe(false);

    // Verified: Forbidden permissions remain blocked
    expect(perms.has(PERMISSIONS.DASHBOARD_VIEW_PROFIT)).toBe(false);
  });

  test('4. Delegation Security: User cannot delegate permissions they do not possess', async () => {
    // User only has Cashier permissions
    jest.spyOn(permissionService, 'resolveUserPermissions').mockResolvedValue(
      new Set([PERMISSIONS.POS_VIEW, PERMISSIONS.POS_CREATE])
    );

    const canDelegate = await permissionService.canDelegatePermissions(
      'cashier_id',
      'shop_1',
      [PERMISSIONS.ACCOUNTS_VIEW_PROFIT_LOSS] // Sensitive financial permission
    );

    expect(canDelegate).toBe(false);
  });

  test('5. Approval Workflow: Requester is strictly blocked from approving their own request', async () => {
    const requesterId = 'cashier_user_99';
    const fakeRequestId = 'req_123';

    jest.spyOn(ApprovalRequest, 'findById').mockResolvedValue({
      _id: fakeRequestId,
      shopId: 'shop_1',
      requestedBy: requesterId,
      status: 'PENDING'
    });

    // Cashier attempts to approve their own request
    await expect(
      approvalService.reviewRequest({
        requestId: fakeRequestId,
        approverId: requesterId,
        decision: 'APPROVED',
        reviewNotes: 'I approve my own discount'
      })
    ).rejects.toThrow('Security policy violation: Requesters cannot approve their own requests.');
  });
});
