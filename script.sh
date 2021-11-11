#!/bin/bash
ufw enable
echo 'allow-guest=false' >> /etc/lightdm/lightdm.conf
apt-get install libpam-cracklib
sed -i 's/PASS_MAX_DAYS	99999/PASS_MAX_DAYS	90/' /etc/login.defs
sed -i 's/PASS_MIN_DAYS	0/PASS_MIN_DAYS	10/' /etc/login.defs
sed -i 's/pam_cracklib.so/pam_cracklib.so ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1 /' /etc/pam.d/common-password
sed -i 's/pam_unix.so/pam_unix.so remember=5 minlen=8 /' /etc/pam.d/common-password
echo 'auth required pam_tally2.so deny=5 onerr=fail unlock_time=1800' >> /etc/pam.d/common-auth
