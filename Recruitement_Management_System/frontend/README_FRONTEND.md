# Recruitment Management System - Frontend

A basic web-based frontend interface for the Recruitment Management System.

## 📁 Files Included

### HTML
- `index.html` - Main application file with all pages and modals

### CSS
- `styles.css` - Complete styling for the application

### JavaScript
- `script.js` - Frontend logic and sample data handling

### PHP (Backend)
- `db_config.php` - Database connection configuration
- `api_jobs.php` - REST API for job operations

## 🚀 Setup Instructions

### Prerequisites
1. Web server (Apache/Nginx) with PHP support
2. MySQL Database
3. Modern web browser

### Installation Steps

#### 1. Database Setup
```bash
# Run the SQL scripts in order:
1. 01_create_tables.sql
2. 02_constraints.sql
3. 03_insert_data.sql
4. 04_queries.sql (optional - for testing)
5. 05_views.sql
6. 06_procedures.sql
7. 07_triggers.sql
8. 08_transactions.sql (optional - for testing)
```

#### 2. PHP Configuration
Edit `db_config.php` and update database credentials:
```php
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', 'your_password');
define('DB_NAME', 'recruitment_management_system');
```

#### 3. Deploy Files
Copy all files to your web server directory:
- XAMPP: `C:/xampp/htdocs/rms/`
- WAMP: `C:/wamp64/www/rms/`
- Linux: `/var/www/html/rms/`

#### 4. Access Application
Open browser and navigate to:
```
http://localhost/rms/index.html
```

## 📱 Features

### Dashboard
- View statistics (Jobs, Candidates, Applications, Interviews)
- Recent jobs listing
- Recent applications overview

### Jobs Management
- View all job listings
- Add new jobs
- Filter by status
- Search functionality

### Candidates Management
- View all registered candidates
- Register new candidates
- Filter by experience
- Search candidates

### Applications Management
- View all job applications
- Submit new applications
- Update application status
- Filter by status

### Interviews
- View interview schedule
- Schedule new interviews
- Update interview results
- Filter by status

### Reports & Analytics
- Application status distribution
- Company-wise recruitment stats
- Interview success rate analysis

## 🔧 Current Implementation

### Data Handling
Currently using **sample/mock data** in JavaScript for demonstration.

To connect to actual database:
1. Uncomment PHP API files
2. Update `script.js` to make AJAX calls to PHP APIs
3. Remove mock data from `script.js`

### Example API Integration
```javascript
// Replace mock data loading with API calls
function loadJobs() {
    fetch('api_jobs.php')
        .then(response => response.json())
        .then(data => displayJobs(data))
        .catch(error => console.error('Error:', error));
}
```

## 📋 Features Overview

### ✅ Implemented
- Responsive design
- Multi-section navigation
- Modal forms for data entry
- Search and filter functionality
- Status badges and visual indicators
- Sample data for testing

### 🔄 To Enhance (Production Ready)
- Connect to actual database via PHP APIs
- User authentication and authorization
- File upload for resumes
- Email notifications
- Advanced analytics charts
- Export to PDF/Excel
- Role-based access control

## 🎨 UI Components

### Color Scheme
- Primary: Purple Gradient (#667eea to #764ba2)
- Success: Green (#27ae60)
- Danger: Red (#e74c3c)
- Info: Blue (#3498db)
- Background: Light Gray (#f5f7fa)

### Responsive Breakpoints
- Desktop: > 768px
- Mobile: < 768px

## 🗂️ Project Structure
```
rms/
│
├── index.html          # Main HTML file
├── styles.css          # Stylesheet
├── script.js           # JavaScript logic
│
├── db_config.php       # Database configuration
├── api_jobs.php        # Jobs API
│
└── README.md           # This file
```

## 🔐 Security Considerations

For production deployment:
1. Implement user authentication
2. Use prepared statements (already in db_config.php)
3. Validate all inputs server-side
4. Use HTTPS
5. Implement CSRF protection
6. Add rate limiting
7. Sanitize all outputs

## 📞 Support

For database queries, refer to the SQL files:
- View definitions: `05_views.sql`
- Stored procedures: `06_procedures.sql`
- Sample queries: `04_queries.sql`

## 📄 License

This is an educational project for DBMS lab/viva demonstration.

## 👨‍💻 Development Notes

### Adding New Features
1. Add HTML in appropriate section
2. Style in `styles.css`
3. Add logic in `script.js`
4. Create PHP API if needed
5. Test thoroughly

### Common Operations
- **Add Modal**: Copy existing modal structure
- **Add Table**: Use table-container class
- **Add Form**: Use form-group pattern
- **Add API Endpoint**: Follow api_jobs.php pattern

---

**Note**: This is a basic frontend implementation. For production use, implement proper backend APIs, authentication, and security measures.
