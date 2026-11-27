// File: backend/src/controllers/shop.controller.js
// ---------------------------------------------------
// Controller for Shop entity – full Phase 1 SaaS tenant lifecycle in MongoDB.
// ---------------------------------------------------
const Shop = require('../models/shop.model');
const User = require('../models/user.model');
const Branch = require('../models/branch.model');
const Role = require('../models/role.model');
const UserRole = require('../models/user-role.model');
const Plan = require('../models/plan.model');
const PaymentReminder = require('../models/payment-reminder.model');
const Subscription = require('../models/subscription.model');
const AuditLog = require('../models/audit-log.model');

const DEFAULT_BRANCH_BY_PLAN = {
  TRIAL: 1,
  BASIC: 1,
  STANDARD: 3,
  PREMIUM: 999,
  ENTERPRISE: 999
};

// GET /api/shops – return all shops with populated owner details
exports.getAllShops = async (req, res, next) => {
  try {
    const shops = await Shop.find()
      .populate('ownerId', 'fullName username email phone')
      .sort({ createdAt: -1 });
    res.status(200).json(shops);
  } catch (err) {
    next(err);
  }
};

// GET /api/shops/:id/details – return shop profile, branches, users, and reminders
exports.getShopDetails = async (req, res, next) => {
  try {
    const shop = await Shop.findById(req.params.id).populate('ownerId', 'fullName username email phone status');
    if (!shop) {
      return res.status(404).json({ success: false, message: 'Shop not found.' });
    }

    const [branches, userRoles, reminders] = await Promise.all([
      Branch.find({ shopId: shop._id }).sort({ isMainBranch: -1, createdAt: 1 }),
      UserRole.find({ shopId: shop._id, status: 'ACTIVE' })
        .populate('userId', 'fullName email phone status')
        .populate('roleId', 'name slug'),
      PaymentReminder.find({ shopId: shop._id }).sort({ createdAt: -1 }).limit(20)
    ]);

    res.status(200).json({
      shop,
      branches,
      users: userRoles,
      reminders
    });
  } catch (err) {
    next(err);
  }
};

// POST /api/shops – create a new shop (supports 5-step registration wizard)
exports.createShop = async (req, res, next) => {
  try {
    const {
      name,
      shopName,
      shopType,
      logoUrl,
      email,
      phone,
      address,
      city,
      country,
      owner,
      ownerName,
      ownerUsername,
      ownerEmail,
      ownerPhone,
      password,
      plan,
      billingCycle,
      isTrial,
      startDate,
      expiresAt,
      discount,
      initialPayment,
      branches,
      branchName,
      branchCode,
      branchAddress,
      branchPhone,
      ownerId
    } = req.body;

    const resolvedName = (name || shopName || '').trim();
    if (!resolvedName) {
      return res.status(400).json({ success: false, message: 'Shop name is required.' });
    }

    let resolvedOwnerId = ownerId;
    let ownerDoc = null;
    const resolvedOwnerEmail = (ownerEmail || email || `owner@${resolvedName.toLowerCase().replace(/[^a-z0-9]/g, '')}.com`)
      .trim()
      .toLowerCase();

    if (!resolvedOwnerId) {
      ownerDoc = await User.findOne({ email: resolvedOwnerEmail });
      if (!ownerDoc) {
        const baseUsername = (ownerUsername || resolvedOwnerEmail.split('@')[0]).replace(/[^a-z0-9_]/g, '').toLowerCase() || 'owner';
        const existingUsername = await User.findOne({ username: baseUsername });
        const username = existingUsername ? `${baseUsername}_${Date.now().toString().slice(-4)}` : baseUsername;
        const passwordHash = await User.hashPassword(password || 'Pass@123');
        ownerDoc = await User.create({
          fullName: (owner || ownerName || 'Shop Owner').trim(),
          email: resolvedOwnerEmail,
          username,
          phone: (ownerPhone || phone || '').trim(),
          passwordHash,
          status: 'ACTIVE'
        });
      }
      resolvedOwnerId = ownerDoc._id;
    } else {
      ownerDoc = await User.findById(resolvedOwnerId);
    }

    const normalizedPlan = (plan || 'STANDARD').toString().toUpperCase();
    const planDoc = await Plan.findOne({ slug: normalizedPlan });
    const maxBranches = Number(branches) || planDoc?.maxBranches || DEFAULT_BRANCH_BY_PLAN[normalizedPlan] || 1;
    const maxUsers = planDoc?.maxUsers || 5;
    const maxPosTerminals = planDoc?.maxPosTerminals || 1;

    const suffix = Date.now().toString().slice(-4);
    const codePrefix = resolvedName.replace(/[^A-Za-z0-9]/g, '').toUpperCase().slice(0, 4) || 'SHOP';
    const code = `${codePrefix}${suffix}`;
    const tenantId = `TNT-${codePrefix}-${suffix}`;

    const start = startDate ? new Date(startDate) : new Date();
    const defaultDays = isTrial || normalizedPlan === 'TRIAL' ? 30 : (billingCycle === 'YEARLY' ? 365 : 30);
    const expiry = expiresAt ? new Date(expiresAt) : new Date(start.getTime() + defaultDays * 86400000);

    const shop = await Shop.create({
      tenantId,
      name: resolvedName,
      code,
      shopType: (shopType || 'Retail').trim(),
      logoUrl: (logoUrl || '').trim(),
      email: (email || resolvedOwnerEmail).trim().toLowerCase(),
      phone: (phone || ownerPhone || '').trim(),
      address: (address || branchAddress || '').trim(),
      city: (city || '').trim(),
      country: (country || 'Pakistan').trim(),
      ownerId: resolvedOwnerId,
      subscription: {
        plan: normalizedPlan,
        status: isTrial || normalizedPlan === 'TRIAL' ? 'TRIAL' : 'ACTIVE',
        billingCycle: (billingCycle || 'MONTHLY').toUpperCase() === 'YEARLY' ? 'YEARLY' : 'MONTHLY',
        startDate: start,
        expiresAt: expiry,
        discount: Number(discount) || 0,
        initialPayment: Number(initialPayment) || 0,
        maxBranches,
        maxUsers,
        maxPosTerminals
      },
      isActive: true
    });

    if (ownerDoc && !ownerDoc.defaultShopId) {
      ownerDoc.defaultShopId = shop._id;
      await ownerDoc.save();
    }

    // Create default Main Branch
    await Branch.create({
      shopId: shop._id,
      name: (branchName || 'Main Branch').trim(),
      code: (branchCode || 'BR-001').trim().toUpperCase(),
      city: (city || '').trim(),
      address: (branchAddress || address || '').trim(),
      managerId: resolvedOwnerId,
      isMainBranch: true,
      isActive: true
    });

    // Assign shop_owner role if RBAC role exists
    const ownerRole = await Role.findOne({ slug: 'shop_owner', shopId: null });
    if (ownerRole) {
      await UserRole.findOneAndUpdate(
        { userId: resolvedOwnerId, shopId: shop._id, roleId: ownerRole._id },
        { userId: resolvedOwnerId, shopId: shop._id, roleId: ownerRole._id, status: 'ACTIVE' },
        { upsert: true, new: true }
      );
    }

    // Create initial Subscription record
    await Subscription.create({
      shopId: shop._id,
      planSlug: normalizedPlan,
      planName: planDoc?.name || normalizedPlan,
      billingCycle: shop.subscription.billingCycle,
      startDate: start,
      expiresAt: expiry,
      amount: Number(initialPayment) || (shop.subscription.billingCycle === 'YEARLY' ? (planDoc?.yearlyPrice || 0) : (planDoc?.monthlyPrice || 0)),
      discount: Number(discount) || 0,
      paymentStatus: (isTrial || normalizedPlan === 'TRIAL') ? 'PAID' : ((Number(initialPayment) || 0) > 0 ? 'PAID' : 'PENDING'),
      status: shop.subscription.status
    });

    // Log welcome notification
    await PaymentReminder.create({
      shopId: shop._id,
      shopName: shop.name,
      ownerName: ownerDoc?.fullName || owner || 'Shop Owner',
      channel: 'EMAIL',
      recipient: shop.email || resolvedOwnerEmail,
      subject: `Welcome to Next Planners POS - ${shop.name}`,
      message: `Your tenant account (${tenantId}) has been provisioned on the ${normalizedPlan} plan.`,
      status: 'SENT'
    });

    const populated = await Shop.findById(shop._id).populate('ownerId', 'fullName username email phone');
    res.status(201).json(populated);
  } catch (err) {
    next(err);
  }
};

// PUT /api/shops/:id – edit shop & owner contact info
exports.updateShop = async (req, res, next) => {
  try {
    const shop = await Shop.findById(req.params.id);
    if (!shop) {
      return res.status(404).json({ success: false, message: 'Shop not found.' });
    }

    const { shopName, name, shopType, email, phone, address, city, country, owner } = req.body;
    if (shopName || name) shop.name = (shopName || name).trim();
    if (shopType !== undefined) shop.shopType = String(shopType).trim();
    if (email !== undefined) shop.email = String(email).trim().toLowerCase();
    if (phone !== undefined) shop.phone = String(phone).trim();
    if (address !== undefined) shop.address = String(address).trim();
    if (city !== undefined) shop.city = String(city).trim();
    if (country !== undefined) shop.country = String(country).trim();
    await shop.save();

    if (owner && shop.ownerId) {
      await User.findByIdAndUpdate(shop.ownerId, { fullName: String(owner).trim() });
    }

    const populated = await Shop.findById(shop._id).populate('ownerId', 'fullName username email phone');
    res.status(200).json(populated);
  } catch (err) {
    next(err);
  }
};

// PATCH /api/shops/:id/status – toggle or set shop active status
exports.updateShopStatus = async (req, res, next) => {
  try {
    const { id } = req.params;
    const shop = await Shop.findById(id);
    if (!shop) {
      return res.status(404).json({ success: false, message: 'Shop not found.' });
    }

    const nextActive = typeof req.body.isActive === 'boolean' ? req.body.isActive : !shop.isActive;
    shop.isActive = nextActive;
    if (shop.subscription) {
      shop.subscription.status = nextActive ? 'ACTIVE' : 'SUSPENDED';
    }
    await shop.save();

    const populated = await Shop.findById(shop._id).populate('ownerId', 'fullName username email phone');
    res.status(200).json(populated);
  } catch (err) {
    next(err);
  }
};

// PATCH /api/shops/:id/plan – update a shop's subscription plan, branches & expiry
exports.updateShopPlan = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { plan, branches, billingCycle, extendDays } = req.body;
    const shop = await Shop.findById(id);
    if (!shop) {
      return res.status(404).json({ success: false, message: 'Shop not found.' });
    }

    const normalizedPlan = (plan || shop.subscription?.plan || 'STANDARD').toString().toUpperCase();
    const planDoc = await Plan.findOne({ slug: normalizedPlan });
    const maxBranches = Number(branches) || planDoc?.maxBranches || DEFAULT_BRANCH_BY_PLAN[normalizedPlan] || 1;

    const currentExpiry = shop.subscription?.expiresAt ? new Date(shop.subscription.expiresAt) : new Date();
    const nextExpiry = extendDays ? new Date(currentExpiry.getTime() + Number(extendDays) * 86400000) : currentExpiry;

    shop.subscription = {
      ...(shop.subscription?.toObject ? shop.subscription.toObject() : shop.subscription || {}),
      plan: normalizedPlan,
      maxBranches,
      maxUsers: planDoc?.maxUsers || shop.subscription?.maxUsers || 5,
      billingCycle: billingCycle ? String(billingCycle).toUpperCase() : (shop.subscription?.billingCycle || 'MONTHLY'),
      expiresAt: nextExpiry
    };
    await shop.save();

    const populated = await Shop.findById(shop._id).populate('ownerId', 'fullName username email phone');
    res.status(200).json(populated);
  } catch (err) {
    next(err);
  }
};

// PATCH /api/shops/:id/reset-password – reset shop owner's password
exports.resetOwnerPassword = async (req, res, next) => {
  try {
    const { newPassword } = req.body;
    if (!newPassword || String(newPassword).length < 6) {
      return res.status(400).json({ success: false, message: 'New password must be at least 6 characters.' });
    }

    const shop = await Shop.findById(req.params.id);
    if (!shop || !shop.ownerId) {
      return res.status(404).json({ success: false, message: 'Shop or owner not found.' });
    }

    const passwordHash = await User.hashPassword(String(newPassword));
    await User.findByIdAndUpdate(shop.ownerId, { passwordHash });

    res.status(200).json({ success: true, message: 'Owner password reset successfully.' });
  } catch (err) {
    next(err);
  }
};

// DELETE /api/shops/:id – delete a shop and its branches/reminders
exports.deleteShop = async (req, res, next) => {
  try {
    const shop = await Shop.findById(req.params.id);
    if (!shop) {
      return res.status(404).json({ success: false, message: 'Shop not found.' });
    }

    await Promise.all([
      Branch.deleteMany({ shopId: shop._id }),
      UserRole.deleteMany({ shopId: shop._id }),
      PaymentReminder.deleteMany({ shopId: shop._id }),
      Shop.findByIdAndDelete(shop._id)
    ]);

    res.status(200).json({ success: true, message: `Shop "${shop.name}" deleted.` });
  } catch (err) {
    next(err);
  }
};

// POST /api/shops/:id/reminder – send/log a payment reminder (Email / SMS / WhatsApp)
exports.sendPaymentReminder = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { channel, recipient, subject, message } = req.body;
    const shop = await Shop.findById(id).populate('ownerId', 'fullName email phone');
    if (!shop) {
      return res.status(404).json({ success: false, message: 'Shop not found.' });
    }

    const resolvedChannel = ['EMAIL', 'SMS', 'WHATSAPP'].includes((channel || '').toUpperCase())
      ? channel.toUpperCase()
      : 'EMAIL';
    const resolvedRecipient = (recipient || (resolvedChannel === 'EMAIL' ? shop.ownerId?.email : shop.ownerId?.phone) || '').trim();
    if (!resolvedRecipient) {
      return res.status(400).json({ success: false, message: 'Recipient email or phone is required.' });
    }

    const emailService = require('../services/email.service');
    let deliveryStatus = 'SENT';
    let deliveryNote = '';
    let whatsappUrl = '';

    const resolvedSubject = (subject || `Payment Reminder - ${shop.name}`).trim();
    const resolvedMessage = (message || `Dear ${shop.ownerId?.fullName || 'Owner'}, your subscription payment for ${shop.name} is due. Please clear it at your earliest convenience.`).trim();

    if (resolvedChannel === 'EMAIL') {
      try {
        const result = await emailService.sendPaymentReminderEmail({
          to: resolvedRecipient,
          shopName: shop.name,
          ownerName: shop.ownerId?.fullName || 'Shop Owner',
          planName: shop.subscription?.plan || 'STANDARD',
          subject: resolvedSubject,
          message: resolvedMessage,
        });
        if (!result.sent) {
          deliveryStatus = 'QUEUED';
          deliveryNote = result.reason || 'SMTP not configured';
        }
      } catch (mailErr) {
        deliveryStatus = 'FAILED';
        deliveryNote = mailErr.message;
      }
    } else if (resolvedChannel === 'WHATSAPP') {
      const cleanPhone = resolvedRecipient.replace(/[^0-9]/g, '');
      const formattedText = `*NPTS Payment Reminder - ${shop.name}*\nPlan: ${shop.subscription?.plan || 'STANDARD'}\n\n${resolvedMessage}`;
      whatsappUrl = `https://wa.me/${cleanPhone}?text=${encodeURIComponent(formattedText)}`;
    }

    const reminder = await PaymentReminder.create({
      shopId: shop._id,
      shopName: shop.name,
      ownerName: shop.ownerId?.fullName || 'Shop Owner',
      channel: resolvedChannel,
      recipient: resolvedRecipient,
      subject: resolvedSubject,
      message: resolvedMessage,
      status: deliveryStatus
    });

    res.status(201).json({
      ...reminder.toObject(),
      deliveryNote,
      whatsappUrl
    });
  } catch (err) {
    next(err);
  }
};

// GET /api/shops/reminders – list recent payment reminders
exports.getReminders = async (req, res, next) => {
  try {
    const reminders = await PaymentReminder.find().sort({ createdAt: -1 }).limit(50);
    res.status(200).json(reminders);
  } catch (err) {
    next(err);
  }
};

// POST /api/shops/:id/impersonate – audited Login as Shop Admin
exports.impersonateShopAdmin = async (req, res, next) => {
  try {
    const jwt = require('jsonwebtoken');
    const { JWT_SECRET } = require('../middleware/auth.middleware');
    const shop = await Shop.findById(req.params.id).populate('ownerId', 'fullName email phone username');
    if (!shop) {
      return res.status(404).json({ success: false, message: 'Shop not found.' });
    }
    if (!shop.ownerId) {
      return res.status(400).json({ success: false, message: 'Shop has no assigned owner account.' });
    }

    await AuditLog.create({
      shopId: shop._id,
      userId: shop.ownerId._id,
      action: 'LOGIN_AS_SHOP_ADMIN',
      module: 'SUPER_ADMIN',
      recordId: String(shop._id),
      newValues: { shopName: shop.name, tenantId: shop.tenantId || shop.code },
      ipAddress: req.ip || ''
    });

    const token = jwt.sign(
      {
        userId: shop.ownerId._id,
        shopId: shop._id,
        isPlatformUser: false,
        impersonatedBy: req.user?._id || 'super_admin'
      },
      JWT_SECRET,
      { expiresIn: '4h' }
    );

    res.status(200).json({
      success: true,
      token,
      shopId: shop._id,
      tenantId: shop.tenantId || shop.code,
      shopName: shop.name,
      owner: shop.ownerId
    });
  } catch (err) {
    next(err);
  }
};
