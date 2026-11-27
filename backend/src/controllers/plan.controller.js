const Plan = require('../models/plan.model');

const DEFAULT_PLANS = [
  {
    slug: 'BASIC',
    name: 'Basic Retail',
    monthlyPrice: 2500,
    yearlyPrice: 25000,
    maxBranches: 1,
    maxUsers: 3,
    maxPosTerminals: 1,
    maxProducts: 1000,
    storageLimitMb: 500,
    trialDays: 0,
    dedicatedSupport: false,
    features: { inventory: true, barcode: true, reports: true, multiBranch: false },
    isActive: true,
    description: '1 Branch • 3 Users • 1 POS Terminal'
  },
  {
    slug: 'STANDARD',
    name: 'Standard Multi-Branch',
    monthlyPrice: 5000,
    yearlyPrice: 50000,
    maxBranches: 3,
    maxUsers: 10,
    maxPosTerminals: 3,
    maxProducts: 5000,
    storageLimitMb: 2048,
    trialDays: 0,
    dedicatedSupport: false,
    features: { inventory: true, barcode: true, reports: true, multiBranch: true },
    isActive: true,
    description: '3 Branches • 10 Users • 3 POS Terminals'
  },
  {
    slug: 'PREMIUM',
    name: 'Premium Enterprise',
    monthlyPrice: 10000,
    yearlyPrice: 100000,
    maxBranches: 999,
    maxUsers: 50,
    maxPosTerminals: 20,
    maxProducts: 50000,
    storageLimitMb: 10240,
    trialDays: 0,
    dedicatedSupport: true,
    features: { inventory: true, barcode: true, reports: true, multiBranch: true },
    isActive: true,
    description: 'Unlimited Branches • 50 Users • Dedicated Support'
  },
  {
    slug: 'TRIAL',
    name: 'Trial Plan',
    monthlyPrice: 0,
    yearlyPrice: 0,
    maxBranches: 1,
    maxUsers: 2,
    maxPosTerminals: 1,
    maxProducts: 250,
    storageLimitMb: 250,
    trialDays: 30,
    dedicatedSupport: false,
    features: { inventory: true, barcode: true, reports: false, multiBranch: false },
    isActive: true,
    description: '1 Branch • 2 Users • Core POS Only (30 Days)'
  }
];

async function ensureDefaultPlans() {
  const count = await Plan.countDocuments();
  if (count === 0) {
    await Plan.insertMany(DEFAULT_PLANS);
  }
}

// GET /api/plans
exports.getPlans = async (req, res, next) => {
  try {
    await ensureDefaultPlans();
    const plans = await Plan.find().sort({ monthlyPrice: 1 });
    res.status(200).json(plans);
  } catch (err) {
    next(err);
  }
};

// POST /api/plans
exports.createPlan = async (req, res, next) => {
  try {
    await ensureDefaultPlans();
    const {
      slug,
      name,
      monthlyPrice = 0,
      yearlyPrice = 0,
      maxBranches = 1,
      maxUsers = 3,
      maxPosTerminals = 1,
      maxProducts = 1000,
      storageLimitMb = 500,
      trialDays = 0,
      dedicatedSupport = false,
      features = {},
      description = '',
      isActive = true
    } = req.body;

    if (!name || !String(name).trim()) {
      return res.status(400).json({ success: false, message: 'Plan name is required.' });
    }

    const resolvedSlug = (slug || String(name).replace(/[^A-Za-z0-9]/g, '_')).toUpperCase().slice(0, 24);
    const existing = await Plan.findOne({ slug: resolvedSlug });
    if (existing) {
      return res.status(409).json({ success: false, message: `Plan slug "${resolvedSlug}" already exists.` });
    }

    const plan = await Plan.create({
      slug: resolvedSlug,
      name: String(name).trim(),
      monthlyPrice: Number(monthlyPrice),
      yearlyPrice: Number(yearlyPrice),
      maxBranches: Number(maxBranches),
      maxUsers: Number(maxUsers),
      maxPosTerminals: Number(maxPosTerminals),
      maxProducts: Number(maxProducts),
      storageLimitMb: Number(storageLimitMb),
      trialDays: Number(trialDays),
      dedicatedSupport: Boolean(dedicatedSupport),
      features: {
        inventory: features.inventory !== false,
        barcode: features.barcode !== false,
        reports: features.reports !== false,
        multiBranch: Boolean(features.multiBranch)
      },
      isActive: Boolean(isActive),
      description: String(description).trim()
    });

    res.status(201).json(plan);
  } catch (err) {
    next(err);
  }
};

// PATCH /api/plans/:slug
exports.updatePlan = async (req, res, next) => {
  try {
    await ensureDefaultPlans();
    const slug = req.params.slug.toUpperCase();
    const plan = await Plan.findOne({ slug });
    if (!plan) {
      return res.status(404).json({ success: false, message: 'Plan not found.' });
    }

    const {
      name,
      monthlyPrice,
      yearlyPrice,
      maxBranches,
      maxUsers,
      maxPosTerminals,
      maxProducts,
      storageLimitMb,
      trialDays,
      dedicatedSupport,
      features,
      isActive,
      description
    } = req.body;

    if (name !== undefined) plan.name = String(name).trim();
    if (monthlyPrice !== undefined) plan.monthlyPrice = Number(monthlyPrice);
    if (yearlyPrice !== undefined) plan.yearlyPrice = Number(yearlyPrice);
    if (maxBranches !== undefined) plan.maxBranches = Number(maxBranches);
    if (maxUsers !== undefined) plan.maxUsers = Number(maxUsers);
    if (maxPosTerminals !== undefined) plan.maxPosTerminals = Number(maxPosTerminals);
    if (maxProducts !== undefined) plan.maxProducts = Number(maxProducts);
    if (storageLimitMb !== undefined) plan.storageLimitMb = Number(storageLimitMb);
    if (trialDays !== undefined) plan.trialDays = Number(trialDays);
    if (dedicatedSupport !== undefined) plan.dedicatedSupport = Boolean(dedicatedSupport);
    if (isActive !== undefined) plan.isActive = Boolean(isActive);
    if (description !== undefined) plan.description = String(description).trim();
    if (features && typeof features === 'object') {
      plan.features = {
        inventory: features.inventory ?? plan.features?.inventory ?? true,
        barcode: features.barcode ?? plan.features?.barcode ?? true,
        reports: features.reports ?? plan.features?.reports ?? true,
        multiBranch: features.multiBranch ?? plan.features?.multiBranch ?? false
      };
    }

    await plan.save();
    res.status(200).json(plan);
  } catch (err) {
    next(err);
  }
};

// POST /api/plans/:slug/duplicate
exports.duplicatePlan = async (req, res, next) => {
  try {
    const source = await Plan.findOne({ slug: req.params.slug.toUpperCase() });
    if (!source) {
      return res.status(404).json({ success: false, message: 'Source plan not found.' });
    }

    const newSlug = `${source.slug}_COPY_${Date.now().toString().slice(-4)}`;
    const copy = await Plan.create({
      slug: newSlug,
      name: `${source.name} (Copy)`,
      monthlyPrice: source.monthlyPrice,
      yearlyPrice: source.yearlyPrice,
      maxBranches: source.maxBranches,
      maxUsers: source.maxUsers,
      maxPosTerminals: source.maxPosTerminals,
      maxProducts: source.maxProducts,
      storageLimitMb: source.storageLimitMb,
      trialDays: source.trialDays,
      dedicatedSupport: source.dedicatedSupport,
      features: source.features,
      isActive: true,
      description: source.description
    });

    res.status(201).json(copy);
  } catch (err) {
    next(err);
  }
};

// PATCH /api/plans/:slug/status
exports.togglePlanStatus = async (req, res, next) => {
  try {
    const plan = await Plan.findOne({ slug: req.params.slug.toUpperCase() });
    if (!plan) {
      return res.status(404).json({ success: false, message: 'Plan not found.' });
    }
    plan.isActive = typeof req.body.isActive === 'boolean' ? req.body.isActive : !plan.isActive;
    await plan.save();
    res.status(200).json(plan);
  } catch (err) {
    next(err);
  }
};
