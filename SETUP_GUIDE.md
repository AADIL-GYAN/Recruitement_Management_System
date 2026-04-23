# CRITICAL: Project Setup Incomplete

The "Connection Refused" error means your XAMPP server is **turned OFF**.

## 1. Start XAMPP Server
1. Open **XAMPP Control Panel** on your computer.
2. Find **Apache** and click **Start**.
3. Find **MySQL** and click **Start**.
4. Wait until the numbers under **PID(s)** and **Port(s)** (usually 80, 443, 3306) turn **green**.

## 2. Move Project Files (REQUIRED)
XAMPP cannot see files in your "Downloads" folder. You must move them.

1. **Copy** the entire folder: `Recruitement_Management_System`
   *(It is currently in your Downloads folder)*
2. **Go to**: `C:\xampp\htdocs\`
3. **Paste** the folder there.
   *(You should end up with: `C:\xampp\htdocs\Recruitement_Management_System`)*

## 3. Try Again
Once the server is **GREEN** and the files are **MOVED**:

👉 **[Click Here to Open Login Page](http://localhost/Recruitement_Management_System/frontend/login.html)**

### Still getting errors?
- **"404 Not Found"**: You pasted the folder in the wrong place or the folder name doesn't match the URL exactly.
- **"Connection Refused"**: XAMPP Apache is NOT running. Check if Skype or VM is blocking port 80.
