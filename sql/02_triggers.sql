-- Trigger 1: Auto-assign complaint to corresponding department
CREATE OR REPLACE TRIGGER trg_auto_assign_complaint
AFTER INSERT ON COMPLAINT
FOR EACH ROW
DECLARE
    v_dept_id NUMBER;
    v_deadline_days NUMBER;
BEGIN
    -- Determine department based on category
    BEGIN
        IF :NEW.category = 'Roads' THEN
            SELECT dept_id INTO v_dept_id FROM DEPARTMENT WHERE dept_name = 'Roads and Infrastructure' FETCH FIRST 1 ROW ONLY;
        ELSIF :NEW.category = 'Street Lights' THEN
            SELECT dept_id INTO v_dept_id FROM DEPARTMENT WHERE dept_name = 'Street Lighting Division' FETCH FIRST 1 ROW ONLY;
        ELSIF :NEW.category = 'Water Supply' THEN
            SELECT dept_id INTO v_dept_id FROM DEPARTMENT WHERE dept_name = 'Water Supply Board' FETCH FIRST 1 ROW ONLY;
        ELSIF :NEW.category = 'Sanitation' THEN
            SELECT dept_id INTO v_dept_id FROM DEPARTMENT WHERE dept_name = 'Sanitation Department' FETCH FIRST 1 ROW ONLY;
        ELSIF :NEW.category = 'Drainage' THEN
            SELECT dept_id INTO v_dept_id FROM DEPARTMENT WHERE dept_name = 'Drainage and Sewage' FETCH FIRST 1 ROW ONLY;
        ELSE
            SELECT dept_id INTO v_dept_id FROM DEPARTMENT WHERE dept_name = 'General Administration' FETCH FIRST 1 ROW ONLY;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_dept_id := NULL; -- If department doesn't exist, leave it unassigned (or handle via default)
    END;

    -- Determine deadline based on priority
    IF :NEW.priority = 'Critical' THEN
        v_deadline_days := 1;
    ELSIF :NEW.priority = 'High' THEN
        v_deadline_days := 3;
    ELSIF :NEW.priority = 'Medium' THEN
        v_deadline_days := 7;
    ELSIF :NEW.priority = 'Low' THEN
        v_deadline_days := 14;
    ELSE
        v_deadline_days := 7;
    END IF;

    IF v_dept_id IS NOT NULL THEN
        INSERT INTO ASSIGNMENT (complaint_id, dept_id, assigned_date, deadline_date)
        VALUES (:NEW.complaint_id, v_dept_id, SYSDATE, SYSDATE + v_deadline_days);

        -- Note: We do not update the COMPLAINT table directly here to avoid mutating table issues
        -- if it's considered mutating. Wait, the prompt says "Update complaint status to 'Assigned'".
        -- PRAGMA AUTONOMOUS_TRANSACTION is required if updating the same table in an AFTER row trigger 
        -- or we can do it in the stored procedure instead.
        -- But wait, standard oracle: "After INSERT on COMPLAINT... update complaint status to 'Assigned'".
        -- In an AFTER INSERT row trigger on COMPLAINT, updating COMPLAINT causes ORA-04091.
        -- We will use PRAGMA AUTONOMOUS_TRANSACTION to fulfill the prompt's exact requirement.
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_update_complaint_assigned
AFTER INSERT ON ASSIGNMENT
FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    UPDATE COMPLAINT SET status = 'Assigned' WHERE complaint_id = :NEW.complaint_id AND status = 'Pending';
    COMMIT;
END;
/

-- Trigger 2: Auto-escalate if deadline passed and status not Resolved/Closed
-- Note: Oracle triggers run on DML. The prompt states "After UPDATE on ASSIGNMENT".
CREATE OR REPLACE TRIGGER trg_auto_escalate
AFTER UPDATE ON ASSIGNMENT
FOR EACH ROW
DECLARE
    v_status VARCHAR2(20);
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    -- Check the current status of the complaint
    SELECT status INTO v_status FROM COMPLAINT WHERE complaint_id = :NEW.complaint_id;

    IF :NEW.deadline_date < SYSDATE AND v_status NOT IN ('Resolved', 'Closed', 'Escalated') THEN
        INSERT INTO ESCALATION (complaint_id, escalated_from_official, reason, escalation_date, escalation_level)
        VALUES (:NEW.complaint_id, :NEW.assigned_to_official, 'Deadline exceeded', SYSDATE, 1);

        UPDATE COMPLAINT SET status = 'Escalated' WHERE complaint_id = :NEW.complaint_id;
        COMMIT;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

-- Trigger 3: Update COMPLAINT status to 'Resolved' after resolution
CREATE OR REPLACE TRIGGER trg_complaint_resolved
AFTER INSERT ON RESOLUTION
FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    UPDATE COMPLAINT 
    SET status = 'Resolved' 
    WHERE complaint_id = :NEW.complaint_id;
    COMMIT;
END;
/
