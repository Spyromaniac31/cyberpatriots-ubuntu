#!/bin/bash
ufw enable
echo 'allow-guest=false' >> /etc/lightdm/lightdm.conf
sed -i 's/pam_cracklib.so/pam_cracklib.so ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1 /' /etc/pam.d/common-password
sed -i 's/pam_unix.so/pam_unix.so remember=5 minlen=8 /' /etc/pam.d/common-password
echo 'auth required pam_tally2.so deny=5 onerr=fail unlock_time=1800' >> /etc/pam.d/common-auth
