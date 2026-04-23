from flask import Flask, request, jsonify
from flask_cors import CORS
import mysql.connector
import os
import json
import requests
import re

app = Flask(__name__)
CORS(app)


DB_HOST = 'localhost'
DB_USER = 'root'
DB_PASS = ''
DB_NAME = 'recruitment_management_system'

def get_db_connection():
    try:
        connection = mysql.connector.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASS,
            database=DB_NAME
        )
        return connection
    except mysql.connector.Error as err:
        print(f"Error: {err}")
        return None


def execute_query(query, params=None):
    try:
        conn = get_db_connection()
        if not conn:
            return None
            
        cursor = conn.cursor(dictionary=True)
        cursor.execute(query, params or ())
        result = cursor.fetchall()
        
        cursor.close()
        conn.close()
        return result
    except Exception as e:
        print(f"Query Error: {e}")
        return None

def execute_non_query(query, params=None):
    try:
        conn = get_db_connection()
        if not conn:
            return False
            
        cursor = conn.cursor()
        cursor.execute(query, params or ())
        conn.commit()
        
        last_id = cursor.lastrowid
        
        cursor.close()
        conn.close()
        return last_id if last_id else True
    except Exception as e:
        print(f"Non-Query Error: {e}")
        return False



@app.route('/')
def home():
    return jsonify({"message": "RMS Python Backend Running!"})


@app.route('/api_auth.php', methods=['POST'])
def auth():
    data = request.json
    password = data.get('password')
    if password in ['admin123', '123456']:
        return jsonify({
            "success": True,
            "user": {"id": 1, "name": "Admin User", "email": data.get('email')},
            "message": "Login successful"
        })
    return jsonify({"success": False, "message": "Incorrect Password (use admin123)"})


@app.route('/api_jobs.php', methods=['GET', 'POST'])
def jobs():
    if request.method == 'GET':
        query = """
            SELECT j.*, c.company_name, CONCAT(r.first_name, ' ', r.last_name) as recruiter_name
            FROM Job j
            INNER JOIN Company c ON j.company_id = c.company_id
            INNER JOIN Recruiter r ON j.recruiter_id = r.recruiter_id
            ORDER BY j.posted_date DESC
        """
        result = execute_query(query)
        return jsonify(result if result else [])
    
    elif request.method == 'POST':
        data = request.json
        query = """
            INSERT INTO Job (job_title, company_id, recruiter_id, department, experience_required, 
                           salary_min, salary_max, vacancies, location, job_description, 
                           skills_required, deadline)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        params = (
            data.get('job_title'), data.get('company_id'), 1,
            data.get('department'), data.get('experience_required'), 
            data.get('salary_min'), data.get('salary_max'), data.get('vacancies'),
            data.get('location'), data.get('job_description'), 
            data.get('skills_required'), data.get('deadline')
        )
        res = execute_non_query(query, params)
        if res:
            return jsonify({"success": True})
        return jsonify({"success": False, "message": "Failed to add job"})



@app.route('/api_candidates.php', methods=['GET', 'POST'])
def candidates():
    if request.method == 'GET':
        return jsonify(execute_query("SELECT * FROM Candidate ORDER BY registration_date DESC") or [])
    elif request.method == 'POST':
        data = request.json
        query = """
            INSERT INTO Candidate (first_name, last_name, email, phone, date_of_birth, gender,
                                 highest_qualification, total_experience, current_company, 
                                 current_designation, city, skills)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        params = (
            data.get('first_name'), data.get('last_name'), data.get('email'), data.get('phone'),
            data.get('date_of_birth'), data.get('gender'), data.get('highest_qualification'),
            data.get('total_experience'), data.get('current_company'), 
            data.get('current_designation'), data.get('city'), data.get('skills')
        )
        res = execute_non_query(query, params)
        return jsonify({"success": True} if res else {"success": False})

@app.route('/api_applications.php', methods=['GET', 'POST', 'PUT'])
def applications():
    if request.method == 'GET':
        query = """
            SELECT a.*, j.job_title, comp.company_name, c.first_name, c.last_name
            FROM Application a
            JOIN Job j ON a.job_id = j.job_id
            JOIN Company comp ON j.company_id = comp.company_id
            JOIN Candidate c ON a.candidate_id = c.candidate_id
            ORDER BY a.application_date DESC
        """
        return jsonify(execute_query(query) or [])
    
    elif request.method == 'POST':
        data = request.json
        query = "INSERT INTO Application (job_id, candidate_id, cover_letter, application_status) VALUES (%s, %s, %s, 'Applied')"
        res = execute_non_query(query, (data.get('job_id'), data.get('candidate_id'), data.get('cover_letter')))
        return jsonify({"success": True} if res else {"success": False})
        
    elif request.method == 'PUT':
        data = request.json
        query = "UPDATE Application SET application_status = %s WHERE application_id = %s"
        res = execute_non_query(query, (data.get('application_status'), data.get('application_id')))
        return jsonify({"success": True} if res else {"success": False})

@app.route('/api_interviews.php', methods=['GET', 'POST', 'PUT'])
def interviews():
    if request.method == 'GET':
        query = """
            SELECT i.*, j.job_title, c.first_name, c.last_name
            FROM Interview i
            JOIN Application a ON i.application_id = a.application_id
            JOIN Job j ON a.job_id = j.job_id
            JOIN Candidate c ON a.candidate_id = c.candidate_id
            ORDER BY i.interview_date DESC, i.interview_time ASC
        """
        return jsonify(execute_query(query) or [])
        
    elif request.method == 'POST':
        data = request.json
        i_query = """
            INSERT INTO Interview (application_id, interview_round, interview_date, interview_time, 
                                 interview_mode, interviewer_name, interviewer_email, location_or_link)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """
        params = (
            data.get('application_id'), data.get('interview_round'), data.get('interview_date'),
            data.get('interview_time'), data.get('interview_mode'), data.get('interviewer_name'),
            data.get('interviewer_email'), data.get('location_or_link')
        )
        res = execute_non_query(i_query, params)
        
        if res:
            execute_non_query("UPDATE Application SET application_status = 'Interview Scheduled' WHERE application_id = %s", (data.get('application_id'),))
            return jsonify({"success": True})
        return jsonify({"success": False})

    elif request.method == 'PUT':
        data = request.json
        query = "UPDATE Interview SET result = %s, interview_status = %s WHERE interview_id = %s"
        res = execute_non_query(query, (data.get('result'), data.get('interview_status'), data.get('interview_id')))
        return jsonify({"success": True} if res else {"success": False})

@app.route('/api_companies.php', methods=['GET'])
def companies():
    return jsonify(execute_query("SELECT * FROM Company ORDER BY company_name") or [])

@app.route('/api_ai.php', methods=['POST'])
def ai_endpoint():
    data = request.json
    action = data.get('action')
    groq_api_key = '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'
    
    if action == 'generate_jd':
        prompt = f"Create a job description for {data.get('title')} at {data.get('company')}."
        resp = call_groq(prompt, groq_api_key)
        return jsonify({"success": True, "result": resp})
    
    elif action == 'generate_questions':
        prompt = f"Generate 5 interview questions for {data.get('job_title')} (numbered list)."
        resp = call_groq(prompt, groq_api_key)
        # Parse list using regex to handle various numbered list formats
        questions = []
        for line in resp.split('\n'):
            line = line.strip()
            # Match formats like "1. Question", "1) Question", "- Question" if it's a list item
            if re.match(r'^(\d+[\.\)] |- )', line):
                questions.append(line)
        return jsonify({"success": True, "result": questions})
        
    return jsonify({"error": "Invalid Action"})

def call_groq(prompt, key):
    url = "https://api.groq.com/openai/v1/chat/completions"
    headers = {"Authorization": f"Bearer {key}", "Content-Type": "application/json"}
    payload = {
        "model": "llama-3.3-70b-versatile",
        "messages": [{"role": "user", "content": prompt}]
    }
    try:
        r = requests.post(url, json=payload, headers=headers)
        return r.json()['choices'][0]['message']['content']
    except Exception as e:
        return f"Error: {str(e)}"

if __name__ == '__main__':
    app.run(debug=True, port=5000)
