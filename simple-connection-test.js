const { PrismaClient } = require('@prisma/client');

// Create Prisma client instance
const prisma = new PrismaClient();

async function simpleConnectionTest() {
  try {
    console.log('🔌 Testing basic database connection...');

    // Test connection
    await prisma.$connect();
    console.log('✅ Database connection successful!');

    // Check database info
    console.log('\n📊 Database Information:');
    const result =
      await prisma.$queryRaw`SELECT DATABASE() as current_db, VERSION() as mysql_version`;
    console.log('Current database:', result[0].current_db);
    console.log('MySQL version:', result[0].mysql_version);

    // Check if our tables exist
    console.log('\n📋 Checking for Prisma tables...');
    const tables = await prisma.$queryRaw`
      SELECT TABLE_NAME
      FROM information_schema.TABLES
      WHERE TABLE_SCHEMA = 'inspection_app'
      AND TABLE_NAME IN ('users', 'inspections', 'inspection_items')
    `;

    if (tables.length === 0) {
      console.log(
        '⚠️  No Prisma tables found. You may need to run: npx prisma db push'
      );
    } else {
      console.log(
        '✅ Found tables:',
        tables.map(t => t.TABLE_NAME)
      );
    }

    console.log('\n🎉 Connection test completed successfully!');
  } catch (error) {
    console.error('\n❌ Connection test failed:', error.message);

    if (error.code === 'ECONNREFUSED') {
      console.error(
        '💡 Make sure MySQL is running and accessible on localhost:3306'
      );
    } else if (error.code === 'P1001') {
      console.error(
        '💡 Check your database credentials and make sure the database exists'
      );
    } else if (error.code === 'P2002') {
      console.error(
        '💡 Database connection successful but there might be schema issues'
      );
    }

    console.error('\n🔍 Full error:', error);
  } finally {
    await prisma.$disconnect();
    console.log('\n🔌 Disconnected from database');
  }
}

// Run the test
console.log('🚀 Starting Simple Connection Test...\n');
simpleConnectionTest()
  .then(() => {
    console.log('\n✨ Test completed!');
    process.exit(0);
  })
  .catch(error => {
    console.error('\n💥 Test failed with unhandled error:', error);
    process.exit(1);
  });
