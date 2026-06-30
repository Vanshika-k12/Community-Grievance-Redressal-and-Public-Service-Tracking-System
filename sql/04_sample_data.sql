-- ============================================================
-- SAMPLE DATA for NagarSeva Grievance System
-- Run AFTER 01_create_tables.sql, 02_triggers.sql, 03_procedures_functions_views.sql
-- ============================================================

-- Insert Departments
INSERT INTO DEPARTMENT (dept_name, dept_head, contact_number) VALUES ('Roads and Infrastructure', 'Rajesh Sharma', '9876543210');
INSERT INTO DEPARTMENT (dept_name, dept_head, contact_number) VALUES ('Street Lighting Division', 'Sunita Desai', '9876543211');
INSERT INTO DEPARTMENT (dept_name, dept_head, contact_number) VALUES ('Water Supply Board', 'Amit Patel', '9876543212');
INSERT INTO DEPARTMENT (dept_name, dept_head, contact_number) VALUES ('Sanitation Department', 'Priya Singh', '9876543213');
INSERT INTO DEPARTMENT (dept_name, dept_head, contact_number) VALUES ('Drainage and Sewage', 'Vikram Reddy', '9876543214');
INSERT INTO DEPARTMENT (dept_name, dept_head, contact_number) VALUES ('General Administration', 'Anjali Gupta', '9876543215');

-- Insert Wards
INSERT INTO WARD (ward_name, councillor_name, population) VALUES ('Ward 1 - Model Town', 'Karan Verma', 25000);
INSERT INTO WARD (ward_name, councillor_name, population) VALUES ('Ward 2 - Railway Colony', 'Meera Iyer', 30000);
INSERT INTO WARD (ward_name, councillor_name, population) VALUES ('Ward 3 - Sector 1', 'Suresh Kumar', 15000);
INSERT INTO WARD (ward_name, councillor_name, population) VALUES ('Ward 4 - Civil Lines', 'Neha Joshi', 45000);
INSERT INTO WARD (ward_name, councillor_name, population) VALUES ('Ward 5 - Industrial Area', 'Rahul Nair', 12000);
INSERT INTO WARD (ward_name, councillor_name, population) VALUES ('Ward 6 - Old City', 'Pooja Bhatia', 50000);

-- ============================================================
-- Insert Citizens (10 citizens)
-- ============================================================
INSERT INTO CITIZEN (name, phone, email, password_hash, ward_id) VALUES ('Aarav Kapoor', '9000000001', 'aarav@example.com', 'temp', 1);
INSERT INTO CITIZEN (name, phone, email, password_hash, ward_id) VALUES ('Vivaan Menon', '9000000002', 'vivaan@example.com', 'temp', 2);
INSERT INTO CITIZEN (name, phone, email, password_hash, ward_id) VALUES ('Aditi Rao', '9000000003', 'aditi@example.com', 'temp', 3);
INSERT INTO CITIZEN (name, phone, email, password_hash, ward_id) VALUES ('Diya Jain', '9000000004', 'diya@example.com', 'temp', 4);
INSERT INTO CITIZEN (name, phone, email, password_hash, ward_id) VALUES ('Rohan Das', '9000000005', 'rohan@example.com', 'temp', 5);
INSERT INTO CITIZEN (name, phone, email, password_hash, ward_id) VALUES ('Sanya Malhotra', '9000000006', 'sanya@example.com', 'temp', 6);
INSERT INTO CITIZEN (name, phone, email, password_hash, ward_id) VALUES ('Vanshika Gupta', '9000000007', 'vanshika@example.com', 'temp', 1);
INSERT INTO CITIZEN (name, phone, email, password_hash, ward_id) VALUES ('Aishwarya Verma', '9000000008', 'aishwarya@example.com', 'temp', 2);
INSERT INTO CITIZEN (name, phone, email, password_hash, ward_id) VALUES ('Kavya Nair', '9000000009', 'kavya@example.com', 'temp', 4);
INSERT INTO CITIZEN (name, phone, email, password_hash, ward_id) VALUES ('Arjun Reddy', '9000000010', 'arjun@example.com', 'temp', 6);

-- ============================================================
-- Insert Government Officials
-- ============================================================
INSERT INTO GOVERNMENT_OFFICIAL (name, designation, dept_id, ward_id, password_hash) VALUES ('Ramesh Yadav', 'Junior Engineer', 1, 1, 'temp');
INSERT INTO GOVERNMENT_OFFICIAL (name, designation, dept_id, ward_id, password_hash) VALUES ('Seema Kaur', 'Inspector', 2, 2, 'temp');
INSERT INTO GOVERNMENT_OFFICIAL (name, designation, dept_id, ward_id, password_hash) VALUES ('Tarun Mehta', 'Executive Engineer', 3, 3, 'temp');
INSERT INTO GOVERNMENT_OFFICIAL (name, designation, dept_id, ward_id, password_hash) VALUES ('Kavita Pillai', 'Supervisor', 4, 4, 'temp');
INSERT INTO GOVERNMENT_OFFICIAL (name, designation, dept_id, ward_id, password_hash) VALUES ('Manish Tiwari', 'Manager', 5, 5, 'temp');
INSERT INTO GOVERNMENT_OFFICIAL (name, designation, dept_id, ward_id, password_hash) VALUES ('Nidhi Rathi', 'Clerk', 6, 6, 'temp');
INSERT INTO GOVERNMENT_OFFICIAL (name, designation, dept_id, ward_id, password_hash) VALUES ('Admin User', 'Administrator', 6, 1, 'temp');

-- ============================================================
-- DISABLE TRIGGERS temporarily so we can insert sample data 
-- with explicit statuses without triggers interfering
-- ============================================================
ALTER TRIGGER trg_auto_assign_complaint DISABLE;
ALTER TRIGGER trg_update_complaint_assigned DISABLE;
ALTER TRIGGER trg_complaint_resolved DISABLE;
ALTER TRIGGER trg_auto_escalate DISABLE;

-- ============================================================
-- Insert 20 Complaints with EXPLICIT final statuses
-- ============================================================

-- === 6 RESOLVED complaints ===
INSERT INTO COMPLAINT (citizen_id, ward_id, category, description, priority, status, complaint_date) 
VALUES (1, 1, 'Roads', 'Large pothole on main road near Model Town gate causing accidents.', 'Critical', 'Resolved', SYSDATE - 30);

INSERT INTO COMPLAINT (citizen_id, ward_id, category, description, priority, status, complaint_date) 
VALUES (4, 4, 'Sanitation', 'Garbage dump overflowing near Civil Lines park, health hazard.', 'Medium', 'Resolved', SYSDATE - 25);

INSERT INTO COMPLAINT (citizen_id, ward_id, category, description, priority, status, complaint_date) 
VALUES (8, 2, 'Water Supply', 'Water pipeline leaking continuously on Railway Colony main street.', 'Medium', 'Resolved', SYSDATE - 18);

INSERT INTO COMPLAINT (citizen_id, ward_id, category, description, priority, status, complaint_date) 
VALUES (1, 1, 'Drainage', 'Blocked drain near Model Town market causing waterlogging during rain.', 'Medium', 'Resolved', SYSDATE - 22);

INSERT INTO COMPLAINT (citizen_id, ward_id, category, description, priority, status, complaint_date) 
VALUES (6, 6, 'Street Lights', 'Flickering street lights near Old City bus stop creating disturbance.', 'Medium', 'Resolved', SYSDATE - 14);

INSERT INTO COMPLAINT (citizen_id, ward_id, category, description, priority, status, complaint_date) 
VALUES (9, 4, 'Roads', 'Broken road divider near Civil Lines hospital causing traffic chaos.', 'High', 'Resolved', SYSDATE - 16);

-- === 4 IN PROGRESS complaints ===
INSERT INTO COMPLAINT (citizen_id, ward_id, category, description, priority, status, complaint_date) 
VALUES (3, 3, 'Water Supply', 'No water supply since yesterday morning in entire Sector 1.', 'Critical', 'In Progress', SYSDATE - 5);

INSERT INTO COMPLAINT (citizen_id, ward_id, category, description, priority, status, complaint_date) 
VALUES (5, 5, 'Drainage', 'Open manhole on industrial road emitting foul smell.', 'High', 'In Progress', SYSDATE - 10);

INSERT INTO COMPLAINT (citizen_id, ward_id, category, description, priority, status, complaint_date) 
VALUES (9, 4, 'Street Lights', 'Complete blackout on Civil Lines main market road, very unsafe at night.', 'Critical', 'In Progress', SYSDATE - 4);

INSERT INTO COMPLAINT (citizen_id, ward_id, category, description, priority, status, complaint_date) 
VALUES (4, 4, 'Roads', 'Road cave-in near Civil Lines bus stand, vehicles stuck.', 'Critical', 'In Progress', SYSDATE - 2);

-- === 2 ESCALATED complaints ===
INSERT INTO COMPLAINT (citizen_id, ward_id, category, description, priority, status, complaint_date) 
VALUES (2, 2, 'Street Lights', 'Street lights not working in Railway Colony sector 4 for over a week.', 'High', 'Escalated', SYSDATE - 20);

INSERT INTO COMPLAINT (citizen_id, ward_id, category, description, priority, status, complaint_date) 
VALUES (7, 1, 'Drainage', 'Sewage overflowing onto Model Town residential street after heavy rain.', 'Critical', 'Escalated', SYSDATE - 8);

-- === 8 ASSIGNED complaints (freshly filed, waiting for action) ===
INSERT INTO COMPLAINT (citizen_id, ward_id, category, description, priority, status, complaint_date) 
VALUES (6, 6, 'Other', 'Stray dogs menace in Old City locality near temple road.', 'Low', 'Assigned', SYSDATE - 3);

INSERT INTO COMPLAINT (citizen_id, ward_id, category, description, priority, status, complaint_date) 
VALUES (7, 1, 'Roads', 'Speed breaker completely worn out on NH bypass near Model Town.', 'High', 'Assigned', SYSDATE - 7);

INSERT INTO COMPLAINT (citizen_id, ward_id, category, description, priority, status, complaint_date) 
VALUES (10, 6, 'Sanitation', 'Public dustbins in Old City not cleared for 5 days, flies everywhere.', 'High', 'Assigned', SYSDATE - 6);

INSERT INTO COMPLAINT (citizen_id, ward_id, category, description, priority, status, complaint_date) 
VALUES (2, 2, 'Sanitation', 'Littering issue near Railway Colony school entrance.', 'Low', 'Assigned', SYSDATE - 12);

INSERT INTO COMPLAINT (citizen_id, ward_id, category, description, priority, status, complaint_date) 
VALUES (5, 5, 'Water Supply', 'Low water pressure in Industrial Area Block C since last month.', 'Low', 'Assigned', SYSDATE - 15);

INSERT INTO COMPLAINT (citizen_id, ward_id, category, description, priority, status, complaint_date) 
VALUES (8, 2, 'Other', 'Encroachment on public footpath near Railway Colony market.', 'Medium', 'Assigned', SYSDATE - 9);

INSERT INTO COMPLAINT (citizen_id, ward_id, category, description, priority, status, complaint_date) 
VALUES (10, 6, 'Water Supply', 'Contaminated water supply in Old City Block D, brownish color.', 'Critical', 'Assigned', SYSDATE - 1);

INSERT INTO COMPLAINT (citizen_id, ward_id, category, description, priority, status, complaint_date) 
VALUES (3, 3, 'Other', 'Broken bench in Sector 1 community park.', 'Low', 'Assigned', SYSDATE - 11);

-- ============================================================
-- Insert ASSIGNMENTS explicitly for all 20 complaints
-- Maps each complaint to the correct department based on category
-- Dept 1=Roads, 2=Street Lights, 3=Water Supply, 4=Sanitation, 5=Drainage, 6=General Admin
-- ============================================================
INSERT INTO ASSIGNMENT (complaint_id, dept_id, assigned_date, deadline_date) VALUES (1, 1, SYSDATE - 30, SYSDATE - 29);
INSERT INTO ASSIGNMENT (complaint_id, dept_id, assigned_date, deadline_date) VALUES (2, 4, SYSDATE - 25, SYSDATE - 18);
INSERT INTO ASSIGNMENT (complaint_id, dept_id, assigned_date, deadline_date) VALUES (3, 3, SYSDATE - 18, SYSDATE - 11);
INSERT INTO ASSIGNMENT (complaint_id, dept_id, assigned_date, deadline_date) VALUES (4, 5, SYSDATE - 22, SYSDATE - 15);
INSERT INTO ASSIGNMENT (complaint_id, dept_id, assigned_date, deadline_date) VALUES (5, 2, SYSDATE - 14, SYSDATE - 7);
INSERT INTO ASSIGNMENT (complaint_id, dept_id, assigned_date, deadline_date) VALUES (6, 1, SYSDATE - 16, SYSDATE - 13);
INSERT INTO ASSIGNMENT (complaint_id, dept_id, assigned_date, deadline_date) VALUES (7, 3, SYSDATE - 5, SYSDATE - 4);
INSERT INTO ASSIGNMENT (complaint_id, dept_id, assigned_date, deadline_date) VALUES (8, 5, SYSDATE - 10, SYSDATE - 7);
INSERT INTO ASSIGNMENT (complaint_id, dept_id, assigned_date, deadline_date) VALUES (9, 2, SYSDATE - 4, SYSDATE - 3);
INSERT INTO ASSIGNMENT (complaint_id, dept_id, assigned_date, deadline_date) VALUES (10, 1, SYSDATE - 2, SYSDATE - 1);
INSERT INTO ASSIGNMENT (complaint_id, dept_id, assigned_date, deadline_date) VALUES (11, 2, SYSDATE - 20, SYSDATE - 10);
INSERT INTO ASSIGNMENT (complaint_id, dept_id, assigned_date, deadline_date) VALUES (12, 5, SYSDATE - 8, SYSDATE - 1);
INSERT INTO ASSIGNMENT (complaint_id, dept_id, assigned_date, deadline_date) VALUES (13, 6, SYSDATE - 3, SYSDATE + 11);
INSERT INTO ASSIGNMENT (complaint_id, dept_id, assigned_date, deadline_date) VALUES (14, 1, SYSDATE - 7, SYSDATE - 4);
INSERT INTO ASSIGNMENT (complaint_id, dept_id, assigned_date, deadline_date) VALUES (15, 4, SYSDATE - 6, SYSDATE - 3);
INSERT INTO ASSIGNMENT (complaint_id, dept_id, assigned_date, deadline_date) VALUES (16, 4, SYSDATE - 12, SYSDATE + 2);
INSERT INTO ASSIGNMENT (complaint_id, dept_id, assigned_date, deadline_date) VALUES (17, 3, SYSDATE - 15, SYSDATE + 1);
INSERT INTO ASSIGNMENT (complaint_id, dept_id, assigned_date, deadline_date) VALUES (18, 6, SYSDATE - 9, SYSDATE - 2);
INSERT INTO ASSIGNMENT (complaint_id, dept_id, assigned_date, deadline_date) VALUES (19, 3, SYSDATE - 1, SYSDATE);
INSERT INTO ASSIGNMENT (complaint_id, dept_id, assigned_date, deadline_date) VALUES (20, 6, SYSDATE - 11, SYSDATE + 3);

-- ============================================================
-- Insert RESOLUTIONS for the 6 resolved complaints
-- ============================================================
INSERT INTO RESOLUTION (complaint_id, resolved_by_official, action_taken, resolution_date, cost_incurred)
VALUES (1, 1, 'Pothole filled with concrete and road surface leveled.', SYSDATE - 25, 5000);

INSERT INTO RESOLUTION (complaint_id, resolved_by_official, action_taken, resolution_date, cost_incurred)
VALUES (2, 4, 'Garbage cleared and area sanitized. Additional dustbin installed.', SYSDATE - 20, 3000);

INSERT INTO RESOLUTION (complaint_id, resolved_by_official, action_taken, resolution_date, cost_incurred)
VALUES (3, 3, 'Leaking pipeline section replaced with new PVC pipe.', SYSDATE - 12, 15000);

INSERT INTO RESOLUTION (complaint_id, resolved_by_official, action_taken, resolution_date, cost_incurred)
VALUES (4, 5, 'Drain cleaned and de-silted. Gratings installed to prevent blockage.', SYSDATE - 15, 8000);

INSERT INTO RESOLUTION (complaint_id, resolved_by_official, action_taken, resolution_date, cost_incurred)
VALUES (5, 2, 'Faulty wiring replaced and LED bulbs installed.', SYSDATE - 8, 4500);

INSERT INTO RESOLUTION (complaint_id, resolved_by_official, action_taken, resolution_date, cost_incurred)
VALUES (6, 1, 'Road divider repaired with fresh concrete and reflective paint applied.', SYSDATE - 10, 12000);

-- ============================================================
-- Insert ESCALATIONS for the 2 escalated complaints
-- ============================================================
INSERT INTO ESCALATION (complaint_id, escalated_from_official, reason, escalation_date, escalation_level)
VALUES (11, 2, 'Deadline exceeded - no action taken for 10 days.', SYSDATE - 10, 1);

INSERT INTO ESCALATION (complaint_id, escalated_from_official, reason, escalation_date, escalation_level)
VALUES (12, 5, 'Critical sewage overflow not addressed within SLA.', SYSDATE - 1, 2);

-- ============================================================
-- Insert FEEDBACK for resolved complaints
-- ============================================================
INSERT INTO FEEDBACK (complaint_id, citizen_id, rating, comments, feedback_date)
VALUES (1, 1, 5, 'Excellent and prompt work! Road is smooth now.', SYSDATE - 24);

INSERT INTO FEEDBACK (complaint_id, citizen_id, rating, comments, feedback_date)
VALUES (2, 4, 4, 'Good job clearing the garbage. Hope it stays clean.', SYSDATE - 19);

INSERT INTO FEEDBACK (complaint_id, citizen_id, rating, comments, feedback_date)
VALUES (3, 8, 3, 'Pipeline fixed but took too long. Acceptable work.', SYSDATE - 11);

INSERT INTO FEEDBACK (complaint_id, citizen_id, rating, comments, feedback_date)
VALUES (4, 1, 5, 'Drain is clear and no more waterlogging. Great work!', SYSDATE - 14);

INSERT INTO FEEDBACK (complaint_id, citizen_id, rating, comments, feedback_date)
VALUES (5, 6, 4, 'Lights working perfectly now. Thank you.', SYSDATE - 7);

INSERT INTO FEEDBACK (complaint_id, citizen_id, rating, comments, feedback_date)
VALUES (6, 9, 2, 'Divider fixed but paint quality is poor. Needs improvement.', SYSDATE - 9);

-- ============================================================
-- RE-ENABLE all triggers for normal operation
-- ============================================================
ALTER TRIGGER trg_auto_assign_complaint ENABLE;
ALTER TRIGGER trg_update_complaint_assigned ENABLE;
ALTER TRIGGER trg_complaint_resolved ENABLE;
ALTER TRIGGER trg_auto_escalate ENABLE;

COMMIT;
