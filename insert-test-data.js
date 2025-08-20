const mysql = require('mysql2/promise');
const fs = require('fs');
require('dotenv').config({ path: './config.env' });

async function insertTestData() {
  let connection;

  try {
    // Create connection
    connection = await mysql.createConnection({
      host: process.env.DB_HOST,
      port: process.env.DB_PORT,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
      multipleStatements: true,
    });

    console.log('Connected to MySQL database');

    // Read the SQL file
    const sqlContent = fs.readFileSync('./test-data.sql', 'utf8');

    // Split by semicolons and filter out empty statements
    const statements = sqlContent
      .split(';')
      .map(stmt => stmt.trim())
      .filter(
        stmt =>
          stmt.length > 0 &&
          !stmt.startsWith('--') &&
          !stmt.startsWith(
            "SELECT 'Test data insertion completed successfully!'"
          )
      );

    console.log(`Executing ${statements.length} SQL statements...`);

    // Execute each statement
    for (let i = 0; i < statements.length; i++) {
      const statement = statements[i];
      if (statement.trim()) {
        try {
          await connection.execute(statement);
          console.log(
            `✓ Statement ${i + 1}/${statements.length} executed successfully`
          );
        } catch (error) {
          console.error(
            `✗ Error executing statement ${i + 1}:`,
            statement.substring(0, 100) + '...'
          );
          console.error('Error:', error.message);
          // Continue with next statement
        }
      }
    }

    console.log('\n🎉 Test data insertion completed!');
    console.log('\n📊 Summary of inserted data:');

    // Get counts of inserted data
    const tables = [
      'roles',
      'organizations',
      'users',
      'sites',
      'contracts',
      'device_models',
      'devices',
      'inspection_templates',
      'inspections',
      'inspection_answers',
      'attachments',
      'inspection_schedules',
      'audit_logs',
      'system_config',
      'doc_details',
    ];

    for (const table of tables) {
      try {
        const [rows] = await connection.execute(
          `SELECT COUNT(*) as count FROM ${table}`
        );
        console.log(`${table}: ${rows[0].count} records`);
      } catch (error) {
        console.log(`${table}: Could not count records (${error.message})`);
      }
    }
  } catch (error) {
    console.error('Database connection error:', error.message);
    process.exit(1);
  } finally {
    if (connection) {
      await connection.end();
      console.log('\nDatabase connection closed');
    }
  }
}

// Run the script
insertTestData();
