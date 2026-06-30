# Community Grievance Redressal and Public Service Tracking System

**NagarSeva - Grievance Portal**

This is the complete source code for the DBMS Project (UCS310), developed by:
- Vanshika (1024030163)
- Aishwarya Verma (1024030170)
- Diya Jain (1024031154)

## Prerequisites
1. **Oracle Database XE** installed and running on `localhost:1521`.
2. **Oracle SQL Developer** (or another SQL client) connected to the database.
3. **Python 3.8+** installed.

## Setup Instructions

### 1. Database Setup (Oracle XE)
1. Open Oracle SQL Developer and connect to your database (typically using the `system` user).
2. Open the SQL scripts located in the `sql/` folder and execute them **in this exact order**:
   - `01_create_tables.sql` (Drops old tables, creates sequences and tables with constraints)
   - `02_triggers.sql` (Creates auto-assignment, auto-escalation, and resolution triggers)
   - `03_procedures_functions_views.sql` (Creates business logic procedures and dashboard views)
   - `04_sample_data.sql` (Inserts realistic sample data)
   - `05_queries.sql` (Contains analytical queries as requested)

### 2. Backend Setup (Python Flask)
1. Open a terminal and navigate to the `backend/` folder.
2. Create a virtual environment:
   ```bash
   python -m venv venv
   ```
3. Activate the virtual environment:
   - **Windows:** `venv\Scripts\activate`
   - **Mac/Linux:** `source venv/bin/activate`
4. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
   *(Note: The project uses `oracledb` instead of `cx_Oracle` because it works instantly without requiring a C++ compiler).*
5. Update Database Credentials:
   - Open `backend/config.py`
   - Change `DB_USER` and `DB_PASSWORD` to match your Oracle connection.
6. Run the Flask Server:
   ```bash
   python app.py
   ```
   The server will start on `http://localhost:5000` with CORS enabled.

### 3. Frontend Execution
The frontend is built using plain HTML, CSS, and vanilla JS. It does not require a Node/NPM server.
1. Simply navigate to the `frontend/` folder.
2. Double-click `index.html` to open it in your browser.
3. Make sure the Flask backend is running so the frontend can fetch the data.

## Features Included
- **Citizen Dashboard:** File complaints, track status on a timeline, and provide resolution feedback.
- **Official Dashboard:** View assigned complaints, mark in progress, and submit resolutions.
- **Admin Dashboard:** View system analytics (Chart.js), department performance, and escalated issues.
- **Oracle PL/SQL:** Triggers for auto-assignment based on category and auto-escalation based on deadlines. Procedures and views handle dashboard data efficiently.
