sed 's/pam_cracklib.so/pam_cracklib.so ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1 /g' /etc/pam.d/common-password
sed 's/pam_unix.so/pam_unix.so remember=5 minlen=8 /g' /etc/pam.d/common-password
