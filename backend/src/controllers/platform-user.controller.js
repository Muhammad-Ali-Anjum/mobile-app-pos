const User = require('../models/user.model');
const Notification = require('../models/notification.model');
const AuditLog = require('../models/audit-log.model');
const Subscription = require('../models/subscription.model');
const Lead = require('../models/lead.model');
const Shop = require('../models/shop.model');
const Branch = require('../models/branch.model');
const Product = require('../models/product.model');
const UserRole = require('../models/user-role.model');

const ROLE_DEFAULT_PERMS = {
  super_admin: ['*'],
  admin: ['view_shops', 'register_shops', 'edit_shops', 'suspend_shops', 'manage_plans', 'manage_subscriptions', 'manage_payments', 'view_revenue', 'manage_tickets', 'view_analytics'],
  accountant: ['view_shops', 'manage_payments', 'view_revenue', 'view_analytics'],
  support_agent: ['view_shops', 'manage_tickets'],
  sales_manager: ['view_shops', 'register_shops', 'manage_plans', 'view_analytics'],
  viewer: ['view_shops', 'view_analytics']
};

exports.getPlatformUsers = async (req, res, next) => {
  try {
    const users = await User.find({ isPlatformUser: true })
      .select('-passwordHash')
      .sort({ createdAt: -1 });
    res.status(200).json(users);
  } catch (err) {
    next(err);
  }
};

exports.createPlatformUser = async (req, res, next) => {
  try {
    const { fullName, email, phone = '', password = 'Pass@123', platformRole = 'support_agent', platformPermissions } = req.body;
    if (!fullName || !email) {
      return res.status(400).json({ success: false, message: 'fullName and email are required.' });
    }

    const normalizedEmail = String(email).trim().toLowerCase();
    const existing = await User.findOne({ email: normalizedEmail });
    if (existing) {
      return res.status(409).json({ success: false, message: 'A user with this email already exists.' });
    }

    const role = String(platformRole).toLowerCase();
    const passwordHash = await User.hashPassword(password);
    const username = `${normalizedEmail.split('@')[0].replace(/[^a-z0-9_]/g, '')}_${Date.now().toString().slice(-3)}`;

    const user = await User.create({
      fullName: String(fullName).trim(),
      email: normalizedEmail,
      username,
      phone: String(phone).trim(),
      passwordHash,
      isPlatformUser: true,
      platformRole: role,
      platformPermissions: Array.isArray(platformPermissions) ? platformPermissions : (ROLE_DEFAULT_PERMS[role] || []),
      status: 'ACTIVE'
    });

    const out = user.toObject();
    delete out.passwordHash;
    res.status(201).json(out);
  } catch (err) {
    next(err);
  }
};

exports.toggleUserStatus = async (req, res, next) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ success: false, message: 'User not found.' });
    user.status = user.status === 'ACTIVE' ? 'SUSPENDED' : 'ACTIVE';
    await user.save();
    const out = user.toObject();
    delete out.passwordHash;
    res.status(200).json(out);
  } catch (err) {
    next(err);
  }
};

exports.updatePlatformUser = async (req, res, next) => {
  try {
    const { fullName, phone, platformRole, platformPermissions } = req.body;
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ success: false, message: 'User not found.' });
    if (fullName !== undefined) user.fullName = String(fullName).trim();
    if (phone !== undefined) user.phone = String(phone).trim();
    if (platformRole !== undefined) {
      const role = String(platformRole).toLowerCase();
      user.platformRole = role;
      user.platformPermissions = Array.isArray(platformPermissions) ? platformPermissions : (ROLE_DEFAULT_PERMS[role] || []);
    }
    await user.save();
    const out = user.toObject();
    delete out.passwordHash;
    res.status(200).json(out);
  } catch (err) {
    next(err);
  }
};

exports.resetUserPassword = async (req, res, next) => {
  try {
    const { newPassword } = req.body;
    if (!newPassword || String(newPassword).length < 6) {
      return res.status(400).json({ success: false, message: 'Password must be at least 6 characters.' });
    }
    const passwordHash = await User.hashPassword(String(newPassword));
    await User.findByIdAndUpdate(req.params.id, { passwordHash });
    res.status(200).json({ success: true, message: 'Password reset successfully.' });
  } catch (err) {
    next(err);
  }
};

exports.getNotifications = async (req, res, next) => {
  try {
    const list = await Notification.find().sort({ createdAt: -1 }).limit(50);
    res.status(200).json(list);
  } catch (err) {
    next(err);
  }
};

exports.markNotificationRead = async (req, res, next) => {
  try {
    const n = await Notification.findByIdAndUpdate(req.params.id, { isRead: true }, { new: true });
    res.status(200).json(n);
  } catch (err) {
    next(err);
  }
};

exports.checkExpiringSubscriptions = async (req, res, next) => {
  try {
    const now = new Date();
    const in7Days = new Date(now.getTime() + 7 * 86400000);
    const expiring = await Subscription.find({
      status: { $in: ['ACTIVE', 'TRIAL'] },
      expiresAt: { $lte: in7Days, $gte: now }
    }).populate('shopId', 'name');

    const created = [];
    for (const sub of expiring) {
      const daysLeft = Math.max(0, Math.ceil((new Date(sub.expiresAt).getTime() - now.getTime()) / 86400000));
      const n = await Notification.create({
        title: `Subscription Expiring (${daysLeft}d left)`,
        message: `${sub.shopId?.name || 'Shop'} (${sub.planSlug}) expires in ${daysLeft} day(s).`,
        type: 'SUBSCRIPTION_EXPIRING',
        channel: 'IN_APP',
        shopId: sub.shopId?._id || null,
        shopName: sub.shopId?.name || ''
      });
      created.push(n);
    }
    res.status(200).json({ checked: expiring.length, created: created.length });
  } catch (err) {
    next(err);
  }
};

exports.getPlatformAuditLogs = async (req, res, next) => {
  try {
    const logs = await AuditLog.find()
      .populate('userId', 'fullName email')
      .populate('shopId', 'name')
      .sort({ createdAt: -1 })
      .limit(100);
    res.status(200).json(logs);
  } catch (err) {
    next(err);
  }
};

// Leads & Sales CRM
exports.getLeads = async (req, res, next) => {
  try {
    const leads = await Lead.find().sort({ createdAt: -1 });
    res.status(200).json(leads);
  } catch (err) {
    next(err);
  }
};

exports.createLead = async (req, res, next) => {
  try {
    const lead = await Lead.create(req.body);
    res.status(201).json(lead);
  } catch (err) {
    next(err);
  }
};

exports.updateLead = async (req, res, next) => {
  try {
    const lead = await Lead.findByIdAndUpdate(req.params.id, { $set: req.body }, { new: true });
    res.status(200).json(lead);
  } catch (err) {
    next(err);
  }
};

exports.deleteLead = async (req, res, next) => {
  try {
    await Lead.findByIdAndDelete(req.params.id);
    res.status(200).json({ success: true });
  } catch (err) {
    next(err);
  }
};

// Usage Analytics & Cross-Tenant Overview
exports.getPlatformAnalytics = async (req, res, next) => {
  try {
    const [shops, branches, products, tenantUsers] = await Promise.all([
      Shop.find().select('name tenantId subscription isActive'),
      Branch.find().select('shopId isActive'),
      Product.countDocuments(),
      UserRole.countDocuments({ status: 'ACTIVE' })
    ]);

    const perShop = shops.map((s) => {
      const bCount = branches.filter((b) => String(b.shopId) === String(s._id) && b.isActive).length;
      return {
        shopId: s._id,
        shopName: s.name,
        tenantId: s.tenantId || '',
        plan: s.subscription?.plan || 'STANDARD',
        branchesUsed: bCount,
        maxBranches: s.subscription?.maxBranches || 1,
        maxUsers: s.subscription?.maxUsers || 5
      };
    });

    res.status(200).json({
      totalShops: shops.length,
      totalBranches: branches.length,
      totalProducts: products,
      totalTenantUsers: tenantUsers,
      perShop
    });
  } catch (err) {
    next(err);
  }
};

exports.getAllBranches = async (req, res, next) => {
  try {
    const branches = await Branch.find()
      .populate('shopId', 'name tenantId')
      .sort({ createdAt: -1 })
      .limit(100);
    res.status(200).json(branches);
  } catch (err) {
    next(err);
  }
};

exports.getAllTenantUsers = async (req, res, next) => {
  try {
    const users = await User.find({ isPlatformUser: false })
      .select('-passwordHash')
      .populate('defaultShopId', 'name tenantId')
      .sort({ createdAt: -1 })
      .limit(100);
    res.status(200).json(users);
  } catch (err) {
    next(err);
  }
};
