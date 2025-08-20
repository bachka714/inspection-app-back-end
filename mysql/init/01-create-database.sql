-- Create database if it doesn't exist
CREATE DATABASE IF NOT EXISTS inspection_app;
USE inspection_app;

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    role ENUM('admin', 'inspector', 'viewer') DEFAULT 'viewer',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create organizations table
CREATE TABLE IF NOT EXISTS organizations (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  name          VARCHAR(200) NOT NULL,
  code          VARCHAR(64)  NULL,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_org_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create contracts table
CREATE TABLE IF NOT EXISTS contracts (
  id              BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  org_id          BIGINT UNSIGNED NOT NULL,
  contract_name   VARCHAR(255) NOT NULL,
  contract_number VARCHAR(128) NOT NULL,
  start_date      DATE NULL,
  end_date        DATE NULL,
  metadata        JSON NULL, -- extra fields if needed
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_contracts_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
  UNIQUE KEY uk_contracts_org_number (org_id, contract_number),
  KEY idx_contracts_org (org_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create sites table
CREATE TABLE IF NOT EXISTS sites (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  org_id        BIGINT UNSIGNED NOT NULL,
  name          VARCHAR(200) NOT NULL,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_sites_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
  KEY idx_sites_org (org_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create device_models table
CREATE TABLE IF NOT EXISTS device_models (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  manufacturer  VARCHAR(200) NOT NULL,
  model         VARCHAR(200) NOT NULL,
  specs         JSON NULL, -- e.g., ratings, classes, protocol
  UNIQUE KEY uk_device_models (manufacturer, model),
  KEY idx_device_models_manu (manufacturer)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create devices table
CREATE TABLE IF NOT EXISTS devices (
  id             BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  org_id         BIGINT UNSIGNED NOT NULL,
  site_id        BIGINT UNSIGNED NULL,
  contract_id    BIGINT UNSIGNED NULL,
  model_id       BIGINT UNSIGNED NULL,
  serial_number  VARCHAR(128) NOT NULL,
  asset_tag      VARCHAR(128) NULL,
  status         ENUM('in_stock','installed','in_service','maintenance','decommissioned') NOT NULL DEFAULT 'in_stock',
  installed_at   DATETIME NULL,
  retired_at     DATETIME NULL,
  metadata       JSON NULL, -- free-form device properties
  created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_devices_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
  CONSTRAINT fk_devices_site FOREIGN KEY (site_id) REFERENCES sites(id) ON DELETE SET NULL,
  CONSTRAINT fk_devices_contract FOREIGN KEY (contract_id) REFERENCES contracts(id) ON DELETE SET NULL,
  CONSTRAINT fk_devices_model FOREIGN KEY (model_id) REFERENCES device_models(id) ON DELETE SET NULL,
  UNIQUE KEY uk_devices_org_serial (org_id, serial_number),
  KEY idx_devices_org (org_id),
  KEY idx_devices_site (site_id),
  KEY idx_devices_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create inspections table (updated version)
CREATE TABLE IF NOT EXISTS inspections (
  id             BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  org_id         BIGINT UNSIGNED NOT NULL,
  device_id      BIGINT UNSIGNED NULL,
  site_id        BIGINT UNSIGNED NULL,
  contract_id    BIGINT UNSIGNED NULL,
  type           ENUM('inspection','installation','maintenance','verification') NOT NULL,
  title          VARCHAR(255) NOT NULL,
  scheduled_at   DATETIME NULL,
  started_at     DATETIME NULL,
  completed_at   DATETIME NULL,
  status         ENUM('draft','in_progress','submitted','approved','rejected','canceled') NOT NULL DEFAULT 'draft',
  progress       INT NULL,
  assigned_to    BIGINT UNSIGNED NULL, -- user id
  created_by     BIGINT UNSIGNED NOT NULL,
  updated_by     BIGINT UNSIGNED NULL,
  notes          TEXT NULL,
  created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_inspections_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
  CONSTRAINT fk_inspections_device FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE SET NULL,
  CONSTRAINT fk_inspections_site FOREIGN KEY (site_id) REFERENCES sites(id) ON DELETE SET NULL,
  CONSTRAINT fk_inspections_contract FOREIGN KEY (contract_id) REFERENCES contracts(id) ON DELETE SET NULL,
  CONSTRAINT fk_inspections_assignee FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL,
  CONSTRAINT fk_inspections_created_by FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT,
  CONSTRAINT fk_inspections_updated_by FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL,
  KEY idx_inspections_org (org_id),
  KEY idx_inspections_status (status),
  KEY idx_inspections_type (type),
  KEY idx_inspections_assigned (assigned_to)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create inspection_answers table
CREATE TABLE IF NOT EXISTS inspection_answers (
  id              BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  inspection_id   BIGINT UNSIGNED NOT NULL,
  answers         JSON NOT NULL,
  pdf_id          BIGINT UNSIGNED NULL,
  answered_by     BIGINT UNSIGNED NULL,     -- user who answered
  answered_at     DATETIME NULL,            -- when answered
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_answer_inspection FOREIGN KEY (inspection_id) REFERENCES inspections(id) ON DELETE CASCADE,
  CONSTRAINT fk_answer_user FOREIGN KEY (answered_by) REFERENCES users(id) ON DELETE SET NULL
  -- Optional: fk to questions table if you have one
  -- CONSTRAINT fk_answer_question FOREIGN KEY (question_id) REFERENCES inspection_questions(id) ON DELETE CASCADE,
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create pdf_details table
CREATE TABLE IF NOT EXISTS pdf_details (
  id              BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  pdf_name        VARCHAR(255) NOT NULL,
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create system_config table
CREATE TABLE IF NOT EXISTS system_config (
  id              BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  pdf_path        VARCHAR(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create inspection_items table (keeping existing for backward compatibility)
CREATE TABLE IF NOT EXISTS inspection_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    inspection_id INT NOT NULL,
    item_name VARCHAR(255) NOT NULL,
    item_description TEXT,
    status ENUM('pending', 'passed', 'failed', 'not_applicable') DEFAULT 'pending',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (inspection_id) REFERENCES inspections(id) ON DELETE CASCADE
);

-- Insert sample data
INSERT INTO users (username, email, password_hash, first_name, last_name, role) VALUES
('admin', 'admin@inspectionapp.com', '$2b$10$example_hash', 'Admin', 'User', 'admin'),
('inspector1', 'inspector1@inspectionapp.com', '$2b$10$example_hash', 'John', 'Doe', 'inspector'),
('inspector2', 'inspector2@inspectionapp.com', '$2b$10$example_hash', 'Jane', 'Smith', 'inspector');

-- Insert sample organizations
INSERT INTO organizations (name, code) VALUES
('Sample Organization', 'SAMPLE_ORG'),
('Test Company', 'TEST_CO');

-- Insert sample contracts
INSERT INTO contracts (org_id, contract_name, contract_number, start_date, end_date) VALUES
(1, 'Maintenance Contract 2024', 'MC-2024-001', '2024-01-01', '2024-12-31'),
(1, 'Service Agreement', 'SA-2024-001', '2024-01-01', '2025-01-01');

-- Insert sample sites
INSERT INTO sites (org_id, name) VALUES
(1, 'Main Office'),
(1, 'Warehouse A'),
(2, 'Branch Office');

-- Insert sample device models
INSERT INTO device_models (manufacturer, model, specs) VALUES
('Generic Corp', 'Safety Device X1', '{"rating": "Class A", "protocol": "Standard"}'),
('Tech Industries', 'Monitor Pro', '{"rating": "Class B", "protocol": "Advanced"}');

-- Insert sample devices
INSERT INTO devices (org_id, site_id, contract_id, model_id, serial_number, asset_tag, status) VALUES
(1, 1, 1, 1, 'SN001', 'AT001', 'in_service'),
(1, 2, 1, 2, 'SN002', 'AT002', 'installed');

-- Insert sample inspections (updated)
INSERT INTO inspections (org_id, title, type, status, created_by) VALUES
(1, 'Safety Equipment Check', 'inspection', 'draft', 1),
(1, 'Fire Safety Inspection', 'inspection', 'in_progress', 2),
(1, 'Electrical Systems Review', 'maintenance', 'completed', 2);

INSERT INTO inspection_items (inspection_id, item_name, item_description, status) VALUES
(1, 'Fire Extinguishers', 'Check all fire extinguishers are properly mounted and charged', 'pending'),
(1, 'Emergency Exits', 'Verify all emergency exits are clear and properly marked', 'pending'),
(1, 'First Aid Kits', 'Inspect first aid kits for completeness and expiration dates', 'pending'),
(2, 'Fire Alarms', 'Test all fire alarm systems', 'in_progress'),
(2, 'Sprinkler Systems', 'Check sprinkler system functionality', 'pending'),
(3, 'Electrical Panels', 'Inspect electrical panels for proper labeling and condition', 'completed'),
(3, 'Circuit Breakers', 'Test circuit breaker functionality', 'completed');
