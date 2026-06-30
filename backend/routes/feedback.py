from flask import Blueprint, request, jsonify
from db import get_connection, release_connection
import oracledb

feedback_bp = Blueprint('feedback', __name__)

def dict_factory(cursor, row):
    return dict((col[0].upper(), row[idx]) for idx, col in enumerate(cursor.description))

@feedback_bp.route('', methods=['POST'])
def submit_feedback():
    data = request.json
    conn = get_connection()
    if not conn:
        return jsonify({"success": False, "error": "Database error"}), 500

    try:
        cursor = conn.cursor()
        feedback_id_var = cursor.var(oracledb.NUMBER)
        
        sql = """
            INSERT INTO FEEDBACK (complaint_id, citizen_id, rating, comments)
            VALUES (:1, :2, :3, :4)
            RETURNING feedback_id INTO :5
        """
        cursor.execute(sql, [
            int(data['complaint_id']),
            int(data['citizen_id']),
            int(data['rating']),
            data.get('comments', ''),
            feedback_id_var
        ])
        conn.commit()
        feedback_id = int(feedback_id_var.getvalue()[0])
        
        return jsonify({
            "success": True, 
            "data": {"feedback_id": feedback_id, "message": "Feedback submitted successfully"}
        }), 201
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500
    finally:
        if 'cursor' in locals():
            cursor.close()
        release_connection(conn)

@feedback_bp.route('/<int:complaint_id>', methods=['GET'])
def get_feedback(complaint_id):
    conn = get_connection()
    if not conn:
        return jsonify({"success": False, "error": "Database error"}), 500

    try:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM FEEDBACK WHERE complaint_id = :1", [complaint_id])
        columns = [col[0].upper() for col in cursor.description]
        cursor.rowfactory = lambda *args: dict(zip(columns, args))
        row = cursor.fetchone()
        
        if row:
            return jsonify({"success": True, "data": row})
        else:
            return jsonify({"success": False, "error": "Feedback not found"}), 404
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500
    finally:
        if 'cursor' in locals():
            cursor.close()
        release_connection(conn)
