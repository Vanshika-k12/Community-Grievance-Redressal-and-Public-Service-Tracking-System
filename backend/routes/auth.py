from flask import Blueprint, request, jsonify
from werkzeug.security import generate_password_hash, check_password_hash
from db import get_connection, release_connection
import oracledb

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/register', methods=['POST'])
def register():
    data = request.json
    required_fields = ['name', 'phone', 'email', 'password', 'ward_id']
    if not all(k in data for k in required_fields):
        return jsonify({"success": False, "error": "Missing required fields"}), 400

    hashed_pw = generate_password_hash(data['password'])
    conn = get_connection()
    if not conn:
        return jsonify({"success": False, "error": "Database connection error"}), 500

    try:
        cursor = conn.cursor()
        citizen_id_var = cursor.var(oracledb.NUMBER)
        
        # Use simple INSERT returning citizen_id
        sql = """
            INSERT INTO CITIZEN (name, phone, email, password_hash, ward_id)
            VALUES (:name, :phone, :email, :password_hash, :ward_id)
            RETURNING citizen_id INTO :citizen_id
        """
        cursor.execute(sql, {
            'name': data['name'],
            'phone': data['phone'],
            'email': data['email'],
            'password_hash': hashed_pw,
            'ward_id': int(data['ward_id']),
            'citizen_id': citizen_id_var
        })
        conn.commit()
        citizen_id = citizen_id_var.getvalue()[0]
        
        return jsonify({
            "success": True, 
            "data": {"message": "Registration successful", "citizen_id": int(citizen_id)}
        }), 201
    except oracledb.IntegrityError as e:
        error_obj, = e.args
        return jsonify({"success": False, "error": f"Integrity error: {error_obj.message}"}), 400
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500
    finally:
        if 'cursor' in locals():
            cursor.close()
        release_connection(conn)

@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.json
    role = data.get('role', 'citizen')
    password = data.get('password')
    
    conn = get_connection()
    if not conn:
        return jsonify({"success": False, "error": "Database connection error"}), 500

    try:
        cursor = conn.cursor()
        
        if role == 'citizen':
            phone = data.get('phone')
            cursor.execute("SELECT citizen_id, name, password_hash FROM CITIZEN WHERE phone = :phone", {'phone': phone})
            row = cursor.fetchone()
            if row and check_password_hash(row[2], password):
                return jsonify({"success": True, "data": {"token": "dummy-token", "role": "citizen", "id": row[0], "name": row[1]}})
        
        elif role in ['official', 'admin']:
            official_id = data.get('employee_id')
            cursor.execute("SELECT official_id, name, password_hash, designation FROM GOVERNMENT_OFFICIAL WHERE official_id = :id", {'id': official_id})
            row = cursor.fetchone()
            if row and check_password_hash(row[2], password):
                # Simple check for admin role
                user_role = 'admin' if row[3] == 'Administrator' else 'official'
                if role == 'admin' and user_role != 'admin':
                    return jsonify({"success": False, "error": "Not an administrator"}), 403
                return jsonify({"success": True, "data": {"token": "dummy-token", "role": user_role, "id": row[0], "name": row[1]}})
        
        return jsonify({"success": False, "error": "Invalid credentials"}), 401
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500
    finally:
        if 'cursor' in locals():
            cursor.close()
        release_connection(conn)

@auth_bp.route('/logout', methods=['POST'])
def logout():
    return jsonify({"success": True, "data": {"message": "Logged out successfully"}})
