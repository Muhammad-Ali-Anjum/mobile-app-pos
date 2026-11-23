require('dotenv').config();
const mongoose = require('mongoose');
const app = require('./app');
const seedRBAC = require('./seeds/seed-rbac');

const PORT = process.env.PORT || 5000;
const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/next_planners_pos';

mongoose
  .connect(MONGO_URI)
  .then(async () => {
    console.log('MongoDB connected successfully for Next Planners POS.');
    // Seed RBAC catalogs if needed
    if (process.env.AUTO_SEED === 'true') {
      await seedRBAC();
    }

    app.listen(PORT, () => {
      console.log(`Next Planners POS Backend running on port ${PORT}`);
    });
  })
  .catch((err) => {
    console.error('Database connection failed:', err);
    process.exit(1);
  });
