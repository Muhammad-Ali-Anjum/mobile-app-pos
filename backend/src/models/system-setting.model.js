const mongoose = require('mongoose');

const systemSettingSchema = new mongoose.Schema(
  {
    key: { type: String, unique: true, default: 'GLOBAL' },
    platformName: { type: String, default: 'Next Planners POS' },
    supportEmail: { type: String, default: 'support@nextplanners.com' },
    supportPhone: { type: String, default: '+92 300 9999999' },
    companyAddress: { type: String, default: 'Main Bazar, Skardu' },
    defaultCurrency: { type: String, default: 'PKR' },
    defaultBillingCycle: { type: String, default: 'MONTHLY' },
    trialDurationDays: { type: Number, default: 30 },
    gracePeriodDays: { type: Number, default: 3 },
    autoSuspendExpired: { type: Boolean, default: true },
    twoFactorRequired: { type: Boolean, default: false },
    maintenanceMode: { type: Boolean, default: false },
    lastBackupAt: { type: Date, default: null }
  },
  { timestamps: true }
);

module.exports = mongoose.model('SystemSetting', systemSettingSchema);
