<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE');
header('Access-Control-Allow-Headers: Content-Type');

require_once 'db_config.php';

$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        getInterviews();
        break;
    case 'POST':
        scheduleInterview();
        break;
    case 'PUT':
        updateInterview();
        break;
    case 'DELETE':
        deleteInterview();
        break;
    default:
        echo json_encode(['error' => 'Method not allowed']);
        break;
}

function getInterviews() {
    $id = isset($_GET['id']) ? intval($_GET['id']) : 0;
    
    if ($id > 0) {
        $query = "SELECT i.*, j.job_title, c.first_name, c.last_name
                  FROM Interview i
                  JOIN Application a ON i.application_id = a.application_id
                  JOIN Job j ON a.job_id = j.job_id
                  JOIN Candidate c ON a.candidate_id = c.candidate_id
                  WHERE i.interview_id = $id";
    } else {
        $query = "SELECT i.*, j.job_title, c.first_name, c.last_name
                  FROM Interview i
                  JOIN Application a ON i.application_id = a.application_id
                  JOIN Job j ON a.job_id = j.job_id
                  JOIN Candidate c ON a.candidate_id = c.candidate_id
                  ORDER BY i.interview_date DESC, i.interview_time ASC";
    }
    
    $result = executeQuery($query);
    echo json_encode($result);
}

function scheduleInterview() {
    $data = json_decode(file_get_contents('php://input'), true);
    
    $application_id = $data['application_id'];
    $interview_round = $data['interview_round'];
    $interview_date = $data['interview_date'];
    $interview_time = $data['interview_time'];
    $interview_mode = $data['interview_mode'];
    $interviewer_name = $data['interviewer_name'] ?? '';
    $location_or_link = $data['location_or_link'] ?? '';
    
    $query = "INSERT INTO Interview (application_id, interview_round, interview_date, interview_time, interview_mode, interviewer_name, location_or_link, interview_status)
              VALUES ($application_id, '$interview_round', '$interview_date', '$interview_time', '$interview_mode', '$interviewer_name', '$location_or_link', 'Scheduled')";
    
    $result = executeNonQuery($query);
    
    if ($result) {
        // Update application status
        executeNonQuery("UPDATE Application SET application_status = 'Interview Scheduled' WHERE application_id = $application_id");
        echo json_encode(['success' => true, 'message' => 'Interview scheduled successfully', 'id' => $result]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to schedule interview']);
    }
}

function updateInterview() {
    $data = json_decode(file_get_contents('php://input'), true);
    $interview_id = $data['interview_id'];
    
    $updates = [];
    if (isset($data['interview_status'])) $updates[] = "interview_status = '{$data['interview_status']}'";
    if (isset($data['result'])) $updates[] = "result = '{$data['result']}'";
    if (isset($data['feedback'])) $updates[] = "feedback = '{$data['feedback']}'";
    
    if (empty($updates)) {
        echo json_encode(['success' => false, 'message' => 'No fields to update']);
        return;
    }
    
    $query = "UPDATE Interview SET " . implode(', ', $updates) . " WHERE interview_id = $interview_id";
    $result = executeNonQuery($query);
    
    if ($result) {
        echo json_encode(['success' => true, 'message' => 'Interview updated successfully']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to update interview']);
    }
}

function deleteInterview() {
    $data = json_decode(file_get_contents('php://input'), true);
    $interview_id = $data['interview_id'];
    
    $query = "DELETE FROM Interview WHERE interview_id = $interview_id";
    $result = executeNonQuery($query);
    
    if ($result) {
        echo json_encode(['success' => true, 'message' => 'Interview deleted successfully']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to delete interview']);
    }
}

closeConnection();
?>
