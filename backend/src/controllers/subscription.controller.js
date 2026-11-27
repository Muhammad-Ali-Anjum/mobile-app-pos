const Subscription = require('../models/subscription.model');
const Shop = require('../models/shop.model');
const Plan = require('../models/plan.model');

async function syncShopSubscription(shopId, subDoc, planDoc) {
  const shop = await Shop.findById(shopId);
  if (!shop) return;

  shop.subscription = {
    ...(shop.subscription?.toObject ? shop.subscription.toObject() : shop.subscription || {}),
    plan: subDoc.planSlug,
    status: subDoc.status,
    billingCycle: subDoc.billingCycle,
    startDate: subDoc.startDate,
    expiresAt: subDoc.expiresAt,
    discount: subDoc.discount,
    maxBranches: planDoc?.maxBranches ?? shop.subscription?.maxBranches ?? 1,
    maxUsers: planDoc?.maxUsers ?? shop.subscription?.maxUsers ?? 5,
    maxPosTerminals: planDoc?.maxPosTerminals ?? shop.subscription?.maxPosTerminals ?? 1
  };
  shop.isActive = subDoc.status === 'ACTIVE' || subDoc.status === 'TRIAL';
  await shop.save();
}

// GET /api/subscriptions
exports.getSubscriptions = async (req, res, next) => {
  try {
    const filter = {};
    if (req.query.status && req.query.status !== 'ALL') {
      filter.status = String(req.query.status).toUpperCase();
    }
    const list = await Subscription.find(filter)
      .populate('shopId', 'name tenantId code shopType')
      .sort({ createdAt: -1 });
    res.status(200).json(list);
  } catch (err) {
    next(err);
  }
};

// GET /api/subscriptions/shop/:shopId
exports.getShopSubscriptions = async (req, res, next) => {
  try {
    const list = await Subscription.find({ shopId: req.params.shopId }).sort({ createdAt: -1 });
    res.status(200).json(list);
  } catch (err) {
    next(err);
  }
};

// POST /api/subscriptions
exports.assignSubscription = async (req, res, next) => {
  try {
    const {
      shopId,
      planSlug = 'STANDARD',
      billingCycle = 'MONTHLY',
      discount = 0,
      paymentStatus = 'PAID',
      status = 'ACTIVE',
      autoRenew = true,
      gracePeriodDays = 3,
      notes = ''
    } = req.body;

    if (!shopId) {
      return res.status(400).json({ success: false, message: 'shopId is required.' });
    }

    const planDoc = await Plan.findOne({ slug: String(planSlug).toUpperCase() });
    const startDate = new Date();
    const days = status === 'TRIAL' ? (planDoc?.trialDays || 30) : (billingCycle === 'YEARLY' ? 365 : 30);
    const expiresAt = new Date(startDate.getTime() + days * 86400000);
    const basePrice = billingCycle === 'YEARLY' ? (planDoc?.yearlyPrice || (planDoc?.monthlyPrice || 0) * 12) : (planDoc?.monthlyPrice || 0);

    const sub = await Subscription.create({
      shopId,
      planSlug: String(planSlug).toUpperCase(),
      planName: planDoc?.name || String(planSlug).toUpperCase(),
      billingCycle: String(billingCycle).toUpperCase(),
      startDate,
      expiresAt,
      amount: Math.max(0, basePrice - Number(discount)),
      discount: Number(discount),
      paymentStatus: String(paymentStatus).toUpperCase(),
      status: String(status).toUpperCase(),
      autoRenew: Boolean(autoRenew),
      gracePeriodDays: Number(gracePeriodDays),
      notes: String(notes).trim()
    });

    await syncShopSubscription(shopId, sub, planDoc);
    const populated = await Subscription.findById(sub._id).populate('shopId', 'name tenantId code shopType');
    res.status(201).json(populated);
  } catch (err) {
    next(err);
  }
};

// PATCH /api/subscriptions/:id/lifecycle
exports.updateLifecycle = async (req, res, next) => {
  try {
    const sub = await Subscription.findById(req.params.id);
    if (!sub) {
      return res.status(404).json({ success: false, message: 'Subscription not found.' });
    }

    const { action, planSlug, billingCycle, extendDays, discount, autoRenew, gracePeriodDays } = req.body;
    const act = String(action || '').toUpperCase();
    let planDoc = await Plan.findOne({ slug: sub.planSlug });

    switch (act) {
      case 'UPGRADE':
      case 'DOWNGRADE':
      case 'CHANGE_PLAN':
        if (planSlug) {
          sub.planSlug = String(planSlug).toUpperCase();
          planDoc = await Plan.findOne({ slug: sub.planSlug });
          sub.planName = planDoc?.name || sub.planSlug;
          const base = sub.billingCycle === 'YEARLY' ? (planDoc?.yearlyPrice || 0) : (planDoc?.monthlyPrice || 0);
          sub.amount = Math.max(0, base - (sub.discount || 0));
        }
        break;
      case 'RENEW': {
        const days = sub.billingCycle === 'YEARLY' ? 365 : 30;
        const baseDate = sub.expiresAt && sub.expiresAt > new Date() ? sub.expiresAt : new Date();
        sub.expiresAt = new Date(baseDate.getTime() + days * 86400000);
        sub.status = 'ACTIVE';
        sub.paymentStatus = 'PAID';
        break;
      }
      case 'EXTEND': {
        const extra = Number(extendDays) || 30;
        const baseDate = sub.expiresAt || new Date();
        sub.expiresAt = new Date(baseDate.getTime() + extra * 86400000);
        if (sub.status === 'EXPIRED') sub.status = 'ACTIVE';
        break;
      }
      case 'SUSPEND':
        sub.status = 'SUSPENDED';
        break;
      case 'ACTIVATE':
        sub.status = 'ACTIVE';
        break;
      case 'CANCEL':
        sub.status = 'CANCELLED';
        sub.autoRenew = false;
        break;
      case 'APPLY_DISCOUNT':
        sub.discount = Number(discount) || 0;
        if (planDoc) {
          const base = sub.billingCycle === 'YEARLY' ? (planDoc.yearlyPrice || 0) : (planDoc.monthlyPrice || 0);
          sub.amount = Math.max(0, base - sub.discount);
        }
        break;
      case 'CHANGE_CYCLE':
        sub.billingCycle = String(billingCycle || 'MONTHLY').toUpperCase();
        if (planDoc) {
          const base = sub.billingCycle === 'YEARLY' ? (planDoc.yearlyPrice || 0) : (planDoc.monthlyPrice || 0);
          sub.amount = Math.max(0, base - (sub.discount || 0));
        }
        break;
      default:
        if (autoRenew !== undefined) sub.autoRenew = Boolean(autoRenew);
        if (gracePeriodDays !== undefined) sub.gracePeriodDays = Number(gracePeriodDays);
    }

    await sub.save();
    await syncShopSubscription(sub.shopId, sub, planDoc);

    const populated = await Subscription.findById(sub._id).populate('shopId', 'name tenantId code shopType');
    res.status(200).json(populated);
  } catch (err) {
    next(err);
  }
};
