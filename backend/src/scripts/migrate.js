const { sequelize } = require('../config/database');
const models = require('../models');

const migrate = async () => {
  try {
    console.log('🔄 Starting database migration...');

    console.log('✅ Database connection established');

    console.log('👤 Syncing User model...');

    
    await sequelize.authenticate();
    console.log('✅ Database connection established');

    // Sync all models
    await sequelize.sync({ force: true });
    console.log('✅ All models synchronized successfully');

    console.log('✨ Migration completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Migration failed:', error);
    process.exit(1);
  }
};

migrate();
