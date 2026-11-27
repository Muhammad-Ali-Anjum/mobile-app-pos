const Invoice = require('../models/invoice.model');
const Coupon = require('../models/coupon.model');
const Shop = require('../models/shop.model');

function computeStatus(netTotal, paidAmount) {
  if (paidAmount <= 0) return 'UNPAID';
  if (paidAmount >= netTotal) return 'PAID';
  return 'PARTIAL';
}

// GET /api/billing/invoices
exports.getInvoices = async (req, res, next) => {
  try {
    const filter = {};
    if (req.query.status && req.query.status !== 'ALL') {
      filter.paymentStatus = String(req.query.status).toUpperCase();
    }
    if (req.query.shopId) {
      filter.shopId = req.query.shopId;
    }
    const invoices = await Invoice.find(filter).sort({ createdAt: -1 });
    res.status(200).json(invoices);
  } catch (err) {
    next(err);
  }
};

// POST /api/billing/invoices
exports.createInvoice = async (req, res, next) => {
  try {
    const {
      shopId,
      planSlug = 'STANDARD',
      totalAmount = 0,
      discount = 0,
      paidAmount = 0,
      paymentMethod = 'BANK_TRANSFER',
      pendingVerification = false,
      notes = ''
    } = req.body;

    if (!shopId) {
      return res.status(400).json({ success: false, message: 'shopId is required.' });
    }
    const shop = await Shop.findById(shopId);
    if (!shop) {
      return res.status(404).json({ success: false, message: 'Shop not found.' });
    }

    const netTotal = Math.max(0, Number(totalAmount) - Number(discount));
    const paid = Math.max(0, Number(paidAmount));
    const remaining = Math.max(0, netTotal - paid);
    const status = pendingVerification ? 'PENDING_VERIFICATION' : computeStatus(netTotal, paid);
    const invoiceNumber = `INV-${new Date().getFullYear()}-${Date.now().toString().slice(-5)}`;

    const invoice = await Invoice.create({
      invoiceNumber,
      shopId: shop._id,
      shopName: shop.name,
      planSlug: String(planSlug).toUpperCase(),
      totalAmount: Number(totalAmount),
      discount: Number(discount),
      paidAmount: paid,
      remainingAmount: remaining,
      paymentMethod: String(paymentMethod).toUpperCase(),
      paymentStatus: status,
      paymentDate: paid > 0 ? new Date() : null,
      notes: String(notes).trim()
    });

    res.status(201).json(invoice);
  } catch (err) {
    next(err);
  }
};

// PATCH /api/billing/invoices/:id/pay
exports.recordPayment = async (req, res, next) => {
  try {
    const invoice = await Invoice.findById(req.params.id);
    if (!invoice) {
      return res.status(404).json({ success: false, message: 'Invoice not found.' });
    }

    const amount = Number(req.body.amount) || 0;
    const method = (req.body.paymentMethod || invoice.paymentMethod).toUpperCase();
    const netTotal = Math.max(0, invoice.totalAmount - invoice.discount);

    invoice.paidAmount = Math.min(netTotal, invoice.paidAmount + amount);
    invoice.remainingAmount = Math.max(0, netTotal - invoice.paidAmount);
    invoice.paymentMethod = method;
    invoice.paymentDate = new Date();
    invoice.paymentStatus = req.body.pendingVerification ? 'PENDING_VERIFICATION' : computeStatus(netTotal, invoice.paidAmount);

    await invoice.save();
    res.status(200).json(invoice);
  } catch (err) {
    next(err);
  }
};

// PATCH /api/billing/invoices/:id/verify
exports.verifyPayment = async (req, res, next) => {
  try {
    const invoice = await Invoice.findById(req.params.id);
    if (!invoice) {
      return res.status(404).json({ success: false, message: 'Invoice not found.' });
    }
    const netTotal = Math.max(0, invoice.totalAmount - invoice.discount);
    if (invoice.paidAmount <= 0) invoice.paidAmount = netTotal;
    invoice.remainingAmount = Math.max(0, netTotal - invoice.paidAmount);
    invoice.paymentStatus = computeStatus(netTotal, invoice.paidAmount);
    invoice.paymentDate = invoice.paymentDate || new Date();
    await invoice.save();
    res.status(200).json(invoice);
  } catch (err) {
    next(err);
  }
};

// PATCH /api/billing/invoices/:id/refund
exports.refundInvoice = async (req, res, next) => {
  try {
    const invoice = await Invoice.findById(req.params.id);
    if (!invoice) {
      return res.status(404).json({ success: false, message: 'Invoice not found.' });
    }
    invoice.paymentStatus = 'REFUNDED';
    invoice.paidAmount = 0;
    invoice.remainingAmount = 0;
    await invoice.save();
    res.status(200).json(invoice);
  } catch (err) {
    next(err);
  }
};

// GET /api/billing/reports
exports.getRevenueReports = async (req, res, next) => {
  try {
    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
    const startOfYear = new Date(now.getFullYear(), 0, 1);

    const all = await Invoice.find();
    let monthlyCollected = 0;
    let yearlyCollected = 0;
    let pendingDue = 0;

    for (const inv of all) {
      if (inv.paymentStatus !== 'REFUNDED') {
        pendingDue += inv.remainingAmount || 0;
        const dt = inv.paymentDate || inv.createdAt;
        if (dt >= startOfMonth) monthlyCollected += inv.paidAmount || 0;
        if (dt >= startOfYear) yearlyCollected += inv.paidAmount || 0;
      }
    }

    res.status(200).json({
      monthlyCollected,
      yearlyCollected,
      pendingDue,
      totalInvoices: all.length
    });
  } catch (err) {
    next(err);
  }
};

// Coupons
exports.getCoupons = async (req, res, next) => {
  try {
    const coupons = await Coupon.find().sort({ createdAt: -1 });
    res.status(200).json(coupons);
  } catch (err) {
    next(err);
  }
};

exports.createCoupon = async (req, res, next) => {
  try {
    const { code, discountType = 'PERCENTAGE', value = 10, usageLimit = 100, expiresAt, applicablePlans } = req.body;
    if (!code || !String(code).trim()) {
      return res.status(400).json({ success: false, message: 'Coupon code is required.' });
    }
    const coupon = await Coupon.create({
      code: String(code).trim().toUpperCase(),
      discountType: String(discountType).toUpperCase(),
      value: Number(value),
      usageLimit: Number(usageLimit),
      expiresAt: expiresAt ? new Date(expiresAt) : new Date(Date.now() + 30 * 86400000),
      applicablePlans: Array.isArray(applicablePlans) ? applicablePlans : ['BASIC', 'STANDARD', 'PREMIUM'],
      isActive: true
    });
    res.status(201).json(coupon);
  } catch (err) {
    next(err);
  }
};

exports.toggleCoupon = async (req, res, next) => {
  try {
    const coupon = await Coupon.findById(req.params.id);
    if (!coupon) return res.status(404).json({ success: false, message: 'Coupon not found.' });
    coupon.isActive = !coupon.isActive;
    await coupon.save();
    res.status(200).json(coupon);
  } catch (err) {
    next(err);
  }
};

exports.deleteCoupon = async (req, res, next) => {
  try {
    await Coupon.findByIdAndDelete(req.params.id);
    res.status(200).json({ success: true });
  } catch (err) {
    next(err);
  }
};
