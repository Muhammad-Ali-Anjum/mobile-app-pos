const mongoose = require('mongoose');
const { Permission, Role, RolePermission } = require('../models');
const {
  PERMISSIONS,
  ROLES,
  DEFAULT_ROLE_PERMISSIONS
} = require('../permissions/permission.constants');

const seedRBAC = async () => {
  console.log('--- Initializing Next Planners POS RBAC Seeder ---');

  // 1. Seed All Permissions
  const permissionEntries = Object.entries(PERMISSIONS).map(([constName, key]) => {
    const [module, action] = key.split('.');
    const formattedName = key
      .split('.')
      .map((part) => part.replace(/_/g, ' '))
      .join(' - ')
      .toUpperCase();

    return {
      key,
      name: formattedName,
      module,
      action: action || 'view',
      description: `Allows user to perform ${action} within ${module} module.`
    };
  });

  for (const p of permissionEntries) {
    await Permission.findOneAndUpdate({ key: p.key }, p, { upsert: true, new: true });
  }
  console.log(`✓ Seeded ${permissionEntries.length} granular permissions across 17 modules.`);

  // 2. Seed Default System Roles
  const systemRoles = [
    {
      name: 'Super Admin',
      slug: ROLES.SUPER_ADMIN,
      description: 'Platform Super Administrator with complete system management.',
      roleType: 'PLATFORM',
      isSystemRole: true
    },
    {
      name: 'Support Admin',
      slug: ROLES.SUPPORT_ADMIN,
      description: 'Platform Support Administrator for troubleshooting and customer help.',
      roleType: 'PLATFORM',
      isSystemRole: true
    },
    {
      name: 'Shop Owner',
      slug: ROLES.SHOP_OWNER,
      description: 'Complete business management, all branch authority and settings.',
      roleType: 'DEFAULT_SHOP',
      isSystemRole: true
    },
    {
      name: 'Shop Administrator',
      slug: ROLES.SHOP_ADMIN,
      description: 'Shop administration and operational controls across branches.',
      roleType: 'DEFAULT_SHOP',
      isSystemRole: true
    },
    {
      name: 'Branch Manager',
      slug: ROLES.BRANCH_MANAGER,
      description: 'Managerial authority scoped strictly to designated branch(es).',
      roleType: 'DEFAULT_SHOP',
      isSystemRole: true
    },
    {
      name: 'Sales Manager',
      slug: ROLES.SALES_MANAGER,
      description: 'Supervision of cashiers, customer credit limits, and sales operations.',
      roleType: 'DEFAULT_SHOP',
      isSystemRole: true
    },
    {
      name: 'Cashier / POS Operator',
      slug: ROLES.CASHIER,
      description: 'POS billing, customer checkout, receipt printing with discount limits.',
      roleType: 'DEFAULT_SHOP',
      isSystemRole: true
    },
    {
      name: 'Inventory Manager',
      slug: ROLES.INVENTORY_MANAGER,
      description: 'Stock management, product catalogs, warehouse movements, and counting.',
      roleType: 'DEFAULT_SHOP',
      isSystemRole: true
    },
    {
      name: 'Purchase Officer',
      slug: ROLES.PURCHASE_OFFICER,
      description: 'Procurement orders, supplier interactions, and goods receiving.',
      roleType: 'DEFAULT_SHOP',
      isSystemRole: true
    },
    {
      name: 'Accountant / Finance Officer',
      slug: ROLES.ACCOUNTANT,
      description: 'Financial ledger, expense reviews, cashbook reconciliation, and reports.',
      roleType: 'DEFAULT_SHOP',
      isSystemRole: true
    },
    {
      name: 'Auditor / Read-only User',
      slug: ROLES.AUDITOR,
      description: 'Comprehensive inspection and reporting with strict zero-mutation policy.',
      roleType: 'DEFAULT_SHOP',
      isSystemRole: true
    }
  ];

  for (const r of systemRoles) {
    const roleDoc = await Role.findOneAndUpdate(
      { slug: r.slug, isSystemRole: true, shopId: null },
      r,
      { upsert: true, new: true }
    );

    // Seed default role-permission mappings if defined
    if (DEFAULT_ROLE_PERMISSIONS[r.slug]) {
      const perms = DEFAULT_ROLE_PERMISSIONS[r.slug];
      for (const permKey of perms) {
        await RolePermission.findOneAndUpdate(
          { roleId: roleDoc._id, permissionKey: permKey },
          { roleId: roleDoc._id, permissionKey: permKey },
          { upsert: true }
        );
      }
    }
  }
  console.log(`✓ Seeded all 11 system roles and their default permission mappings.`);
  console.log('--- RBAC Seeding Completed Successfully ---');
};

module.exports = seedRBAC;

if (require.main === module) {
  const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/next_planners_pos';
  mongoose
    .connect(MONGO_URI)
    .then(async () => {
      await seedRBAC();
      process.exit(0);
    })
    .catch((err) => {
      console.error('Seeding error:', err);
      process.exit(1);
    });
}
