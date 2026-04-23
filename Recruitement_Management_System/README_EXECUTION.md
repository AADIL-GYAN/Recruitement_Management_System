# recruitment Management System - Execution Guide (Updated)

## Project Structure
- **frontend/**: HTML, CSS, JavaScript files.
- **backend/**: PHP scripts for API endpoints and database configuration.
- **sql/**: Database schema and initial data.

## Steps to Run the Project for Presentation

### 1. Start XAMPP
1. Open **XAMPP Control Panel**.
2. Click **Start** for **Apache** and **MySQL**.

### 2. Deploy the Project
1. Locate your XAMPP installation folder (usually `C:\xampp`).
2. Open the `htdocs` folder within it (`C:\xampp\htdocs`).
3. Copy the entire `Recruitement_Management_System` folder into `htdocs`.
   - Path should be: `C:\xampp\htdocs\Recruitement_Management_System`.

### 3. Initialize the Database
1. Open your web browser.
2. Go to: `http://localhost/Recruitement_Management_System/backend/setup_database.php`
3. You should see a success message.

### 4. Run the Application
1. Go to: `http://localhost/Recruitement_Management_System/frontend/login.html`
2. **Login**: use any email (e.g., `admin@techcorp.com`) and any password (e.g., `123456`).
   - The system uses a simulated login for demo purposes.

### 5. Demo Flow (Key Features to Show)
1. **Authentication**: Show the new Login page with glassmorphism design.
2. **Smart Dashboard**:
   - **Live Counters**: Show animated numbers.
   - **Analytics Chart**: Show the donut chart (powered by Chart.js) visualizing application status.
3. **AI Tools (New!)**:
   - Go to the **AI Tools** tab.
   - **Generate Job Description**: Enter "Product Manager" and "Google", click Generate. Show the instant result.
   - **Interview Questions**: Enter a role "Python Developer", click Get Questions.
4. **Core Workflow**:
   - Add a Job, Register a Candidate, Schedule an Interview.
   - Show how the Dashboard counters update instantly.

## Troubleshooting
- If fetching fails, check if the URL is correct: `http://localhost/Recruitement_Management_System/frontend/login.html`.
- Ensure Apache matches the file path.
