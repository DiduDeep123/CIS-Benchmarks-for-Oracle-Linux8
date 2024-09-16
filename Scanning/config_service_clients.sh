#!/usr/bin/bash

LOG_FILE="/var/log/hardening_scan.log"
RESULT_FILE="/var/tmp/scan_results.txt"


# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $LOG_FILE	  #output to both screen and log file
}


check_config_service_clients() {
    packages=("ftp" "openldap-clients" "ypbind" "telnet" "tftp" )
    
    for i in "${!packages[@]}"; do
        package="${packages[$i]}"
       

        if rpm -q "$package" > /dev/null 2>&1; then
            log_message "$package is installed."
			echo ""$package":INSTALLED" >> "$RESULT_FILE"
			

        else
            log_message "$package is not installed."
			echo ""$package":NOT INSTALLED" >> "$RESULT_FILE"
        fi
    done
}


check_config_service_clients
