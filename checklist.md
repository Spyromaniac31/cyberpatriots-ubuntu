# Checklist
## 1. Forensic Questions 🔎
* Solve the three forensic questions. These may rely on files or programs you will eventually delete, which is why we do them first.
## 2. Configure Update Settings 📦
* Open System Settings and make sure the system checks for and installs updates as much as possible, and make sure the correct software sources are enabled.
## 3. Users 👥
* Add and remove users and change their permissions as dictated by the README. Don't modify passwords just yet.
## Run Script 📜
The script performs each of the following steps:
### 4. Enable Firewall 🛡️
* Turn on the firewall using `ufw enable`
* Certain critical services may require firewall rules
### 5. Disable Guest Login 🔓
* Add `allow-guest=false` to the end of `/etc/lightdm/lightdm.conf`
* This edits the configuration file for LightDM, the desktop manager.
* Note: The 2021 Round 1 Ubuntu image did not seem to use LightDM, so this step may not always be applicable.
### 6. Update Password Security 🔑
* Install cracklib, a PAM that allows for complexity enforcement using `sudo apt-get install libpam-cracklib`
* Open the PAM password file with `gedit /etc/pam.d/common-password`
  * Add `remember=5` and `minlen-8` to the end of the line with `pam_unix.so`
  * Add `ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1`  to the end of the line with `pam_cracklib.so`. These add requirements for **U**ppercase, **L**owercase, **D**igits, and **O**ther characters (symbols).
* Open the password policy file with `gedit /etc/login.defs`
  * Press `Ctrl` + `F` and find `PASS_MAX_DAYS`
  * Set maximum duration to 90 days with `PASS_MAX_DAYS 90`
  * Set minimum duration to 10 days with `PASS_MIN_DAYS 10`
  * Set warning time before expiration to 7 days with `PASS_WARN_AGE  7`
### 7. Set Login Policies 🔐
* Open the authentication policy file with `gedit /etc/pam.d/common-auth`
* Add `auth required pam_tally2.so deny=5 onerr=fail unlock_time=1800` to the end of the file
