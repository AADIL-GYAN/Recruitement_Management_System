<?php
// Database Setup Script
// This script will:
// 1. Create the database
// 2. Create tables
// 3. Insert sample data

// Configuration
$host = 'localhost';
$user = 'root';
$pass = ''; // Default XAMPP password is empty

// Connect to MySQL
$conn = new mysqli($host, $user, $pass);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

echo "<h1>Setting up Recruitment Management System...</h1>";

// Function to execute SQL commands from a file
function executeSqlFile($conn, $filePath) {
    if (!file_exists($filePath)) {
        echo "<p style='color:red;'>Error: File not found - $filePath</p>";
        return;
    }

    echo "<p>Executing $filePath...</p>";
    
    $sql = file_get_contents($filePath);
    
    // Split by semicolon, but be careful with delimiters if stored procedures change it
    // For simple scripts, splitting by ; is usually enough, but comments can be tricky.
    // Let's use a simpler approach: multiple queries if supported or simplistic split.
    
    if ($conn->multi_query($sql)) {
        do {
            // store first result set
            if ($result = $conn->store_result()) {
                $result->free();
            }
            // print divider
            if ($conn->more_results()) {
                // printf("-----------------\n");
            }
        } while ($conn->next_result());
        echo "<p style='color:green;'>Success!</p>";
    } else {
        echo "<p style='color:red;'>Error executing SQL: " . $conn->error . "</p>";
    }
}

// Order matters!
// 1. Create Tables (includes DB creation)
executeSqlFile($conn, '../sql/01_create_tables.sql');

// 2. Constraints
executeSqlFile($conn, '../sql/02_constraints.sql');

// 3. Insert Data
executeSqlFile($conn, '../sql/03_insert_data.sql');

// 4. Views
executeSqlFile($conn, '../sql/05_views.sql');

// 5. Procedures
executeSqlFile($conn, '../sql/06_procedures.sql');

// 6. Triggers
executeSqlFile($conn, '../sql/07_triggers.sql');

$conn->close();

echo "<h2>Setup Complete!</h2>";
echo "<p><a href='index.html'>Go to Home Page</a></p>";
?>
