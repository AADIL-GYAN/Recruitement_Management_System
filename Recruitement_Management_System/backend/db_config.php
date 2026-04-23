<?php
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', ''); 
define('DB_NAME', 'recruitment_management_system');

$conn = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$conn->set_charset("utf8");

function executeQuery($query) {
    global $conn;
    $result = $conn->query($query);
    
    if ($result === false) {
        return ['error' => $conn->error];
    }
    
    $data = [];
    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
    
    return $data;
}

function executeNonQuery($query) {
    global $conn;
    
    if ($conn->query($query) === TRUE) {
        return $conn->insert_id > 0 ? $conn->insert_id : true;
    }
    
    return false;
}

function executePrepared($query, $params = [], $types = '') {
    global $conn;
    
    $stmt = $conn->prepare($query);
    
    if ($stmt === false) {
        return ['error' => $conn->error];
    }
    
    if (!empty($params)) {
        $stmt->bind_param($types, ...$params);
    }
    
    $stmt->execute();
    
    $result = $stmt->get_result();
    
    if ($result) {
        $data = [];
        while ($row = $result->fetch_assoc()) {
            $data[] = $row;
        }
        return $data;
    }
    
    return $stmt->affected_rows > 0 ? $stmt->insert_id : true;
}

function closeConnection() {
    global $conn;
    $conn->close();
}
?>
