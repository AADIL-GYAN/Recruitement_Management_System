

USE recruitment_management_system;

-- ============================================
-- Insert Data: Company
-- ============================================
INSERT INTO Company (company_name, industry, location, website, contact_email, contact_phone, established_year, company_size) VALUES
('TechCorp Solutions', 'Information Technology', 'Bangalore', 'www.techcorp.com', 'hr@techcorp.com', '9876543210', 2010, 'Large'),
('DataViz Analytics', 'Data Science', 'Mumbai', 'www.dataviz.com', 'careers@dataviz.com', '9876543211', 2015, 'Medium'),
('CloudNine Systems', 'Cloud Computing', 'Hyderabad', 'www.cloudnine.com', 'jobs@cloudnine.com', '9876543212', 2012, 'Large'),
('FinTech Innovations', 'Financial Technology', 'Pune', 'www.fintech.com', 'recruitment@fintech.com', '9876543213', 2018, 'Small'),
('AI Ventures', 'Artificial Intelligence', 'Delhi', 'www.aiventures.com', 'hiring@aiventures.com', '9876543214', 2019, 'Startup'),
('WebWorks Digital', 'Web Development', 'Chennai', 'www.webworks.com', 'contact@webworks.com', '9876543215', 2014, 'Medium'),
('CyberSec Pro', 'Cybersecurity', 'Noida', 'www.cybersec.com', 'hr@cybersec.com', '9876543216', 2016, 'Medium'),
('MobileFirst Apps', 'Mobile Development', 'Bangalore', 'www.mobilefirst.com', 'careers@mobilefirst.com', '9876543217', 2017, 'Small');

-- ============================================
-- Insert Data: Recruiter
-- ============================================
INSERT INTO Recruiter (company_id, first_name, last_name, email, phone, designation, hire_date, is_active) VALUES
(1, 'Rajesh', 'Kumar', 'rajesh.kumar@techcorp.com', '9999988881', 'Senior HR Manager', '2015-03-15', TRUE),
(1, 'Priya', 'Sharma', 'priya.sharma@techcorp.com', '9999988882', 'Talent Acquisition Lead', '2017-06-20', TRUE),
(2, 'Amit', 'Patel', 'amit.patel@dataviz.com', '9999988883', 'HR Executive', '2016-01-10', TRUE),
(3, 'Sneha', 'Reddy', 'sneha.reddy@cloudnine.com', '9999988884', 'Recruitment Manager', '2014-08-25', TRUE),
(4, 'Vikram', 'Singh', 'vikram.singh@fintech.com', '9999988885', 'HR Head', '2018-05-12', TRUE),
(5, 'Ananya', 'Gupta', 'ananya.gupta@aiventures.com', '9999988886', 'Talent Scout', '2019-09-01', TRUE),
(6, 'Rohit', 'Verma', 'rohit.verma@webworks.com', '9999988887', 'HR Manager', '2015-11-18', TRUE),
(7, 'Kavita', 'Nair', 'kavita.nair@cybersec.com', '9999988888', 'Senior Recruiter', '2017-04-22', TRUE);

            
INSERT INTO Job (company_id, recruiter_id, job_title, job_description, department, employment_type, experience_required, salary_min, salary_max, location, skills_required, vacancies, posted_date, deadline, job_status) VALUES
(1, 1, 'Senior Software Engineer', 'Develop scalable backend systems using Java and Spring Boot', 'Engineering', 'Full-Time', 5, 1200000.00, 1800000.00, 'Bangalore', 'Java, Spring Boot, MySQL, Microservices', 3, '2025-01-15', '2025-03-15', 'Open'),
(1, 2, 'Frontend Developer', 'Build responsive web applications using React', 'Engineering', 'Full-Time', 3, 800000.00, 1200000.00, 'Bangalore', 'React, JavaScript, HTML, CSS', 2, '2025-01-20', '2025-03-20', 'Open'),
(2, 3, 'Data Scientist', 'Analyze large datasets and build ML models', 'Data Science', 'Full-Time', 4, 1500000.00, 2000000.00, 'Mumbai', 'Python, Machine Learning, SQL, Statistics', 2, '2025-01-10', '2025-02-28', 'Open'),
(3, 4, 'Cloud Architect', 'Design and implement cloud infrastructure on AWS', 'Cloud Operations', 'Full-Time', 6, 2000000.00, 2800000.00, 'Hyderabad', 'AWS, Docker, Kubernetes, Terraform', 1, '2025-01-05', '2025-02-20', 'Open'),
(4, 5, 'Backend Developer', 'Develop APIs for financial applications', 'Engineering', 'Full-Time', 2, 700000.00, 1000000.00, 'Pune', 'Node.js, MongoDB, REST API', 3, '2025-01-25', '2025-03-25', 'Open'),
(5, 6, 'AI Research Engineer', 'Research and implement AI algorithms', 'Research', 'Full-Time', 3, 1300000.00, 1800000.00, 'Delhi', 'Python, TensorFlow, PyTorch, NLP', 1, '2025-01-12', '2025-03-01', 'Open'),
(6, 7, 'Full Stack Developer', 'Work on both frontend and backend development', 'Engineering', 'Full-Time', 4, 1000000.00, 1500000.00, 'Chennai', 'React, Node.js, PostgreSQL, Docker', 2, '2025-01-18', '2025-03-10', 'Open'),
(7, 8, 'Security Analyst', 'Monitor and secure company networks', 'Security', 'Full-Time', 3, 900000.00, 1400000.00, 'Noida', 'Network Security, Penetration Testing, SIEM', 2, '2025-01-22', '2025-03-15', 'Open'),
(1, 1, 'DevOps Engineer', 'Manage CI/CD pipelines and infrastructure', 'Operations', 'Full-Time', 4, 1100000.00, 1600000.00, 'Bangalore', 'Jenkins, Docker, Kubernetes, AWS', 2, '2025-01-08', '2025-02-25', 'Open'),
(2, 3, 'Business Analyst', 'Analyze business requirements and data trends', 'Analytics', 'Full-Time', 2, 600000.00, 900000.00, 'Mumbai', 'SQL, Excel, Tableau, Business Analysis', 1, '2025-01-28', '2025-03-20', 'Open');

-- ============================================
-- Insert Data: Candidate
-- ============================================
INSERT INTO Candidate (first_name, last_name, email, phone, date_of_birth, gender, address, city, state, country, highest_qualification, total_experience, current_company, current_designation, skills, registration_date) VALUES
('Arjun', 'Malhotra', 'arjun.malhotra@email.com', '9876501234', '1995-05-15', 'Male', '123 MG Road', 'Bangalore', 'Karnataka', 'India', 'B.Tech in Computer Science', 5.5, 'Infosys', 'Senior Developer', 'Java, Spring Boot, MySQL', '2025-01-16'),
('Neha', 'Chopra', 'neha.chopra@email.com', '9876501235', '1997-08-22', 'Female', '456 Park Street', 'Mumbai', 'Maharashtra', 'India', 'B.Tech in IT', 3.0, 'TCS', 'Frontend Developer', 'React, JavaScript, CSS', '2025-01-21'),
('Karthik', 'Iyer', 'karthik.iyer@email.com', '9876501236', '1994-03-10', 'Male', '789 Brigade Road', 'Bangalore', 'Karnataka', 'India', 'M.Tech in Data Science', 4.5, 'Wipro', 'Data Scientist', 'Python, Machine Learning, SQL', '2025-01-11'),
('Divya', 'Menon', 'divya.menon@email.com', '9876501237', '1993-11-28', 'Female', '321 Nehru Place', 'Delhi', 'Delhi', 'India', 'B.Tech in CSE', 6.0, 'Amazon', 'Cloud Engineer', 'AWS, Docker, Kubernetes', '2025-01-06'),
('Siddharth', 'Jain', 'siddharth.jain@email.com', '9876501238', '1998-07-05', 'Male', '654 FC Road', 'Pune', 'Maharashtra', 'India', 'B.E in IT', 2.5, 'Accenture', 'Backend Developer', 'Node.js, MongoDB, Express', '2025-01-26'),
('Pooja', 'Desai', 'pooja.desai@email.com', '9876501239', '1996-02-18', 'Female', '987 Residency Road', 'Bangalore', 'Karnataka', 'India', 'M.Sc in AI', 3.5, 'Microsoft', 'AI Engineer', 'Python, TensorFlow, NLP', '2025-01-13'),
('Rahul', 'Bose', 'rahul.bose@email.com', '9876501240', '1995-09-30', 'Male', '147 Anna Salai', 'Chennai', 'Tamil Nadu', 'India', 'B.Tech in CSE', 4.0, 'Cognizant', 'Full Stack Developer', 'React, Node.js, PostgreSQL', '2025-01-19'),
('Anjali', 'Rao', 'anjali.rao@email.com', '9876501241', '1997-04-12', 'Female', '258 Sector 62', 'Noida', 'Uttar Pradesh', 'India', 'B.Tech in IT', 3.0, 'HCL', 'Security Analyst', 'Network Security, Ethical Hacking', '2025-01-23'),
('Varun', 'Kapoor', 'varun.kapoor@email.com', '9876501242', '1994-12-25', 'Male', '369 MG Road', 'Bangalore', 'Karnataka', 'India', 'B.Tech in CSE', 4.5, 'Google', 'DevOps Engineer', 'Jenkins, Docker, AWS', '2025-01-09'),
('Meera', 'Shah', 'meera.shah@email.com', '9876501243', '1999-06-08', 'Female', '741 Marine Drive', 'Mumbai', 'Maharashtra', 'India', 'BBA with Analytics', 2.0, 'Deloitte', 'Business Analyst', 'SQL, Excel, Tableau', '2025-01-29'),
('Aditya', 'Nambiar', 'aditya.nambiar@email.com', '9876501244', '1996-01-20', 'Male', '852 Whitefield', 'Bangalore', 'Karnataka', 'India', 'B.Tech in CSE', 3.0, 'Flipkart', 'Backend Developer', 'Java, Spring Boot, Redis', '2025-01-17'),
('Ishita', 'Bansal', 'ishita.bansal@email.com', '9876501245', '1998-10-15', 'Female', '963 Hitech City', 'Hyderabad', 'Telangana', 'India', 'B.Tech in ECE', 2.0, 'Samsung', 'IoT Developer', 'Python, MQTT, AWS IoT', '2025-01-14');

-- ============================================
-- Insert Data: Application
-- ============================================
INSERT INTO Application (job_id, candidate_id, application_date, cover_letter, application_status) VALUES
(1, 1, '2025-01-16', 'I am excited to apply for the Senior Software Engineer position...', 'Shortlisted'),
(2, 2, '2025-01-21', 'I have 3 years of experience in React development...', 'Interview Scheduled'),
(3, 3, '2025-01-11', 'As a data scientist with 4.5 years of experience...', 'Shortlisted'),
(4, 4, '2025-01-07', 'I have extensive experience in AWS cloud architecture...', 'Selected'),
(5, 5, '2025-01-26', 'I am proficient in Node.js and MongoDB...', 'Applied'),
(6, 6, '2025-01-13', 'With my background in AI and NLP...', 'Interview Scheduled'),
(7, 7, '2025-01-19', 'I am a full stack developer with strong skills...', 'Shortlisted'),
(8, 8, '2025-01-23', 'I have 3 years of experience in cybersecurity...', 'Applied'),
(9, 9, '2025-01-09', 'I have been working as a DevOps engineer at Google...', 'Offered'),
(10, 10, '2025-01-29', 'I am skilled in data analysis and business intelligence...', 'Applied'),
(1, 11, '2025-01-17', 'I have strong backend development experience...', 'Rejected'),
(3, 12, '2025-01-15', 'I am interested in the data scientist role...', 'Applied'),
(2, 1, '2025-01-18', 'I am also interested in frontend development...', 'Applied'),
(5, 11, '2025-01-27', 'I have experience with Node.js development...', 'Shortlisted'),
(7, 2, '2025-01-24', 'I want to expand my skills to full stack...', 'Applied');

-- ============================================
-- Insert Data: Interview
-- ============================================
INSERT INTO Interview (application_id, interview_round, interview_date, interview_time, interview_mode, interviewer_name, interviewer_email, location_or_link, interview_status, feedback, rating, result) VALUES
(1, 'Technical', '2025-02-01', '10:00:00', 'Online', 'Suresh Kumar', 'suresh.kumar@techcorp.com', 'https://meet.google.com/abc-defg', 'Completed', 'Strong technical skills, good problem solving', 8.5, 'Pass'),
(1, 'Managerial', '2025-02-05', '14:00:00', 'Online', 'Anjali Mehta', 'anjali.mehta@techcorp.com', 'https://meet.google.com/xyz-pqrs', 'Scheduled', NULL, NULL, 'Pending'),
(2, 'Screening', '2025-02-03', '11:00:00', 'Phone', 'Priya Sharma', 'priya.sharma@techcorp.com', '+91-9999988882', 'Completed', 'Good communication, relevant experience', 7.5, 'Pass'),
(2, 'Technical', '2025-02-08', '15:00:00', 'Online', 'Rakesh Joshi', 'rakesh.joshi@techcorp.com', 'https://meet.google.com/tech-123', 'Scheduled', NULL, NULL, 'Pending'),
(3, 'Technical', '2025-01-30', '10:30:00', 'Online', 'Dr. Sanjay Rao', 'sanjay.rao@dataviz.com', 'https://zoom.us/j/123456', 'Completed', 'Excellent ML knowledge, strong portfolio', 9.0, 'Pass'),
(3, 'HR', '2025-02-06', '16:00:00', 'Online', 'Amit Patel', 'amit.patel@dataviz.com', 'https://zoom.us/j/789012', 'Scheduled', NULL, NULL, 'Pending'),
(4, 'Technical', '2025-01-28', '09:00:00', 'In-Person', 'Raghu Krishnan', 'raghu.k@cloudnine.com', 'CloudNine Office, Hyderabad', 'Completed', 'Outstanding AWS knowledge, certified architect', 9.5, 'Pass'),
(4, 'Final', '2025-02-02', '11:00:00', 'In-Person', 'CEO - Ramesh Babu', 'ceo@cloudnine.com', 'CloudNine Office, Hyderabad', 'Completed', 'Perfect fit for the role', 9.8, 'Pass'),
(6, 'Screening', '2025-02-04', '13:00:00', 'Phone', 'Ananya Gupta', 'ananya.gupta@aiventures.com', '+91-9999988886', 'Completed', 'Strong AI background, innovative thinking', 8.0, 'Pass'),
(9, 'Technical', '2025-01-25', '10:00:00', 'Online', 'Ravi Shankar', 'ravi.s@techcorp.com', 'https://meet.google.com/devops-int', 'Completed', 'Exceptional DevOps skills, hands-on experience', 9.2, 'Pass'),
(9, 'HR', '2025-01-31', '14:30:00', 'Online', 'Rajesh Kumar', 'rajesh.kumar@techcorp.com', 'https://meet.google.com/hr-final', 'Completed', 'Cultural fit, ready to join', 8.8, 'Pass');

-- ============================================
-- Insert Data: Offer
-- ============================================
INSERT INTO Offer (application_id, job_id, candidate_id, offer_date, offered_salary, offered_designation, joining_date, offer_status, acceptance_date) VALUES
(4, 4, 4, '2025-02-05', 2500000.00, 'Senior Cloud Architect', '2025-03-01', 'Accepted', '2025-02-07'),
(9, 9, 9, '2025-02-03', 1400000.00, 'DevOps Engineer', '2025-02-20', 'Accepted', '2025-02-05');

-- ============================================
-- Insert Data: Skill
-- ============================================
INSERT INTO Skill (skill_name, skill_category) VALUES
('Java', 'Programming Language'),
('Python', 'Programming Language'),
('JavaScript', 'Programming Language'),
('React', 'Frontend Framework'),
('Node.js', 'Backend Framework'),
('Spring Boot', 'Backend Framework'),
('MySQL', 'Database'),
('MongoDB', 'Database'),
('PostgreSQL', 'Database'),
('AWS', 'Cloud Platform'),
('Docker', 'DevOps Tool'),
('Kubernetes', 'DevOps Tool'),
('Machine Learning', 'AI/ML'),
('TensorFlow', 'AI/ML'),
('NLP', 'AI/ML'),
('REST API', 'Web Technology'),
('Microservices', 'Architecture'),
('Network Security', 'Cybersecurity'),
('SQL', 'Database Query Language'),
('Tableau', 'Data Visualization');

-- ============================================
-- Insert Data: CandidateSkill
-- ============================================
INSERT INTO CandidateSkill (candidate_id, skill_id, proficiency_level, years_of_experience) VALUES
(1, 1, 'Expert', 5.5),
(1, 6, 'Advanced', 4.0),
(1, 7, 'Advanced', 5.0),
(2, 3, 'Advanced', 3.0),
(2, 4, 'Advanced', 3.0),
(3, 2, 'Expert', 4.5),
(3, 13, 'Advanced', 3.0),
(3, 19, 'Expert', 4.0),
(4, 10, 'Expert', 6.0),
(4, 11, 'Advanced', 5.0),
(4, 12, 'Advanced', 4.5),
(5, 5, 'Advanced', 2.5),
(5, 8, 'Advanced', 2.0),
(6, 2, 'Expert', 3.5),
(6, 14, 'Advanced', 2.5),
(6, 15, 'Advanced', 2.0),
(7, 4, 'Advanced', 4.0),
(7, 5, 'Advanced', 3.5),
(7, 9, 'Intermediate', 3.0),
(8, 18, 'Advanced', 3.0),
(9, 11, 'Expert', 4.5),
(9, 12, 'Advanced', 3.5),
(9, 10, 'Advanced', 4.0),
(10, 19, 'Advanced', 2.0),
(10, 20, 'Intermediate', 1.5);

-- ============================================
-- Insert Data: JobSkill
-- ============================================
INSERT INTO JobSkill (job_id, skill_id, is_mandatory) VALUES
(1, 1, TRUE),
(1, 6, TRUE),
(1, 7, TRUE),
(1, 17, FALSE),
(2, 3, TRUE),
(2, 4, TRUE),
(3, 2, TRUE),
(3, 13, TRUE),
(3, 19, TRUE),
(4, 10, TRUE),
(4, 11, TRUE),
(4, 12, TRUE),
(5, 5, TRUE),
(5, 8, TRUE),
(5, 16, TRUE),
(6, 2, TRUE),
(6, 14, TRUE),
(6, 15, FALSE),
(7, 4, TRUE),
(7, 5, TRUE),
(7, 9, TRUE),
(8, 18, TRUE),
(9, 11, TRUE),
(9, 12, TRUE),
(9, 10, FALSE),
(10, 19, TRUE),
(10, 20, FALSE);

-- ============================================
-- Verify Data Insertion
-- ============================================
SELECT 'Company' AS TableName, COUNT(*) AS RecordCount FROM Company
UNION ALL
SELECT 'Recruiter', COUNT(*) FROM Recruiter
UNION ALL
SELECT 'Job', COUNT(*) FROM Job
UNION ALL
SELECT 'Candidate', COUNT(*) FROM Candidate
UNION ALL
SELECT 'Application', COUNT(*) FROM Application
UNION ALL
SELECT 'Interview', COUNT(*) FROM Interview
UNION ALL
SELECT 'Offer', COUNT(*) FROM Offer
UNION ALL
SELECT 'Skill', COUNT(*) FROM Skill
UNION ALL
SELECT 'CandidateSkill', COUNT(*) FROM CandidateSkill
UNION ALL
SELECT 'JobSkill', COUNT(*) FROM JobSkill;
