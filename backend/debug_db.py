from db import get_connection, release_connection

conn = get_connection()
c = conn.cursor()

c.execute('SELECT complaint_id, category, status FROM COMPLAINT')
print("COMPLAINTS:", c.fetchall())

c.execute('SELECT * FROM ASSIGNMENT')
print("ASSIGNMENTS:", c.fetchall())

c.execute("SELECT trigger_name, status FROM user_triggers WHERE UPPER(trigger_name) LIKE '%ASSIGN%'")
print("TRIGGERS:", c.fetchall())

c.close()
release_connection(conn)
