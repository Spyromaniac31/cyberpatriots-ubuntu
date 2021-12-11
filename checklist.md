# Checklist
## 1. Forensic Questions 🔎
* Solve the three forensic questions. These may rely on files or programs you will eventually delete, which is why we do them first.
## 2. Configure Update Settings 📦
* Open System Settings and make sure the system checks for and installs updates as much as possible, and make sure the correct software sources are enabled.
## 3. Run Script 📜
## 4. Manage Services ⚙️
* List enabled services with `service --status-all`
## 5. Check Ports 🚤
* List processes listening on ports with `sudo netstat -tulpn`
## 6. Check for Rootkits 🔒
* Run Rookit Hunter with `sudo rkhunter -c`
## 7. Run Lynis 📝
* Lynis gives an incredibly comprehensive system audit report
* Run `sudo lynis audit system`
## 8. Check Password Files 🔑
* The script sets up the users as dictated by the files, but there may be hidden users or undesirable groups.
* `sudo gedit /etc/passwd`
* `sudo gedit /etc/shadow`
* `sudo gedit /etc/sudoers.d`
## 9. Check Log Files 📄
* Log files can allow you to find potential security issues caused by malicious activity.
* /var/log/messages
* /var/log/boot
* /var/log/debug
* /var/log/auth.log
* /var/log/daemon.log
* /var/log/kern.log
* /var/log/dpkg.log
## 10. Remove user files 
* Look in userfiles.txt for the files you want to remove.