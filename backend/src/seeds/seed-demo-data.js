const mongoose = require('mongoose');
const {
  User,
  Shop,
  Branch,
  Role,
  UserRole,
  UserBranchAccess,
  Product,
  Customer,
  Sale,
  ApprovalRequest,
  AuditLog
} = require('../models');
const { ROLES } = require('../permissions/permission.constants');
const seedRBAC = require('./seed-rbac');

const seedDemoData = async () => {
  console.log('--- Seeding Next Planners POS Demo Environment ---');

  // First ensure RBAC default roles and permissions exist
  await seedRBAC();

  // 1. Create Demo Shop
  let shop = await Shop.findOne({ code: 'ABCSKD' });
  if (!shop) {
    shop = await Shop.create({
      name: 'ABC Supermarket',
      code: 'ABCSKD',
      ownerId: new mongoose.Types.ObjectId(), // updated below
      subscription: {
        plan: 'ENTERPRISE',
        status: 'ACTIVE',
        maxBranches: 10,
        maxUsers: 50
      },
      settings: {
        currency: 'PKR',
        currencySymbol: 'Rs.',
        taxPercentage: 0,
        maxCashierDiscountPercent: 10,
        requireRefundApprovalAbove: 5000
      }
    });
  }

  // 2. Create Branches
  const branches = [
    { name: 'Main Branch – Skardu', code: 'BR-SKD', city: 'Skardu', isMainBranch: true },
    { name: 'Branch 2 – Gilgit', code: 'BR-GLT', city: 'Gilgit', isMainBranch: false },
    { name: 'Branch 3 – Islamabad', code: 'BR-ISB', city: 'Islamabad', isMainBranch: false }
  ];

  const branchDocs = [];
  for (const b of branches) {
    const doc = await Branch.findOneAndUpdate(
      { shopId: shop._id, code: b.code },
      { ...b, shopId: shop._id, isActive: true },
      { upsert: true, new: true }
    );
    branchDocs.push(doc);
  }
  const mainBranch = branchDocs[0];

  // 3. Create Demo Users & Staff
  const defaultPassword = 'password123';
  const passwordHash = await User.hashPassword(defaultPassword);

  // 3.1 Create Platform Super Admin
  const adminPasswordHash = await User.hashPassword('admin123');
  await User.findOneAndUpdate(
    { email: 'superadmin@nextplanners.com' },
    {
      fullName: 'NPTS Platform Admin',
      username: 'superadmin',
      email: 'superadmin@nextplanners.com',
      phone: '03009999999',
      employeeId: 'SA-001',
      passwordHash: adminPasswordHash,
      isPlatformUser: true,
      platformRole: ROLES.SUPER_ADMIN,
      status: 'ACTIVE'
    },
    { upsert: true, new: true }
  );
  console.log('✓ Platform Super Admin (superadmin@nextplanners.com / admin123) seeded.');

  const staff = [
    {
      fullName: 'Anjum',
      email: 'owner@abc.com',
      username: 'alikhan',
      phone: '03001234567',
      employeeId: 'EMP-001',
      roleSlug: ROLES.SHOP_OWNER,
      branchScope: 'ALL_BRANCHES'
    },
    {
      fullName: 'M Ali Anjum',
      email: 'manager@abc.com',
      username: 'fatimaali',
      phone: '03129876543',
      employeeId: 'EMP-002',
      roleSlug: ROLES.BRANCH_MANAGER,
      branchScope: 'ASSIGNED_BRANCH',
      branchId: mainBranch._id
    },
    {
      fullName: ' Raza',
      email: 'cashier@abc.com',
      username: 'usmanraza',
      phone: '03451112233',
      employeeId: 'EMP-003',
      roleSlug: ROLES.CASHIER,
      branchScope: 'ASSIGNED_BRANCH',
      branchId: mainBranch._id
    },
    {
      fullName: 'Sana Malik',
      email: 'accountant@abc.com',
      username: 'sanamalik',
      phone: '03224455667',
      employeeId: 'EMP-004',
      roleSlug: ROLES.ACCOUNTANT,
      branchScope: 'ALL_BRANCHES'
    }
  ];

  let ownerDoc;
  for (const s of staff) {
    const userDoc = await User.findOneAndUpdate(
      { email: s.email },
      {
        fullName: s.fullName,
        username: s.username,
        email: s.email,
        phone: s.phone,
        employeeId: s.employeeId,
        passwordHash,
        defaultShopId: shop._id,
        status: 'ACTIVE'
      },
      { upsert: true, new: true }
    );

    if (s.roleSlug === ROLES.SHOP_OWNER) {
      ownerDoc = userDoc;
      shop.ownerId = userDoc._id;
      await shop.save();
    }

    const role = await Role.findOne({ slug: s.roleSlug });
    if (role) {
      await UserRole.findOneAndUpdate(
        { userId: userDoc._id, shopId: shop._id, roleId: role._id },
        { assignedBy: ownerDoc ? ownerDoc._id : userDoc._id, status: 'ACTIVE' },
        { upsert: true }
      );
    }

    await UserBranchAccess.findOneAndUpdate(
      { userId: userDoc._id, shopId: shop._id },
      {
        accessType: s.branchScope,
        branchId: s.branchId || null,
        assignedBy: ownerDoc ? ownerDoc._id : userDoc._id
      },
      { upsert: true }
    );
  }

  // 4. Create Products from Design Sheet
  const sampleProducts = [
    { name: 'Rice 5kg', sku: 'RCK001', category: 'Groceries', brand: 'Super Basmati', purchasePrice: 90, sellingPrice: 120, currentStock: 120 },
    { name: 'Sugar 1kg', sku: 'SUG001', category: 'Groceries', brand: 'SweetPure', purchasePrice: 38, sellingPrice: 50, currentStock: 80 },
    { name: 'Milk 1L', sku: 'MIL001', category: 'Daily', brand: 'DairyFresh', purchasePrice: 30, sellingPrice: 40, currentStock: 25 },
    { name: 'Cooking Oil 1L', sku: 'OIL001', category: 'Groceries', brand: 'Dalda', purchasePrice: 420, sellingPrice: 500, currentStock: 4 }, // Low Stock
    { name: 'Biscuits', sku: 'BIS001', category: 'Snacks', brand: 'Luu', purchasePrice: 90, sellingPrice: 120, currentStock: 110 },
    { name: 'Tea 250g', sku: 'TEA001', category: 'Groceries', brand: 'Tapal', purchasePrice: 200, sellingPrice: 250, currentStock: 45 },
    { name: 'Noodles', sku: 'NOD001', category: 'Snacks', brand: 'Knorr', purchasePrice: 45, sellingPrice: 60, currentStock: 90 },
    { name: 'Detergent', sku: 'DET001', category: 'Household', brand: 'Surf Excel', purchasePrice: 280, sellingPrice: 350, currentStock: 30 }
  ];

  for (const p of sampleProducts) {
    let status = 'ACTIVE';
    if (p.currentStock <= 5) status = 'LOW_STOCK';
    await Product.findOneAndUpdate(
      { shopId: shop._id, sku: p.sku },
      { ...p, shopId: shop._id, status, lowStockThreshold: 10, unit: 'pk' },
      { upsert: true }
    );
  }

  // 5. Create Customers
  const sampleCustomers = [
    { fullName: 'Ali Khan', phone: '03001234567', email: 'ali@abc.com', currentBalance: 2500, creditLimit: 50000 },
    { fullName: 'Fatima Ali', phone: '03129876543', email: 'fatima@abc.com', currentBalance: 0, creditLimit: 25000 },
    { fullName: 'Usman Raza', phone: '03451112233', email: 'usman@abc.com', currentBalance: 1200, creditLimit: 30000 },
    { fullName: 'Sana Malik', phone: '03224455667', email: 'sana@abc.com', currentBalance: 0, creditLimit: 40000 }
  ];

  for (const c of sampleCustomers) {
    await Customer.findOneAndUpdate(
      { shopId: shop._id, phone: c.phone },
      { ...c, shopId: shop._id, status: 'ACTIVE' },
      { upsert: true }
    );
  }

  console.log('✓ Demo Shop "ABC Supermarket" (Code: ABCSKD) with branches, staff, products & customers seeded!');
};

module.exports = seedDemoData;

if (require.main === module) {
  const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/next_planners_pos';
  mongoose
    .connect(MONGO_URI)
    .then(async () => {
      await seedDemoData();
      process.exit(0);
    })
    .catch((err) => {
      console.error(err);
      process.exit(1);
    });
}

