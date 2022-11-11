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

# UPDATE THIS PASSWORD BEFORE RUNNING THE SCRIPT
echo -e "[ i ] Updating user passwords..."
while read line; do
  echo $line':Cyb3rP@triot' | chpasswd &> /dev/null
  chage -m 7 -M 90 -W 14 &> /dev/null
done < users.txt
overwrite "${YES} User passwords updated"

echo -e "[ i ] Disabling root account..."
passwd -l root
overwrite "${YES} Disabled root account"

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

echo -e "[ i ] Updating cache of available packages..."
apt-get update > /dev/null
overwrite "${YES} Updated cache of available packages"

echo -e "[ i ] Upgrading installed packages..."
apt-get -y upgrade > /dev/null
overwrite "${YES} Updated installed packages"

echo -e "[ i ] Updating APT periodic configuration..."
cp 10periodic /etc/apt/apt.conf.d/10periodic > /dev/null
overwrite "${YES} Updated APT periodic configuration"

echo -e "[ i ] Ensuring ufw is installed..."
apt install -y ufw > /dev/null
overwrite "${YES} Ensured ufw is installed"

echo -e "[ i ] Ensuring iptables-persistent is not installed with ufw"
apt purge -y iptables-persistent > /dev/null
overwrite "${YES} Ensured iptables-persistent is not installed with ufw"

echo -e "[ i ] Ensuring ufw service is enabled..."
systemctl unmask ufw.service > /dev/null
systemctl --now enable ufw.service > /dev/null
ufw enable > /dev/null
ufw logging full > /dev/null
echo -e "${YES} Enabled Uncomplicated Firewall (UFW)"

echo -e "[ i ] Ensuring ufw loopback traffic is configured..."
ufw allow in on lo > /dev/null
ufw allow out on lo > /dev/null
ufw deny in from 127.0.0.0/8 > /dev/null
ufw deny out from ::1 > /dev/null
overwrite "${YES} Ensured ufw loopback traffic is configured"

echo -e "[ i ] Ensuring ufw outbound connections are configured..."
ufw allow out on all > /dev/null
overwrite "${YES} Ensured ufw outbound connections are configured"

echo -e "[ i ] Configuring UFW rules..."
cp before.rules /etc/ufw/before.rules > /dev/null
ufw reload > /dev/null
overwrite "${YES} UFW rules configured"

echo -e "[ i ] Configuring SSH..."
cp sshd_config /etc/ssh/sshd_config > /dev/null
cp sshd /etc/pam.d/sshd > /dev/null
# Ensure correct permissions and owner on private keys
# Check if SSH keys present
if [[ -f "/etc/ssh/ssh_host_rsa_key" ]]; then
  chmod 600 /etc/ssh/ssh_host_rsa_key
  chown root:root /etc/ssh/ssh_host_rsa_key
fi
if [[ -f "/etc/ssh/ssh_host_dsa_key" ]]; then
  chmod 600 /etc/ssh/ssh_host_dsa_key
  chown root:root /etc/ssh/ssh_host_dsa_key
fi
if [[ -f "/etc/ssh/ssh_host_ecdsa_key" ]]; then
  chmod 600 /etc/ssh/ssh_host_ecdsa_key
  chown root:root /etc/ssh/ssh_host_ecdsa_key
fi
if [[ -f "/etc/ssh/ssh_host_ed25519_key" ]]; then
  chmod 600 /etc/ssh/ssh_host_ed25519_key
  chown root:root /etc/ssh/ssh_host_ed25519_key
fi
# Check if public SSH keys present
if [[ -f "/etc/ssh/ssh_host_rsa_key.pub" ]]; then
  chmod 644 /etc/ssh/ssh_host_rsa_key.pub
  chown root:root /etc/ssh/ssh_host_rsa_key.pub
fi
if [[ -f "/etc/ssh/ssh_host_dsa_key.pub" ]]; then
  chmod 644 /etc/ssh/ssh_host_dsa_key.pub
  chown root:root /etc/ssh/ssh_host_dsa_key.pub
fi
if [[ -f "/etc/ssh/ssh_host_ecdsa_key.pub" ]]; then
  chmod 644 /etc/ssh/ssh_host_ecdsa_key.pub
  chown root:root /etc/ssh/ssh_host_ecdsa_key.pub
fi
if [[ -f "/etc/ssh/ssh_host_ed25519_key.pub" ]]; then
  chmod 644 /etc/ssh/ssh_host_ed25519_key.pub
  chown root:root /etc/ssh/ssh_host_ed25519_key.pub
fi
service ssh restart &> /dev/null
overwrite "${YES} SSH configured"

echo -e "[ i ] Installing Cracklib..."
apt-get -y install libpam-cracklib > /dev/null
overwrite "${YES} Installed Cracklib"

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
echo "install dccp /bin/false" > /etc/modprobe.d/dccp.conf
overwrite "${YES} Disabled DCCP protocol"

echo -e "[ i ] Disabling SCTP protocol..."
echo "install sctp /bin/false" > /etc/modprobe.d/sctp.conf
overwrite "${YES} Disabled SCTP protocol"

echo -e "[ i ] Disabling RDS protocol..."
echo "install rds /bin/false" > /etc/modprobe.d/rds.conf
overwrite "${YES} Disabled RDS protocol"

echo -e "[ i ] Disabling TIPC protocol..."
echo "install tipc /bin/false" > /etc/modprobe.d/tipc.conf
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

echo -e "[ i ] Updating resolver configuration file..."
cp host.conf /etc/host.conf
overwrite "${YES} Updated resolver configuration file"

echo -e "[ i ] Securing shared memory..."
cp fstab /etc/fstab
mount -a
overwrite "${YES} Secured shared memory"

### CIS Benchmark ###

echo -e "[ i ] Ensuring Avahi Server is not installed..."
systemctl stop avahi-daemon.service &> /dev/null
systemctl stop avahi-daemon.socket &> /dev/null
apt purge -y avahi-daemon &> /dev/null
overwrite "${YES} Ensured Avahi Server is not installed"

echo -e "[ i ] Ensuring CUPS is not installed..."
apt purge -y cups &> /dev/null
overwrite "${YES} Ensured CUPS is not installed"

echo -e "[ i ] Ensuring DHCP Server is not installed..."
apt purge -y isc-dhcp-server &> /dev/null
overwrite "${YES} Ensured DHCP Server is not installed"

echo -e "[ i ] Ensuring LDAP Server is not installed..."
apt purge -y slapd &> /dev/null
overwrite "${YES} Ensured LDAP Server is not installed"

echo -e "[ i ] Ensuring NFS is not installed..."
apt purge -y nfs-kernel-server &> /dev/null
overwrite "${YES} Ensured NFS is not installed"

echo -e "[ i ] Ensuring DNS Server is not installed..."
apt purge -y bind9 &> /dev/null
overwrite "${YES} Ensured DNS Server is not installed"

echo -e "[ i ] Ensuring FTP Server is not installed..."
apt purge -y vsftpd &> /dev/null
overwrite "${YES} Ensured FTP Server is not installed"

echo -e "[ i ] Ensuring HTTP Server is not installed..."
apt purge -y apache2 &> /dev/null
overwrite "${YES} Ensured HTTP Server is not installed"

echo -e "[ i ] Ensuring IMAP and POP3 Server are not installed..."
apt purge -y dovecot-imapd &> /dev/null
apt purge -y dovecot-pop3d &> /dev/null
overwrite "${YES} Ensured IMAP and POP3 Server are not installed"

echo -e "[ i ] Ensuring Samba is not installed..."
apt purge -y samba &> /dev/null
overwrite "${YES} Ensured Samba is not installed"

echo -e "[ i ] Ensuring HTTP Proxy Server is not installed..."
apt purge -y squid &> /dev/null
overwrite "${YES} Ensured HTTP Proxy Server is not installed"

echo -e "[ i ] Ensuring SNMP Server is not installed..."
apt purge -y snmpd &> /dev/null
overwrite "${YES} Ensured SNMP Server is not installed"

echo -e "[ i ] Ensuring NIS Server is not installed..."
apt purge -y nis &> /dev/null
overwrite "${YES} Ensured NIS Server is not installed"

echo -e "[ i ] Ensuring rsync service is not installed"
apt purge -y rsync &> /dev/null
overwrite "${YES} Ensured rsync service is not installed"

echo -e "[ i ] Ensuring NIS Client is not installed..."
apt purge -y nis &> /dev/null
overwrite "${YES} Ensured NIS Client is not installed"

echo -e "[ i ] Ensuring rsh client is not installed..."
apt purge -y rsh-client &> /dev/null
apt purge -y rsh-redone-client &> /dev/null
overwrite "${YES} Ensured rsh client is not installed"

echo -e "[ i ] Ensuring talk client is not installed..."
apt purge -y talk &> /dev/null
apt purge -y ntalk &> /dev/null
overwrite "${YES} Ensured talk client is not installed"

echo -e "[ i ] Ensuring telnet client is not installed..."
apt purge -y telnet &> /dev/null
overwrite "${YES} Ensured telnet client is not installed"

echo -e "[ i ] Ensuring LDAP client is not installed..."
apt purge -y ldap-utils &> /dev/null
overwrite "${YES} Ensured LDAP client is not installed"

echo -e "[ i ] Ensuring RPC is not installed..."
apt purge -y rpcbind &> /dev/null
overwrite "${YES} Ensured RPC is not installed"

