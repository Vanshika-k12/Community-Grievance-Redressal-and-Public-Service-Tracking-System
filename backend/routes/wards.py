from flask import Blueprint, jsonify
from db import get_connection, release_connection

wards_bp = Blueprint('wards', __name__)

def dict_factory(cursor, row):
    return dict((col[0].upper(), row[idx]) for idx, col in enumerate(cursor.description))

@wards_bp.route('', methods=['GET'])
def get_wards():
    conn = get_connection()
    if not conn:
        return jsonify({"success": False, "error": "Database error"}), 500

    try:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM WARD ORDER BY ward_id")
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
