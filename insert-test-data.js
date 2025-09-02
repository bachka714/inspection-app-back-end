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

    console.log('🔗 Connected to MySQL database');
    console.log(`📊 Database: ${process.env.DB_NAME}`);
    console.log(`🖥️  Host: ${process.env.DB_HOST}:${process.env.DB_PORT}`);

    // Check if test-data.sql file exists
    if (!fs.existsSync('./test-data.sql')) {
      throw new Error('test-data.sql file not found in current directory');
    }

    // Read the SQL file
    console.log('\n📖 Reading test-data.sql file...');
    const sqlContent = fs.readFileSync('./test-data.sql', 'utf8');

    // Enhanced statement parsing with debugging
    console.log(`📄 File size: ${sqlContent.length} characters`);

    const rawStatements = sqlContent.split(';');
    console.log(`🔍 Raw statements after split: ${rawStatements.length}`);

    const statements = rawStatements
      .map(stmt => stmt.trim())
      .filter(stmt => {
        // Filter out empty statements and success messages only
        const isEmpty = stmt.length === 0;
        const isSuccessMessage = stmt.includes(
          "SELECT 'Test data insertion completed"
        );
        const isOnlyComments = stmt.match(/^--[\s\S]*$/);

        return !isEmpty && !isSuccessMessage && !isOnlyComments;
      })
      .map(stmt => {
        // Clean up comments but preserve SQL statements
        // Remove leading comment lines but keep SQL
        const lines = stmt.split('\n');
        const sqlLines = [];
        let foundSQL = false;

        for (const line of lines) {
          const trimmedLine = line.trim();
          // Skip comment-only lines at the start
          if (!foundSQL && trimmedLine.startsWith('--')) {
            continue;
          }
          // Once we hit SQL, include everything
          if (trimmedLine.length > 0) {
            foundSQL = true;
            sqlLines.push(line);
          }
        }

        return sqlLines.join('\n').trim();
      })
      .filter(stmt => {
        // Final filter: must have actual SQL content
        // Look for SQL keywords anywhere in the statement, not just at the start
        const upperStmt = stmt.toUpperCase();
        const hasSQL =
          upperStmt.includes('INSERT INTO') ||
          upperStmt.includes('UPDATE ') ||
          upperStmt.includes('DELETE FROM') ||
          upperStmt.includes('CREATE ') ||
          upperStmt.includes('ALTER ') ||
          upperStmt.includes('DROP ') ||
          upperStmt.includes('SET ');

        // Debug logging for troubleshooting
        if (stmt.length > 10) {
          const preview = stmt.substring(0, 50).replace(/\s+/g, ' ');
          console.log(
            `🔍 Checking: "${preview}..." -> ${hasSQL ? 'VALID' : 'SKIPPED'}`
          );
        }

        return stmt.length > 0 && hasSQL;
      });

    console.log(`📝 Found ${statements.length} SQL statements to execute`);

    // Debug: Show first few statements
    if (statements.length > 0) {
      console.log('\n🔍 First few statements:');
      statements.slice(0, 3).forEach((stmt, index) => {
        const preview = stmt.substring(0, 100).replace(/\s+/g, ' ');
        console.log(`  ${index + 1}. ${preview}...`);
      });
    } else {
      console.log(
        '\n❌ No valid SQL statements found. Debugging raw content...'
      );
      console.log('📋 First 500 characters of file:');
      console.log(sqlContent.substring(0, 500));
    }

    // Option to clean existing data (uncomment if needed)
    // await cleanExistingData(connection);

    // Execute each statement with better error handling
    let successCount = 0;
    let errorCount = 0;
    const errors = [];

    for (let i = 0; i < statements.length; i++) {
      const statement = statements[i];
      const statementPreview = statement.substring(0, 80).replace(/\s+/g, ' ');

      try {
        await connection.execute(statement);
        successCount++;

        // Show progress for every 5th statement or important ones
        if (
          (i + 1) % 5 === 0 ||
          statement.toUpperCase().includes('INSERT INTO')
        ) {
          console.log(
            `✅ [${i + 1}/${statements.length}] ${statementPreview}...`
          );
        }
      } catch (error) {
        errorCount++;
        const errorInfo = {
          statementNumber: i + 1,
          statement: statementPreview,
          error: error.message,
        };
        errors.push(errorInfo);

        console.error(
          `❌ [${i + 1}/${statements.length}] Failed: ${statementPreview}...`
        );
        console.error(`   Error: ${error.message}`);

        // Continue with next statement unless it's a critical error
        if (error.code === 'ER_NO_SUCH_TABLE') {
          console.warn(
            '   ⚠️  Table does not exist - you may need to run database migration first'
          );
        }
      }
    }

    console.log('\n🎉 Test data insertion completed!');
    console.log(`✅ Successful statements: ${successCount}`);
    console.log(`❌ Failed statements: ${errorCount}`);

    if (errors.length > 0) {
      console.log('\n⚠️  Errors encountered:');
      errors.forEach((err, index) => {
        console.log(
          `${index + 1}. Statement ${err.statementNumber}: ${err.error}`
        );
      });
    }

    console.log('\n📊 Summary of inserted data:');

    // Updated table list to match our schema
    const tables = [
      'roles',
      'system_config',
      'device_models',
      'organizations',
      'users',
      'sites',
      'contracts',
      'devices',
      'inspection_templates',
      'inspections',
      'inspection_schedules',
      'doc_details',
      'inspection_answers',
      'attachments',
      'audit_logs',
    ];

    const tableCounts = {};
    for (const table of tables) {
      try {
        const [rows] = await connection.execute(
          `SELECT COUNT(*) as count FROM ${table}`
        );
        const count = rows[0].count;
        tableCounts[table] = count;

        const icon = count > 0 ? '📈' : '📭';
        console.log(`${icon} ${table.padEnd(20)}: ${count} records`);
      } catch (error) {
        console.log(
          `❓ ${table.padEnd(20)}: Could not count (${error.message})`
        );
      }
    }

    // Summary statistics
    const totalRecords = Object.values(tableCounts).reduce(
      (sum, count) => sum + count,
      0
    );
    console.log(`\n📊 Total records inserted: ${totalRecords}`);

    if (totalRecords > 0) {
      console.log('\n✨ Database is ready for testing!');
    } else {
      console.log('\n⚠️  No data was inserted. Please check for errors above.');
    }
  } catch (error) {
    console.error('\n💥 Database connection error:', error.message);
    process.exit(1);
  } finally {
    if (connection) {
      await connection.end();
      console.log('\n🔌 Database connection closed');
    }
  }
}

// Optional: Function to clean existing data before insertion
async function cleanExistingData(connection) {
  console.log('\n🧹 Cleaning existing data...');

  const cleanupQueries = [
    'SET FOREIGN_KEY_CHECKS = 0',
    'DELETE FROM attachments',
    'DELETE FROM inspection_answers',
    'DELETE FROM inspections',
    'DELETE FROM inspection_schedules',
    'DELETE FROM devices',
    'DELETE FROM device_models',
    'DELETE FROM contracts',
    'DELETE FROM sites',
    'DELETE FROM users',
    'DELETE FROM organizations',
    'DELETE FROM roles',
    'DELETE FROM system_config',
    'DELETE FROM doc_details',
    'DELETE FROM inspection_templates',
    'DELETE FROM audit_logs',
    'SET FOREIGN_KEY_CHECKS = 1',
  ];

  for (const query of cleanupQueries) {
    try {
      await connection.execute(query);
    } catch (error) {
      console.warn(`Warning during cleanup: ${error.message}`);
    }
  }

  console.log('✅ Cleanup completed');
}

// Enhanced error handling for the main execution
async function main() {
  try {
    await insertTestData();
  } catch (error) {
    console.error('\n💥 Fatal error:', error.message);
    console.error('\nPlease check:');
    console.error('1. Database connection settings in config.env');
    console.error('2. Database server is running');
    console.error('3. Database schema is properly created');
    console.error('4. test-data.sql file exists and is readable');
    process.exit(1);
  }
}

// Run the script
main();
