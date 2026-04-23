const API_BASE = 'http://localhost:5000/';

let jobs = [];
let candidates = [];
let applications = [];
let interviews = [];



document.addEventListener('DOMContentLoaded', function () {
    // Auth Protection
    if (!localStorage.getItem('user')) {
        window.location.href = 'login.html';
        return;
    }

    const dateOptions = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };
    document.getElementById('currentDate').textContent = new Date().toLocaleDateString('en-US', dateOptions);

    showSection('dashboard');
});

function logout() {
    localStorage.removeItem('user');
    window.location.href = 'login.html';
}

function showSection(sectionId) {
    document.querySelectorAll('.content-section').forEach(section => {
        section.classList.remove('active');
    });

    document.querySelectorAll('.nav-menu a').forEach(link => {
        link.classList.remove('active');
        if (link.getAttribute('onclick') === `showSection('${sectionId}')`) {
            link.classList.add('active');
        }
    });

    document.getElementById(sectionId).classList.add('active');

    switch (sectionId) {
        case 'dashboard':
            loadDashboard();
            break;
        case 'jobs':
            loadJobs();
            break;
        case 'candidates':
            loadCandidates();
            break;
        case 'applications':
            loadApplications();
            break;
        case 'interviews':
            loadInterviews();
            break;
    }
}

function openModal(modalId) {
    const modal = document.getElementById(modalId);
    modal.classList.add('show');

    if (modalId === 'addJobModal') {
        loadCompanyDropdown();
    } else if (modalId === 'addApplicationModal') {
        loadJobsDropdown();
        loadCandidatesDropdown();
    } else if (modalId === 'scheduleInterviewModal') {
        loadApplicationsDropdown();
    }
}

function closeModal(modalId) {
    document.getElementById(modalId).classList.remove('show');
}

window.onclick = function (event) {
    if (event.target.classList.contains('modal')) {
        event.target.classList.remove('show');
    }
}



async function loadDashboard() {
    try {
        await Promise.all([
            fetchJobs(),
            fetchCandidates(),
            fetchApplications(),
            fetchInterviews()
        ]);

        // Update Counters
        animateCounter('totalJobs', jobs.length);
        animateCounter('totalCandidates', candidates.length);
        animateCounter('totalApplications', applications.length);
        animateCounter('totalInterviews', interviews.length);

        loadRecentJobs();
        loadRecentApplications();
        renderChart();
    } catch (error) {
        console.error('Error loading dashboard:', error);
    }
}

function animateCounter(id, target) {
    let current = 0;
    const element = document.getElementById(id);
    const interval = setInterval(() => {
        if (current >= target) {
            clearInterval(interval);
            element.textContent = target;
        } else {
            current++;
            element.textContent = current;
        }
    }, 20);
}

function renderChart() {
    const ctx = document.getElementById('recruitmentChart').getContext('2d');


    const statusCounts = {};
    applications.forEach(app => {
        const s = app.application_status || 'Unknown';
        statusCounts[s] = (statusCounts[s] || 0) + 1;
    });

    if (window.myChart) {
        window.myChart.destroy();
    }

    const baseColors = {
        'Applied': '#2563eb',
        'Shortlisted': '#7c3aed',
        'Interview Scheduled': '#d97706',
        'Selected': '#059669',
        'Rejected': '#dc2626'
    };

    const labels = Object.keys(statusCounts);
    const data = Object.values(statusCounts);
    const bgColors = labels.map(label => baseColors[label] || '#94a3b8');

    window.myChart = new Chart(ctx, {
        type: 'doughnut',
        data: {
            labels: labels,
            datasets: [{
                data: data,
                backgroundColor: bgColors,
                borderWidth: 2,
                borderColor: '#ffffff'
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { position: 'right' }
            }
        }
    });
}



async function generateJD(event) {
    event.preventDefault();
    const title = document.getElementById('aiJobTitle').value;
    const company = document.getElementById('aiCompany').value;
    const resultDiv = document.getElementById('jdResult');

    resultDiv.style.display = 'block';
    resultDiv.innerHTML = '<p class="loading">Generating AI content...</p>';

    try {
        const response = await fetch(API_BASE + 'api_ai.php', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                action: 'generate_jd',
                title: title,
                company: company
            })
        });

        const data = await response.json();
        if (data.success) {
            resultDiv.textContent = data.result;
        } else {
            resultDiv.textContent = 'Error: ' + data.error;
        }
    } catch (error) {
        resultDiv.textContent = 'Error connecting to AI service.';
    }
}

async function generateQuestions(event) {
    event.preventDefault();
    const role = document.getElementById('aiQuestionRole').value;
    const resultDiv = document.getElementById('questionsResult');

    resultDiv.style.display = 'block';
    resultDiv.innerHTML = '<p class="loading">Generating questions...</p>';

    try {
        const response = await fetch(API_BASE + 'api_ai.php', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                action: 'generate_questions',
                job_title: role
            })
        });

        const data = await response.json();
        if (data.success) {
            const list = data.result.map(q => `<li>${q}</li>`).join('');
            resultDiv.innerHTML = `<ul>${list}</ul>`;
        } else {
            resultDiv.textContent = 'Error: ' + data.error;
        }
    } catch (error) {
        resultDiv.textContent = 'Error connecting to AI service.';
    }
}



async function fetchJobs() {
    if (jobs.length === 0) {
        jobs = [
            { job_id: 1, job_title: "Senior Product Manager", company_name: "Google", location: "Mountain View", vacancies: 2, job_status: "Open" },
            { job_id: 2, job_title: "Frontend Engineer", company_name: "Apple", location: "Cupertino", vacancies: 5, job_status: "Open" },
            { job_id: 3, job_title: "Data Scientist", company_name: "Netflix", location: "Remote", vacancies: 1, job_status: "Closed" },
            { job_id: 4, job_title: "DevOps Engineer", company_name: "Amazon", location: "Seattle", vacancies: 3, job_status: "Open" },
            { job_id: 5, job_title: "UI/UX Designer", company_name: "Microsoft", location: "Redmond", vacancies: 2, job_status: "On-Hold" }
        ];
    }
    return jobs;
}

async function fetchCandidates() {
    if (candidates.length === 0) {
        candidates = [
            { candidate_id: 1, first_name: "Alice", last_name: "Smith", email: "alice@example.com", total_experience: 5 },
            { candidate_id: 2, first_name: "Bob", last_name: "Johnson", email: "bob@example.com", total_experience: 3 },
            { candidate_id: 3, first_name: "Charlie", last_name: "Davis", email: "charlie@example.com", total_experience: 8 },
            { candidate_id: 4, first_name: "Diana", last_name: "Miller", email: "diana@example.com", total_experience: 1 },
            { candidate_id: 5, first_name: "Ethan", last_name: "Moore", email: "ethan@example.com", total_experience: 12 }
        ];
    }
    return candidates;
}

async function fetchApplications() {
    if (applications.length === 0) {
        applications = [
            { application_id: 1, first_name: "Alice", last_name: "Smith", job_title: "Senior Product Manager", application_status: "Applied" },
            { application_id: 2, first_name: "Bob", last_name: "Johnson", job_title: "Frontend Engineer", application_status: "Shortlisted" },
            { application_id: 3, first_name: "Charlie", last_name: "Davis", job_title: "Senior Product Manager", application_status: "Interview Scheduled" },
            { application_id: 4, first_name: "Diana", last_name: "Miller", job_title: "Data Scientist", application_status: "Rejected" },
            { application_id: 5, first_name: "Ethan", last_name: "Moore", job_title: "DevOps Engineer", application_status: "Selected" }
        ];
    }
    return applications;
}

async function fetchInterviews() {
    if (interviews.length === 0) {
        interviews = [
            { interview_id: 1, first_name: "Charlie", last_name: "Davis", job_title: "Senior Product Manager", interview_date: "2026-05-01", interview_time: "10:00 AM", interview_status: "Scheduled" },
            { interview_id: 2, first_name: "Ethan", last_name: "Moore", job_title: "DevOps Engineer", interview_date: "2026-04-10", interview_time: "02:00 PM", interview_status: "Completed" }
        ];
    }
    return interviews;
}



function loadRecentJobs() {
    const recentJobs = jobs.slice(0, 5);
    const html = `
        <table>
            <thead>
                <tr>
                    <th>Job Title</th>
                    <th>Company</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                ${recentJobs.map(job => `
                    <tr>
                        <td>${job.job_title}</td>
                        <td>${job.company_name}</td>
                        <td><span class="status-badge status-${job.job_status.toLowerCase()}">${job.job_status}</span></td>
                    </tr>
                `).join('')}
            </tbody>
        </table>
    `;
    document.getElementById('recentJobs').innerHTML = html;
}

function loadRecentApplications() {
    const recentApps = applications.slice(0, 5);
    const html = `
        <table>
            <thead>
                <tr>
                    <th>Candidate</th>
                    <th>Job</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                ${recentApps.map(app => `
                    <tr>
                        <td>${app.first_name} ${app.last_name}</td>
                        <td>${app.job_title}</td>
                        <td><span class="status-badge status-${app.application_status.toLowerCase().replace(' ', '-')}">${app.application_status}</span></td>
                    </tr>
                `).join('')}
            </tbody>
        </table>
    `;
    document.getElementById('recentApplications').innerHTML = html;
}

async function loadJobs() {
    await fetchJobs();
    displayJobs(jobs);
}

function displayJobs(jobsList) {
    if (jobsList.length === 0) {
        document.getElementById('jobsList').innerHTML = '<div class="empty-state"><p>No jobs found</p></div>';
        return;
    }
    const html = `
        <table>
            <thead>
                <tr>
                    <th>Job Title</th>
                    <th>Company</th>
                    <th>Location</th>
                    <th>Vacancies</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                ${jobsList.map(job => `
                    <tr>
                        <td><strong>${job.job_title}</strong></td>
                        <td>${job.company_name}</td>
                        <td>${job.location}</td>
                        <td>${job.vacancies}</td>
                        <td><span class="status-badge status-${job.job_status.toLowerCase()}">${job.job_status}</span></td>
                        <td><button class="btn btn-info" onclick="alert('View details clicked')">View</button></td>
                    </tr>
                `).join('')}
            </tbody>
        </table>
    `;
    document.getElementById('jobsList').innerHTML = html;
}

function filterJobs() {
    const searchTerm = document.getElementById('jobSearch').value.toLowerCase();
    const statusFilter = document.getElementById('jobStatusFilter').value;
    const filtered = jobs.filter(job => {
        return (job.job_title.toLowerCase().includes(searchTerm) || job.company_name.toLowerCase().includes(searchTerm)) &&
            (!statusFilter || job.job_status === statusFilter);
    });
    displayJobs(filtered);
}

async function loadCandidates() {
    await fetchCandidates();
    displayCandidates(candidates);
}

function displayCandidates(list) {
    if (list.length === 0) {
        document.getElementById('candidatesList').innerHTML = '<div class="empty-state"><p>No candidates found</p></div>';
        return;
    }
    const html = `
        <table>
            <thead>
                <tr>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Experience</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                ${list.map(c => `
                    <tr>
                        <td>${c.first_name} ${c.last_name}</td>
                        <td>${c.email}</td>
                        <td>${c.total_experience} yrs</td>
                        <td><button class="btn btn-info" onclick="alert('View candidate clicked')">View</button></td>
                    </tr>
                `).join('')}
            </tbody>
        </table>
    `;
    document.getElementById('candidatesList').innerHTML = html;
}

async function loadApplications() {
    await fetchApplications();
    displayApplications(applications);
}

function displayApplications(list) {
    if (list.length === 0) {
        document.getElementById('applicationsList').innerHTML = '<div class="empty-state"><p>No applications found</p></div>';
        return;
    }
    const html = `
        <table>
            <thead>
                <tr>
                    <th>Candidate</th>
                    <th>Job</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                ${list.map(app => `
                    <tr>
                        <td>${app.first_name} ${app.last_name}</td>
                        <td>${app.job_title}</td>
                        <td><span class="status-badge status-${app.application_status.toLowerCase().replace(' ', '-')}">${app.application_status}</span></td>
                        <td><button class="btn btn-success" onclick="updateApplicationStatus(${app.application_id})">Update</button></td>
                    </tr>
                `).join('')}
            </tbody>
        </table>
    `;
    document.getElementById('applicationsList').innerHTML = html;
}

async function loadInterviews() {
    await fetchInterviews();
    displayInterviews(interviews);
}

function displayInterviews(list) {
    if (list.length === 0) {
        document.getElementById('interviewsList').innerHTML = '<div class="empty-state"><p>No interviews found</p></div>';
        return;
    }
    const html = `
        <table>
            <thead>
                <tr>
                    <th>Candidate</th>
                    <th>Job</th>
                    <th>Date & Time</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                ${list.map(i => `
                    <tr>
                        <td>${i.first_name} ${i.last_name}</td>
                        <td>${i.job_title}</td>
                        <td>${i.interview_date} ${i.interview_time}</td>
                        <td><span class="status-badge status-${i.interview_status.toLowerCase()}">${i.interview_status}</span></td>
                        <td>${i.interview_status === 'Scheduled' ? `<button class="btn btn-success" onclick="updateInterviewResult(${i.interview_id})">Result</button>` : ''}</td>
                    </tr>
                `).join('')}
            </tbody>
        </table>
    `;
    document.getElementById('interviewsList').innerHTML = html;
}



async function addJob(event) {
    event.preventDefault();
    const data = Object.fromEntries(new FormData(event.target));
    data.job_id = jobs.length + 1;
    data.job_status = "Open";
    data.company_name = data.company_id == "1" ? "Google" : "TechCorp"; 
    jobs.unshift(data);
    closeModal('addJobModal');
    document.querySelector('#addJobModal form').reset();
    showSection('jobs');
    loadDashboard(); // Refresh dash numbers
    alert('Job added!');
}

async function addCandidate(event) {
    event.preventDefault();
    const data = Object.fromEntries(new FormData(event.target));
    data.candidate_id = candidates.length + 1;
    candidates.unshift(data);
    closeModal('addCandidateModal');
    document.querySelector('#addCandidateModal form').reset();
    showSection('candidates');
    loadDashboard();
    alert('Candidate registered!');
}

async function addApplication(event) {
    event.preventDefault();
    const data = Object.fromEntries(new FormData(event.target));
    data.application_id = applications.length + 1;
    data.application_status = "Applied";
    
    const c = candidates.find(c => c.candidate_id == data.candidate_id) || {};
    const j = jobs.find(j => j.job_id == data.job_id) || {};
    data.first_name = c.first_name || "Mock";
    data.last_name = c.last_name || "User";
    data.job_title = j.job_title || "Mock Job";

    applications.unshift(data);
    closeModal('addApplicationModal');
    document.querySelector('#addApplicationModal form').reset();
    showSection('applications');
    loadDashboard();
    alert('Application submitted!');
}

async function scheduleInterview(event) {
    event.preventDefault();
    const data = Object.fromEntries(new FormData(event.target));
    data.interview_id = interviews.length + 1;
    data.interview_status = "Scheduled";
    
    const a = applications.find(a => a.application_id == data.application_id) || {};
    data.first_name = a.first_name || "Mock";
    data.last_name = a.last_name || "User";
    data.job_title = a.job_title || "Mock Job";

    interviews.unshift(data);
    closeModal('scheduleInterviewModal');
    document.querySelector('#scheduleInterviewModal form').reset();
    showSection('interviews');
    loadDashboard();
    alert('Interview scheduled!');
}

async function postData(endpoint, data, successMsg, modalId, sectionId) {
    // Disabled for offline demo mode
    console.log("Mocking POST", endpoint, data);
}

async function updateApplicationStatus(id) {
    const newStatus = prompt('Status: Shortlisted, Interview Scheduled, Selected, Rejected');
    if (newStatus) {
        const app = applications.find(a => a.application_id == id);
        if (app) app.application_status = newStatus;
        loadApplications();
        loadDashboard();
    }
}

async function updateInterviewResult(id) {
    const result = prompt('Result: Pass, Fail, On-Hold');
    if (result) {
        const intv = interviews.find(i => i.interview_id == id);
        if (intv) {
            intv.result = result;
            intv.interview_status = 'Completed';
        }
        loadInterviews();
        loadDashboard();
    }
}



async function loadCompanyDropdown() {
    const companies = [
        {company_id: 1, company_name: 'Google'},
        {company_id: 2, company_name: 'TechCorp'},
        {company_id: 3, company_name: 'Apple'}
    ];
    populateSelect('#addJobForm select[name="company_id"]', companies, 'company_id', 'company_name');
}

async function loadJobsDropdown() {
    populateSelect('#addApplicationForm select[name="job_id"]', jobs, 'job_id', 'job_title');
}

async function loadCandidatesDropdown() {
    populateSelect('#addApplicationForm select[name="candidate_id"]', candidates, 'candidate_id', 'first_name', 'last_name');
}

async function loadApplicationsDropdown() {
    populateSelect('#scheduleInterviewForm select[name="application_id"]', applications, 'application_id', 'job_title', 'first_name');
}

function populateSelect(selector, items, valueKey, textKey1, textKey2 = '') {
    const select = document.querySelector(selector);
    let html = '<option value="">Select</option>';
    items.forEach(item => {
        const text = item[textKey1] + (textKey2 ? ' ' + item[textKey2] : '');
        html += `<option value="${item[valueKey]}">${text}</option>`;
    });
    select.innerHTML = html;
}
