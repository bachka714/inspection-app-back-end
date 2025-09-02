const { PrismaClient } = require('@prisma/client');
const axios = require('axios');

const prisma = new PrismaClient();
const BASE_URL = 'http://localhost:3000/api';

async function createTestInspectionsForTypes() {
  try {
    console.log('🔧 Creating test inspections for all types...');

    // Find test user
    const testUser = await prisma.user.findUnique({
      where: { email: 'test@example.com' },
    });

    if (!testUser) {
      throw new Error(
        'Test user not found. Please run create-test-user.js first.'
      );
    }

    const org = await prisma.organization.findFirst();

    // Create inspections for each type
    const inspectionTypes = [
      'INSPECTION',
      'INSTALLATION',
      'MAINTENANCE',
      'VERIFICATION',
    ];

    for (let i = 0; i < inspectionTypes.length; i++) {
      const type = inspectionTypes[i];
      const inspectionId = BigInt(1000 + i);

      await prisma.inspection.upsert({
        where: { id: inspectionId },
        update: {
          assignedTo: testUser.id,
          type,
        },
        create: {
          id: inspectionId,
          orgId: org.id,
          type,
          title: `Test ${type} Inspection`,
          status: 'IN_PROGRESS',
          progress: 50,
          scheduledAt: new Date(Date.now() + (i + 1) * 24 * 60 * 60 * 1000), // Different days
          assignedTo: testUser.id,
          createdBy: testUser.id,
          notes: `This is a test ${type.toLowerCase()} inspection`,
        },
      });

      console.log(`✅ Created ${type} inspection`);
    }

    console.log('🎯 All test inspections created successfully!');
  } catch (error) {
    console.error('❌ Error creating test inspections:', error);
  }
}

async function testAllEndpoints() {
  try {
    console.log('🧪 Testing all type-specific endpoints\n');

    // Step 1: Login
    console.log('1️⃣ Logging in...');
    const loginResponse = await axios.post(`${BASE_URL}/auth/login`, {
      email: 'test@example.com',
      password: 'test123',
    });

    const token = loginResponse.data.data.token;
    console.log('✅ Login successful!\n');

    // Headers for authenticated requests
    const headers = { Authorization: `Bearer ${token}` };

    // Test endpoints
    const endpoints = [
      { path: '/inspections/assigned', name: 'All Assigned' },
      { path: '/inspections/inspection/assigned', name: 'INSPECTION' },
      { path: '/inspections/installation/assigned', name: 'INSTALLATION' },
      { path: '/inspections/maintenance/assigned', name: 'MAINTENANCE' },
      { path: '/inspections/verification/assigned', name: 'VERIFICATION' },
    ];

    for (const endpoint of endpoints) {
      console.log(`2️⃣ Testing ${endpoint.name} endpoint...`);

      try {
        const response = await axios.get(`${BASE_URL}${endpoint.path}`, {
          headers,
        });
        const data = response.data;

        console.log(`✅ ${endpoint.name} - Success!`);
        console.log(`   Count: ${data.count}`);
        console.log(`   Type filter: ${data.type || 'None (all types)'}`);

        if (data.data.length > 0) {
          data.data.forEach((inspection, index) => {
            console.log(
              `   ${index + 1}. ${inspection.title} (${inspection.type})`
            );
          });
        } else {
          console.log('   📋 No inspections found');
        }
        console.log('');
      } catch (error) {
        console.error(
          `❌ ${endpoint.name} failed:`,
          error.response?.data || error.message
        );
      }
    }

    console.log('🎉 All endpoint tests completed!');
  } catch (error) {
    console.error('❌ Test failed:', error.response?.data || error.message);
  } finally {
    await prisma.$disconnect();
  }
}

async function main() {
  await createTestInspectionsForTypes();
  await testAllEndpoints();
}

main();
