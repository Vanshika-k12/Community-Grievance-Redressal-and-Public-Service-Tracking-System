from flask import Blueprint, jsonify
from db import get_connection, release_connection

analytics_bp = Blueprint('analytics', __name__)

def dict_factory(cursor, row):
    return dict((col[0].upper(), row[idx]) for idx, col in enumerate(cursor.description))

@analytics_bp.route('/complaints-by-department', methods=['GET'])
def complaints_by_dept():
    conn = get_connection()
    if not conn: return jsonify({"success": False, "error": "DB Error"}), 500
    try:
        cursor = conn.cursor()
        sql = """
            SELECT d.dept_name, COUNT(a.complaint_id) as count
            FROM DEPARTMENT d
            LEFT JOIN ASSIGNMENT a ON d.dept_id = a.dept_id
            GROUP BY d.dept_name
        """
        cursor.execute(sql)
        columns = [col[0].upper() for col in cursor.description]
        cursor.rowfactory = lambda *args: dict(zip(columns, args))
        return jsonify({"success": True, "data": cursor.fetchall()})
    except Exception as e: return jsonify({"success": False, "error": str(e)}), 500
    finally:
        if 'cursor' in locals(): cursor.close()
        release_connection(conn)

@analytics_bp.route('/complaints-by-status', methods=['GET'])
def complaints_by_status():
    conn = get_connection()
    if not conn: return jsonify({"success": False, "error": "DB Error"}), 500
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT status, COUNT(*) as count FROM COMPLAINT GROUP BY status")
        columns = [col[0].upper() for col in cursor.description]
        cursor.rowfactory = lambda *args: dict(zip(columns, args))
        return jsonify({"success": True, "data": cursor.fetchall()})
    except Exception as e: return jsonify({"success": False, "error": str(e)}), 500
    finally:
        if 'cursor' in locals(): cursor.close()
        release_connection(conn)

@analytics_bp.route('/complaints-by-month', methods=['GET'])
def complaints_by_month():
    conn = get_connection()
    if not conn: return jsonify({"success": False, "error": "DB Error"}), 500
    try:
        cursor = conn.cursor()
        sql = """
            SELECT TO_CHAR(complaint_date, 'YYYY-MM') as month, COUNT(*) as count
            FROM COMPLAINT
            WHERE complaint_date >= ADD_MONTHS(SYSDATE, -6)
            GROUP BY TO_CHAR(complaint_date, 'YYYY-MM')
            ORDER BY month
        """
        cursor.execute(sql)
        columns = [col[0].upper() for col in cursor.description]
        cursor.rowfactory = lambda *args: dict(zip(columns, args))
        return jsonify({"success": True, "data": cursor.fetchall()})
    except Exception as e: return jsonify({"success": False, "error": str(e)}), 500
    finally:
        if 'cursor' in locals(): cursor.close()
        release_connection(conn)

@analytics_bp.route('/top-wards', methods=['GET'])
def top_wards():
    conn = get_connection()
    if not conn: return jsonify({"success": False, "error": "DB Error"}), 500
    try:
        cursor = conn.cursor()
        sql = """
            SELECT w.ward_name, COUNT(c.complaint_id) as count
            FROM WARD w
            LEFT JOIN COMPLAINT c ON w.ward_id = c.ward_id
            GROUP BY w.ward_name
            ORDER BY count DESC
            FETCH FIRST 5 ROWS ONLY
        """
        cursor.execute(sql)
        columns = [col[0].upper() for col in cursor.description]
        cursor.rowfactory = lambda *args: dict(zip(columns, args))
        return jsonify({"success": True, "data": cursor.fetchall()})
    except Exception as e: return jsonify({"success": False, "error": str(e)}), 500
    finally:
        if 'cursor' in locals(): cursor.close()
        release_connection(conn)

@analytics_bp.route('/overdue', methods=['GET'])
def overdue_complaints():
    conn = get_connection()
    if not conn: return jsonify({"success": False, "error": "DB Error"}), 500
    try:
        cursor = conn.cursor()
        sql = """
            SELECT c.complaint_id, c.category, a.deadline_date, o.name as official_name, d.dept_name
            FROM COMPLAINT c
            JOIN ASSIGNMENT a ON c.complaint_id = a.complaint_id
            JOIN GOVERNMENT_OFFICIAL o ON a.assigned_to_official = o.official_id
            JOIN DEPARTMENT d ON a.dept_id = d.dept_id
            WHERE a.deadline_date < SYSDATE AND c.status NOT IN ('Resolved', 'Closed')
        """
        cursor.execute(sql)
        columns = [col[0].upper() for col in cursor.description]
        cursor.rowfactory = lambda *args: dict(zip(columns, args))
        return jsonify({"success": True, "data": cursor.fetchall()})
    except Exception as e: return jsonify({"success": False, "error": str(e)}), 500
    finally:
        if 'cursor' in locals(): cursor.close()
        release_connection(conn)

@analytics_bp.route('/escalated', methods=['GET'])
def escalated_complaints():
    conn = get_connection()
    if not conn: return jsonify({"success": False, "error": "DB Error"}), 500
    try:
        cursor = conn.cursor()
        sql = """
            SELECT c.complaint_id, c.category, e.escalation_level, e.reason, e.escalation_date
            FROM ESCALATION e
            JOIN COMPLAINT c ON e.complaint_id = c.complaint_id
            ORDER BY e.escalation_date DESC
        """
        cursor.execute(sql)
        columns = [col[0].upper() for col in cursor.description]
        cursor.rowfactory = lambda *args: dict(zip(columns, args))
        return jsonify({"success": True, "data": cursor.fetchall()})
    except Exception as e: return jsonify({"success": False, "error": str(e)}), 500
    finally:
        if 'cursor' in locals(): cursor.close()
        release_connection(conn)
