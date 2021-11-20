#!/bin/bash

YES="[\033[0;32m ✓ \033[0m]"
NO="[\033[0;31m ✗ \033[0m]"

overwrite() { echo -e "\r\033[1A\033[0K$@"; }

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
    if grep -q $user "admins.txt"; then
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
wget -q -O - https://packages.cisofy.com/keys/cisofy-software-public.key | sudo apt-key add - &> /dev/null
echo "deb https://packages.cisofy.com/community/lynis/deb/ stable main" | sudo tee /etc/apt/sources.list.d/cisofy-lynis.list > /dev/null
apt-get -y install apt-transport-https > /dev/null
apt-get update > /dev/null
apt-get -y install lynis > /dev/null
overwrite "${YES} Installed Lynis"

echo -e "[ i ] Installing Rootkit Hunter..."
apt-get -y install rkhunter > /dev/null
overwrite "${YES} Installed Rootkit Hunter"

echo -e "[ i ] Installing AuditD..."
apt-get -y install auditd > /dev/null
overwrite "${YES} Installed AuditD"

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

echo -e "[ i ] Listing files in user directories..."
find /home ~+ -type f -name "*" > userfiles.txt
overwrite "${YES} Listed files in user directories in userfiles.txt"

echo -e "[ i ] Removing games from /usr/..."
rm -rf /usr/games > /dev/null
rm -rf /usr/local/games > /dev/null
overwrite "${YES} Removed games from /usr/"

echo -e "[ i ] Removing unneeded software..."
apt-get -y purge nmap > /dev/null
killall -9 netcat &> /dev/null
apt-get -y purge netcat > /dev/null
apt-get -y purge telnetd > /dev/null
apt-get -y purge telnet > /dev/null
apt-get -y purge pure-ftpd > /dev/null
apt-get -y purge wireshark > /dev/null
apt-get -y purge xinetd > /dev/null
apt-get -y purge openssh-server > /dev/null
apt-get -y purge rsync > /dev/null
overwrite "${YES} Removed unneeded software"

echo -e "[ i ] Setting shadow file permissions..."
chown root:shadow /etc/shadow
chmod 640 /etc/shadow
overwrite "${YES} Set shadow file permissions"

echo -e "[ i ] Setting account file permissions..."
chown root:root /etc/passwd
chmod 644 /etc/passwd
overwrite "${YES} Set account file permissions"

echo -e "[ i ] Setting group file permissions..."
chown root:root /etc/group
chmod 644 /etc/group
overwrite "${YES} Set group file permissions"

echo -e "[ i ] Setting PAM file permissions..."
chown root:root /etc/pam.d
chmod 644 /etc/pam.d
overwrite "${YES} Set PAM file permissions"

echo -e "[ i ] Setting group password file permissions..."
chown root:shadow /etc/gshadow
chmod 640 /etc/gshadow
overwrite "${YES} Set group password file permissions"

echo -e "[ i ] Enabling address space randomization..."
echo 2 > /proc/sys/kernel/randomize_va_space
overwrite "${YES} Enabled address space randomization"

echo -e "[ i ] Disabling core dumps..."
echo "* hard core 0" >> /etc/security/limits.conf
echo "* soft core 0" >> /etc/security/limits.conf
echo "fs.suid_dumpable=0" >> /etc/sysctl.conf
echo "kernel.core_pattern=|/bin/false" >> /etc/sysctl.conf
sysctl -p > /dev/null
overwrite "${YES} Disabled core dumps"

echo -e "[ i ] Updating sysctl.conf..."
cp sysctl.conf /etc/sysctl.conf
sysctl -p > /dev/null
overwrite "${YES} Updated sysctl.conf"