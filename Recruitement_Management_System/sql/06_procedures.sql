

USE recruitment_management_system;

-- Change delimiter for procedure creation
DELIMITER //

-- ============================================
-- PROCEDURE 1: ApplyForJob
-- Purpose: Allow a candidate to apply for a job
-- Parameters: 
--   p_job_id: Job ID
--   p_candidate_id: Candidate ID
--   p_cover_letter: Cover letter text
-- ============================================
CREATE PROCEDURE ApplyForJob(
    IN p_job_id INT,
    IN p_candidate_id INT,
    IN p_cover_letter TEXT
)
BEGIN
    DECLARE v_job_status VARCHAR(20);
    DECLARE v_deadline DATE;
    DECLARE v_application_exists INT;
    
    -- Check if job exists and is open
    SELECT job_status, deadline INTO v_job_status, v_deadline
    FROM Job
    WHERE job_id = p_job_id;
    
    -- Validate job status
    IF v_job_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Job does not exist';
    END IF;
    
    IF v_job_status != 'Open' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Job is not open for applications';
    END IF;
    
    -- Check if deadline has passed
    IF v_deadline < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Application deadline has passed';
    END IF;
    
    -- Check if candidate has already applied
    SELECT COUNT(*) INTO v_application_exists
    FROM Application
    WHERE job_id = p_job_id AND candidate_id = p_candidate_id;
    
    IF v_application_exists > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Candidate has already applied for this job';
    END IF;
    
    -- Insert application
    INSERT INTO Application (job_id, candidate_id, application_date, cover_letter, application_status)
    VALUES (p_job_id, p_candidate_id, CURDATE(), p_cover_letter, 'Applied');
    
    SELECT 'Application submitted successfully' AS message;
END //

-- ============================================
-- PROCEDURE 2: ScheduleInterview
-- Purpose: Schedule an interview for an application
-- Parameters:
--   p_application_id: Application ID
--   p_interview_round: Round type
--   p_interview_date: Date of interview
--   p_interview_time: Time of interview
--   p_interview_mode: Mode (Online/In-Person/Phone)
--   p_interviewer_name: Interviewer name
--   p_interviewer_email: Interviewer email
--   p_location_or_link: Location or meeting link
-- ============================================
CREATE PROCEDURE ScheduleInterview(
    IN p_application_id INT,
    IN p_interview_round ENUM('Screening', 'Technical', 'HR', 'Managerial', 'Final'),
    IN p_interview_date DATE,
    IN p_interview_time TIME,
    IN p_interview_mode ENUM('In-Person', 'Online', 'Phone'),
    IN p_interviewer_name VARCHAR(100),
    IN p_interviewer_email VARCHAR(100),
    IN p_location_or_link VARCHAR(255)
)
BEGIN
    DECLARE v_application_status VARCHAR(50);
    
    -- Check if application exists
    SELECT application_status INTO v_application_status
    FROM Application
    WHERE application_id = p_application_id;
    
    IF v_application_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Application does not exist';
    END IF;
    
    -- Check if application is in valid status
    IF v_application_status NOT IN ('Shortlisted', 'Interview Scheduled', 'Applied') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Application is not in valid status for interview scheduling';
    END IF;
    
    -- Insert interview record
    INSERT INTO Interview (
        application_id, interview_round, interview_date, interview_time, 
        interview_mode, interviewer_name, interviewer_email, location_or_link, 
        interview_status, result
    )
    VALUES (
        p_application_id, p_interview_round, p_interview_date, p_interview_time,
        p_interview_mode, p_interviewer_name, p_interviewer_email, p_location_or_link,
        'Scheduled', 'Pending'
    );
    
    -- Update application status
    UPDATE Application
    SET application_status = 'Interview Scheduled'
    WHERE application_id = p_application_id;
    
    SELECT 'Interview scheduled successfully' AS message;
END //

-- ============================================
-- PROCEDURE 3: UpdateInterviewResult
-- Purpose: Update interview result and feedback
-- Parameters:
--   p_interview_id: Interview ID
--   p_result: Pass/Fail/On-Hold
--   p_rating: Rating (0-10)
--   p_feedback: Feedback text
-- ============================================
CREATE PROCEDURE UpdateInterviewResult(
    IN p_interview_id INT,
    IN p_result ENUM('Pass', 'Fail', 'On-Hold', 'Pending'),
    IN p_rating DECIMAL(2,1),
    IN p_feedback TEXT
)
BEGIN
    DECLARE v_interview_exists INT;
    
    SELECT COUNT(*) INTO v_interview_exists
    FROM Interview
    WHERE interview_id = p_interview_id;
    
    IF v_interview_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Interview does not exist';
    END IF;
    
    -- Update interview record
    UPDATE Interview
    SET 
        interview_status = 'Completed',
        result = p_result,
        rating = p_rating,
        feedback = p_feedback
    WHERE interview_id = p_interview_id;
    
    SELECT 'Interview result updated successfully' AS message;
END //

-- ============================================
-- PROCEDURE 4: MakeJobOffer
-- Purpose: Create a job offer for a selected candidate
-- Parameters:
--   p_application_id: Application ID
--   p_offered_salary: Salary offered
--   p_offered_designation: Designation offered
--   p_joining_date: Proposed joining date
-- ============================================
CREATE PROCEDURE MakeJobOffer(
    IN p_application_id INT,
    IN p_offered_salary DECIMAL(10,2),
    IN p_offered_designation VARCHAR(100),
    IN p_joining_date DATE
)
BEGIN
    DECLARE v_job_id INT;
    DECLARE v_candidate_id INT;
    DECLARE v_application_status VARCHAR(50);
    DECLARE v_offer_exists INT;
    
    -- Get application details
    SELECT job_id, candidate_id, application_status
    INTO v_job_id, v_candidate_id, v_application_status
    FROM Application
    WHERE application_id = p_application_id;
    
    IF v_application_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Application does not exist';
    END IF;
    
    IF v_application_status != 'Selected' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Application must be in Selected status to make an offer';
    END IF;
    
    -- Check if offer already exists
    SELECT COUNT(*) INTO v_offer_exists
    FROM Offer
    WHERE application_id = p_application_id;
    
    IF v_offer_exists > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Offer already exists for this application';
    END IF;
    
    -- Create offer
    INSERT INTO Offer (
        application_id, job_id, candidate_id, offer_date, 
        offered_salary, offered_designation, joining_date, offer_status
    )
    VALUES (
        p_application_id, v_job_id, v_candidate_id, CURDATE(),
        p_offered_salary, p_offered_designation, p_joining_date, 'Pending'
    );
    
    -- Update application status
    UPDATE Application
    SET application_status = 'Offered'
    WHERE application_id = p_application_id;
    
    SELECT 'Offer created successfully' AS message;
END //

-- ============================================
-- PROCEDURE 5: AcceptOffer
-- Purpose: Mark an offer as accepted by candidate
-- Parameters:
--   p_offer_id: Offer ID
-- ============================================
CREATE PROCEDURE AcceptOffer(
    IN p_offer_id INT
)
BEGIN
    DECLARE v_offer_status VARCHAR(20);
    
    SELECT offer_status INTO v_offer_status
    FROM Offer
    WHERE offer_id = p_offer_id;
    
    IF v_offer_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Offer does not exist';
    END IF;
    
    IF v_offer_status != 'Pending' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Offer is not in pending status';
    END IF;
    
    -- Update offer status
    UPDATE Offer
    SET 
        offer_status = 'Accepted',
        acceptance_date = CURDATE()
    WHERE offer_id = p_offer_id;
    
    -- Update application status
    UPDATE Application
    SET application_status = 'Joined'
    WHERE application_id = (SELECT application_id FROM Offer WHERE offer_id = p_offer_id);
    
    SELECT 'Offer accepted successfully' AS message;
END //

-- ============================================
-- PROCEDURE 6: GetJobStatistics
-- Purpose: Get comprehensive statistics for a job
-- Parameters:
--   p_job_id: Job ID
-- ============================================
CREATE PROCEDURE GetJobStatistics(
    IN p_job_id INT
)
BEGIN
    SELECT 
        j.job_id,
        j.job_title,
        c.company_name,
        j.posted_date,
        j.deadline,
        j.vacancies,
        COUNT(DISTINCT a.application_id) AS total_applications,
        COUNT(DISTINCT CASE WHEN a.application_status = 'Shortlisted' THEN a.application_id END) AS shortlisted,
        COUNT(DISTINCT CASE WHEN a.application_status = 'Selected' THEN a.application_id END) AS selected,
        COUNT(DISTINCT i.interview_id) AS interviews_conducted,
        COUNT(DISTINCT o.offer_id) AS offers_made,
        SUM(CASE WHEN o.offer_status = 'Accepted' THEN 1 ELSE 0 END) AS offers_accepted
    FROM 
        Job j
    INNER JOIN 
        Company c ON j.company_id = c.company_id
    LEFT JOIN 
        Application a ON j.job_id = a.job_id
    LEFT JOIN 
        Interview i ON a.application_id = i.application_id
    LEFT JOIN 
        Offer o ON a.application_id = o.application_id
    WHERE 
        j.job_id = p_job_id
    GROUP BY 
        j.job_id, j.job_title, c.company_name, j.posted_date, j.deadline, j.vacancies;
END //

-- ============================================
-- PROCEDURE 7: ShortlistCandidates
-- Purpose: Shortlist candidates based on experience and skills
-- Parameters:
--   p_job_id: Job ID
--   p_min_experience: Minimum experience required
-- ============================================
CREATE PROCEDURE ShortlistCandidates(
    IN p_job_id INT,
    IN p_min_experience DECIMAL(3,1)
)
BEGIN
    -- Update application status for qualified candidates
    UPDATE Application a
    INNER JOIN Candidate c ON a.candidate_id = c.candidate_id
    SET a.application_status = 'Shortlisted'
    WHERE 
        a.job_id = p_job_id
        AND a.application_status = 'Applied'
        AND c.total_experience >= p_min_experience;
    
    -- Return shortlisted candidates
    SELECT 
        a.application_id,
        CONCAT(c.first_name, ' ', c.last_name) AS candidate_name,
        c.email,
        c.total_experience,
        c.current_designation,
        a.application_date
    FROM 
        Application a
    INNER JOIN 
        Candidate c ON a.candidate_id = c.candidate_id
    WHERE 
        a.job_id = p_job_id
        AND a.application_status = 'Shortlisted'
    ORDER BY 
        c.total_experience DESC;
END //

-- Reset delimiter
DELIMITER ;

-- ============================================
-- Test Procedures
-- ============================================

-- Test ApplyForJob (Candidate 12 applying for Job 1)
CALL ApplyForJob(1, 12, 'I am very interested in this Senior Software Engineer position at TechCorp...');

-- Test ScheduleInterview
CALL ScheduleInterview(1, 'Technical', '2025-02-10', '10:00:00', 'Online', 'Suresh Kumar', 'suresh@techcorp.com', 'https://meet.google.com/test');

-- Test GetJobStatistics
CALL GetJobStatistics(1);

-- Test ShortlistCandidates (Shortlist candidates with 4+ years experience)
CALL ShortlistCandidates(1, 4.0);

-- Show all procedures
SHOW PROCEDURE STATUS WHERE Db = 'recruitment_management_system';
