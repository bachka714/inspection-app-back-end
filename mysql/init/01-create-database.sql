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

-- Create inspections table
CREATE TABLE IF NOT EXISTS inspections (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    location VARCHAR(255),
    inspector_id INT,
    status ENUM('pending', 'in_progress', 'completed', 'cancelled') DEFAULT 'pending',
    priority ENUM('low', 'medium', 'high', 'critical') DEFAULT 'medium',
    scheduled_date DATETIME,
    completed_date DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (inspector_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Create inspection_items table
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

INSERT INTO inspections (title, description, location, inspector_id, status, priority, scheduled_date) VALUES
('Safety Equipment Check', 'Monthly safety equipment inspection', 'Building A - Floor 1', 2, 'pending', 'high', NOW() + INTERVAL 1 DAY),
('Fire Safety Inspection', 'Quarterly fire safety systems check', 'Building B - All Floors', 3, 'in_progress', 'critical', NOW() - INTERVAL 1 DAY),
('Electrical Systems Review', 'Annual electrical systems inspection', 'Building C - Basement', 2, 'completed', 'medium', NOW() - INTERVAL 7 DAY);

INSERT INTO inspection_items (inspection_id, item_name, item_description, status) VALUES
(1, 'Fire Extinguishers', 'Check all fire extinguishers are properly mounted and charged', 'pending'),
(1, 'Emergency Exits', 'Verify all emergency exits are clear and properly marked', 'pending'),
(1, 'First Aid Kits', 'Inspect first aid kits for completeness and expiration dates', 'pending'),
(2, 'Fire Alarms', 'Test all fire alarm systems', 'in_progress'),
(2, 'Sprinkler Systems', 'Check sprinkler system functionality', 'pending'),
(3, 'Electrical Panels', 'Inspect electrical panels for proper labeling and condition', 'completed'),
(3, 'Circuit Breakers', 'Test circuit breaker functionality', 'completed');
