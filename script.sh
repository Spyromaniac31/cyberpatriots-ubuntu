#!/bin/bash

if [ $EUID -ne 0 ]; then
  echo 'Script must be run as root.'
  exit 1
fi

echo 'Enabling firewall...'
ufw enable
echo 'Firewall enabled.'

echo 'Disabling guest account...'
echo 'allow-guest=false' >> /etc/lightdm/lightdm.conf
echo 'Guest account disabled.'

echo 'Updating available packages...'
apt-get update
echo 'Update complete.'

echo 'Installing software...'
apt-get --assume-yes install libpam-cracklib lynis rkhunter auditd php
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

chown root:root /etc/grub.conf
chmod o-rwx,g-rw /etc/grub.conf

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
chmod 440 /etc/inetd.conf
chmod 440 /etc/xinetd.conf
chmod 400 /etc/inetd.d
chmod 644 /etc/hosts.allow
chmod 440 /etc/sudoers
