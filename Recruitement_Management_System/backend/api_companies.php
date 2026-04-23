<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type');

require_once 'db_config.php';

$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        getCompanies();
        break;
    default:
        echo json_encode(['error' => 'Method not allowed']);
        break;
}

function getCompanies() {
    $result = executeQuery("SELECT company_id, company_name FROM Company ORDER BY company_name");
    echo json_encode($result);
}

closeConnection();
?>
