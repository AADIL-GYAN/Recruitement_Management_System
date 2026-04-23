USE recruitment_management_system;


-- Company Table Indexes
CREATE INDEX idx_company_name ON Company(company_name);
CREATE INDEX idx_company_location ON Company(location);

-- Recruiter Table Indexes
CREATE INDEX idx_recruiter_company ON Recruiter(company_id);
CREATE INDEX idx_recruiter_email ON Recruiter(email);

-- Job Table Indexes
CREATE INDEX idx_job_company ON Job(company_id);
CREATE INDEX idx_job_status ON Job(job_status);
CREATE INDEX idx_job_posted_date ON Job(posted_date);
CREATE INDEX idx_job_title ON Job(job_title);

-- Candidate Table Indexes
CREATE INDEX idx_candidate_email ON Candidate(email);
CREATE INDEX idx_candidate_experience ON Candidate(total_experience);
CREATE INDEX idx_candidate_city ON Candidate(city);

-- Application Table Indexes
CREATE INDEX idx_application_job ON Application(job_id);
CREATE INDEX idx_application_candidate ON Application(candidate_id);
CREATE INDEX idx_application_status ON Application(application_status);
CREATE INDEX idx_application_date ON Application(application_date);

-- Interview Table Indexes
CREATE INDEX idx_interview_application ON Interview(application_id);
CREATE INDEX idx_interview_date ON Interview(interview_date);
CREATE INDEX idx_interview_status ON Interview(interview_status);

-- Offer Table Indexes
CREATE INDEX idx_offer_job ON Offer(job_id);
CREATE INDEX idx_offer_candidate ON Offer(candidate_id);
CREATE INDEX idx_offer_status ON Offer(offer_status);

ALTER TABLE Company 
ADD CONSTRAINT chk_company_email 
CHECK (contact_email LIKE '%@%.%');


ALTER TABLE Recruiter 
ADD CONSTRAINT chk_recruiter_email 
CHECK (email LIKE '%@%.%');

ALTER TABLE Candidate 
ADD CONSTRAINT chk_candidate_email 
CHECK (email LIKE '%@%.%');

ALTER TABLE Candidate 
ADD CONSTRAINT chk_candidate_age 
CHECK (YEAR(CURDATE()) - YEAR(date_of_birth) >= 18);

ALTER TABLE Job 
ADD CONSTRAINT chk_job_vacancies 
CHECK (vacancies > 0);

ALTER TABLE Offer 
ADD CONSTRAINT chk_offer_salary 
CHECK (offered_salary > 0);

SELECT 
    TABLE_NAME,
    CONSTRAINT_NAME,
    CONSTRAINT_TYPE
FROM 
    INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE 
    TABLE_SCHEMA = 'recruitment_management_system'
ORDER BY 
    TABLE_NAME, CONSTRAINT_TYPE;
