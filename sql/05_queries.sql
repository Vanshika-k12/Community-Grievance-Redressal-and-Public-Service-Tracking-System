-- 1. All pending complaints in a specific ward with citizen details
-- This query helps the ward councillor track unresolved issues in their area.
SELECT 
    c.complaint_id, 
    c.description, 
    c.priority, 
    cz.name AS citizen_name, 
    cz.phone 
FROM COMPLAINT c
JOIN CITIZEN cz ON c.citizen_id = cz.citizen_id
WHERE c.ward_id = 4 AND c.status = 'Pending';

-- 2. All overdue complaints with assigned official names
-- Useful for administrators to find bottlenecks where officials have missed deadlines.
SELECT 
    c.complaint_id, 
    c.category, 
    c.status, 
    a.deadline_date, 
    o.name AS official_name, 
    d.dept_name
FROM COMPLAINT c
JOIN ASSIGNMENT a ON c.complaint_id = a.complaint_id
JOIN GOVERNMENT_OFFICIAL o ON a.assigned_to_official = o.official_id
JOIN DEPARTMENT d ON a.dept_id = d.dept_id
WHERE a.deadline_date < SYSDATE AND c.status NOT IN ('Resolved', 'Closed');

-- 3. Complaint count per department per category
-- Helps in resource allocation by showing which types of issues are most common per department.
SELECT 
    d.dept_name, 
    c.category, 
    COUNT(c.complaint_id) AS total_complaints
FROM COMPLAINT c
JOIN ASSIGNMENT a ON c.complaint_id = a.complaint_id
JOIN DEPARTMENT d ON a.dept_id = d.dept_id
GROUP BY d.dept_name, c.category
ORDER BY d.dept_name, total_complaints DESC;

-- 4. Top 3 wards with the most complaints in the last 30 days
-- Identifies the most problematic areas requiring urgent attention from city planners.
SELECT 
    w.ward_name, 
    COUNT(c.complaint_id) AS recent_complaints
FROM COMPLAINT c
JOIN WARD w ON c.ward_id = w.ward_id
WHERE c.complaint_date >= SYSDATE - 30
GROUP BY w.ward_name
ORDER BY recent_complaints DESC
FETCH FIRST 3 ROWS ONLY;

-- 5. All escalated complaints with escalation level and reason
-- Gives higher management visibility into issues that require intervention.
SELECT 
    c.complaint_id, 
    c.category, 
    e.escalation_level, 
    e.reason, 
    o1.name AS escalated_from, 
    o2.name AS escalated_to
FROM ESCALATION e
JOIN COMPLAINT c ON e.complaint_id = c.complaint_id
JOIN GOVERNMENT_OFFICIAL o1 ON e.escalated_from_official = o1.official_id
LEFT JOIN GOVERNMENT_OFFICIAL o2 ON e.escalated_to_official = o2.official_id;

-- 6. Average resolution time per department (in days)
-- A key performance indicator (KPI) metric for evaluating department efficiency.
SELECT 
    d.dept_name, 
    ROUND(AVG(r.resolution_date - c.complaint_date), 2) AS avg_resolution_days
FROM RESOLUTION r
JOIN COMPLAINT c ON r.complaint_id = c.complaint_id
JOIN ASSIGNMENT a ON c.complaint_id = a.complaint_id
JOIN DEPARTMENT d ON a.dept_id = d.dept_id
GROUP BY d.dept_name
ORDER BY avg_resolution_days ASC;

-- 7. Citizens who have filed more than 3 complaints
-- Identifies highly active citizens or chronic issues faced by a specific individual.
SELECT 
    cz.name, 
    cz.phone, 
    COUNT(c.complaint_id) AS total_complaints_filed
FROM CITIZEN cz
JOIN COMPLAINT c ON cz.citizen_id = c.citizen_id
GROUP BY cz.name, cz.phone
HAVING COUNT(c.complaint_id) > 3;

-- 8. Department-wise count of complaints resolved within deadline vs overdue
-- Compares on-time delivery vs delayed delivery for performance review.
SELECT 
    d.dept_name,
    SUM(CASE WHEN r.resolution_date <= a.deadline_date THEN 1 ELSE 0 END) AS resolved_on_time,
    SUM(CASE WHEN r.resolution_date > a.deadline_date THEN 1 ELSE 0 END) AS resolved_late
FROM RESOLUTION r
JOIN COMPLAINT c ON r.complaint_id = c.complaint_id
JOIN ASSIGNMENT a ON c.complaint_id = a.complaint_id
JOIN DEPARTMENT d ON a.dept_id = d.dept_id
GROUP BY d.dept_name;
