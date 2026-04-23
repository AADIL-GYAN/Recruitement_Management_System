    

USE recruitment_management_system;

-- ============================================
-- QUERY 1: Display all open jobs with company details
-- ============================================
SELECT 
    j.job_id,
    c.company_name,
    j.job_title,
    j.employment_type,
    j.experience_required,
    j.salary_min,
    j.salary_max,
    j.location,
    j.vacancies,
    j.posted_date,
    j.deadline
FROM 
    Job j
INNER JOIN 
    Company c ON j.company_id = c.company_id
WHERE 
    j.job_status = 'Open'
ORDER BY 
    j.posted_date DESC;

-- ============================================
-- QUERY 2: Count applications per job
-- ============================================
SELECT 
    j.job_id,
    j.job_title,
    c.company_name,
    COUNT(a.application_id) AS total_applications,
    j.vacancies,
    ROUND(COUNT(a.application_id) / j.vacancies, 2) AS applications_per_vacancy
FROM 
    Job j
INNER JOIN 
    Company c ON j.company_id = c.company_id
LEFT JOIN 
    Application a ON j.job_id = a.job_id
GROUP BY 
    j.job_id, j.job_title, c.company_name, j.vacancies
ORDER BY 
    total_applications DESC;

-- ============================================
-- QUERY 3: Find candidates with experience above average
-- ============================================
SELECT 
    candidate_id,
    CONCAT(first_name, ' ', last_name) AS candidate_name,
    email,
    total_experience,
    current_designation,
    current_company
FROM 
    Candidate
WHERE 
    total_experience > (SELECT AVG(total_experience) FROM Candidate)
ORDER BY 
    total_experience DESC;

-- ============================================
-- QUERY 4: List all shortlisted candidates with job details
-- ============================================
SELECT 
    c.candidate_id,
    CONCAT(c.first_name, ' ', c.last_name) AS candidate_name,
    c.email,
    j.job_title,
    comp.company_name,
    a.application_status,
    a.application_date
FROM 
    Application a
INNER JOIN 
    Candidate c ON a.candidate_id = c.candidate_id
INNER JOIN 
    Job j ON a.job_id = j.job_id
INNER JOIN 
    Company comp ON j.company_id = comp.company_id
WHERE 
    a.application_status IN ('Shortlisted', 'Interview Scheduled', 'Selected')
ORDER BY 
    a.application_date;

-- ============================================
-- QUERY 5: Get interview schedule with candidate and job info
-- ============================================
SELECT 
    i.interview_id,
    CONCAT(c.first_name, ' ', c.last_name) AS candidate_name,
    j.job_title,
    comp.company_name,
    i.interview_round,
    i.interview_date,
    i.interview_time,
    i.interview_mode,
    i.interviewer_name,
    i.interview_status
FROM 
    Interview i
INNER JOIN 
    Application a ON i.application_id = a.application_id
INNER JOIN 
    Candidate c ON a.candidate_id = c.candidate_id
INNER JOIN 
    Job j ON a.job_id = j.job_id
INNER JOIN 
    Company comp ON j.company_id = comp.company_id
WHERE 
    i.interview_status = 'Scheduled'
ORDER BY 
    i.interview_date, i.interview_time;

-- ============================================
-- QUERY 6: Company-wise hiring summary
-- ============================================
SELECT 
    c.company_id,
    c.company_name,
    COUNT(DISTINCT j.job_id) AS total_jobs_posted,
    COUNT(DISTINCT a.application_id) AS total_applications,
    COUNT(DISTINCT CASE WHEN a.application_status = 'Selected' THEN a.application_id END) AS candidates_selected,
    COUNT(DISTINCT o.offer_id) AS offers_made,
    COUNT(DISTINCT CASE WHEN o.offer_status = 'Accepted' THEN o.offer_id END) AS offers_accepted
FROM 
    Company c
LEFT JOIN 
    Job j ON c.company_id = j.company_id
LEFT JOIN 
    Application a ON j.job_id = a.job_id
LEFT JOIN 
    Offer o ON a.application_id = o.application_id
GROUP BY 
    c.company_id, c.company_name
ORDER BY 
    total_applications DESC;

-- ============================================
-- QUERY 7: Find candidates who passed all interview rounds
-- ============================================
SELECT 
    c.candidate_id,
    CONCAT(c.first_name, ' ', c.last_name) AS candidate_name,
    j.job_title,
    comp.company_name,
    COUNT(i.interview_id) AS total_interviews,
    AVG(i.rating) AS average_rating
FROM 
    Candidate c
INNER JOIN 
    Application a ON c.candidate_id = a.candidate_id
INNER JOIN 
    Job j ON a.job_id = j.job_id
INNER JOIN 
    Company comp ON j.company_id = comp.company_id
INNER JOIN 
    Interview i ON a.application_id = i.application_id
WHERE 
    i.result = 'Pass' AND i.interview_status = 'Completed'
GROUP BY 
    c.candidate_id, c.first_name, c.last_name, j.job_title, comp.company_name
HAVING 
    COUNT(i.interview_id) >= 1
ORDER BY 
    average_rating DESC;

-- ============================================
-- QUERY 8: Jobs with salary above company average
-- ============================================
SELECT 
    j.job_id,
    j.job_title,
    c.company_name,
    j.salary_max,
    (SELECT AVG(salary_max) FROM Job WHERE company_id = j.company_id) AS company_avg_salary
FROM 
    Job j
INNER JOIN 
    Company c ON j.company_id = c.company_id
WHERE 
    j.salary_max > (SELECT AVG(salary_max) FROM Job WHERE company_id = j.company_id)
ORDER BY 
    j.salary_max DESC;

-- ============================================
-- QUERY 9: Application status distribution
-- ============================================
SELECT 
    application_status,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Application), 2) AS percentage
FROM 
    Application
GROUP BY 
    application_status
ORDER BY 
    count DESC;

-- ============================================
-- QUERY 10: Candidates with multiple applications
-- ============================================
SELECT 
    c.candidate_id,
    CONCAT(c.first_name, ' ', c.last_name) AS candidate_name,
    c.email,
    COUNT(a.application_id) AS total_applications,
    GROUP_CONCAT(j.job_title SEPARATOR ', ') AS applied_jobs
FROM 
    Candidate c
INNER JOIN 
    Application a ON c.candidate_id = a.candidate_id
INNER JOIN 
    Job j ON a.job_id = j.job_id
GROUP BY 
    c.candidate_id, c.first_name, c.last_name, c.email
HAVING 
    COUNT(a.application_id) > 1
ORDER BY 
    total_applications DESC;

-- ============================================
-- QUERY 11: Skills in highest demand (most required in jobs)
-- ============================================
SELECT 
    s.skill_id,
    s.skill_name,
    s.skill_category,
    COUNT(js.job_id) AS jobs_requiring_skill,
    SUM(CASE WHEN js.is_mandatory = TRUE THEN 1 ELSE 0 END) AS mandatory_count
FROM 
    Skill s
INNER JOIN 
    JobSkill js ON s.skill_id = js.skill_id
GROUP BY 
    s.skill_id, s.skill_name, s.skill_category
ORDER BY 
    jobs_requiring_skill DESC;

-- ============================================
-- QUERY 12: Recruiter performance report
-- ============================================
SELECT 
    r.recruiter_id,
    CONCAT(r.first_name, ' ', r.last_name) AS recruiter_name,
    c.company_name,
    COUNT(DISTINCT j.job_id) AS jobs_posted,
    COUNT(DISTINCT a.application_id) AS applications_received,
    COUNT(DISTINCT CASE WHEN a.application_status = 'Selected' THEN a.application_id END) AS selections_made
FROM 
    Recruiter r
INNER JOIN 
    Company c ON r.company_id = c.company_id
LEFT JOIN 
    Job j ON r.recruiter_id = j.recruiter_id
LEFT JOIN 
    Application a ON j.job_id = a.job_id
WHERE 
    r.is_active = TRUE
GROUP BY 
    r.recruiter_id, r.first_name, r.last_name, c.company_name
ORDER BY 
    jobs_posted DESC;

-- ============================================
-- QUERY 13: Candidates matching specific job requirements (Skill-based)
-- ============================================
SELECT DISTINCT
    c.candidate_id,
    CONCAT(c.first_name, ' ', c.last_name) AS candidate_name,
    c.total_experience,
    j.job_title,
    comp.company_name,
    COUNT(DISTINCT cs.skill_id) AS matching_skills
FROM 
    Candidate c
INNER JOIN 
    CandidateSkill cs ON c.candidate_id = cs.candidate_id
INNER JOIN 
    JobSkill js ON cs.skill_id = js.skill_id
INNER JOIN 
    Job j ON js.job_id = j.job_id
INNER JOIN 
    Company comp ON j.company_id = comp.company_id
WHERE 
    c.total_experience >= j.experience_required
    AND j.job_status = 'Open'
GROUP BY 
    c.candidate_id, c.first_name, c.last_name, c.total_experience, j.job_title, comp.company_name
HAVING 
    COUNT(DISTINCT cs.skill_id) >= 2
ORDER BY 
    matching_skills DESC, c.total_experience DESC;

-- ============================================
-- QUERY 14: Offer acceptance rate by company
-- ============================================
SELECT 
    c.company_id,
    c.company_name,
    COUNT(o.offer_id) AS total_offers,
    SUM(CASE WHEN o.offer_status = 'Accepted' THEN 1 ELSE 0 END) AS accepted_offers,
    SUM(CASE WHEN o.offer_status = 'Rejected' THEN 1 ELSE 0 END) AS rejected_offers,
    ROUND(SUM(CASE WHEN o.offer_status = 'Accepted' THEN 1 ELSE 0 END) * 100.0 / COUNT(o.offer_id), 2) AS acceptance_rate
FROM 
    Company c
INNER JOIN 
    Job j ON c.company_id = j.company_id
INNER JOIN 
    Offer o ON j.job_id = o.job_id
GROUP BY 
    c.company_id, c.company_name
HAVING 
    COUNT(o.offer_id) > 0
ORDER BY 
    acceptance_rate DESC;

-- ============================================
-- QUERY 15: Time-to-hire analysis (Days from application to offer)
-- ============================================
SELECT 
    o.offer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS candidate_name,
    j.job_title,
    comp.company_name,
    a.application_date,
    o.offer_date,
    DATEDIFF(o.offer_date, a.application_date) AS days_to_offer
FROM 
    Offer o
INNER JOIN 
    Application a ON o.application_id = a.application_id
INNER JOIN 
    Candidate c ON o.candidate_id = c.candidate_id
INNER JOIN 
    Job j ON o.job_id = j.job_id
INNER JOIN 
    Company comp ON j.company_id = comp.company_id
ORDER BY 
    days_to_offer;

-- ============================================
-- QUERY 16: Jobs about to expire (deadline within 7 days)
-- ============================================
SELECT 
    j.job_id,
    c.company_name,
    j.job_title,
    j.posted_date,
    j.deadline,
    DATEDIFF(j.deadline, CURDATE()) AS days_remaining,
    COUNT(a.application_id) AS applications_received
FROM 
    Job j
INNER JOIN 
    Company c ON j.company_id = c.company_id
LEFT JOIN 
    Application a ON j.job_id = a.job_id
WHERE 
    j.job_status = 'Open'
    AND j.deadline BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY)
GROUP BY 
    j.job_id, c.company_name, j.job_title, j.posted_date, j.deadline
ORDER BY 
    days_remaining;

-- ============================================
-- QUERY 17: Interview success rate by round
-- ============================================
SELECT 
    interview_round,
    COUNT(*) AS total_interviews,
    SUM(CASE WHEN result = 'Pass' THEN 1 ELSE 0 END) AS passed,
    SUM(CASE WHEN result = 'Fail' THEN 1 ELSE 0 END) AS failed,
    ROUND(SUM(CASE WHEN result = 'Pass' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS pass_rate,
    ROUND(AVG(rating), 2) AS average_rating
FROM 
    Interview
WHERE 
    interview_status = 'Completed' AND result IN ('Pass', 'Fail')
GROUP BY 
    interview_round
ORDER BY 
    pass_rate DESC;

-- ============================================
-- QUERY 18: Top 5 candidates by skills count
-- ============================================
SELECT 
    c.candidate_id,
    CONCAT(c.first_name, ' ', c.last_name) AS candidate_name,
    c.total_experience,
    COUNT(cs.skill_id) AS total_skills,
    GROUP_CONCAT(s.skill_name ORDER BY cs.proficiency_level DESC SEPARATOR ', ') AS skills_list
FROM 
    Candidate c
INNER JOIN 
    CandidateSkill cs ON c.candidate_id = cs.candidate_id
INNER JOIN 
    Skill s ON cs.skill_id = s.skill_id
GROUP BY 
    c.candidate_id, c.first_name, c.last_name, c.total_experience
ORDER BY 
    total_skills DESC
LIMIT 5;

-- ============================================
-- QUERY 19: Monthly application trends
-- ============================================
SELECT 
    DATE_FORMAT(application_date, '%Y-%m') AS month,
    COUNT(*) AS total_applications,
    COUNT(DISTINCT candidate_id) AS unique_candidates,
    COUNT(DISTINCT job_id) AS jobs_applied_to
FROM 
    Application
GROUP BY 
    DATE_FORMAT(application_date, '%Y-%m')
ORDER BY 
    month DESC;

-- ============================================
-- QUERY 20: Candidates with no applications
-- ============================================
SELECT 
    c.candidate_id,
    CONCAT(c.first_name, ' ', c.last_name) AS candidate_name,
    c.email,
    c.total_experience,
    c.registration_date,
    DATEDIFF(CURDATE(), c.registration_date) AS days_since_registration
FROM 
    Candidate c
LEFT JOIN 
    Application a ON c.candidate_id = a.candidate_id
WHERE 
    a.application_id IS NULL
ORDER BY 
    c.registration_date;
