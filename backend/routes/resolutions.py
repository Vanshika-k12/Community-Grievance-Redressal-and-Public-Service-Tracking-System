from flask import Blueprint, request, jsonify
from db import get_connection, release_connection
import oracledb

resolutions_bp = Blueprint('resolutions', __name__)

@resolutions_bp.route('', methods=['POST'])
def resolve_complaint():
    data = request.json
    required = ['complaint_id', 'official_id', 'action_taken', 'cost_incurred']
    if not all(k in data for k in required):
        return jsonify({"success": False, "error": "Missing required fields"}), 400

    conn = get_connection()
    if not conn:
        return jsonify({"success": False, "error": "Database connection error"}), 500

    try:
        cursor = conn.cursor()
        cursor.callproc('resolve_complaint', [
            int(data['complaint_id']), 
            int(data['official_id']), 
            data['action_taken'], 
            float(data['cost_incurred']) if data.get('cost_incurred') else 0
        ])
        
        # Get the generated resolution_id
        cursor.execute("SELECT resolution_id FROM RESOLUTION WHERE complaint_id = :1", [data['complaint_id']])
        row = cursor.fetchone()
        resolution_id = row[0] if row else None
        
        return jsonify({
            "success": True, 
            "data": {"resolution_id": resolution_id, "message": "Complaint resolved successfully"}
        }), 201
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500
    finally:
        if 'cursor' in locals():
            cursor.close()
        release_connection(conn)
