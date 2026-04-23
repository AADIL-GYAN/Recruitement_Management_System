

USE recruitment_management_system;

-- ============================================
-- TRANSACTION 1: Complete Application Process
-- Purpose: Apply for job and schedule initial screening
-- Demonstrates: Atomicity (All-or-Nothing)
-- ============================================

START TRANSACTION;

-- Step 1: Insert application
INSERT INTO Application (job_id, candidate_id, application_date, cover_letter, application_status)
VALUES (2, 12, CURDATE(), 'I am very interested in the Frontend Developer position...', 'Applied');

-- Get the last inserted application_id
SET @last_app_id = LAST_INSERT_ID();

-- Step 2: Schedule screening interview
INSERT INTO Interview (
    application_id, interview_round, interview_date, interview_time, 
    interview_mode, interviewer_name, interviewer_email, 
    location_or_link, interview_status, result
)
VALUES (
    @last_app_id, 'Screening', '2025-02-15', '11:00:00',
    'Phone', 'Priya Sharma', 'priya.sharma@techcorp.com',
    '+91-9999988882', 'Scheduled', 'Pending'
);

-- Step 3: Update application status to Interview Scheduled
UPDATE Application
SET application_status = 'Interview Scheduled'
WHERE application_id = @last_app_id;

-- Verify the changes
SELECT 'Application and Interview Created' AS status;
SELECT * FROM Application WHERE application_id = @last_app_id;
SELECT * FROM Interview WHERE application_id = @last_app_id;

COMMIT;

-- ============================================
-- TRANSACTION 2: Interview Result to Offer Process
-- Purpose: Update interview result and create offer if passed
-- Demonstrates: Atomicity and Consistency
-- ============================================

START TRANSACTION;

-- Assume interview_id = 11 (from existing data)
SET @interview_id = 11;
SET @application_id = 9;

-- Step 1: Update interview result
UPDATE Interview
SET 
    interview_status = 'Completed',
    result = 'Pass',
    rating = 9.0,
    feedback = 'Excellent technical skills and cultural fit'
WHERE interview_id = @interview_id;

-- Step 2: Update application status to Selected
UPDATE Application
SET application_status = 'Selected'
WHERE application_id = @application_id;

-- Step 3: Create offer
INSERT INTO Offer (
    application_id, job_id, candidate_id, 
    offer_date, offered_salary, offered_designation, 
    joining_date, offer_status
)
SELECT 
    @application_id, 
    a.job_id, 
    a.candidate_id,
    CURDATE(),
    1400000.00,
    'DevOps Engineer',
    DATE_ADD(CURDATE(), INTERVAL 30 DAY),
    'Pending'
FROM Application a
WHERE a.application_id = @application_id;

SELECT 'Interview completed and offer created' AS status;

COMMIT;

-- ============================================
-- TRANSACTION 3: Bulk Candidate Shortlisting
-- Purpose: Shortlist multiple candidates based on criteria
-- Demonstrates: Atomicity with multiple updates
-- ============================================

START TRANSACTION;

-- Shortlist all candidates with experience >= 4 years for job_id = 1
UPDATE Application a
INNER JOIN Candidate c ON a.candidate_id = c.candidate_id
SET a.application_status = 'Shortlisted'
WHERE 
    a.job_id = 1
    AND a.application_status = 'Applied'
    AND c.total_experience >= 4.0;

-- Get count of shortlisted candidates
SELECT 
    COUNT(*) AS shortlisted_count,
    'Candidates shortlisted successfully' AS message
FROM Application
WHERE job_id = 1 AND application_status = 'Shortlisted';

COMMIT;

-- ============================================
-- TRANSACTION 4: Offer Acceptance and Vacancy Update
-- Purpose: Accept offer and update job vacancy
-- Demonstrates: Consistency (maintaining valid state)
-- ============================================

START TRANSACTION;

SET @offer_id = 2;

-- Step 1: Get offer details
SELECT job_id, application_id INTO @job_id, @app_id
FROM Offer
WHERE offer_id = @offer_id;

-- Step 2: Update offer status to Accepted
UPDATE Offer
SET 
    offer_status = 'Accepted',
    acceptance_date = CURDATE()
WHERE offer_id = @offer_id;

-- Step 3: Update application status
UPDATE Application
SET application_status = 'Joined'
WHERE application_id = @app_id;

-- Step 4: Reduce vacancy count
UPDATE Job
SET vacancies = GREATEST(0, vacancies - 1)
WHERE job_id = @job_id;

SELECT 'Offer accepted and vacancy updated' AS status;
SELECT * FROM Offer WHERE offer_id = @offer_id;
SELECT job_id, job_title, vacancies FROM Job WHERE job_id = @job_id;

COMMIT;

-- ============================================
-- TRANSACTION 5: ROLLBACK Example - Failed Application
-- Purpose: Demonstrate transaction rollback on error
-- Demonstrates: Atomicity (rollback on failure)
-- ============================================

START TRANSACTION;

-- Try to apply for a closed job (this should fail)
SET @test_job_id = 1;
SET @test_candidate_id = 10;

-- First, let's check the job status
SELECT job_status FROM Job WHERE job_id = @test_job_id;

-- Attempt to insert application
INSERT INTO Application (job_id, candidate_id, application_date, cover_letter, application_status)
VALUES (@test_job_id, @test_candidate_id, CURDATE(), 'Test application', 'Applied');

-- Simulate a business rule check
SET @job_status = (SELECT job_status FROM Job WHERE job_id = @test_job_id);

-- If job is closed, rollback
IF @job_status = 'Closed' THEN
    ROLLBACK;
    SELECT 'Transaction rolled back - Job is closed' AS status;
ELSE
    COMMIT;
    SELECT 'Application submitted successfully' AS status;
END IF;

-- Note: In actual implementation, you would use stored procedures for complex conditional logic

-- ============================================
-- TRANSACTION 6: Savepoint Example
-- Purpose: Demonstrate partial rollback using savepoints
-- Demonstrates: Savepoint usage for complex transactions
-- ============================================

START TRANSACTION;

-- Create a new job
INSERT INTO Job (
    company_id, recruiter_id, job_title, job_description, 
    department, employment_type, experience_required, 
    salary_min, salary_max, location, vacancies, 
    posted_date, deadline, job_status
)
VALUES (
    1, 1, 'Senior Data Engineer', 'Work on big data pipelines',
    'Engineering', 'Full-Time', 5, 
    1500000.00, 2000000.00, 'Bangalore', 2,
    CURDATE(), DATE_ADD(CURDATE(), INTERVAL 30 DAY), 'Open'
);

SET @new_job_id = LAST_INSERT_ID();

-- Create savepoint after job creation
SAVEPOINT after_job_creation;

-- Add job skills
INSERT INTO JobSkill (job_id, skill_id, is_mandatory)
VALUES 
    (@new_job_id, 2, TRUE),  -- Python
    (@new_job_id, 19, TRUE); -- SQL

-- Create another savepoint
SAVEPOINT after_skills;

-- Try to add an invalid skill (assume skill_id 999 doesn't exist)
-- This would fail, so we can rollback to savepoint
-- INSERT INTO JobSkill (job_id, skill_id, is_mandatory)
-- VALUES (@new_job_id, 999, FALSE);

-- If error occurs, rollback to last savepoint
-- ROLLBACK TO SAVEPOINT after_skills;

-- Otherwise commit everything
SELECT 'Job and skills created successfully' AS status;
SELECT * FROM Job WHERE job_id = @new_job_id;
SELECT * FROM JobSkill WHERE job_id = @new_job_id;

COMMIT;

-- ============================================
-- TRANSACTION 7: Concurrent Application Handling
-- Purpose: Handle race condition for last vacancy
-- Demonstrates: Isolation (preventing concurrent issues)
-- ============================================

-- Session 1 (Simulated)
START TRANSACTION;

-- Lock the job row for update
SELECT job_id, job_title, vacancies
FROM Job
WHERE job_id = 5 AND job_status = 'Open'
FOR UPDATE;

-- Check if vacancy available
SET @vacancies = (SELECT vacancies FROM Job WHERE job_id = 5);

IF @vacancies > 0 THEN
    -- Submit application
    INSERT INTO Application (job_id, candidate_id, application_date, application_status)
    VALUES (5, 10, CURDATE(), 'Applied');
    
    SELECT 'Application submitted' AS status;
ELSE
    SELECT 'No vacancies available' AS status;
END IF;

COMMIT;

-- ============================================
-- TRANSACTION 8: Batch Interview Scheduling
-- Purpose: Schedule interviews for all shortlisted candidates
-- Demonstrates: Batch operations in transaction
-- ============================================

START TRANSACTION;

-- Get all shortlisted applications for a specific job
SET @target_job_id = 1;

-- Schedule technical interviews for all shortlisted candidates
INSERT INTO Interview (
    application_id, interview_round, interview_date, interview_time,
    interview_mode, interviewer_name, interviewer_email,
    location_or_link, interview_status, result
)
SELECT 
    a.application_id,
    'Technical',
    DATE_ADD(CURDATE(), INTERVAL 5 DAY),
    '10:00:00',
    'Online',
    'Technical Panel',
    'tech@techcorp.com',
    'https://meet.google.com/batch-interviews',
    'Scheduled',
    'Pending'
FROM Application a
WHERE 
    a.job_id = @target_job_id
    AND a.application_status = 'Shortlisted'
    AND NOT EXISTS (
        SELECT 1 FROM Interview i 
        WHERE i.application_id = a.application_id 
        AND i.interview_round = 'Technical'
    );

-- Update all these applications to Interview Scheduled
UPDATE Application
SET application_status = 'Interview Scheduled'
WHERE 
    job_id = @target_job_id
    AND application_status = 'Shortlisted';

SELECT ROW_COUNT() AS interviews_scheduled;

COMMIT;

-- ============================================
-- TRANSACTION DOCUMENTATION
-- ============================================

/*
ACID PROPERTIES DEMONSTRATED:

1. ATOMICITY:
   - Transactions 1, 2, 5: All operations succeed or all fail
   - Example: Application + Interview creation happens together

2. CONSISTENCY:
   - Transaction 4: Maintains data integrity (vacancy count matches hires)
   - Database rules and constraints are never violated

3. ISOLATION:
   - Transaction 7: FOR UPDATE lock prevents concurrent modifications
   - Prevents race conditions in vacancy allocation

4. DURABILITY:
   - All committed transactions persist in database
   - COMMIT ensures permanent storage

KEY CONCEPTS ILLUSTRATED:

1. START TRANSACTION: Begins transaction block
2. COMMIT: Saves all changes permanently
3. ROLLBACK: Undoes all changes in transaction
4. SAVEPOINT: Creates checkpoint for partial rollback
5. FOR UPDATE: Row-level locking for concurrency control
6. SET variables: Store intermediate results
7. Conditional logic: Business rule enforcement
8. Batch operations: Multiple related operations together

BEST PRACTICES:

1. Keep transactions short and focused
2. Handle errors appropriately
3. Use savepoints for complex transactions
4. Lock rows when reading for update
5. Verify data before committing
6. Use appropriate isolation levels
7. Document transaction purpose
8. Test rollback scenarios
*/

-- ============================================
-- Verify Transaction Results
-- ============================================

-- Check recent applications
SELECT * FROM Application ORDER BY application_id DESC LIMIT 5;

-- Check recent interviews
SELECT * FROM Interview ORDER BY interview_id DESC LIMIT 5;

-- Check recent offers
SELECT * FROM Offer ORDER BY offer_id DESC LIMIT 5;

-- Check job vacancies
SELECT job_id, job_title, vacancies FROM Job WHERE vacancies > 0;
