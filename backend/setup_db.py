import os
from db import get_connection, release_connection
from werkzeug.security import generate_password_hash

def run_setup():
    conn = get_connection()
    if not conn:
        print("No DB connection")
        return
        
    try:
        cursor = conn.cursor()
        
        # Read the sample data file
        with open('../sql/04_sample_data.sql', 'r') as f:
            content = f.read()
            
        # Execute each INSERT or UPDATE statement
        statements = [s.strip() for s in content.split(';') if s.strip()]
        for stmt in statements:
            if stmt.upper().startswith(('INSERT', 'UPDATE')):
                try:
                    cursor.execute(stmt)
                except Exception as e:
                    print(f"Failed statement: {stmt[:50]}... Error: {e}")
                    
        conn.commit()
        print("Sample data inserted successfully!")
        
        # Now reset the passwords to something known
        hashed_pw = generate_password_hash('password')
        cursor.execute("UPDATE CITIZEN SET password_hash = :1", [hashed_pw])
        cursor.execute("UPDATE GOVERNMENT_OFFICIAL SET password_hash = :1", [hashed_pw])
        conn.commit()
        
        print("All passwords reset to 'password'")
        
    except Exception as e:
        print(f"Error: {e}")
    finally:
        if 'cursor' in locals():
            cursor.close()
        release_connection(conn)

if __name__ == '__main__':
    run_setup()
