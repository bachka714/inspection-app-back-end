# MySQL Workbench Setup Guide

This guide will help you connect MySQL Workbench to the MySQL database running in Docker.

## Prerequisites

1. **Install MySQL Workbench**
   - Download from: https://dev.mysql.com/downloads/workbench/
   - Available for Windows, macOS, and Linux

2. **Start the Docker containers**
   ```bash
   docker-compose up -d
   ```

## Connection Setup

### Step 1: Open MySQL Workbench

1. Launch MySQL Workbench
2. Click on the "+" icon next to "MySQL Connections" to add a new connection

### Step 2: Configure Connection

**Connection Name:** `Inspection App MySQL`

**Connection Method:** `Standard (TCP/IP)`

**Hostname:** `localhost`

**Port:** `3306`

**Username:** Choose one of the following:

#### Option A: Root User (Full Access)

- **Username:** `root`
- **Password:** `rootpassword`
- **Default Schema:** `inspection_app`

#### Option B: Application User (Limited Access)

- **Username:** `inspection_user`
- **Password:** `inspection_password`
- **Default Schema:** `inspection_app`

### Step 3: Test Connection

1. Click "Test Connection" to verify the setup
2. If successful, click "OK" to save the connection

## Database Schema

Once connected, you'll have access to:

### Tables

- **`users`** - User management with roles
- **`inspections`** - Main inspection records
- **`inspection_items`** - Individual items within inspections

### Sample Data

The database comes pre-populated with sample data for testing:

- 3 users (admin, inspector1, inspector2)
- 3 inspections with different statuses
- Multiple inspection items

## Useful MySQL Workbench Features

### 1. Query Editor

- Write and execute SQL queries
- View results in tabular format
- Export data to CSV/JSON

### 2. Schema Inspector

- Browse table structures
- View relationships between tables
- Examine indexes and constraints

### 3. Data Export/Import

- Export data to various formats
- Import data from CSV files
- Generate database documentation

### 4. Performance Monitoring

- Monitor query performance
- Analyze slow queries
- View server status

## Troubleshooting

### Connection Issues

1. **"Can't connect to MySQL server"**
   - Ensure Docker containers are running: `docker-compose ps`
   - Check if port 3306 is available: `netstat -an | grep 3306`

2. **"Access denied for user"**
   - Verify username and password
   - Try connecting as root user first

3. **"Host not allowed"**
   - This shouldn't occur with localhost connections
   - Check Docker network configuration

### Performance Tips

1. **Use indexes** for frequently queried columns
2. **Limit result sets** when querying large tables
3. **Use EXPLAIN** to analyze query performance
4. **Monitor connection pool** usage

## Security Notes

- Change default passwords in production
- Use strong passwords for database users
- Limit database user permissions appropriately
- Consider using SSL connections for production

## Quick Commands

```sql
-- View all users
SELECT * FROM users;

-- View all inspections
SELECT * FROM inspections;

-- View inspection items
SELECT * FROM inspection_items;

-- Join inspection with inspector
SELECT i.title, u.first_name, u.last_name
FROM inspections i
LEFT JOIN users u ON i.inspector_id = u.id;
```
