#!/usr/bin/bash

LOG_FILE="/var/log/hardening_scan.log"
RESULT_FILE="/var/tmp/scan_results.txt"

# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $LOG_FILE	  #output to both screen and log file
}

check_aide(){
package="aide"

	log_message "Checking if aide is installed..."

if rpm -q "$package" > /dev/null 2>&1; then
	log_message "$package is installed."
	echo "AIDE:INSTALLED" >> "$RESULT_FILE"
		
else
	echo "$package is not installed."
	echo "AIDE:NOT INSTALLED" >> "$RESULT_FILE"
fi
}

# Function to check the status of aidecheck service and timer
check_aidecheck_status() {

if grep -q "AIDE:INSTALLED" $RESULT_FILE; then
    

    log_message "Checking the status of aidecheck.service and aidecheck.timer..."

    # Check if aidecheck.service is enabled
    if systemctl is-enabled --quiet aidecheck.service; then
        log_message "aidecheck.service is enabled."
        echo "AIDECHECK SERVICE:ENABLED" >> "$RESULT_FILE"
    else
        log_message "aidecheck.service is not enabled."
        echo "AIDECHECK SERVICE:NOT ENABLED" >> "$RESULT_FILE"
    fi

    # Check if aidecheck.timer is enabled
    if systemctl is-enabled --quiet aidecheck.timer; then
        log_message "aidecheck.timer is enabled."
        echo "AIDECHECK TIMER:ENABLED" >> "$RESULT_FILE"
    else
        log_message "aidecheck.timer is not enabled."
        echo "AIDECHECK TIMER:NOT ENABLED" >> "$RESULT_FILE"
    fi

    # Check if aidecheck.timer is running
    if systemctl is-active --quiet aidecheck.timer; then
        log_message "aidecheck.timer is running."
        echo "AIDECHECK TIMER:RUNNING" >> "$RESULT_FILE"
    else
        log_message "aidecheck.timer is not running."
        echo "AIDECHECK TIMER:NOT RUNNING" >> "$RESULT_FILE"
    fi

fi
}

# Function to check AIDE configuration for cryptographic mechanisms
check_aide_configuration() {

if grep -q "AIDE:INSTALLED" $RESULT_FILE; then
    log_message "Verifying AIDE configuration for cryptographic mechanisms..."


    # Define the required entries
    required_entries=(
        "/sbin/auditctl p+i+n+u+g+s+b+acl+xattrs+sha512"
        "/sbin/auditd p+i+n+u+g+s+b+acl+xattrs+sha512"
        "/sbin/ausearch p+i+n+u+g+s+b+acl+xattrs+sha512"
        "/sbin/aureport p+i+n+u+g+s+b+acl+xattrs+sha512"
        "/sbin/autrace p+i+n+u+g+s+b+acl+xattrs+sha512"
        "/sbin/augenrules p+i+n+u+g+s+b+acl+xattrs+sha512"
    )

    all_entries_found=true

    for entry in "${required_entries[@]}"; do
        # First, check if the entry is present in /etc/aide.conf
        if grep -qF "$entry" /etc/aide.conf; then
            continue
        fi

        # If not found in /etc/aide.conf, check in /etc/aide.conf.d/*.conf
        if grep -qF "$entry" /etc/aide.conf.d/*.conf 2>/dev/null; then
            continue
        fi

        # If the entry is not found in either location
        log_message "Missing required AIDE configuration entry: $entry"
        echo "AIDE CONFIGURATION:INCOMPLETE" >> "$RESULT_FILE"
        all_entries_found=false
    done

    if $all_entries_found; then
        log_message "AIDE is properly configured with cryptographic mechanisms."
        echo "AIDE CONFIGURATION:COMPLETE" >> "$RESULT_FILE"
    fi
}


check_aide_configuration
check_aide
check_aidecheck_status
check_aide_configuration
