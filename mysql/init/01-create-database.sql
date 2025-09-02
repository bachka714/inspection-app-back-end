-- Create database if it doesn't exist
CREATE DATABASE IF NOT EXISTS inspection_app;
USE inspection_app;

-- Create roles table
CREATE TABLE IF NOT EXISTS roles (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  name          VARCHAR(64) UNIQUE NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create organizations table
CREATE TABLE IF NOT EXISTS organizations (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  name          VARCHAR(200) NOT NULL,
  code          VARCHAR(64) NULL UNIQUE,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create users table
CREATE TABLE IF NOT EXISTS users (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  org_id        BIGINT UNSIGNED NOT NULL,
  role_id       BIGINT UNSIGNED NOT NULL,
  email         VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  full_name     VARCHAR(200) NOT NULL,
  phone         VARCHAR(20) NULL,
  is_active     BOOLEAN DEFAULT TRUE,
  deleted_at    TIMESTAMP NULL,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_users_org FOREIGN KEY (org_id) REFERENCES organizations(id),
  CONSTRAINT fk_users_role FOREIGN KEY (role_id) REFERENCES roles(id),
  KEY idx_users_org (org_id),
  KEY idx_users_role (role_id),
  KEY idx_users_deleted (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create system_config table
CREATE TABLE IF NOT EXISTS system_config (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `key`         VARCHAR(100) UNIQUE NOT NULL,
  value         TEXT NOT NULL,
  description   VARCHAR(255) NULL,
  category      VARCHAR(50) NOT NULL,
  is_active     BOOLEAN DEFAULT TRUE,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_system_config_category (category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create contracts table
CREATE TABLE IF NOT EXISTS contracts (
  id              BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  org_id          BIGINT UNSIGNED NOT NULL,
  contract_name   VARCHAR(255) NOT NULL,
  contract_number VARCHAR(128) NOT NULL,
  start_date      DATE NULL,
  end_date        DATE NULL,
  metadata        JSON NULL,
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
  specs         JSON NULL,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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
  serial_number  VARCHAR(100) NOT NULL,
  asset_tag      VARCHAR(128) NULL,
  status         ENUM('IN_STOCK','INSTALLED','IN_SERVICE','NORMAL','MAINTENANCE','DECOMMISSIONED') NOT NULL DEFAULT 'IN_STOCK',
  installed_at   DATETIME NULL,
  retired_at     DATETIME NULL,
  deleted_at     DATETIME NULL,
  metadata       JSON NULL,
  created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_devices_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
  CONSTRAINT fk_devices_site FOREIGN KEY (site_id) REFERENCES sites(id) ON DELETE SET NULL,
  CONSTRAINT fk_devices_contract FOREIGN KEY (contract_id) REFERENCES contracts(id) ON DELETE SET NULL,
  CONSTRAINT fk_devices_model FOREIGN KEY (model_id) REFERENCES device_models(id) ON DELETE SET NULL,
  UNIQUE KEY uk_devices_org_serial (org_id, serial_number),
  KEY idx_devices_org (org_id),
  KEY idx_devices_site (site_id),
  KEY idx_devices_status (status),
  KEY idx_devices_contract (contract_id),
  KEY idx_devices_model (model_id),
  KEY idx_devices_installed (installed_at),
  KEY idx_devices_deleted (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create inspection_templates table
CREATE TABLE IF NOT EXISTS inspection_templates (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  name          VARCHAR(255) NOT NULL,
  type          ENUM('INSPECTION','INSTALLATION','MAINTENANCE','VERIFICATION') NOT NULL,
  description   TEXT NULL,
  questions     JSON NOT NULL,
  is_active     BOOLEAN DEFAULT TRUE,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_inspection_templates_type (type),
  KEY idx_inspection_templates_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create inspections table
CREATE TABLE IF NOT EXISTS inspections (
  id             BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  org_id         BIGINT UNSIGNED NOT NULL,
  device_id      BIGINT UNSIGNED NULL,
  site_id        BIGINT UNSIGNED NULL,
  contract_id    BIGINT UNSIGNED NULL,
  template_id    BIGINT UNSIGNED NULL,
  type           ENUM('INSPECTION','INSTALLATION','MAINTENANCE','VERIFICATION') NOT NULL,
  title          VARCHAR(255) NOT NULL,
  scheduled_at   DATETIME NULL,
  started_at     DATETIME NULL,
  completed_at   DATETIME NULL,
  status         ENUM('DRAFT','IN_PROGRESS','SUBMITTED','APPROVED','REJECTED','CANCELED') NOT NULL DEFAULT 'DRAFT',
  progress       TINYINT NULL,
  assigned_to    BIGINT UNSIGNED NULL,
  created_by     BIGINT UNSIGNED NOT NULL,
  updated_by     BIGINT UNSIGNED NULL,
  notes          TEXT NULL,
  deleted_at     DATETIME NULL,
  created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_inspections_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
  CONSTRAINT fk_inspections_device FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE SET NULL,
  CONSTRAINT fk_inspections_site FOREIGN KEY (site_id) REFERENCES sites(id) ON DELETE SET NULL,
  CONSTRAINT fk_inspections_contract FOREIGN KEY (contract_id) REFERENCES contracts(id) ON DELETE SET NULL,
  CONSTRAINT fk_inspections_template FOREIGN KEY (template_id) REFERENCES inspection_templates(id) ON DELETE SET NULL,
  CONSTRAINT fk_inspections_assignee FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL,
  CONSTRAINT fk_inspections_created_by FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT,
  CONSTRAINT fk_inspections_updated_by FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL,
  KEY idx_inspections_org (org_id),
  KEY idx_inspections_status (status),
  KEY idx_inspections_type (type),
  KEY idx_inspections_assigned (assigned_to),
  KEY idx_inspections_org_status (org_id, status),
  KEY idx_inspections_org_scheduled (org_id, scheduled_at),
  KEY idx_inspections_creator_date (created_by, created_at),
  KEY idx_inspections_device_status (device_id, status),
  KEY idx_inspections_scheduled (scheduled_at),
  KEY idx_inspections_completed (completed_at),
  KEY idx_inspections_deleted (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create doc_details table
CREATE TABLE IF NOT EXISTS doc_details (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  doc_name      VARCHAR(255) NOT NULL,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create inspection_answers table
CREATE TABLE IF NOT EXISTS inspection_answers (
  id              BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  inspection_id   BIGINT UNSIGNED NOT NULL,
  answers         JSON NOT NULL,
  pdf_id          BIGINT UNSIGNED NULL,
  answered_by     BIGINT UNSIGNED NULL,
  answered_at     DATETIME NULL,
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_inspection_answers_inspection FOREIGN KEY (inspection_id) REFERENCES inspections(id) ON DELETE CASCADE,
  CONSTRAINT fk_inspection_answers_user FOREIGN KEY (answered_by) REFERENCES users(id) ON DELETE SET NULL,
  CONSTRAINT fk_inspection_answers_doc FOREIGN KEY (pdf_id) REFERENCES doc_details(id),
  KEY idx_inspection_answers_user (answered_by),
  KEY idx_inspection_answers_date (answered_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create attachments table
CREATE TABLE IF NOT EXISTS attachments (
  id              BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  inspection_id   BIGINT UNSIGNED NULL,
  device_id       BIGINT UNSIGNED NULL,
  filename        VARCHAR(255) NOT NULL,
  original_name   VARCHAR(255) NOT NULL,
  mime_type       VARCHAR(100) NOT NULL,
  size            INT UNSIGNED NOT NULL,
  uploaded_by     BIGINT UNSIGNED NOT NULL,
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_attachments_inspection FOREIGN KEY (inspection_id) REFERENCES inspections(id) ON DELETE CASCADE,
  CONSTRAINT fk_attachments_device FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE CASCADE,
  CONSTRAINT fk_attachments_uploader FOREIGN KEY (uploaded_by) REFERENCES users(id),
  KEY idx_attachments_inspection (inspection_id),
  KEY idx_attachments_device (device_id),
  KEY idx_attachments_uploader (uploaded_by)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create inspection_schedules table
CREATE TABLE IF NOT EXISTS inspection_schedules (
  id              BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  org_id          BIGINT UNSIGNED NOT NULL,
  device_id       BIGINT UNSIGNED NULL,
  site_id         BIGINT UNSIGNED NULL,
  template_id     BIGINT UNSIGNED NULL,
  frequency       VARCHAR(20) NOT NULL,
  interval_days   INT NULL,
  next_due_date   DATETIME NOT NULL,
  is_active       BOOLEAN DEFAULT TRUE,
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_inspection_schedules_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
  CONSTRAINT fk_inspection_schedules_device FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE SET NULL,
  CONSTRAINT fk_inspection_schedules_site FOREIGN KEY (site_id) REFERENCES sites(id) ON DELETE SET NULL,
  CONSTRAINT fk_inspection_schedules_template FOREIGN KEY (template_id) REFERENCES inspection_templates(id) ON DELETE SET NULL,
  KEY idx_schedule_due_date (next_due_date),
  KEY idx_schedule_org (org_id),
  KEY idx_schedule_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create audit_logs table
CREATE TABLE IF NOT EXISTS audit_logs (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  table_id      VARCHAR(50) NOT NULL,
  record_id     BIGINT UNSIGNED NOT NULL,
  action        VARCHAR(20) NOT NULL,
  old_data      JSON NULL,
  new_data      JSON NULL,
  user_id       BIGINT UNSIGNED NULL,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_audit_logs_user FOREIGN KEY (user_id) REFERENCES users(id),
  KEY idx_audit_log_record (table_id, record_id),
  KEY idx_audit_log_user (user_id),
  KEY idx_audit_log_date (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;