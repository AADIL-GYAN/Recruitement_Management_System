<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE');
header('Access-Control-Allow-Headers: Content-Type');

require_once 'db_config.php';

$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        getCandidates();
        break;
    case 'POST':
        addCandidate();
        break;
    case 'PUT':
        updateCandidate();
        break;
    case 'DELETE':
        deleteCandidate();
        break;
    default:
        echo json_encode(['error' => 'Method not allowed']);
        break;
}

function getCandidates() {
    $id = isset($_GET['id']) ? intval($_GET['id']) : 0;
    
    if ($id > 0) {
        $query = "SELECT * FROM Candidate WHERE candidate_id = $id";
    } else {
        $query = "SELECT * FROM Candidate ORDER BY registration_date DESC";
    }
    
    $result = executeQuery($query);
    echo json_encode($result);
}

function addCandidate() {
    $data = json_decode(file_get_contents('php://input'), true);
    
    $first_name = $data['first_name'];
    $last_name = $data['last_name'];
    $email = $data['email'];
    $phone = $data['phone'] ?? '';
    $date_of_birth = $data['date_of_birth'] ?? '';
    $gender = $data['gender'] ?? '';
    $current_company = $data['current_company'] ?? '';
    $current_designation = $data['current_designation'] ?? '';
    $total_experience = $data['total_experience'] ?? 0;
    $highest_qualification = $data['highest_qualification'] ?? '';
    $skills = $data['skills'] ?? '';
    $city = $data['city'] ?? '';
    
    $query = "INSERT INTO Candidate (first_name, last_name, email, phone, date_of_birth, gender, 
              current_company, current_designation, total_experience, highest_qualification, skills, city)
              VALUES ('$first_name', '$last_name', '$email', '$phone', '$date_of_birth', '$gender',
              '$current_company', '$current_designation', $total_experience, '$highest_qualification', '$skills', '$city')";
    
    $result = executeNonQuery($query);
    
    if ($result) {
        echo json_encode(['success' => true, 'message' => 'Candidate added successfully', 'id' => $result]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to add candidate']);
    }
}

function updateCandidate() {
    $data = json_decode(file_get_contents('php://input'), true);
    $candidate_id = $data['candidate_id'];
    
    $updates = [];
    if (isset($data['first_name'])) $updates[] = "first_name = '{$data['first_name']}'";
    if (isset($data['last_name'])) $updates[] = "last_name = '{$data['last_name']}'";
    if (isset($data['email'])) $updates[] = "email = '{$data['email']}'";
    if (isset($data['total_experience'])) $updates[] = "total_experience = {$data['total_experience']}";
    
    if (empty($updates)) {
        echo json_encode(['success' => false, 'message' => 'No fields to update']);
        return;
    }
    
    $query = "UPDATE Candidate SET " . implode(', ', $updates) . " WHERE candidate_id = $candidate_id";
    $result = executeNonQuery($query);
    
    if ($result) {
        echo json_encode(['success' => true, 'message' => 'Candidate updated successfully']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to update candidate']);
    }
}

function deleteCandidate() {
    $data = json_decode(file_get_contents('php://input'), true);
    $candidate_id = $data['candidate_id'];
    
    $query = "DELETE FROM Candidate WHERE candidate_id = $candidate_id";
    $result = executeNonQuery($query);
    
    if ($result) {
        echo json_encode(['success' => true, 'message' => 'Candidate deleted successfully']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to delete candidate']);
    }
}

closeConnection();
?>
