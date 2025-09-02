const express = require('express');
const { PrismaClient } = require('@prisma/client');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();
const prisma = new PrismaClient();

// Helper function to fetch assigned inspections by type
async function getAssignedInspectionsByType(userId, inspectionType = null) {
  const whereClause = {
    assignedTo: userId,
    deletedAt: null, // Exclude soft-deleted inspections
  };

  // Add type filter if specified
  if (inspectionType) {
    whereClause.type = inspectionType;
  }

  const inspections = await prisma.inspection.findMany({
    where: whereClause,
    include: {
      device: {
        select: {
          id: true,
          serialNumber: true,
          assetTag: true,
          model: {
            select: {
              manufacturer: true,
              model: true,
            },
          },
        },
      },
      site: {
        select: {
          id: true,
          name: true,
        },
      },
      contract: {
        select: {
          id: true,
          contractName: true,
          contractNumber: true,
        },
      },
      createdByUser: {
        select: {
          id: true,
          fullName: true,
          email: true,
        },
      },
      template: {
        select: {
          id: true,
          name: true,
          type: true,
        },
      },
    },
    orderBy: [{ scheduledAt: 'asc' }, { createdAt: 'desc' }],
  });

  // Convert BigInt values to strings for JSON serialization
  return inspections.map(inspection => ({
    ...inspection,
    id: inspection.id.toString(),
    orgId: inspection.orgId.toString(),
    deviceId: inspection.deviceId?.toString(),
    siteId: inspection.siteId?.toString(),
    contractId: inspection.contractId?.toString(),
    templateId: inspection.templateId?.toString(),
    assignedTo: inspection.assignedTo?.toString(),
    createdBy: inspection.createdBy.toString(),
    updatedBy: inspection.updatedBy?.toString(),
    device: inspection.device
      ? {
          ...inspection.device,
          id: inspection.device.id.toString(),
        }
      : null,
    site: inspection.site
      ? {
          ...inspection.site,
          id: inspection.site.id.toString(),
        }
      : null,
    contract: inspection.contract
      ? {
          ...inspection.contract,
          id: inspection.contract.id.toString(),
        }
      : null,
    createdByUser: {
      ...inspection.createdByUser,
      id: inspection.createdByUser.id.toString(),
    },
    template: inspection.template
      ? {
          ...inspection.template,
          id: inspection.template.id.toString(),
        }
      : null,
  }));
}

// GET all inspections assigned to logged-in user
router.get('/assigned', authMiddleware, async (req, res) => {
  try {
    const userId = BigInt(req.user.id);
    const inspections = await getAssignedInspectionsByType(userId);

    res.json({
      message: 'All assigned inspections fetched successfully',
      data: inspections,
      count: inspections.length,
    });
  } catch (error) {
    console.error('Error fetching assigned inspections:', error);
    res.status(500).json({
      error: 'Failed to fetch assigned inspections',
      message:
        process.env.NODE_ENV === 'development'
          ? error.message
          : 'Internal server error',
    });
  }
});

// GET INSPECTION type inspections assigned to logged-in user
router.get('/inspection/assigned', authMiddleware, async (req, res) => {
  try {
    const userId = BigInt(req.user.id);
    const inspections = await getAssignedInspectionsByType(
      userId,
      'INSPECTION'
    );

    res.json({
      message: 'Assigned INSPECTION inspections fetched successfully',
      data: inspections,
      count: inspections.length,
      type: 'INSPECTION',
    });
  } catch (error) {
    console.error('Error fetching assigned INSPECTION inspections:', error);
    res.status(500).json({
      error: 'Failed to fetch assigned INSPECTION inspections',
      message:
        process.env.NODE_ENV === 'development'
          ? error.message
          : 'Internal server error',
    });
  }
});

// GET INSTALLATION type inspections assigned to logged-in user
router.get('/installation/assigned', authMiddleware, async (req, res) => {
  try {
    const userId = BigInt(req.user.id);
    const inspections = await getAssignedInspectionsByType(
      userId,
      'INSTALLATION'
    );

    res.json({
      message: 'Assigned INSTALLATION inspections fetched successfully',
      data: inspections,
      count: inspections.length,
      type: 'INSTALLATION',
    });
  } catch (error) {
    console.error('Error fetching assigned INSTALLATION inspections:', error);
    res.status(500).json({
      error: 'Failed to fetch assigned INSTALLATION inspections',
      message:
        process.env.NODE_ENV === 'development'
          ? error.message
          : 'Internal server error',
    });
  }
});

// GET MAINTENANCE type inspections assigned to logged-in user
router.get('/maintenance/assigned', authMiddleware, async (req, res) => {
  try {
    const userId = BigInt(req.user.id);
    const inspections = await getAssignedInspectionsByType(
      userId,
      'MAINTENANCE'
    );

    res.json({
      message: 'Assigned MAINTENANCE inspections fetched successfully',
      data: inspections,
      count: inspections.length,
      type: 'MAINTENANCE',
    });
  } catch (error) {
    console.error('Error fetching assigned MAINTENANCE inspections:', error);
    res.status(500).json({
      error: 'Failed to fetch assigned MAINTENANCE inspections',
      message:
        process.env.NODE_ENV === 'development'
          ? error.message
          : 'Internal server error',
    });
  }
});

// GET VERIFICATION type inspections assigned to logged-in user
router.get('/verification/assigned', authMiddleware, async (req, res) => {
  try {
    const userId = BigInt(req.user.id);
    const inspections = await getAssignedInspectionsByType(
      userId,
      'VERIFICATION'
    );

    res.json({
      message: 'Assigned VERIFICATION inspections fetched successfully',
      data: inspections,
      count: inspections.length,
      type: 'VERIFICATION',
    });
  } catch (error) {
    console.error('Error fetching assigned VERIFICATION inspections:', error);
    res.status(500).json({
      error: 'Failed to fetch assigned VERIFICATION inspections',
      message:
        process.env.NODE_ENV === 'development'
          ? error.message
          : 'Internal server error',
    });
  }
});

// GET all inspections
router.get('/', (req, res) => {
  try {
    // TODO: Implement database query
    res.json({
      message: 'Get all inspections',
      data: [],
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch inspections' });
  }
});

// GET inspection by ID
router.get('/:id', (req, res) => {
  try {
    const { id } = req.params;
    // TODO: Implement database query
    res.json({
      message: `Get inspection ${id}`,
      data: { id, status: 'pending' },
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch inspection' });
  }
});

// POST new inspection
router.post('/', (req, res) => {
  try {
    const inspectionData = req.body;
    // TODO: Implement database insert
    res.status(201).json({
      message: 'Inspection created successfully',
      data: { id: Date.now(), ...inspectionData },
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to create inspection' });
  }
});

// PUT update inspection
router.put('/:id', (req, res) => {
  try {
    const { id } = req.params;
    const updateData = req.body;
    // TODO: Implement database update
    res.json({
      message: `Inspection ${id} updated successfully`,
      data: { id, ...updateData },
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update inspection' });
  }
});

// DELETE inspection
router.delete('/:id', (req, res) => {
  try {
    const { id } = req.params;
    // TODO: Implement database delete
    res.json({
      message: `Inspection ${id} deleted successfully`,
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete inspection' });
  }
});

module.exports = router;
