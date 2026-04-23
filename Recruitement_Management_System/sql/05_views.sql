    

USE recruitment_management_system;

-- ============================================
-- VIEW 1: SelectedCandidates
-- Purpose: Display all candidates who have been selected
-- Use Case: Quick reference for HR to see all selected candidates
-- ============================================
CREATE OR REPLACE VIEW SelectedCandidates AS
SELECT 
    c.candidate_id,
    CONCAT(c.first_name, ' ', c.last_name) AS candidate_name,
    c.email,
    c.phone,
    c.total_experience,
    j.job_title,
    comp.company_name,
    a.application_status,
    a.application_date,
    CASE 
        WHEN o.offer_id IS NOT NULL THEN 'Offer Extended'
        ELSE 'Pending Offer'
    END AS offer_status
FROM 
    Candidate c
INNER JOIN 
    Application a ON c.candidate_id = a.candidate_id
INNER JOIN 
    Job j ON a.job_id = j.job_id
INNER JOIN 
    Company comp ON j.company_id = comp.company_id
LEFT JOIN 
    Offer o ON a.application_id = o.application_id
WHERE 
    a.application_status = 'Selected';

-- Test the view
SELECT * FROM SelectedCandidates;

-- ============================================
-- VIEW 2: JobApplicationSummary
-- Purpose: Summary of applications for each job
-- Use Case: Recruiters can quickly see application statistics for their jobs
-- ============================================
CREATE OR REPLACE VIEW JobApplicationSummary AS
SELECT 
    j.job_id,
    j.job_title,
    c.company_name,
    CONCAT(r.first_name, ' ', r.last_name) AS recruiter_name,
    j.vacancies,
    j.posted_date,
    j.deadline,
    j.job_status,
    COUNT(a.application_id) AS total_applications,
    SUM(CASE WHEN a.application_status = 'Applied' THEN 1 ELSE 0 END) AS new_applications,
    SUM(CASE WHEN a.application_status = 'Shortlisted' THEN 1 ELSE 0 END) AS shortlisted,
    SUM(CASE WHEN a.application_status = 'Interview Scheduled' THEN 1 ELSE 0 END) AS interviews_scheduled,
    SUM(CASE WHEN a.application_status = 'Selected' THEN 1 ELSE 0 END) AS selected,
    SUM(CASE WHEN a.application_status = 'Rejected' THEN 1 ELSE 0 END) AS rejected
FROM 
    Job j
INNER JOIN 
    Company c ON j.company_id = c.company_id
INNER JOIN 
    Recruiter r ON j.recruiter_id = r.recruiter_id
LEFT JOIN 
    Application a ON j.job_id = a.job_id
GROUP BY 
    j.job_id, j.job_title, c.company_name, r.first_name, r.last_name, 
    j.vacancies, j.posted_date, j.deadline, j.job_status;

-- Test the view
SELECT * FROM JobApplicationSummary;

-- ============================================
-- VIEW 3: ActiveInterviews
-- Purpose: Show all scheduled interviews with complete details
-- Use Case: Daily interview schedule for interviewers and HR
-- ============================================
CREATE OR REPLACE VIEW ActiveInterviews AS
SELECT 
    i.interview_id,
    CONCAT(c.first_name, ' ', c.last_name) AS candidate_name,
    c.email AS candidate_email,
    c.phone AS candidate_phone,
    j.job_title,
    comp.company_name,
    i.interview_round,
    i.interview_date,
    i.interview_time,
    i.interview_mode,
    i.interviewer_name,
    i.interviewer_email,
    i.location_or_link,
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

-- Test the view
SELECT * FROM ActiveInterviews;

-- ============================================
-- VIEW 4: CandidateProfile
-- Purpose: Comprehensive candidate profile with skills
-- Use Case: Quick candidate overview for recruiters
-- ============================================
CREATE OR REPLACE VIEW CandidateProfile AS
SELECT 
    c.candidate_id,
    CONCAT(c.first_name, ' ', c.last_name) AS candidate_name,
    c.email,
    c.phone,
    c.total_experience,
    c.highest_qualification,
    c.current_company,
    c.current_designation,
    c.city,
    c.state,
    COUNT(DISTINCT cs.skill_id) AS total_skills,
    GROUP_CONCAT(DISTINCT s.skill_name ORDER BY cs.proficiency_level DESC SEPARATOR ', ') AS skills,
    COUNT(DISTINCT a.application_id) AS total_applications,
    SUM(CASE WHEN a.application_status = 'Selected' THEN 1 ELSE 0 END) AS selections
FROM 
    Candidate c
LEFT JOIN 
    CandidateSkill cs ON c.candidate_id = cs.candidate_id
LEFT JOIN 
    Skill s ON cs.skill_id = s.skill_id
LEFT JOIN 
    Application a ON c.candidate_id = a.candidate_id
GROUP BY 
    c.candidate_id, c.first_name, c.last_name, c.email, c.phone, 
    c.total_experience, c.highest_qualification, c.current_company, 
    c.current_designation, c.city, c.state;

-- Test the view
SELECT * FROM CandidateProfile;

-- ============================================
-- VIEW 5: CompanyRecruitmentDashboard
-- Purpose: Executive dashboard view for company recruitment metrics
-- Use Case: Management reporting and analytics
-- ============================================
CREATE OR REPLACE VIEW CompanyRecruitmentDashboard AS
SELECT 
    c.company_id,
    c.company_name,
    c.location,
    c.industry,
    COUNT(DISTINCT j.job_id) AS total_jobs,
    SUM(CASE WHEN j.job_status = 'Open' THEN 1 ELSE 0 END) AS open_positions,
    SUM(j.vacancies) AS total_vacancies,
    COUNT(DISTINCT a.application_id) AS total_applications,
    COUNT(DISTINCT a.candidate_id) AS unique_applicants,
    COUNT(DISTINCT i.interview_id) AS interviews_conducted,
    COUNT(DISTINCT o.offer_id) AS offers_made,
    SUM(CASE WHEN o.offer_status = 'Accepted' THEN 1 ELSE 0 END) AS offers_accepted,
    ROUND(AVG(DATEDIFF(o.offer_date, a.application_date)), 0) AS avg_days_to_offer
FROM 
    Company c
LEFT JOIN 
    Job j ON c.company_id = j.company_id
LEFT JOIN 
    Application a ON j.job_id = a.job_id
LEFT JOIN 
    Interview i ON a.application_id = i.application_id
LEFT JOIN 
    Offer o ON a.application_id = o.application_id
GROUP BY 
    c.company_id, c.company_name, c.location, c.industry;

-- Test the view
SELECT * FROM CompanyRecruitmentDashboard;

-- ============================================
-- VIEW 6: PendingOffers
-- Purpose: Track all pending job offers
-- Use Case: Follow up with candidates on pending offers
-- ============================================
CREATE OR REPLACE VIEW PendingOffers AS
SELECT 
    o.offer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS candidate_name,
    c.email,
    c.phone,
    j.job_title,
    comp.company_name,
    o.offered_salary,
    o.offered_designation,
    o.offer_date,
    o.joining_date,
    DATEDIFF(CURDATE(), o.offer_date) AS days_pending
FROM 
    Offer o
INNER JOIN 
    Candidate c ON o.candidate_id = c.candidate_id
INNER JOIN 
    Job j ON o.job_id = j.job_id
INNER JOIN 
    Company comp ON j.company_id = comp.company_id
WHERE 
    o.offer_status = 'Pending'
ORDER BY 
    o.offer_date;

-- Test the view
SELECT * FROM PendingOffers;

-- ============================================
-- Display all created views
-- ============================================
SHOW FULL TABLES WHERE Table_type = 'VIEW';

-- ============================================
-- Example queries using views
-- ============================================

-- Get all selected candidates
SELECT * FROM SelectedCandidates;

-- Get jobs with high application count
SELECT * FROM JobApplicationSummary 
WHERE total_applications > 2 
ORDER BY total_applications DESC;

-- Today's interviews
SELECT * FROM ActiveInterviews 
WHERE interview_date = CURDATE();

-- Experienced candidates
SELECT * FROM CandidateProfile 
WHERE total_experience >= 4 
ORDER BY total_experience DESC;

-- Top performing companies in recruitment
SELECT * FROM CompanyRecruitmentDashboard 
ORDER BY offers_accepted DESC;
