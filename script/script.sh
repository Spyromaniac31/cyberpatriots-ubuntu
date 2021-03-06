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
    userdel -r $user &> /dev/null
  fi
done < /etc/passwd
overwrite "${YES} Unauthorized users removed"

echo -e "[ i ] Updating user passwords..."
while read line; do
  chpasswd $line:Cyb3rP@triot &> /dev/null
done < users.txt
overwrite "${YES} User passwords updated"

echo -e "[ i ] Configuring admin privileges"
while read -r user pass uid gid desc home shell; do
  if (($uid >= 1000)); then
    if grep -q $user "admins.txt"; then
      usermod -aG sudo $user > /dev/null
    else
      gpasswd -d $user sudo &> /dev/null
    fi
  fi
done < /etc/passwd
overwrite "${YES} Admin priviliges configured"

echo -e "[ i ] Restricting home directory access..."
while read -r user pass uid gid desc home shell; do
  if (($uid >= 1000)); then
    chmod 750 $home
  fi
done < /etc/passwd
overwrite "${YES} Home directory access restricted"

ufw enable > /dev/null
ufw logging full > /dev/null
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
DEBIAN_FRONTEND=noninteractive apt-get install -y postfix > /dev/null
systemctl stop postfix
rm -f /etc/postfix/main.cf > /dev/null
apt-get -y install rkhunter > /dev/null
overwrite "${YES} Installed Rootkit Hunter"

echo -e "[ i ] Installing AuditD..."
apt-get -y install auditd > /dev/null
overwrite "${YES} Installed AuditD"

echo -e "[ i ] Adding AuditD rules..."
cp audit.rules /etc/audit/audit.rules > /dev/null
overwrite "${YES} Added AuditD rules"

echo -e "[ i ] Installing SysStat..."
apt-get -y install sysstat > /dev/null
overwrite "${YES} Installed SysStat"

echo -e "[ i ] Enabling SysStat..."
echo "ENABLED=true" > /etc/default/sysstat
systemctl enable sysstat &> /dev/null
systemctl start sysstat > /dev/null
overwrite "${YES} Enabled SysStat"

echo -e "[ i ] Installing acct..."
apt-get -y install acct > /dev/null
overwrite "${YES} Installed acct"

echo -e "[ i ] Enabling acct..."
/etc/init.d/acct start > /dev/null
overwrite "${YES} Enabled acct"

echo -e "[ i ] Installing DebSums..."
apt-get -y install debsums > /dev/null
overwrite "${YES} Installed DebSums"

echo -e "[ i ] Installing apt-show-versions..."
apt-get -y install apt-show-versions > /dev/null
overwrite "${YES} Installed apt-show-versions"

echo -e "[ i ] Adding legal banners..."
echo "WARNING: UNAUTHORIZED ACCESS IS FORBIDDEN. PENAL LAWS WILL BE ENFORCED BY OWNER." > /etc/issue.net
echo "WARNING: UNAUTHORIZED ACCESS IS FORBIDDEN. PENAL LAWS WILL BE ENFORCED BY OWNER." > /etc/issue
overwrite "${YES} Added legal banners"

echo -e "[ i ] Disabling DCCP protocol..."
echo "install dccp /bin/true" > /etc/modprobe.d/dccp.conf
overwrite "${YES} Disabled DCCP protocol"

echo -e "[ i ] Disabling SCTP protocol..."
echo "install sctp /bin/true" > /etc/modprobe.d/sctp.conf
overwrite "${YES} Disabled SCTP protocol"

echo -e "[ i ] Disabling RDS protocol..."
echo "install rds /bin/true" > /etc/modprobe.d/rds.conf
overwrite "${YES} Disabled RDS protocol"

echo -e "[ i ] Disabling TIPC protocol..."
echo "install tipc /bin/true" > /etc/modprobe.d/tipc.conf
overwrite "${YES} Disabled TIPC protocol"

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
while read line; do
  apt-get -y purge $line &> /dev/null
done < software.txt
overwrite "${YES} Removed unneeded software"

echo -e "[ i ] Disabling unneeded services..."
while read line; do 
  systemctl stop $line &> /dev/null
  systemctl disable $line &> /dev/null
done < services.txt
overwrite "${YES} Disabled unneeded services"

echo -e "[ i ] Restricting compiler access..."
chmod o-rx /usr/bin/x86_64-linux-gnu-as > /dev/null
overwrite "${YES} Restricted compiler access"

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

echo -e "[ i ] Setting Cron file permissions..."
chmod 600 /etc/crontab
chmod 700 /etc/cron.d
chmod 700 /etc/cron.daily
chmod 700 /etc/cron.hourly
chmod 700 /etc/cron.monthly
chmod 700 /etc/cron.weekly
overwrite "${YES} Set Cron file permissions"

echo -e "[ i ] Setting CUPS file permissions..."
chmod 600 /etc/cups/cupsd.conf
overwrite "${YES} Set CUPS file permissions"

echo -e "[ i ] Disabling core dumps..."
cp limits.conf /etc/security/limits.conf
overwrite "${YES} Disabled core dumps"

echo -e "[ i ] Updating sysctl.conf..."
cp sysctl.conf /etc/sysctl.conf > /dev/null
sysctl -p > /dev/null
overwrite "${YES} Updated sysctl.conf"

echo -e "[ i ] Purging old packages..."
apt-get -y autoremove > /dev/null
overwrite "${YES} Purged old packages"