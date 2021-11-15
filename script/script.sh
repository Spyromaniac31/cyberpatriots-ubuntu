#!/bin/bash

YES="[\033[0;32m ✓ \033[0m]"
NO="[\033[0;31m ✗ \033[0m]"

overwrite() { echo -e "\r\033[1A\033{OK$@"; }

if [ $EUID -ne 0 ]; then
  echo -e "${NO} Script called with non-root privileges"
  exit 1
fi
echo -e "${YES} Root user check"

if [[ -f "users.txt" ]]; then
  echo -e "${YES} Users file found"
else
  echo -e "${NO} Users file not found"
  exit 1
fi

if [[ -f "admins.txt" ]]; then
  echo -e "${YES} Admins file found"
else
  echo -e "${NO} Admins file not found"
  exit 1
fi

echo -e "[ i ] Adding specified users..."
while read line; do 
  useradd -m $line &> /dev/null
done < users.txt
overwrite "${YES} All users added"

echo -e "[ i ] Removing unauthorized users..."
IFS=':'
while read -r user pass uid gid desc home shell; do
  if (($uid >= 1000)) && !(grep -q $user "users.txt"); then
    userdel -r $user
  fi
done < /etc/passwd
overwrite "${YES} Unauthorized users removed"

echo -e "[ i ] Configuring admin privileges"
while read -r user pass uid gid desc home shell; do
  if (($uid >= 1000)); then
    if grep -q $user "admin.txt"; then
      usermod -aG sudo $user
    else
      gpasswd -d $user sudo
    fi
  fi
done < /etc/passwd
overwrite "${YES} Admin priviliges configured"

ufw enable > /dev/null
echo -e "${YES} Enabled Uncomplicated Firewall (UFW)"

echo -e "[ i ] Updating cache of available packages..."
apt-get update > /dev/null
overwrite "${YES} Updated cache of available packages"

echo -e "[ i ] Upgrading installed packages..."
apt-get -y upgrade > /dev/null
overwrite "${YES} Updated installed packages"

echo -e "[ i ] Installing Cracklib..."
apt-get -y install libpam-cracklib > /dev/null
overwrite "${YES} Installed Cracklib"

echo -e "[ i ] Installing Lynis..."
apt-get -y install lynis > /dev/null
overwrite "${YES} Installed Lynis"

echo -e "[ i ] Installing Rootkit Hunter..."
apt-get -y install rkhunter > /dev/null
overwrite "${YES} Installed Rootkit Hunter"

echo -e "[ i ] Installing AuditD..."
apt-get -y install auditd > /dev/null
overwrite "${YES} Installed AuditD"

echo -e "[ i ] Installing PHP..."
apt-get -y install php > /dev/null
overwrite "${YES} Installed PHP"

echo -e "[ i ] Updating shadow password configuration file..."
cp login.defs /etc/login.defs
overwrite "${YES} Updated shadow password configuration file"

echo -e "[ i ] Updating PAM authentication file..."
cp common-auth /etc/pam.d/common-auth
overwrite "${YES} Updated PAM authentication file"

echo -e "[ i ] Updating PAM password file..."
cp common-password /etc/pam.d/common-password
overwrite "${YES} Updated PAM password file"

echo -e "[ i ] Removing GNOME games..."
apt-get -y purge gnome-games > /dev/null
overwrite "${YES} Removed GNOME games"

echo -e "[ i ] Files in user directories:"
find /home ~+ -type f -name "*"

echo -e "[ i ] Enabling address space randomization"
echo 2 > /proc/sys/kernel/randomize_va_space
overwrite "${YES} Enabled address space randomization"
