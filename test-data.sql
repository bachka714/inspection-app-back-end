-- 1. Insert Roles (no dependencies)
INSERT INTO roles (id, name) VALUES
(1, 'admin'),
(2, 'inspector');

-- 2. Insert System Config (no dependencies)
INSERT INTO system_config (id, `key`, value, description, category, is_active, created_at, updated_at) VALUES
(1, 'app_name', 'Inspection Management System', 'Application name', 'general', 1, NOW(), NOW()),
(2, 'max_file_size', '10485760', 'Maximum file upload size in bytes (10MB)', 'upload', 1, NOW(), NOW()),
(3, 'allowed_file_types', 'jpg,jpeg,png,pdf,doc,docx', 'Allowed file extensions for uploads', 'upload', 1, NOW(), NOW()),
(4, 'inspection_reminder_days', '7', 'Days before inspection due date to send reminder', 'inspection', 1, NOW(), NOW()),
(5, 'auto_assign_inspections', 'false', 'Automatically assign inspections to available inspectors', 'inspection', 1, NOW(), NOW());

-- 3. Insert Device Models (no dependencies)
INSERT INTO device_models (id, manufacturer, model, specs, created_at, updated_at) VALUES
(1, 'Puu', 'Puu-1200', '{"cpu": "CPU 1214C", "memory": "100KB", "io_points": "14DI/10DO"}', NOW(), NOW()),
(2, 'Puu', 'Puu-1200', '{"cpu": "L33ER", "memory": "2MB", "communication": "EtherNet/IP"}', NOW(), NOW()),
(3, 'Puu', 'Puu-1200', '{"cpu": "TM221CE16R", "memory": "16KB", "io_points": "16I/O"}', NOW(), NOW()),
(4, 'Puu', 'Puu-1200', '{"cpu": "CP1E", "memory": "8KB", "io_points": "18DI/12DO"}', NOW(), NOW()),
(5, 'Mitsubishi', 'FX3U-32MR/ES-A', '{"cpu": "FX3U", "memory": "64KB", "io_points": "32I/O"}', NOW(), NOW());

-- 4. Insert Organizations (no dependencies)
INSERT INTO organizations (id, name, code, created_at, updated_at) VALUES
(1, 'Energy Resourse.', 'ER', NOW(), NOW()),
(2, 'Tavan Tolgoi', 'TT', NOW(), NOW()),
(3, 'Oy Tolgoi', 'OT', NOW(), NOW()),
(4, 'Measurement', 'TT', NOW(), NOW());

-- 5. Insert Users (depends on organizations and roles)
INSERT INTO users (id, org_id, role_id, email, password_hash, full_name, phone, is_active, created_at, updated_at) VALUES
(1, 4, 1, 'admin@mmnt.mn', '$2b$10$K8JVH1zK8JVH1zK8JVH1zK8JVH1zK8JVH1zK8JVH1zK8JVH1zK8JVH1z', 'John Smith', '+1-555-0101', 1, NOW(), NOW()),
(2, 2, 2, 'inspector1@mmnt.mn', '$2b$10$M0LXJ3bM0LXJ3bM0LXJ3bM0LXJ3bM0LXJ3bM0LXJ3bM0LXJ3bM0LXJ3b', 'Bachka', '+1-555-0103', 1, NOW(), NOW()),
(3, 2, 2, 'inspector2@mmnt.mn', '$2b$10$N1MYK4cN1MYK4cN1MYK4cN1MYK4cN1MYK4cN1MYK4cN1MYK4cN1MYK4c', 'Batka', '+1-555-0104', 1, NOW(), NOW()),
(4, 2, 2, 'inspector3@mmnt.mn', '$2b$10$N1MYK4cN1MYK4cN1MYK4cN1MYK4cN1MYK4cN1MYK4cN1MYK4cN1MYK4c', 'Ideree', '+1-555-0104', 1, NOW(), NOW());

-- 6. Insert Sites (depends on organizations)
INSERT INTO sites (id, org_id, name, created_at, updated_at) VALUES
(1, 1, 'Ухаа худаг', NOW(), NOW()),
(2, 1, 'Цагаан хад', NOW(), NOW()),
(3, 1, 'Баруун наран', NOW(), NOW()),
(4, 2, 'урд', NOW(), NOW()),
(5, 2, 'Хойд', NOW(), NOW()),
(6, 3, 'Урд', NOW(), NOW()),
(7, 3, 'Хойд', NOW(), NOW());

-- 7. Insert Contracts (depends on organizations)
INSERT INTO contracts (id, org_id, contract_name, contract_number, start_date, end_date, metadata, created_at, updated_at) VALUES
(1, 1, 'Ухаа худал Пүү сервис', 'MAINT-2024-001', '2024-01-01', '2024-12-31', '{"coverage": "24/7", "included_parts": true}', NOW(), NOW()),
(2, 1, 'Баруун наран сервис', 'SAFE-2024-002', '2024-01-01', '2024-12-31', '{"coverage": "24/7", "included_parts": false}', NOW(), NOW()),
(3, 1, 'Цагаан хад сервис', 'MOD-2024-003', '2024-03-01', '2024-11-30', '{"coverage": "24/7", "included_parts": true}', NOW(), NOW()),
(4, 2, 'Таван толгой Пүү сервис', 'PREV-2022-001', '2024-02-01', '2025-01-31', '{"coverage": "24/7", "included_parts": true}', NOW(), NOW()),
(5, 2, 'Таван толгой Пүү сервис', 'PREV-2023-001', '2024-02-01', '2025-01-31', '{"coverage": "24/7", "included_parts": false}', NOW(), NOW()),
(6, 3, 'Оюу толгой Пүү сервис', 'PREV-2025-001', '2024-02-01', '2025-01-31', '{"coverage": "24/7", "included_parts": false}', NOW(), NOW()),
(7, 3, 'Оюу толгой Пүү сервис', 'PREV-2026-001', '2024-02-01', '2025-01-31', '{"coverage": "24/7", "included_parts": false}', NOW(), NOW());

-- 8. Insert Inspection Templates (no dependencies - standardized across all organizations)
INSERT INTO inspection_templates (id, name, type, description, questions, is_active, created_at, updated_at) VALUES

(1, 'Weighing Scale Inspection', 'INSPECTION', 'Comprehensive weighing scale inspection checklist',
'[
  {"section": "exterior", "title": "Exterior Inspection", "fields": [
    {"id": "platform_status", "question": "Platform condition", "type": "select", "options": ["Зүгээр", "Сайжруулах шаардлагатай", "Солих шаардлагатай"], "required": true},
    {"id": "platform_comment", "question": "Platform comments", "type": "text", "required": false},
    {"id": "sensor_base_status", "question": "Sensor base condition", "type": "select", "options": ["Зүгээр", "Сайжруулах шаардлагатай", "Солих шаардлагатай"], "required": true},
    {"id": "sensor_base_comment", "question": "Sensor base comments", "type": "text", "required": false},
    {"id": "beam_status", "question": "Beam condition", "type": "select", "options": ["Зүгээр", "Сайжруулах шаардлагатай", "Солих шаардлагатай"], "required": true},
    {"id": "beam_comment", "question": "Beam comments", "type": "text", "required": false},
    {"id": "platform_plate_status", "question": "Platform plate condition", "type": "select", "options": ["Зүгээр", "Сайжруулах шаардлагатай", "Солих шаардлагатай"], "required": true},
    {"id": "platform_plate_comment", "question": "Platform plate comments", "type": "text", "required": false},
    {"id": "beam_joint_plate_status", "question": "Beam joint plate condition", "type": "select", "options": ["Зүгээр", "Сайжруулах шаардлагатай", "Солих шаардлагатай"], "required": true},
    {"id": "beam_joint_plate_comment", "question": "Beam joint plate comments", "type": "text", "required": false},
    {"id": "stop_bolt_status", "question": "Stop bolt condition", "type": "select", "options": ["Зүгээр", "Сайжруулах шаардлагатай", "Солих шаардлагатай"], "required": true},
    {"id": "stop_bolt_comment", "question": "Stop bolt comments", "type": "text", "required": false},
    {"id": "interplatform_bolts_status", "question": "Inter-platform bolts condition", "type": "select", "options": ["Зүгээр", "Сайжруулах шаардлагатай", "Солих шаардлагатай"], "required": true},
    {"id": "interplatform_bolts_comment", "question": "Inter-platform bolts comments", "type": "text", "required": false}
  ]},
  {"section": "indicator", "title": "Indicator Inspection", "fields": [
    {"id": "led_display_status", "question": "LED display condition", "type": "select", "options": ["Зүгээр", "Сайжруулах шаардлагатай", "Солих шаардлагатай"], "required": true},
    {"id": "led_display_comment", "question": "LED display comments", "type": "text", "required": false},
    {"id": "power_plug_status", "question": "Power plug condition", "type": "select", "options": ["Зүгээр", "Сайжруулах шаардлагатай", "Солих шаардлагатай"], "required": true},
    {"id": "power_plug_comment", "question": "Power plug comments", "type": "text", "required": false},
    {"id": "seal_bolt_status", "question": "Seal and bolt condition", "type": "select", "options": ["Бүтэн", "Сайжруулах шаардлагатай", "Солих шаардлагатай"], "required": true},
    {"id": "seal_bolt_comment", "question": "Seal and bolt comments", "type": "text", "required": false},
    {"id": "buttons_status", "question": "Buttons condition", "type": "select", "options": ["Зүгээр", "Сайжруулах шаардлагатай", "Солих шаардлагатай"], "required": true},
    {"id": "buttons_comment", "question": "Buttons comments", "type": "text", "required": false},
    {"id": "junction_wiring_status", "question": "Junction wiring condition", "type": "select", "options": ["Зүгээр", "Сайжруулах шаардлагатай", "Солих шаардлагатай"], "required": true},
    {"id": "junction_wiring_comment", "question": "Junction wiring comments", "type": "text", "required": false},
    {"id": "serial_converter_status", "question": "Serial converter plug condition", "type": "select", "options": ["Зүгээр", "Сайжруулах шаардлагатай", "Солих шаардлагатай"], "required": true},
    {"id": "serial_converter_comment", "question": "Serial converter plug comments", "type": "text", "required": false}
  ]},
  {"section": "jbox", "title": "Junction Box Inspection", "fields": [
    {"id": "box_integrity_status", "question": "Box integrity condition", "type": "select", "options": ["Зүгээр", "Сайжруулах шаардлагатай", "Солих шаардлагатай"], "required": true},
    {"id": "box_integrity_comment", "question": "Box integrity comments", "type": "text", "required": false},
    {"id": "collector_board_status", "question": "Collector board condition", "type": "select", "options": ["Зүгээр", "Сайжруулах шаардлагатай", "Солих шаардлагатай"], "required": true},
    {"id": "collector_board_comment", "question": "Collector board comments", "type": "text", "required": false},
    {"id": "wire_tightener_status", "question": "Wire tightener condition", "type": "select", "options": ["Зүгээр", "Сайжруулах шаардлагатай", "Солих шаардлагатай"], "required": true},
    {"id": "wire_tightener_comment", "question": "Wire tightener comments", "type": "text", "required": false},
    {"id": "resistor_element_status", "question": "Resistor element condition", "type": "select", "options": ["Зүгээр", "Сайжруулах шаардлагатай", "Солих шаардлагатай"], "required": true},
    {"id": "resistor_element_comment", "question": "Resistor element comments", "type": "text", "required": false},
    {"id": "protective_box_status", "question": "Protective box condition", "type": "select", "options": ["Зүгээр", "Сайжруулах шаардлагатай", "Солих шаардлагатай"], "required": true},
    {"id": "protective_box_comment", "question": "Protective box comments", "type": "text", "required": false}
  ]},
  {"section": "sensor", "title": "Sensor Inspection", "fields": [
    {"id": "signal_wire_status", "question": "Signal wire condition", "type": "select", "options": ["Зүгээр", "Сайжруулах шаардлагатай", "Солих шаардлагатай"], "required": true},
    {"id": "signal_wire_comment", "question": "Signal wire comments", "type": "text", "required": false},
    {"id": "ball_status", "question": "Ball condition", "type": "select", "options": ["Зүгээр", "Сайжруулах шаардлагатай", "Солих шаардлагатай"], "required": true},
    {"id": "ball_comment", "question": "Ball comments", "type": "text", "required": false},
    {"id": "base_status", "question": "Base condition", "type": "select", "options": ["Зүгээр", "Сайжруулах шаардлагатай", "Солих шаардлагатай"], "required": true},
    {"id": "base_comment", "question": "Base comments", "type": "text", "required": false},
    {"id": "ball_cup_thin_status", "question": "Ball cup thin condition", "type": "select", "options": ["Зүгээр", "Сайжруулах шаардлагатай", "Солих шаардлагатай"], "required": true},
    {"id": "ball_cup_thin_comment", "question": "Ball cup thin comments", "type": "text", "required": false},
    {"id": "plate_status", "question": "Plate condition", "type": "select", "options": ["Зүгээр", "Сайжруулах шаардлагатай", "Солих шаардлагатай"], "required": true},
    {"id": "plate_comment", "question": "Plate comments", "type": "text", "required": false}
  ]},
  {"section": "foundation", "title": "Foundation Inspection", "fields": [
    {"id": "cross_base_status", "question": "Cross base condition", "type": "select", "options": ["Зүгээр", "Сайжруулах шаардлагатай", "Солих шаардлагатай"], "required": true},
    {"id": "cross_base_comment", "question": "Cross base comments", "type": "text", "required": false},
    {"id": "anchor_plate_status", "question": "Anchor plate condition", "type": "select", "options": ["Зүгээр", "Сайжруулах шаардлагатай", "Солих шаардлагатай"], "required": true},
    {"id": "anchor_plate_comment", "question": "Anchor plate comments", "type": "text", "required": false},
    {"id": "ramp_angle_status", "question": "Ramp angle condition", "type": "select", "options": ["Зүгээр", "Сайжруулах шаардлагатай", "Солих шаардлагатай"], "required": true},
    {"id": "ramp_angle_comment", "question": "Ramp angle comments", "type": "text", "required": false},
    {"id": "ramp_stopper_status", "question": "Ramp stopper condition", "type": "select", "options": ["Зүгээр", "Сайжруулах шаардлагатай", "Солих шаардлагатай"], "required": true},
    {"id": "ramp_stopper_comment", "question": "Ramp stopper comments", "type": "text", "required": false},
    {"id": "ramp_status", "question": "Ramp condition", "type": "select", "options": ["Зүгээр", "Сайжруулах шаардлагатай", "Солих шаардлагатай"], "required": true},
    {"id": "ramp_comment", "question": "Ramp comments", "type": "text", "required": false},
    {"id": "slab_base_status", "question": "Slab base condition", "type": "select", "options": ["Зүгээр", "Сайжруулах шаардлагатай", "Солих шаардлагатай"], "required": true},
    {"id": "slab_base_comment", "question": "Slab base comments", "type": "text", "required": false}
  ]},
  {"section": "cleanliness", "title": "Cleanliness Inspection", "fields": [
    {"id": "under_platform_status", "question": "Under platform cleanliness", "type": "select", "options": ["Цэвэр", "Цэвэрлэх шаардлагатай"], "required": true},
    {"id": "under_platform_comment", "question": "Under platform comments", "type": "text", "required": false},
    {"id": "top_platform_status", "question": "Top platform cleanliness", "type": "select", "options": ["Цэвэр", "Цэвэрлэх шаардлагатай"], "required": true},
    {"id": "top_platform_comment", "question": "Top platform comments", "type": "text", "required": false},
    {"id": "gap_platform_ramp_status", "question": "Gap between platform and ramp", "type": "select", "options": ["Саадгүй", "Цэвэрлэх шаардлагатай"], "required": true},
    {"id": "gap_platform_ramp_comment", "question": "Gap platform-ramp comments", "type": "text", "required": false},
    {"id": "both_sides_area_status", "question": "Both sides area", "type": "select", "options": ["Саадгүй", "Цэвэрлэх шаардлагатай"], "required": true},
    {"id": "both_sides_area_comment", "question": "Both sides area comments", "type": "text", "required": false}
  ]},
  {"section": "final", "title": "Final Assessment", "fields": [
    {"id": "remarks", "question": "General remarks and recommendations", "type": "textarea", "required": false},
    {"id": "next_service_date", "question": "Next preventive service date", "type": "date", "required": false},
    {"id": "overall_status", "question": "Overall scale condition", "type": "select", "options": ["Хэвийн", "Сайжруулах шаардлагатай", "Солих шаардлагатай", "Аюултай - Ашиглахыг хориглох"], "required": true}
  ]}
]', 1, NOW(), NOW());

-- 9. Insert Devices (depends on organizations, sites, contracts, device_models)
INSERT INTO devices (id, org_id, site_id, contract_id, model_id, serial_number, asset_tag, status, installed_at, metadata, created_at, updated_at) VALUES
(1, 1, 1, 1, 1, 'S7-001-2024', 'ASSET-001', 'IN_SERVICE', '2024-01-15 10:00:00', '{"location": "Control Panel A", "firmware": "v4.2.1"}', NOW(), NOW()),
(2, 1, 1, 1, 2, 'AB-002-2024', 'ASSET-002', 'IN_SERVICE', '2024-01-20 14:30:00', '{"location": "Control Panel B", "firmware": "v21.01"}', NOW(), NOW()),
(3, 1, 2, 1, 3, 'SE-003-2024', 'ASSET-003', 'IN_SERVICE', '2024-02-01 09:15:00', '{"location": "Warehouse Control", "firmware": "v1.4.0"}', NOW(), NOW()),
(4, 1, 3, 2, 4, 'OM-004-2024', 'ASSET-004', 'IN_SERVICE', '2024-02-10 11:45:00', '{"location": "QC Station 1", "firmware": "v2.3.1"}', NOW(), NOW()),
(5, 2, 4, 3, 5, 'MI-005-2024', 'ASSET-005', 'MAINTENANCE', '2024-03-01 08:00:00', '{"location": "Line 1 Control", "firmware": "v3.1.2"}', NOW(), NOW()),
(6, 2, 5, 3, 1, 'S7-006-2024', 'ASSET-006', 'IN_SERVICE', '2024-03-15 13:20:00', '{"location": "Conveyor Control", "firmware": "v4.2.0"}', NOW(), NOW()),
(7, 3, 6, 4, 2, 'AB-007-2024', 'ASSET-007', 'IN_SERVICE', '2024-04-01 10:30:00', '{"location": "Assembly Station A", "firmware": "v21.02"}', NOW(), NOW()),
(8, 3, 7, 4, 3, 'SE-008-2024', 'ASSET-008', 'IN_STOCK', NULL, '{"storage_location": "Parts Room B"}', NOW(), NOW());

-- 10. Insert Inspection Schedules (depends on organizations, devices, sites, inspection_templates)
INSERT INTO inspection_schedules (id, org_id, device_id, site_id, template_id, frequency, interval_days, next_due_date, is_active, created_at, updated_at) VALUES
(1, 1, 1, 1, 1, 'MONTHLY', 30, '2024-02-15', 1, NOW(), NOW()),
(2, 1, 2, 1, 1, 'MONTHLY', 30, '2024-02-20', 1, NOW(), NOW()),
(3, 1, 4, 3, 2, 'QUARTERLY', 90, '2024-05-10', 1, NOW(), NOW()),
(4, 2, 5, 4, 3, 'WEEKLY', 7, '2024-01-22', 1, NOW(), NOW()),
(5, 2, 6, 5, 3, 'MONTHLY', 30, '2024-04-15', 1, NOW(), NOW()),
(6, 3, 7, 6, 1, 'MONTHLY', 30, '2024-05-01', 1, NOW(), NOW());

-- 11. Insert Doc Details (no dependencies)
INSERT INTO doc_details (id, doc_name, created_at, updated_at) VALUES
(1, 'PLC_Manual_S7-1200_v4.2.pdf', NOW(), NOW()),
(2, 'Safety_Procedures_2024.pdf', NOW(), NOW()),
(3, 'Maintenance_Schedule_Q1.xlsx', NOW(), NOW()),
(4, 'Installation_Guide_CompactLogix.pdf', NOW(), NOW());

-- 12. Insert Inspections (depends on organizations, devices, sites, contracts, users, inspection_templates)
INSERT INTO inspections (id, org_id, device_id, site_id, contract_id, template_id, type, title, scheduled_at, started_at, completed_at, status, progress, assigned_to, created_by, updated_by, notes, created_at, updated_at) VALUES
(1, 1, 1, 1, 1, 1, 'INSPECTION', 'Monthly PLC Inspection - Control Panel A', '2024-01-15 09:00:00', '2024-01-15 09:15:00', '2024-01-15 10:30:00', 'APPROVED', 100, 3, 2, 3, 'All systems operating normally. Minor dust buildup cleaned.', NOW(), NOW()),

(2, 1, 2, 1, 1, 1, 'INSPECTION', 'Monthly PLC Inspection - Control Panel B', '2024-01-20 10:00:00', '2024-01-20 10:10:00', '2024-01-20 11:45:00', 'APPROVED', 100, 4, 2, 4, 'System running well. Updated firmware documentation.', NOW(), NOW()),

(3, 1, 4, 3, 2, 2, 'VERIFICATION', 'Safety System Check - QC Station 1', '2024-02-10 14:00:00', '2024-02-10 14:05:00', '2024-02-10 15:15:00', 'APPROVED', 100, 3, 2, 3, 'All safety systems verified and compliant.', NOW(), NOW()),

(4, 2, 5, 4, 3, 3, 'MAINTENANCE', 'Weekly Maintenance - Line 1 Control', '2024-01-15 08:00:00', '2024-01-15 08:30:00', NULL, 'IN_PROGRESS', 75, 6, 5, NULL, 'Maintenance in progress. Awaiting replacement part.', NOW(), NOW()),

(5, 1, 3, 2, 1, 1, 'INSPECTION', 'Warehouse Control System Check', '2024-02-01 11:00:00', NULL, NULL, 'DRAFT', 0, 3, 2, NULL, 'Scheduled for next week.', NOW(), NOW()),

(6, 3, 7, 6, 4, 1, 'INSPECTION', 'Assembly Station A - Monthly Check', '2024-04-01 09:00:00', '2024-04-01 09:20:00', '2024-04-01 10:50:00', 'SUBMITTED', 100, 3, 7, NULL, 'Inspection completed, awaiting approval.', NOW(), NOW()),

(7, 1, 1, 1, 1, 5, 'INSPECTION', 'Weighing Scale Inspection - AS-12345', '2025-08-19 09:00:00', '2025-08-19 09:15:00', '2025-08-19 11:30:00', 'APPROVED', 100, 2, 1, 2, 'Comprehensive weighing scale inspection completed. All systems normal.', NOW(), NOW());

-- 13. Insert Inspection Answers (depends on inspections, users, doc_details)
INSERT INTO inspection_answers (id, inspection_id, answers, doc_id, answered_by, answered_at, created_at, updated_at) VALUES
(1, 1, '{"1": true, "2": 45, "3": "Good", "4": "Minor dust on CPU module, cleaned during inspection"}', 1, 3, '2024-01-15 10:30:00', NOW(), NOW()),

(2, 2, '{"1": true, "2": 42, "3": "Good", "4": "All connections secure, no issues found"}', 1, 4, '2024-01-20 11:45:00', NOW(), NOW()),

(3, 3, '{"1": true, "2": "Pass", "3": true, "4": "Safety documentation updated and filed"}', 2, 3, '2024-02-10 15:15:00', NOW(), NOW()),

(4, 4, '{"1": true, "2": false, "3": true, "4": "Waiting for bearing replacement - Part #BR-4410"}', 3, 6, '2024-01-15 11:30:00', NOW(), NOW()),

(5, 6, '{"1": true, "2": 38, "3": "Good", "4": "System operating within normal parameters"}', 4, 3, '2024-04-01 10:50:00', NOW(), NOW()),

(6, 7, '{
  "inspector": "Ж. Болд",
  "location": "Гүүрийн зүүн гар талын гарц, А хэсэг",
  "scale_id": "AS-12345",
  "serial_no": "SN-987654321",
  "model": "Sommer RQ-30",
  "platform_status": "Зүгээр",
  "platform_comment": "Элдэв цууралтгүй, шулуун",
  "sensor_base_status": "Зүгээр",
  "sensor_base_comment": "",
  "beam_status": "Зүгээр",
  "beam_comment": "",
  "platform_plate_status": "Зүгээр",
  "platform_plate_comment": "Зэвгүй",
  "beam_joint_plate_status": "Зүгээр",
  "beam_joint_plate_comment": "",
  "stop_bolt_status": "Зүгээр",
  "stop_bolt_comment": "Тохируулга хэвийн",
  "interplatform_bolts_status": "Зүгээр",
  "interplatform_bolts_comment": "",
  "led_display_status": "Зүгээр",
  "led_display_comment": "Бүх сегмент асна",
  "power_plug_status": "Зүгээр",
  "power_plug_comment": "",
  "seal_bolt_status": "Бүтэн",
  "seal_bolt_comment": "Лац гэмтээгүй",
  "buttons_status": "Зүгээр",
  "buttons_comment": "",
  "junction_wiring_status": "Зүгээр",
  "junction_wiring_comment": "Холболтууд чанга",
  "serial_converter_status": "Зүгээр",
  "serial_converter_comment": "",
  "box_integrity_status": "Зүгээр",
  "box_integrity_comment": "",
  "collector_board_status": "Зүгээр",
  "collector_board_comment": "",
  "wire_tightener_status": "Зүгээр",
  "wire_tightener_comment": "",
  "resistor_element_status": "Зүгээр",
  "resistor_element_comment": "",
  "protective_box_status": "Зүгээр",
  "protective_box_comment": "",
  "signal_wire_status": "Зүгээр",
  "signal_wire_comment": "Гэмтэлгүй",
  "ball_status": "Зүгээр",
  "ball_comment": "",
  "base_status": "Зүгээр",
  "base_comment": "",
  "ball_cup_thin_status": "Зүгээр",
  "ball_cup_thin_comment": "",
  "plate_status": "Зүгээр",
  "plate_comment": "",
  "cross_base_status": "Зүгээр",
  "cross_base_comment": "",
  "anchor_plate_status": "Зүгээр",
  "anchor_plate_comment": "",
  "ramp_angle_status": "Зүгээр",
  "ramp_angle_comment": "",
  "ramp_stopper_status": "Зүгээр",
  "ramp_stopper_comment": "",
  "ramp_status": "Зүгээр",
  "ramp_comment": "Гулсалтгүй",
  "slab_base_status": "Зүгээр",
  "slab_base_comment": "",
  "under_platform_status": "Цэвэр",
  "under_platform_comment": "",
  "top_platform_status": "Цэвэр",
  "top_platform_comment": "",
  "gap_platform_ramp_status": "Саадгүй",
  "gap_platform_ramp_comment": "",
  "both_sides_area_status": "Саадгүй",
  "both_sides_area_comment": "",
  "remarks": "Бүх үзлэг хэвийн. Дараагийн урьдчилсан үйлчилгээ: 6 сарын дараа.",
  "next_service_date": "2026-02-19",
  "overall_status": "Хэвийн"
}', 1, 2, '2025-08-19 11:30:00', NOW(), NOW());

-- 14. Insert Attachments (depends on inspections, devices, users)
INSERT INTO attachments (id, inspection_id, device_id, filename, original_name, mime_type, size, uploaded_by, created_at) VALUES
(1, 1, 1, 'insp_001_photo1_20240115.jpg', 'Control_Panel_A_Photo.jpg', 'image/jpeg', 2457600, 3, '2024-01-15 10:25:00'),
(2, 1, 1, 'insp_001_photo2_20240115.jpg', 'CPU_Module_Close_Up.jpg', 'image/jpeg', 1843200, 3, '2024-01-15 10:27:00'),
(3, 2, 2, 'insp_002_report_20240120.pdf', 'Inspection_Report_Panel_B.pdf', 'application/pdf', 524288, 4, '2024-01-20 11:50:00'),
(4, 3, 4, 'safety_cert_20240210.pdf', 'Safety_Compliance_Certificate.pdf', 'application/pdf', 387456, 3, '2024-02-10 15:20:00'),
(5, 4, 5, 'maint_photo_20240115.jpg', 'Maintenance_Progress_Photo.jpg', 'image/jpeg', 1956480, 6, '2024-01-15 11:35:00'),
(6, NULL, 8, 'device_specs_20240401.pdf', 'SE-008-2024_Specifications.pdf', 'application/pdf', 756224, 7, '2024-04-01 09:00:00');

-- 15. Insert Audit Logs (depends on users)
INSERT INTO audit_logs (id, table_id, record_id, action, old_data, new_data, user_id, created_at) VALUES
(1, 'users', 3, 'CREATE', NULL, '{"email": "inspector1@techmanufacturing.com", "full_name": "Mike Davis", "role_id": 3}', 1, '2024-01-01 08:00:00'),
(2, 'devices', 1, 'CREATE', NULL, '{"serial_number": "S7-001-2024", "status": "IN_STOCK", "site_id": 1}', 2, '2024-01-15 09:30:00'),
(3, 'devices', 1, 'UPDATE', '{"status": "IN_STOCK"}', '{"status": "IN_SERVICE", "installed_at": "2024-01-15 10:00:00"}', 2, '2024-01-15 10:00:00'),
(4, 'inspections', 1, 'CREATE', NULL, '{"title": "Monthly PLC Inspection - Control Panel A", "status": "DRAFT", "assigned_to": 3}', 2, '2024-01-15 08:45:00'),
(5, 'inspections', 1, 'UPDATE', '{"status": "DRAFT"}', '{"status": "IN_PROGRESS", "started_at": "2024-01-15 09:15:00"}', 3, '2024-01-15 09:15:00'),
(6, 'inspections', 1, 'UPDATE', '{"status": "IN_PROGRESS", "progress": 0}', '{"status": "APPROVED", "progress": 100, "completed_at": "2024-01-15 10:30:00"}', 3, '2024-01-15 10:30:00'),
(7, 'devices', 5, 'UPDATE', '{"status": "IN_SERVICE"}', '{"status": "MAINTENANCE"}', 5, '2024-01-15 08:00:00'),
(8, 'inspection_templates', 1, 'CREATE', NULL, '{"name": "PLC System Inspection", "type": "INSPECTION", "is_active": true}', 1, '2024-01-01 10:00:00');

-- Final message
SELECT 'Test data insertion completed successfully!' as result;
