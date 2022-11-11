# Checklist

## 1. Forensic Questions 🔎

* Solve the three forensic questions. These may rely on files or programs you will eventually delete, which is why we do them first.

## 2. Configure Update Settings 📦

* Open System Settings and make sure the system checks for and installs updates as much as possible, and make sure the correct software sources are enabled.
* `sudo nano /etc/apt/sources.list` and make sure nothing besides the official Ubuntu repositories are enabled.
* `nano` is a built-in command-line text editor. Learn more [here](https://help.ubuntu.com/community/Nano)

## 3. Run Script 📜

* Before you do this, make sure you set the script to executable. You can do this by running `chmod +x script.sh` in the terminal.
* Make sure you modify the script to use the primary user's password instead of the default password `Cyb3rP@triot`, as changing the primary user's password will not be necessary and can introduce login errors.
* Once the script is ready, run it with `./script.sh`. This will take a while, so be patient.

## 4. Manage Services ⚙️

* List enabled services with `service --status-all`
* Common unwanted services are disabled by the script, but there may be other rogue services to remove
* If SSH is required, use `sudo nano /etc/ssh/sshd_config` to examine and configure SSH access

## 5. Check Ports 🚤

* Run `sudo lsof -i -P -n | grep -v "(ESTABLISHED)"` to list all services listening on ports
* Run `sudo apt purge <package_name>` to remove any unwanted services
* If you can't remove the package for dependency reasons, you can stop and mask the service with `sudo systemctl --now mask <service_name>`

## 6. Check for Rootkits 🔒

* Run Rookit Hunter with `sudo rkhunter -c`
* The following may result in positives, but are safe to leave:
* `/usr/bin/unhide.rb`
* `passwd` file changes
* Group file changes
* `/dev/.udev/rules.d/root.rules`
* `/dev/.udev`
* `/etc/.java`
* `/dev/.initramfs`
* Rootkit Hunter will detail its findings in `/var/log/rkhunter.log`
* If Rootkit Hunter finds anything aside from `unhide.rb`, agree to let it clean the system
* Set Rootkit Hunter to run periodically by opening `/etc/default/rkhunter` and changing `CRON_DAILY_RUN` and `CRON_DB_UPDATE` to true

## 7. Run Lynis 📝

* Lynis gives an incredibly comprehensive system audit report
* You won't be able to do this on APS Wi-Fi because it blocks cisofy.com for some reason
* `wget -q -O - https://packages.cisofy.com/keys/cisofy-software-public.key | sudo apt-key add -`
* `echo "deb https://packages.cisofy.com/community/lynis/deb/ stable main" | sudo tee /etc/apt/sources.list.d/cisofy-lynis.list`
* `sudo apt install apt-transport-https`
* `sudo apt update`
* `sudo apt install lynis`
* Run `sudo lynis audit system` to begin the report

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
* The dpkg log can be very useful to find programs installed around the same time as known malware

## 10. Remove User Files

* Look in userfiles.txt for the files you want to remove.

## 11. Check Running Processes 💿

* `ps aef` lists all processes. You might want to scan these to see if anything weird is listed
* `ps aux | grep netcat` returns all running processes with `netcat` in the name. Netcat is a networking utility that we don't want on the machine.
* Note: If Netcat isn't running, the above command will still return one entry for `grep --color=auto netcat` (the process you invoke by running the command)
* htop is a useful tool for monitoring processes. Learn more [here](https://www.tecmint.com/htop-cpu-monitoring-tool-in-linux/)
* Learn more about `ps` [here](https://www.computernetworkingnotes.com/linux-tutorials/ps-aux-command-and-ps-command-explained.html)

## 12. Configure Firefox 🦊

* Go through Firefox settings and make everything as secure as possible. Make sure Firefox is updated before you do this, as settings may change between versions.

## 13. Check for Startup Programs 🚀

* Use `sudo nano <file name>` to check the contents of the following files:
* /etc/rc.local
* /etc/crontab
* ~/.config/autostart
* /etc/xdg/autostart
* /etc/rc0.d
* /etc/rc1.d
* /etc/rc2.d
* /etc/rc3.d
* /etc/rc4.d
* /etc/rc5.d
* /etc/rc6.d
* /etc/rcS.d
* /etc/cron.d
* /etc/cron.daily
* /etc/cron.hourly
* /etc/cron.monthly
* /etc/cron.weekly
* /etc/init.d

## 14. Ensure postfix is configured for local use only 📬

* Postfix should be removed, but I think Lynis installs it by default, so if you're able to install Lynis, you'll need to configure postfix to only send mail locally.
* `sudo nano /etc/postfix/main.cf`
* Add or modify the following line in the `RECEIVING MAIL` section:
* `inet_interfaces = loopback-only`
* Restart postfix with `sudo systemctl restart postfix`
