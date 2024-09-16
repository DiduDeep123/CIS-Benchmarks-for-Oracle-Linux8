#!/usr/bin/bash

LOG_FILE="/var/log/hardening_scan.log"
RESULT_FILE="/var/tmp/scan_results.txt"


# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $LOG_FILE	  #output to both screen and log file
}

check_chrony(){
package="chrony"

	log_message "Checking if chrony is installed..."

if rpm -q "$package" > /dev/null 2>&1; then
	log_message "$package is installed."
	echo "CHRONY:INSTALLED" >> "$RESULT_FILE"
		
else
	echo "$package is not installed."
	echo "CHRONY:NOT INSTALLED" >> "$RESULT_FILE"
fi
}

check_chrony_configuration(){

	config_files="/etc/chrony.conf /etc/chrony.d/*"
	remote_server_pattern='^\h*(server|pool)\h+[^#\n\r]+'
	config_found="false"
	
	log_message "Checking chrony configuration for remote servers..."
	
	for file in $config_files; do 
	if [ -f "$file" ]; then
		if grep -Pq -- "$remote_server_pattern" "$file"; then
			log_message "chrony is configured in "$file"."
			config_found=true
		fi
	fi 
	done
	
if [ "$config_found" = "false" ]; then
	log_message " No remote servers are configured for time synchronization."
	echo "To configure remote servers, edit /etc/chrony.conf or files in /etc/chrony.d/ and add server or pool entries."
	fi
}

check_chrony_root_user() {
    local chrony_config="/etc/sysconfig/chronyd"
    local pattern='^\h*OPTIONS="?\h+-u\h+root\b'

    log_message "Checking if Chrony is not configured to run as root..."

    if grep -Psi -- "$pattern" "$chrony_config" > /dev/null; then
        result="Chrony is configured to run as the root user."
        echo "CHRONY_NOT_RUN_AS_ROOT_USER:FAIL" >> "$RESULT_FILE"
    else
        result="Chrony is not configured to run as the root user."
        echo "CHRONY_NOT_RUN_AS_ROOT_USER:SUCCESS" >> "$RESULT_FILE"
    fi

    log_message "$result"
}

check_chrony
check_chrony_configuration
check_chrony_root_user
