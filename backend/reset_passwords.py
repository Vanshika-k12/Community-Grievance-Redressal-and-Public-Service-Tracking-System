from werkzeug.security import generate_password_hash
from db import get_connection, release_connection

def reset_passwords():
    conn = get_connection()
    if not conn:
        print("Failed to connect to DB")
        return
        
    try:
        cursor = conn.cursor()
        hashed_pw = generate_password_hash('password')
        
        cursor.execute("UPDATE CITIZEN SET password_hash = :1", [hashed_pw])
        cursor.execute("UPDATE GOVERNMENT_OFFICIAL SET password_hash = :1", [hashed_pw])
        
        conn.commit()
        print("Successfully reset all user passwords to 'password'")
    except Exception as e:
        print(f"Error: {e}")
    finally:
        if 'cursor' in locals():
            cursor.close()
        release_connection(conn)

if __name__ == '__main__':
    reset_passwords()
