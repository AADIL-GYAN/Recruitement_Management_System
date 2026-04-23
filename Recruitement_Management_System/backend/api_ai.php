<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

$data = json_decode(file_get_contents('php://input'), true);
$action = $data['action'] ?? '';
$groq_api_key = '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';

if (empty($action)) {
    echo json_encode(['error' => 'Action required']);
    exit;
}

function callGroqAPI($prompt, $apiKey) {
    if (empty($apiKey)) {
        return ['error' => 'API Key Config Missing'];
    }

    $url = 'https://api.groq.com/openai/v1/chat/completions';
    
    $payload = [
        'messages' => [
            ['role' => 'user', 'content' => $prompt]
        ],
        'model' => 'llama-3.3-70b-versatile', // Updated for compatibility
        'temperature' => 0.7,
        'max_tokens' => 1024
    ];

    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Content-Type: application/json',
        'Authorization: Bearer ' . $apiKey
    ]);
    
    // Disable SSL verification for XAMPP/local dev ease (NOT for prod)
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);

    $response = curl_exec($ch);
    
    if (curl_errno($ch)) {
        return ['error' => curl_error($ch)];
    }
    
    curl_close($ch);
    
    $result = json_decode($response, true);
    if (isset($result['choices'][0]['message']['content'])) {
        return trim($result['choices'][0]['message']['content']);
    } else {
        return ['error' => 'Invalid API Response', 'raw' => $result];
    } 
}

if ($action === 'generate_jd') {
    $title = $data['title'] ?? 'Software Engineer';
    $company = $data['company'] ?? 'Tech Company';
    
    $prompt = "Create a professional job description for a '$title' role at '$company'. Include Key Responsibilities and Required Qualifications. Keep it concise but professional.";
    
    $ai_response = callGroqAPI($prompt, $groq_api_key);
    
    if (is_array($ai_response) && isset($ai_response['error'])) {
        echo json_encode(['success' => false, 'error' => $ai_response['error']]);
    } else {
        echo json_encode(['success' => true, 'result' => $ai_response]);
    }

} elseif ($action === 'generate_questions') {
    $job_title = $data['job_title'] ?? 'General Role';
    
    $prompt = "Generate 5 key interview questions for a '$job_title' position. Return ONLY the questions as a numbered list.";
    
    $ai_response = callGroqAPI($prompt, $groq_api_key);
    
    if (is_array($ai_response) && isset($ai_response['error'])) {
        echo json_encode(['success' => false, 'error' => $ai_response['error']]);
    } else {
        // Parse the list into an array for better frontend display
        $questions = [];
        $lines = explode("\n", $ai_response);
        foreach ($lines as $line) {
            $line = trim($line);
            // Remove numbering like "1. " or "1) "
            $clean_line = preg_replace('/^\d+[\.\)]\s*/', '', $line);
            if (!empty($clean_line)) {
                $questions[] = $clean_line;
            }
        }
        
        echo json_encode(['success' => true, 'result' => $questions]);
    }
    
} else {
    echo json_encode(['error' => 'Invalid action']);
}
?>
