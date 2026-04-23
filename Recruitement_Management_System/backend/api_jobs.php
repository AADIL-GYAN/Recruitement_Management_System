<?php
/**
 * Jobs API
 * Handles job-related operations
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE');
header('Access-Control-Allow-Headers: Content-Type');

require_once 'db_config.php';

// Get request method
$method = $_SERVER['REQUEST_METHOD'];

// Handle different HTTP methods
switch ($method) {
    case 'GET':
        getJobs();
        break;
    case 'POST':
        addJob();
        break;
    case 'PUT':
        updateJob();
        break;
    case 'DELETE':
        deleteJob();
        break;
    default:
        echo json_encode(['error' => 'Method not allowed']);
        break;
}

/**
 * Get all jobs or a specific job
 */
function getJobs() {
    $id = isset($_GET['id']) ? intval($_GET['id']) : 0;
    $status = isset($_GET['status']) ? $_GET['status'] : '';
    
    if ($id > 0) {
        // Get specific job
        $query = "SELECT j.*, c.company_name, CONCAT(r.first_name, ' ', r.last_name) as recruiter_name
                  FROM Job j
                  INNER JOIN Company c ON j.company_id = c.company_id
                  INNER JOIN Recruiter r ON j.recruiter_id = r.recruiter_id
                  WHERE j.job_id = $id";
    } else if ($status) {
        // Filter by status
        $query = "SELECT j.*, c.company_name, CONCAT(r.first_name, ' ', r.last_name) as recruiter_name
                  FROM Job j
                  INNER JOIN Company c ON j.company_id = c.company_id
                  INNER JOIN Recruiter r ON j.recruiter_id = r.recruiter_id
                  WHERE j.job_status = '$status'
                  ORDER BY j.posted_date DESC";
    } else {
        // Get all jobs
        $query = "SELECT j.*, c.company_name, CONCAT(r.first_name, ' ', r.last_name) as recruiter_name
                  FROM Job j
                  INNER JOIN Company c ON j.company_id = c.company_id
                  INNER JOIN Recruiter r ON j.recruiter_id = r.recruiter_id
                  ORDER BY j.posted_date DESC";
    }
    
    $result = executeQuery($query);
    echo json_encode($result);
}

/**
 * Add a new job
 */
function addJob() {
    $data = json_decode(file_get_contents('php://input'), true);
    
    $company_id = $data['company_id'];
    $recruiter_id = $data['recruiter_id'];
    $job_title = $data['job_title'];
    $job_description = $data['job_description'] ?? '';
    $department = $data['department'] ?? '';
    $employment_type = $data['employment_type'] ?? 'Full-Time';
    $experience_required = $data['experience_required'] ?? 0;
    $salary_min = $data['salary_min'] ?? 0;
    $salary_max = $data['salary_max'] ?? 0;
    $location = $data['location'] ?? '';
    $skills_required = $data['skills_required'] ?? '';
    $vacancies = $data['vacancies'] ?? 1;
    $deadline = $data['deadline'] ?? '';
    
    $query = "INSERT INTO Job (company_id, recruiter_id, job_title, job_description, department, 
              employment_type, experience_required, salary_min, salary_max, location, 
              skills_required, vacancies, deadline)
              VALUES ($company_id, $recruiter_id, '$job_title', '$job_description', '$department',
              '$employment_type', $experience_required, $salary_min, $salary_max, '$location',
              '$skills_required', $vacancies, '$deadline')";
    
    $result = executeNonQuery($query);
    
    if ($result) {
        echo json_encode(['success' => true, 'message' => 'Job added successfully', 'id' => $result]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to add job']);
    }
}

/**
 * Update a job
 */
function updateJob() {
    $data = json_decode(file_get_contents('php://input'), true);
    
    $job_id = $data['job_id'];
    $job_status = $data['job_status'] ?? '';
    $vacancies = $data['vacancies'] ?? null;
    
    $updates = [];
    if ($job_status) $updates[] = "job_status = '$job_status'";
    if ($vacancies !== null) $updates[] = "vacancies = $vacancies";
    
    if (empty($updates)) {
        echo json_encode(['success' => false, 'message' => 'No fields to update']);
        return;
    }
    
    $query = "UPDATE Job SET " . implode(', ', $updates) . " WHERE job_id = $job_id";
    
    $result = executeNonQuery($query);
    
    if ($result) {
        echo json_encode(['success' => true, 'message' => 'Job updated successfully']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to update job']);
    }
}

/**
 * Delete a job
 */
function deleteJob() {
    $data = json_decode(file_get_contents('php://input'), true);
    $job_id = $data['job_id'];
    
    $query = "DELETE FROM Job WHERE job_id = $job_id";
    
    $result = executeNonQuery($query);
    
    if ($result) {
        echo json_encode(['success' => true, 'message' => 'Job deleted successfully']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to delete job']);
    }
}

closeConnection();
?>
