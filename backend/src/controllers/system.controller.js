const SystemSetting = require('../models/system-setting.model');
const Shop = require('../models/shop.model');
const User = require('../models/user.model');
const Subscription = require('../models/subscription.model');
const Invoice = require('../models/invoice.model');
const Plan = require('../models/plan.model');

exports.getSettings = async (req, res, next) => {
  try {
    let settings = await SystemSetting.findOne({ key: 'GLOBAL' });
    if (!settings) {
      settings = await SystemSetting.create({ key: 'GLOBAL' });
    }
    res.status(200).json(settings);
  } catch (err) {
    next(err);
  }
};

exports.updateSettings = async (req, res, next) => {
  try {
    const settings = await SystemSetting.findOneAndUpdate(
      { key: 'GLOBAL' },
      { $set: req.body },
      { upsert: true, new: true }
    );
    res.status(200).json(settings);
  } catch (err) {
    next(err);
  }
};

exports.triggerBackup = async (req, res, next) => {
  try {
    const [shops, users, plans, subscriptions, invoices] = await Promise.all([
      Shop.countDocuments(),
      User.countDocuments(),
      Plan.countDocuments(),
      Subscription.countDocuments(),
      Invoice.countDocuments()
    ]);

    const now = new Date();
    await SystemSetting.findOneAndUpdate(
      { key: 'GLOBAL' },
      { $set: { lastBackupAt: now } },
      { upsert: true }
    );

    res.status(200).json({
      success: true,
      backupAt: now.toISOString(),
      counts: { shops, users, plans, subscriptions, invoices }
    });
  } catch (err) {
    next(err);
  }
};
