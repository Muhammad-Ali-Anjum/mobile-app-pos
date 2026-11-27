require('dotenv').config();
const mongoose = require('mongoose');
const app = require('./app');
const seedRBAC = require('./seeds/seed-rbac');

const PORT = process.env.PORT || 5002;
const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/next_planners_pos';

mongoose
  .connect(MONGO_URI)
  .then(async () => {
    console.log('MongoDB connected successfully for Next Planners POS.');
    // Seed RBAC catalogs if needed
    if (process.env.AUTO_SEED === 'true') {
      await seedRBAC();
    }

    // Ensure default Super Admin exists in MongoDB
    try {
      const { User, SystemSetting, Subscription, Shop } = require('./models');
      const existingAdmin = await User.findOne({ email: 'superadmin@nextplanners.com' });
      if (!existingAdmin) {
        const passwordHash = await User.hashPassword('admin123');
        await User.create({
          fullName: 'Super Admin',
          username: 'superadmin',
          email: 'superadmin@nextplanners.com',
          passwordHash,
          isPlatformUser: true,
          platformRole: 'super_admin',
          permissions: ['*'],
          status: 'ACTIVE'
        });
        console.log('Seeded default Super Admin: superadmin@nextplanners.com');
      } else if (!existingAdmin.passwordHash) {
        existingAdmin.passwordHash = await User.hashPassword('admin123');
        existingAdmin.isPlatformUser = true;
        existingAdmin.platformRole = 'super_admin';
        await existingAdmin.save();
      }

      // Subscription expiry auto-suspend check (runs on startup and every 12 hours)
      const checkExpiredSubscriptions = async () => {
        try {
          const settings = await SystemSetting.findOne();
          if (!settings || settings.autoSuspendExpired !== false) {
            const now = new Date();
            const expiredSubs = await Subscription.find({
              status: { $in: ['ACTIVE', 'TRIAL'] },
              expiresAt: { $lt: now }
            });
            for (const sub of expiredSubs) {
              const graceDays = sub.gracePeriodDays || 3;
              const graceEnd = new Date(sub.expiresAt.getTime() + graceDays * 86400000);
              if (now > graceEnd) {
                sub.status = 'EXPIRED';
                await sub.save();
                await Shop.findByIdAndUpdate(sub.shopId, {
                  isActive: false,
                  'subscription.status': 'EXPIRED'
                });
              }
            }
          }
        } catch (err) {
          console.error('Subscription expiry job error:', err.message);
        }
      };
      checkExpiredSubscriptions();
      setInterval(checkExpiredSubscriptions, 12 * 60 * 60 * 1000);
    } catch (seedErr) {
      console.error('Startup seed/job error:', seedErr.message);
    }

    app.listen(PORT, () => {
      console.log(`Next Planners POS Backend running on port ${PORT}`);
    });
  })
  .catch((err) => {
    console.error('Database connection failed:', err);
    process.exit(1);
  });
