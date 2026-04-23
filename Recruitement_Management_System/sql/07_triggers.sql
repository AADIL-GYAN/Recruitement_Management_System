

USE recruitment_management_system;

-- Change delimiter for trigger creation
DELIMITER //

-- ============================================
-- TRIGGER 1: AutoUpdateApplicationStatus
-- Type: AFTER UPDATE on Interview table
-- Purpose: Automatically update application status when interview result is updated
-- Business Logic: 
--   - If all interviews are passed, set status to 'Selected'
--   - If any interview is failed, set status to 'Rejected'
-- ============================================
CREATE TRIGGER AutoUpdateApplicationStatus
AFTER UPDATE ON Interview
FOR EACH ROW
BEGIN
    DECLARE v_failed_count INT;
    DECLARE v_pending_count INT;
    DECLARE v_total_count INT;
    
    -- Count interview results for this application
    SELECT 
        COUNT(*) AS total,
        SUM(CASE WHEN result = 'Fail' THEN 1 ELSE 0 END) AS failed,
        SUM(CASE WHEN result = 'Pending' THEN 1 ELSE 0 END) AS pending
    INTO v_total_count, v_failed_count, v_pending_count
    FROM Interview
    WHERE application_id = NEW.application_id
    AND interview_status = 'Completed';
    
    -- If any interview failed, reject the application
    IF v_failed_count > 0 THEN
        UPDATE Application
        SET application_status = 'Rejected'
        WHERE application_id = NEW.application_id;
    
    -- If all interviews passed (no pending, no failed)
    ELSEIF v_pending_count = 0 AND v_total_count > 0 THEN
        UPDATE Application
        SET application_status = 'Selected'
        WHERE application_id = NEW.application_id;
    END IF;
END //

-- ============================================
-- TRIGGER 2: PreventDuplicateApplication
-- Type: BEFORE INSERT on Application table
-- Purpose: Prevent candidate from applying to same job twice
-- Note: This is also handled by UNIQUE constraint, but trigger provides custom message
-- ============================================
CREATE TRIGGER PreventDuplicateApplication
BEFORE INSERT ON Application
FOR EACH ROW
BEGIN
    DECLARE v_exists INT;
    
    SELECT COUNT(*) INTO v_exists
    FROM Application
    WHERE job_id = NEW.job_id AND candidate_id = NEW.candidate_id;
    
    IF v_exists > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Candidate has already applied for this job';
    END IF;
END //

-- ============================================
-- TRIGGER 3: ValidateJobDeadline
-- Type: BEFORE INSERT on Job table
-- Purpose: Ensure job deadline is at least 7 days from posting date
-- Business Rule: Jobs must be open for minimum 7 days
-- ============================================
CREATE TRIGGER ValidateJobDeadline
BEFORE INSERT ON Job
FOR EACH ROW
BEGIN
    IF NEW.deadline < DATE_ADD(NEW.posted_date, INTERVAL 7 DAY) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Job deadline must be at least 7 days from posting date';
    END IF;
END //

-- ============================================
-- TRIGGER 4: LogOfferAcceptance
-- Type: AFTER UPDATE on Offer table
-- Purpose: Update application status when offer is accepted/rejected
-- ============================================
CREATE TRIGGER LogOfferAcceptance
AFTER UPDATE ON Offer
FOR EACH ROW
BEGIN
    -- If offer is accepted, update application to Joined
    IF NEW.offer_status = 'Accepted' AND OLD.offer_status != 'Accepted' THEN
        UPDATE Application
        SET application_status = 'Joined'
        WHERE application_id = NEW.application_id;
    
    -- If offer is rejected, update application status
    ELSEIF NEW.offer_status = 'Rejected' AND OLD.offer_status != 'Rejected' THEN
        UPDATE Application
        SET application_status = 'Offered'
        WHERE application_id = NEW.application_id;
    END IF;
END //

-- ============================================
-- TRIGGER 5: AutoCloseJobAfterDeadline
-- Type: BEFORE UPDATE on Job table
-- Purpose: Automatically close job if updated after deadline
-- ============================================
CREATE TRIGGER AutoCloseJobAfterDeadline
BEFORE UPDATE ON Job
FOR EACH ROW
BEGIN
    IF NEW.deadline < CURDATE() AND OLD.job_status = 'Open' THEN
        SET NEW.job_status = 'Closed';
    END IF;
END //

-- ============================================
-- TRIGGER 6: ValidateInterviewDate
-- Type: BEFORE INSERT on Interview table
-- Purpose: Ensure interview is not scheduled in the past
-- ============================================
CREATE TRIGGER ValidateInterviewDate
BEFORE INSERT ON Interview
FOR EACH ROW
BEGIN
    IF NEW.interview_date < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Interview cannot be scheduled in the past';
    END IF;
END //

-- ============================================
-- TRIGGER 7: UpdateJobVacancyOnOffer
-- Type: AFTER INSERT on Offer table
-- Purpose: Reduce vacancy count when offer is made (if accepted)
-- Note: This is a simplified version; in production, you might want more complex logic
-- ============================================
CREATE TRIGGER UpdateJobVacancyOnOffer
AFTER UPDATE ON Offer
FOR EACH ROW
BEGIN
    -- When offer is accepted, reduce vacancy count
    IF NEW.offer_status = 'Accepted' AND OLD.offer_status != 'Accepted' THEN
        UPDATE Job
        SET vacancies = GREATEST(0, vacancies - 1)
        WHERE job_id = NEW.job_id;
    
    -- When offer is rejected, increase vacancy count back
    ELSEIF NEW.offer_status = 'Rejected' AND OLD.offer_status = 'Accepted' THEN
        UPDATE Job
        SET vacancies = vacancies + 1
        WHERE job_id = NEW.job_id;
    END IF;
END //

-- ============================================
-- TRIGGER 8: ValidateCandidateAge
-- Type: BEFORE INSERT on Candidate table
-- Purpose: Ensure candidate is at least 18 years old
-- ============================================
CREATE TRIGGER ValidateCandidateAge
BEFORE INSERT ON Candidate
FOR EACH ROW
BEGIN
    DECLARE v_age INT;
    
    SET v_age = YEAR(CURDATE()) - YEAR(NEW.date_of_birth);
    
    IF v_age < 18 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Candidate must be at least 18 years old';
    END IF;
END //

-- ============================================
-- TRIGGER 9: ValidateOfferSalary
-- Type: BEFORE INSERT on Offer table
-- Purpose: Ensure offered salary is within job salary range
-- ============================================
CREATE TRIGGER ValidateOfferSalary
BEFORE INSERT ON Offer
FOR EACH ROW
BEGIN
    DECLARE v_salary_min DECIMAL(10,2);
    DECLARE v_salary_max DECIMAL(10,2);
    
    SELECT salary_min, salary_max INTO v_salary_min, v_salary_max
    FROM Job
    WHERE job_id = NEW.job_id;
    
    IF NEW.offered_salary < v_salary_min OR NEW.offered_salary > v_salary_max THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Offered salary must be within job salary range';
    END IF;
END //

-- Reset delimiter
DELIMITER ;

-- ============================================
-- Display all triggers
-- ============================================
SHOW TRIGGERS FROM recruitment_management_system;

-- ============================================
-- Test Triggers
-- ============================================

-- Test Trigger 1: AutoUpdateApplicationStatus
-- (Already tested through interview updates)

-- Test Trigger 3: ValidateJobDeadline
-- This will fail due to trigger
-- INSERT INTO Job (company_id, recruiter_id, job_title, posted_date, deadline) 
-- VALUES (1, 1, 'Test Job', '2025-02-01', '2025-02-03');

-- Test Trigger 6: ValidateInterviewDate
-- This will fail due to trigger
-- INSERT INTO Interview (application_id, interview_round, interview_date, interview_time)
-- VALUES (1, 'Technical', '2024-01-01', '10:00:00');

-- Test Trigger 8: ValidateCandidateAge
-- This will fail due to trigger (candidate too young)
-- INSERT INTO Candidate (first_name, last_name, email, date_of_birth)
-- VALUES ('Test', 'Minor', 'minor@test.com', '2010-01-01');

-- ============================================
-- Trigger Documentation
-- ============================================
/*
TRIGGER SUMMARY:

1. AutoUpdateApplicationStatus
   - Timing: AFTER UPDATE on Interview
   - Event: Interview result update
   - Logic: Changes application status based on interview outcomes

2. PreventDuplicateApplication
   - Timing: BEFORE INSERT on Application
   - Event: New application
   - Logic: Prevents duplicate applications

3. ValidateJobDeadline
   - Timing: BEFORE INSERT on Job
   - Event: New job posting
   - Logic: Ensures minimum 7-day application period

4. LogOfferAcceptance
   - Timing: AFTER UPDATE on Offer
   - Event: Offer status change
   - Logic: Synchronizes application status with offer status

5. AutoCloseJobAfterDeadline
   - Timing: BEFORE UPDATE on Job
   - Event: Job update
   - Logic: Automatically closes jobs past deadline

6. ValidateInterviewDate
   - Timing: BEFORE INSERT on Interview
   - Event: Interview scheduling
   - Logic: Prevents past-date scheduling

7. UpdateJobVacancyOnOffer
   - Timing: AFTER UPDATE on Offer
   - Event: Offer acceptance/rejection
   - Logic: Adjusts vacancy count

8. ValidateCandidateAge
   - Timing: BEFORE INSERT on Candidate
   - Event: Candidate registration
   - Logic: Ensures minimum age requirement

9. ValidateOfferSalary
   - Timing: BEFORE INSERT on Offer
   - Event: Offer creation
   - Logic: Validates salary within job range
*/
