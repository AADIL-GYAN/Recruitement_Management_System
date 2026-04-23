<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE');
header('Access-Control-Allow-Headers: Content-Type');

require_once 'db_config.php';

$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        getApplications();
        break;
    case 'POST':
        addApplication();
        break;
    case 'PUT':
        updateApplication();
        break;
    case 'DELETE':
        deleteApplication();
        break;
    default:
        echo json_encode(['error' => 'Method not allowed']);
        break;
}

function getApplications() {
    $id = isset($_GET['id']) ? intval($_GET['id']) : 0;
    
    if ($id > 0) {
        $query = "SELECT a.*, j.job_title, j.company_name, c.first_name, c.last_name, c.email
                  FROM Application a
                  JOIN Job j ON a.job_id = j.job_id
                  JOIN Candidate c ON a.candidate_id = c.candidate_id
                  WHERE a.application_id = $id";
    } else {
        $query = "SELECT a.*, j.job_title, comp.company_name, c.first_name, c.last_name
                  FROM Application a
                  JOIN Job j ON a.job_id = j.job_id
                  JOIN Company comp ON j.company_id = comp.company_id
                  JOIN Candidate c ON a.candidate_id = c.candidate_id
                  ORDER BY a.application_date DESC";
    }
    
    $result = executeQuery($query);
    echo json_encode($result);
}

function addApplication() {
    $data = json_decode(file_get_contents('php://input'), true);
    
    $job_id = $data['job_id'];
    $candidate_id = $data['candidate_id'];
    $cover_letter = $data['cover_letter'] ?? '';
    $application_status = 'Applied';
    
    $query = "INSERT INTO Application (job_id, candidate_id, cover_letter, application_status)
              VALUES ($job_id, $candidate_id, '$cover_letter', '$application_status')";
    
    $result = executeNonQuery($query);
    
    if ($result) {
        echo json_encode(['success' => true, 'message' => 'Application submitted successfully', 'id' => $result]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to submit application']);
    }
}

function updateApplication() {
    $data = json_decode(file_get_contents('php://input'), true);
    $application_id = $data['application_id'];
    
    $updates = [];
    if (isset($data['application_status'])) $updates[] = "application_status = '{$data['application_status']}'";
    if (isset($data['cover_letter'])) $updates[] = "cover_letter = '{$data['cover_letter']}'";
    
    if (empty($updates)) {
        echo json_encode(['success' => false, 'message' => 'No fields to update']);
        return;
    }
    
    $query = "UPDATE Application SET " . implode(', ', $updates) . " WHERE application_id = $application_id";
    $result = executeNonQuery($query);
    
    if ($result) {
        echo json_encode(['success' => true, 'message' => 'Application updated successfully']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to update application']);
    }
}

function deleteApplication() {
    $data = json_decode(file_get_contents('php://input'), true);
    $application_id = $data['application_id'];
    
    $query = "DELETE FROM Application WHERE application_id = $application_id";
    $result = executeNonQuery($query);
    
    if ($result) {
        echo json_encode(['success' => true, 'message' => 'Application deleted successfully']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to delete application']);
    }
}

closeConnection();
?>
