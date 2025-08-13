const express = require('express');
const { PrismaClient } = require('@prisma/client');
const { authMiddleware } = require('../middleware/auth');
const bcrypt = require('bcrypt');

const router = express.Router();
const prisma = new PrismaClient();

// GET all users (protected route)
router.get('/', authMiddleware, async (req, res) => {
  try {
    const users = await prisma.user.findMany({
      where: {
        orgId: BigInt(req.user.orgId), // Only show users from same organization
      },
      include: {
        organization: true,
        userRoles: {
          include: {
            role: true,
          },
        },
      },
    });

    // Format response
    const formattedUsers = users.map(user => ({
      id: user.id.toString(),
      email: user.email,
      fullName: user.fullName,
      phone: user.phone,
      isActive: user.isActive,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      organization: {
        id: user.organization.id.toString(),
        name: user.organization.name,
        code: user.organization.code,
      },
      roles: user.userRoles.map(ur => ur.role.name),
    }));

    res.json({
      message: 'Users retrieved successfully',
      data: formattedUsers,
    });
  } catch (error) {
    console.error('Error fetching users:', error);
    res.status(500).json({
      error: 'Failed to fetch users',
      message:
        process.env.NODE_ENV === 'development'
          ? error.message
          : 'Internal server error',
    });
  }
});

// GET current user profile (protected route)
router.get('/profile', authMiddleware, async (req, res) => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: BigInt(req.user.id) },
      include: {
        organization: true,
        userRoles: {
          include: {
            role: true,
          },
        },
      },
    });

    if (!user) {
      return res.status(404).json({
        error: 'User not found',
        message: 'User profile not found',
      });
    }

    res.json({
      message: 'Profile retrieved successfully',
      data: {
        id: user.id.toString(),
        email: user.email,
        fullName: user.fullName,
        phone: user.phone,
        isActive: user.isActive,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
        organization: {
          id: user.organization.id.toString(),
          name: user.organization.name,
          code: user.organization.code,
        },
        roles: user.userRoles.map(ur => ur.role.name),
      },
    });
  } catch (error) {
    console.error('Error fetching profile:', error);
    res.status(500).json({
      error: 'Failed to fetch profile',
      message:
        process.env.NODE_ENV === 'development'
          ? error.message
          : 'Internal server error',
    });
  }
});

// GET user by ID (protected route)
router.get('/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;

    const user = await prisma.user.findFirst({
      where: {
        id: BigInt(id),
        orgId: BigInt(req.user.orgId), // Only allow access to users in same organization
      },
      include: {
        organization: true,
        userRoles: {
          include: {
            role: true,
          },
        },
      },
    });

    if (!user) {
      return res.status(404).json({
        error: 'User not found',
        message:
          'User not found or you do not have permission to view this user',
      });
    }

    res.json({
      message: 'User retrieved successfully',
      data: {
        id: user.id.toString(),
        email: user.email,
        fullName: user.fullName,
        phone: user.phone,
        isActive: user.isActive,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
        organization: {
          id: user.organization.id.toString(),
          name: user.organization.name,
          code: user.organization.code,
        },
        roles: user.userRoles.map(ur => ur.role.name),
      },
    });
  } catch (error) {
    console.error('Error fetching user:', error);
    res.status(500).json({
      error: 'Failed to fetch user',
      message:
        process.env.NODE_ENV === 'development'
          ? error.message
          : 'Internal server error',
    });
  }
});

// POST new user (protected route - admin only would be added later)
router.post('/', authMiddleware, async (req, res) => {
  try {
    const { email, password, fullName, phone, roleIds } = req.body;

    // Validate required fields
    if (!email || !password || !fullName) {
      return res.status(400).json({
        error: 'Missing required fields',
        message: 'Email, password, and fullName are required',
      });
    }

    // Check if user already exists
    const existingUser = await prisma.user.findUnique({
      where: { email },
    });

    if (existingUser) {
      return res.status(409).json({
        error: 'User already exists',
        message: 'A user with this email already exists',
      });
    }

    // Hash password
    const saltRounds = 10;
    const passwordHash = await bcrypt.hash(password, saltRounds);

    // Create user with roles
    const user = await prisma.user.create({
      data: {
        email,
        passwordHash,
        fullName,
        phone,
        orgId: BigInt(req.user.orgId), // Same organization as creating user
        userRoles: {
          create:
            roleIds && roleIds.length > 0
              ? roleIds.map(roleId => ({ roleId: BigInt(roleId) }))
              : [],
        },
      },
      include: {
        organization: true,
        userRoles: {
          include: {
            role: true,
          },
        },
      },
    });

    res.status(201).json({
      message: 'User created successfully',
      data: {
        id: user.id.toString(),
        email: user.email,
        fullName: user.fullName,
        phone: user.phone,
        isActive: user.isActive,
        organization: {
          id: user.organization.id.toString(),
          name: user.organization.name,
          code: user.organization.code,
        },
        roles: user.userRoles.map(ur => ur.role.name),
      },
    });
  } catch (error) {
    console.error('Error creating user:', error);
    res.status(500).json({
      error: 'Failed to create user',
      message:
        process.env.NODE_ENV === 'development'
          ? error.message
          : 'Internal server error',
    });
  }
});

// PUT update user (protected route)
router.put('/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const { fullName, phone, isActive, password, roleIds } = req.body;

    // Check if user exists and belongs to same organization
    const existingUser = await prisma.user.findFirst({
      where: {
        id: BigInt(id),
        orgId: BigInt(req.user.orgId),
      },
    });

    if (!existingUser) {
      return res.status(404).json({
        error: 'User not found',
        message:
          'User not found or you do not have permission to update this user',
      });
    }

    // Prepare update data
    const updateData = {};
    if (fullName !== undefined) updateData.fullName = fullName;
    if (phone !== undefined) updateData.phone = phone;
    if (isActive !== undefined) updateData.isActive = isActive;

    // Hash new password if provided
    if (password) {
      const saltRounds = 10;
      updateData.passwordHash = await bcrypt.hash(password, saltRounds);
    }

    // Update user
    const user = await prisma.user.update({
      where: { id: BigInt(id) },
      data: updateData,
      include: {
        organization: true,
        userRoles: {
          include: {
            role: true,
          },
        },
      },
    });

    // Update roles if provided
    if (roleIds && Array.isArray(roleIds)) {
      // Delete existing roles
      await prisma.userRole.deleteMany({
        where: { userId: BigInt(id) },
      });

      // Add new roles
      if (roleIds.length > 0) {
        await prisma.userRole.createMany({
          data: roleIds.map(roleId => ({
            userId: BigInt(id),
            roleId: BigInt(roleId),
          })),
        });
      }

      // Refetch user with updated roles
      const updatedUser = await prisma.user.findUnique({
        where: { id: BigInt(id) },
        include: {
          organization: true,
          userRoles: {
            include: {
              role: true,
            },
          },
        },
      });

      return res.json({
        message: 'User updated successfully',
        data: {
          id: updatedUser.id.toString(),
          email: updatedUser.email,
          fullName: updatedUser.fullName,
          phone: updatedUser.phone,
          isActive: updatedUser.isActive,
          organization: {
            id: updatedUser.organization.id.toString(),
            name: updatedUser.organization.name,
            code: updatedUser.organization.code,
          },
          roles: updatedUser.userRoles.map(ur => ur.role.name),
        },
      });
    }

    res.json({
      message: 'User updated successfully',
      data: {
        id: user.id.toString(),
        email: user.email,
        fullName: user.fullName,
        phone: user.phone,
        isActive: user.isActive,
        organization: {
          id: user.organization.id.toString(),
          name: user.organization.name,
          code: user.organization.code,
        },
        roles: user.userRoles.map(ur => ur.role.name),
      },
    });
  } catch (error) {
    console.error('Error updating user:', error);
    res.status(500).json({
      error: 'Failed to update user',
      message:
        process.env.NODE_ENV === 'development'
          ? error.message
          : 'Internal server error',
    });
  }
});

// DELETE user (protected route)
router.delete('/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;

    // Check if user exists and belongs to same organization
    const existingUser = await prisma.user.findFirst({
      where: {
        id: BigInt(id),
        orgId: BigInt(req.user.orgId),
      },
    });

    if (!existingUser) {
      return res.status(404).json({
        error: 'User not found',
        message:
          'User not found or you do not have permission to delete this user',
      });
    }

    // Prevent self-deletion
    if (existingUser.id.toString() === req.user.id) {
      return res.status(400).json({
        error: 'Cannot delete self',
        message: 'You cannot delete your own account',
      });
    }

    // Delete user roles first
    await prisma.userRole.deleteMany({
      where: { userId: BigInt(id) },
    });

    // Delete user
    await prisma.user.delete({
      where: { id: BigInt(id) },
    });

    res.json({
      message: 'User deleted successfully',
    });
  } catch (error) {
    console.error('Error deleting user:', error);
    res.status(500).json({
      error: 'Failed to delete user',
      message:
        process.env.NODE_ENV === 'development'
          ? error.message
          : 'Internal server error',
    });
  }
});

module.exports = router;
