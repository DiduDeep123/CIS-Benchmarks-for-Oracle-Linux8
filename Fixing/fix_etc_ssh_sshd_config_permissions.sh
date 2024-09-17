#!/usr/bin/bash


LOG_FILE="/var/log/hardening_fix.log"
RESULT_FILE="/var/tmp/scan_results.txt"
NEW_LOG_FILE="/var/log/user_select.log"

# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $LOG_FILE
}

#User opted not to apply remediation function
select_no() {
	log_message "User opted not to apply remediation."
	echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $NEW_LOG_FILE
}
	


if grep -q "/etc/ssh/sshd_config_permissions:NOT CONFIGURED" $RESULT_FILE; then
	read -p "Do you want to configure correct pemissions on /etc/ssh/sshd_config ? (y/n)" answer
	if [[ answer = [Yy] ]]; then


		 chmod u-x,og-rwx /etc/ssh/sshd_config
		 chown root:root /etc/ssh/sshd_config
		 while IFS= read -r -d $'\0' l_file; do
		 if [ -e "$l_file" ]; then
		 chmod u-x,og-rwx "$l_file"
		 chown root:root "$l_file"
		 fi
		 done < <(find /etc/ssh/sshd_config.d -type f -print0)
		 
	else
		select_no "/etc/ssh/sshd_config PERMISSIONS:REQUIRES CHANGE"
		
	fi
fi


