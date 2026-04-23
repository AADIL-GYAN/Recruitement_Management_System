
DROP DATABASE IF EXISTS recruitment_management_system;
CREATE DATABASE recruitment_management_system;
USE recruitment_management_system;

CREATE TABLE Company (
    company_id INT PRIMARY KEY AUTO_INCREMENT,
    company_name VARCHAR(100) NOT NULL,
    industry VARCHAR(50),
    location VARCHAR(100),
    website VARCHAR(150),
    contact_email VARCHAR(100) UNIQUE NOT NULL,
    contact_phone VARCHAR(15),
    established_year INT,
    company_size ENUM('Startup', 'Small', 'Medium', 'Large', 'Enterprise') DEFAULT 'Medium',
    registration_date DATE NOT NULL DEFAULT (CURRENT_DATE)
);

CREATE TABLE Recruiter (
    recruiter_id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15),
    designation VARCHAR(50),
    hire_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (company_id) REFERENCES Company(company_id) ON DELETE CASCADE
);

CREATE TABLE Job (
    job_id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
    recruiter_id INT NOT NULL,
    job_title VARCHAR(100) NOT NULL,
    job_description TEXT,
    department VARCHAR(50),
    employment_type ENUM('Full-Time', 'Part-Time', 'Contract', 'Internship') DEFAULT 'Full-Time',
    experience_required INT DEFAULT 0,
    salary_min DECIMAL(10, 2),
    salary_max DECIMAL(10, 2),
    location VARCHAR(100),
    skills_required VARCHAR(255),
    vacancies INT DEFAULT 1,
    posted_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    deadline DATE,
    job_status ENUM('Open', 'Closed', 'On-Hold') DEFAULT 'Open',
    FOREIGN KEY (company_id) REFERENCES Company(company_id) ON DELETE CASCADE,
    FOREIGN KEY (recruiter_id) REFERENCES Recruiter(recruiter_id) ON DELETE CASCADE,
    CHECK (salary_max >= salary_min),
    CHECK (deadline >= posted_date)
);

CREATE TABLE Candidate (
    candidate_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15),
    date_of_birth DATE,
    gender ENUM('Male', 'Female', 'Other', 'Prefer not to say'),
    address VARCHAR(255),
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50) DEFAULT 'India',
    highest_qualification VARCHAR(100),
    total_experience DECIMAL(3, 1) DEFAULT 0.0,
    current_company VARCHAR(100),
    current_designation VARCHAR(100),
    skills VARCHAR(255),
    resume_path VARCHAR(255),
    registration_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    CHECK (total_experience >= 0)
);

CREATE TABLE Application (
    application_id INT PRIMARY KEY AUTO_INCREMENT,
    job_id INT NOT NULL,
    candidate_id INT NOT NULL,
    application_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    cover_letter TEXT,
    application_status ENUM('Applied', 'Shortlisted', 'Rejected', 'Interview Scheduled', 'Selected', 'Offered', 'Joined') DEFAULT 'Applied',
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (job_id) REFERENCES Job(job_id) ON DELETE CASCADE,
    FOREIGN KEY (candidate_id) REFERENCES Candidate(candidate_id) ON DELETE CASCADE,
    UNIQUE KEY unique_application (job_id, candidate_id)
);

CREATE TABLE Interview (
    interview_id INT PRIMARY KEY AUTO_INCREMENT,
    application_id INT NOT NULL,
    interview_round ENUM('Screening', 'Technical', 'HR', 'Managerial', 'Final') NOT NULL,
    interview_date DATE NOT NULL,
    interview_time TIME NOT NULL,
    interview_mode ENUM('In-Person', 'Online', 'Phone') DEFAULT 'Online',
    interviewer_name VARCHAR(100),
    interviewer_email VARCHAR(100),
    location_or_link VARCHAR(255),
    interview_status ENUM('Scheduled', 'Completed', 'Cancelled', 'No-Show') DEFAULT 'Scheduled',
    feedback TEXT,
    rating DECIMAL(2, 1),
    result ENUM('Pass', 'Fail', 'On-Hold', 'Pending') DEFAULT 'Pending',
    FOREIGN KEY (application_id) REFERENCES Application(application_id) ON DELETE CASCADE,
    CHECK (rating >= 0 AND rating <= 10)
);

CREATE TABLE Offer (
    offer_id INT PRIMARY KEY AUTO_INCREMENT,
    application_id INT NOT NULL UNIQUE,
    job_id INT NOT NULL,
    candidate_id INT NOT NULL,
    offer_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    offered_salary DECIMAL(10, 2) NOT NULL,
    offered_designation VARCHAR(100) NOT NULL,
    joining_date DATE,
    offer_status ENUM('Pending', 'Accepted', 'Rejected', 'Withdrawn') DEFAULT 'Pending',
    offer_letter_path VARCHAR(255),
    acceptance_date DATE,
    FOREIGN KEY (application_id) REFERENCES Application(application_id) ON DELETE CASCADE,
    FOREIGN KEY (job_id) REFERENCES Job(job_id) ON DELETE CASCADE,
    FOREIGN KEY (candidate_id) REFERENCES Candidate(candidate_id) ON DELETE CASCADE,
    CHECK (joining_date >= offer_date)
);

CREATE TABLE Skill (
    skill_id INT PRIMARY KEY AUTO_INCREMENT,
    skill_name VARCHAR(50) UNIQUE NOT NULL,
    skill_category VARCHAR(50)
);

CREATE TABLE CandidateSkill (
    candidate_id INT NOT NULL,
    skill_id INT NOT NULL,
    proficiency_level ENUM('Beginner', 'Intermediate', 'Advanced', 'Expert') DEFAULT 'Intermediate',
    years_of_experience DECIMAL(3, 1) DEFAULT 0.0,
    PRIMARY KEY (candidate_id, skill_id),
    FOREIGN KEY (candidate_id) REFERENCES Candidate(candidate_id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id) REFERENCES Skill(skill_id) ON DELETE CASCADE
);

CREATE TABLE JobSkill (
    job_id INT NOT NULL,
    skill_id INT NOT NULL,
    is_mandatory BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (job_id, skill_id),
    FOREIGN KEY (job_id) REFERENCES Job(job_id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id) REFERENCES Skill(skill_id) ON DELETE CASCADE
);

SHOW TABLES;
