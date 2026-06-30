from flask import Blueprint, jsonify
from db import get_connection, release_connection
import oracledb

departments_bp = Blueprint('departments', __name__)

def dict_factory(cursor, row):
    return dict((col[0].upper(), row[idx]) for idx, col in enumerate(cursor.description))

@departments_bp.route('', methods=['GET'])
def get_departments():
    conn = get_connection()
    if not conn:
        return jsonify({"success": False, "error": "Database error"}), 500

    try:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM DEPARTMENT")
        columns = [col[0].upper() for col in cursor.description]
        cursor.rowfactory = lambda *args: dict(zip(columns, args))
        rows = cursor.fetchall()
        return jsonify({"success": True, "data": rows})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500
    finally:
        if 'cursor' in locals():
            cursor.close()
        release_connection(conn)

@departments_bp.route('/<int:dept_id>/stats', methods=['GET'])
def get_department_stats(dept_id):
    conn = get_connection()
    if not conn:
        return jsonify({"success": False, "error": "Database error"}), 500

    try:
        cursor = conn.cursor()
        
        # Get total complaints
        cursor.execute("SELECT COUNT(*) FROM ASSIGNMENT WHERE dept_id = :1", [dept_id])
        total_complaints = cursor.fetchone()[0]
        
        # Get Average Resolution Time
        cursor.execute("SELECT get_avg_resolution_time(:1) FROM DUAL", [dept_id])
        avg_time = cursor.fetchone()[0]
        
        # Get Performance Score
        cursor.execute("SELECT get_dept_performance_score(:1) FROM DUAL", [dept_id])
        score = cursor.fetchone()[0]
        
        return jsonify({
            "success": True, 
            "data": {
                "dept_id": dept_id,
                "total_complaints": total_complaints,
                "avg_resolution_days": avg_time,
                "performance_score": score
            }
        })
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500
    finally:
        if 'cursor' in locals():
            cursor.close()
        release_connection(conn)
