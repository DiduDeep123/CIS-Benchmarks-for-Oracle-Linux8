#!/usr/bin/bash

# Configure Cron
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


install_nftables() {

if grep -q "nftables:NOT INSTALLED" $RESULT_FILE; then
read -p "Do you want to install nftables? (y/n)" answer
	if [[ answer = [Yy] ]]; then
	log_message "Installing SELinux..."
	dnf install nftables
	log_message "SELinux installed."
	fi
	else
	select_no "NFTABLES NOT INSTALLED: REQUIRES CHANGE"
	

fi
}
