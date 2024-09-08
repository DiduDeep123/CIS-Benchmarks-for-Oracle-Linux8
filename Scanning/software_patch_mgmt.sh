#!/usr/bin/bash

LOG_FILE="/var/log/hardening_scan.log"
RESULT_FILE="/var/tmp/scan_results.txt"


# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $LOG_FILE	  #output to both screen and log file
}

#Global gpg check
global_gpgcheck() {
    dnf_conf_file="/etc/dnf/dnf.conf"

    log_message "Checking gpgcheck setting in $dnf_conf_file..."
    current_gpgcheck=$(grep -P '^gpgcheck\s*=' "$dnf_conf_file" | awk -F= '{print $2}' | tr -d '[:space:]')

    if [[ "$current_gpgcheck" == "1" ]]; then
        log_message "gpgcheck is already set to 1 in $dnf_conf_file."
		echo "gpg_check:SUCCESS">> $RESULT_FILE
    else
        log_message "gpgcheck is not set to 1 in $dnf_conf_file. Current value: $current_gpgcheck"
        echo "gpg_check:FAILED">> $RESULT_FILE
    fi
	
	if  grep -Prsq -- '^\h*gpgcheck\h*=\h*(0|[2-9]|[1-9][0-9]+|[a-zA-Z_]+)\b' /etc/yum.repos.d/; then
		log_message "gpgcheck is already set to 1 in $dnf_conf_file."
	fi
}


global_gpgcheck
