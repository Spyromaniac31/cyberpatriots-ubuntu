#!/bin/bash

if [ $EUID -ne 0 ]; then
  echo 'Script must be run as root.'
  exit 1
fi

echo 'Enabling firewall...'
ufw enable

echo 'Disabling guest account...'
echo 'allow-guest=false' >> /etc/lightdm/lightdm.conf
echo 'Guest account disabled.'

echo 'Updating available packages...'
(apt-get update)
echo 'Update complete.'

echo 'Installing software...'
apt-get --assume-yes install libpam-cracklib lynis rkhunter auditd php systemctl
echo 'Software installed.'

echo 'Updating password age requirements...'
sed -i 's/PASS_MAX_DAYS	99999/PASS_MAX_DAYS	90/' /etc/login.defs
sed -i 's/PASS_MIN_DAYS	0/PASS_MIN_DAYS	10/' /etc/login.defs
echo 'Requirements updated.'

echo 'Updating PAM settings...'
sed -i 's/pam_cracklib.so/pam_cracklib.so ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1 /' /etc/pam.d/common-password
sed -i 's/pam_unix.so/pam_unix.so remember=5 minlen=8 /' /etc/pam.d/common-password
echo 'auth required pam_tally2.so deny=5 onerr=fail unlock_time=1800' >> /etc/pam.d/common-auth
echo 'PAM settings updated.'

echo 'Securing file permissions...'
chown root:root /etc/passwd
chmod 644 /etc/passwd

chown root:shadow /etc/shadow
chmod o-rwx,g-wx /etc/shadow

chown root:root /etc/group
chmod 644 /etc/group

chown root:root /etc/grub.conf > /dev/null
chmod o-rwx,g-rw /etc/grub.conf > /dev/null

chown -R root:root /etc/pam.d
chmod -R o-rwx,g-rw /etc/pam.d

chown root:shadow /etc/gshadow
chmod o-rwx,g-rw /etc/gshadow

chown root:root /etc/passwd-
chmod u-x,go-wx /etc/passwd-

chown root:shadow /etc/shadow-
chmod o-rwx,g-rw /etc/shadow-

chown root:root /etc/group-
chmod u-x,go-wx /etc/group-

chown root:shadow /etc/gshadow-
chmod o-rwx,g-rw /etc/gshadow-

chown root:shadow /etc/cron.d
chmod o-rwx,g-rw /etc/cron.d

chown root:shadow /etc/cron.daily
chmod o-rwx,g-rw /etc/cron.daily

chown root:shadow /etc/cron.hourly
chmod o-rwx,g-rw /etc/cron.hourly

chown root:shadow /etc/cron.monthly
chmod o-rwx,g-rw /etc/cron.monthly

chown root:shadow /etc/cron.weekly
chmod o-rwx,g-rw /etc/cron.weekly

chmod 600 /etc/securetty
chmod 644 /etc/crontab
chmod 640 /etc/ftpusers
chmod 440 /etc/inetd.conf > /dev/null
chmod 440 /etc/xinetd.conf > /dev/null
chmod 400 /etc/inetd.d > /dev/null
chmod 644 /etc/hosts.allow
chmod 440 /etc/sudoers

echo 'Permissions secured.'

echo 'Disabling unneeded services...'
systemctl disable cups.service cups ssh xinetd avahi-daemon isc-dhcp-server6 slapd nfs-server rcpbind bind9 vsftd dovecot smbd squid snmpd rsync rsh nis samba snmp talk ntalk ftp > /dev/null
echo 'Services disabled. Make sure to re-enable any specified in the README.'

echo 'Removing unneeded software and games...'
apt-get --assume-yes remove openbsd-inetd xserver-xorg* nis talk telnet ldap-utils rsh-client rsh-redone-client wesnoth > /dev/null
apt-get purge -y nmap > /dev/null
apt-get remove -y pure-ftpd
apt-get purge -y jack > /dev/null
apt-get purge -y icecast2 > /dev/null
rm -r /usr/games* > /dev/null
rm -r /usr/local/games* /dev/null
echo 'Software and games removed.'

echo 'Finding media files...'
find . -type f -name "*.mp3"
find . -type f -name "*.wav"
find . -type f -name "*.mp4"
find . -type f -name "*.ogg || .OGG"
find . -type f -name "*.flac"
find . -type f -name "*.aac"
find . -type f -name "*.jpeg"
find . -type f -name "*.gif"
find . -type f -name "*.png"
find . -type f -name "*.dts"
find . -type f -name "*.bmp"
find . -type f -name "*.aiff"
find . -type f -name "*.dsd"
find . -type f -name "*.lpcm"
find . -type f -name "*.mkv"
find . -type f -name "*.jpg"
echo 'Media search done.'

echo 'Script complete.'
