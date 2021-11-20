# Checklist
## 1. Forensic Questions 🔎
* Solve the three forensic questions. These may rely on files or programs you will eventually delete, which is why we do them first.
## 2. Configure Update Settings 📦
* Open System Settings and make sure the system checks for and installs updates as much as possible, and make sure the correct software sources are enabled.
## 3. Run Script 📜
## 4. Update Passwords 🔑
* Update users' passwords to meet the new requirements
## 5. Manage Services ⚙️
* List enabled services with `service --status-all`
## 6. Check Ports 🚤
* List processes listening on ports with `sudo netstat -tulpn`
## 7. Check for Rootkits 🔒
* Run Rookit Hunter with `rkhunter -c`
