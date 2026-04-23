<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

require_once 'db_config.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);
    
    $email = $data['email'] ?? '';
    $password = $data['password'] ?? '';
    
    // For this demo, we can just return success for any email
    // Or we can check if the email exists in Recruiter table
    
    if (empty($email)) {
        echo json_encode(['success' => false, 'message' => 'Email is required']);
        exit;
    }
    
    // Dummy Credentials for Demo
    // Simplified Demo Login: Any email, as long as password is 'admin123' or '123456'
    if ($password === 'admin123' || $password === '123456') {
        echo json_encode([
            'success' => true,
            'user' => [
                'id' => 1,
                'name' => 'Demo Admin',
                'email' => $email
            ],
            'message' => 'Login successful'
        ]);
        exit;
    } else {
        echo json_encode(['success' => false, 'message' => 'Incorrect Password. Use: admin123']);
        exit;
    }
} else {
    echo json_encode(['error' => 'Method not allowed']);
}
?>
