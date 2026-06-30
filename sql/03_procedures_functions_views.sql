CREATE OR REPLACE PROCEDURE register_complaint(
    p_citizen_id IN NUMBER,
    p_ward_id IN NUMBER,
    p_category IN VARCHAR2,
    p_description IN VARCHAR2,
    p_priority IN VARCHAR2,
    p_complaint_id OUT NUMBER
) AS
BEGIN
    INSERT INTO COMPLAINT (citizen_id, ward_id, category, description, priority)
    VALUES (p_citizen_id, p_ward_id, p_category, p_description, p_priority)
    RETURNING complaint_id INTO p_complaint_id;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END register_complaint;
/

CREATE OR REPLACE PROCEDURE resolve_complaint(
    p_complaint_id IN NUMBER,
    p_official_id IN NUMBER,
    p_action_taken IN VARCHAR2,
    p_cost IN NUMBER
) AS
BEGIN
    INSERT INTO RESOLUTION (complaint_id, resolved_by_official, action_taken, cost_incurred)
    VALUES (p_complaint_id, p_official_id, p_action_taken, p_cost);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END resolve_complaint;
/

CREATE OR REPLACE FUNCTION get_avg_resolution_time(p_dept_id IN NUMBER)
RETURN NUMBER AS
    v_avg_days NUMBER;
BEGIN
    SELECT NVL(AVG(r.resolution_date - c.complaint_date), 0)
    INTO v_avg_days
    FROM COMPLAINT c
    JOIN ASSIGNMENT a ON c.complaint_id = a.complaint_id
    JOIN RESOLUTION r ON c.complaint_id = r.complaint_id
    WHERE a.dept_id = p_dept_id;
    
    RETURN ROUND(v_avg_days, 2);
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END get_avg_resolution_time;
/

CREATE OR REPLACE FUNCTION get_dept_performance_score(p_dept_id IN NUMBER)
RETURN NUMBER AS
    v_total_complaints NUMBER;
    v_resolved_complaints NUMBER;
    v_resolution_rate NUMBER := 0;
    v_avg_rating NUMBER := 0;
    v_final_score NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO v_total_complaints
    FROM ASSIGNMENT
    WHERE dept_id = p_dept_id;

    IF v_total_complaints > 0 THEN
        SELECT COUNT(*) INTO v_resolved_complaints
        FROM ASSIGNMENT a
        JOIN COMPLAINT c ON a.complaint_id = c.complaint_id
        WHERE a.dept_id = p_dept_id AND c.status IN ('Resolved', 'Closed');
        
        v_resolution_rate := (v_resolved_complaints / v_total_complaints) * 100;
        
        SELECT NVL(AVG(f.rating), 3) INTO v_avg_rating
        FROM FEEDBACK f
        JOIN ASSIGNMENT a ON f.complaint_id = a.complaint_id
        WHERE a.dept_id = p_dept_id;
        
        -- Score out of 100: 70% weight to resolution rate, 30% weight to avg rating (normalized to 100)
        v_final_score := (v_resolution_rate * 0.7) + ((v_avg_rating / 5) * 100 * 0.3);
    END IF;

    RETURN ROUND(v_final_score, 2);
END get_dept_performance_score;
/

CREATE OR REPLACE VIEW citizen_complaint_view AS
SELECT 
    c.citizen_id,
    cz.name AS citizen_name,
    c.complaint_id,
    c.category,
    c.description,
    c.priority,
    c.status,
    c.complaint_date,
    a.assigned_date,
    a.deadline_date,
    d.dept_name,
    d.contact_number AS dept_contact
FROM COMPLAINT c
LEFT JOIN CITIZEN cz ON c.citizen_id = cz.citizen_id
LEFT JOIN ASSIGNMENT a ON c.complaint_id = a.complaint_id
LEFT JOIN DEPARTMENT d ON a.dept_id = d.dept_id;

CREATE OR REPLACE VIEW admin_dashboard_view AS
SELECT 
    c.complaint_id,
    c.category,
    c.priority,
    c.status,
    c.complaint_date,
    cz.citizen_id,
    cz.name AS citizen_name,
    cz.phone,
    w.ward_id,
    w.ward_name,
    a.assignment_id,
    a.assigned_date,
    a.deadline_date,
    d.dept_id,
    d.dept_name,
    go.official_id,
    go.name AS official_name,
    r.resolution_date,
    r.action_taken,
    r.cost_incurred,
    e.escalation_level,
    e.reason AS escalation_reason,
    f.rating AS feedback_rating
FROM COMPLAINT c
LEFT JOIN CITIZEN cz ON c.citizen_id = cz.citizen_id
LEFT JOIN WARD w ON c.ward_id = w.ward_id
LEFT JOIN ASSIGNMENT a ON c.complaint_id = a.complaint_id
LEFT JOIN DEPARTMENT d ON a.dept_id = d.dept_id
LEFT JOIN GOVERNMENT_OFFICIAL go ON a.assigned_to_official = go.official_id
LEFT JOIN RESOLUTION r ON c.complaint_id = r.complaint_id
LEFT JOIN ESCALATION e ON c.complaint_id = e.complaint_id
LEFT JOIN FEEDBACK f ON c.complaint_id = f.complaint_id;
