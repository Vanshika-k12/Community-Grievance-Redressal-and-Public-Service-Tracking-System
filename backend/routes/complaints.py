from flask import Blueprint, request, jsonify
from db import get_connection, release_connection
import oracledb

complaints_bp = Blueprint('complaints', __name__)

def dict_factory(cursor, row):
    return dict((col[0].upper(), row[idx]) for idx, col in enumerate(cursor.description))

@complaints_bp.route('', methods=['POST'])
def create_complaint():
    data = request.json
    conn = get_connection()
    if not conn:
        return jsonify({"success": False, "error": "Database connection error"}), 500

    try:
        cursor = conn.cursor()
        complaint_id_var = cursor.var(oracledb.NUMBER)
        
        cursor.callproc('register_complaint', [
            int(data['citizen_id']), 
            int(data['ward_id']), 
            data['category'], 
            data['description'], 
            data['priority'], 
            complaint_id_var
        ])
        
        complaint_id = int(complaint_id_var.getvalue())
        
        # Fetch the auto-assigned deadline
        cursor.execute("SELECT deadline_date FROM ASSIGNMENT WHERE complaint_id = :1", [complaint_id])
        row = cursor.fetchone()
        deadline = row[0].strftime('%Y-%m-%d') if row else None
        
        return jsonify({
            "success": True, 
            "data": {"complaint_id": complaint_id, "deadline_date": deadline}
        }), 201
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500
    finally:
        if 'cursor' in locals():
            cursor.close()
        release_connection(conn)

@complaints_bp.route('', methods=['GET'])
def get_all_complaints():
    ward_id = request.args.get('ward_id')
    dept_id = request.args.get('dept_id')
    status = request.args.get('status')
    category = request.args.get('category')
    
    conn = get_connection()
    if not conn:
        return jsonify({"success": False, "error": "Database error"}), 500

    try:
        cursor = conn.cursor()
        
        sql = "SELECT * FROM admin_dashboard_view WHERE 1=1"
        params = {}
        
        if ward_id:
            sql += " AND ward_id = :ward_id"
            params['ward_id'] = ward_id
        if dept_id:
            sql += " AND dept_id = :dept_id"
            params['dept_id'] = dept_id
        if status:
            sql += " AND status = :status"
            params['status'] = status
        if category:
            sql += " AND category = :category"
            params['category'] = category
            
        sql += " ORDER BY complaint_date DESC"
        
        cursor.execute(sql, params)
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

@complaints_bp.route('/<int:complaint_id>', methods=['GET'])
def get_complaint(complaint_id):
    conn = get_connection()
    if not conn:
        return jsonify({"success": False, "error": "Database error"}), 500

    try:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM admin_dashboard_view WHERE complaint_id = :1", [complaint_id])
        columns = [col[0].upper() for col in cursor.description]
        cursor.rowfactory = lambda *args: dict(zip(columns, args))
        row = cursor.fetchone()
        if not row:
            return jsonify({"success": False, "error": "Complaint not found"}), 404
        return jsonify({"success": True, "data": row})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500
    finally:
        if 'cursor' in locals():
            cursor.close()
        release_connection(conn)

@complaints_bp.route('/citizen/<int:citizen_id>', methods=['GET'])
def get_citizen_complaints(citizen_id):
    conn = get_connection()
    if not conn:
        return jsonify({"success": False, "error": "Database error"}), 500

    try:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM citizen_complaint_view WHERE citizen_id = :1 ORDER BY complaint_date DESC", [citizen_id])
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

@complaints_bp.route('/official/<int:official_id>', methods=['GET'])
def get_official_complaints(official_id):
    conn = get_connection()
    if not conn:
        return jsonify({"success": False, "error": "Database error"}), 500

    try:
        cursor = conn.cursor()
        sql = """
            SELECT c.*, a.assigned_date, a.deadline_date, w.ward_name
            FROM COMPLAINT c
            JOIN ASSIGNMENT a ON c.complaint_id = a.complaint_id
            JOIN WARD w ON c.ward_id = w.ward_id
            JOIN GOVERNMENT_OFFICIAL g ON g.dept_id = a.dept_id
            WHERE g.official_id = :1
            ORDER BY a.deadline_date ASC
        """
        cursor.execute(sql, [official_id])
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

@complaints_bp.route('/<int:complaint_id>/status', methods=['PUT'])
def update_status(complaint_id):
    data = request.json
    new_status = data.get('status')
    
    conn = get_connection()
    if not conn:
        return jsonify({"success": False, "error": "Database error"}), 500

    try:
        cursor = conn.cursor()
        cursor.execute("UPDATE COMPLAINT SET status = :1 WHERE complaint_id = :2", [new_status, complaint_id])
        conn.commit()
        return jsonify({"success": True, "data": {"message": "Status updated successfully"}})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500
    finally:
        if 'cursor' in locals():
            cursor.close()
        release_connection(conn)
