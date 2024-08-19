#!/usr/bin/bash

LOG_FILE="/var/log/hardening_scan.log"
RESULT_FILE="/var/tmp/scan_results.txt"

# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $LOG_FILE	  #output to both screen and log file
}

check_audit() {
    package="audit"
  
        if rpm -q "$package" > /dev/null 2>&1; then
            log_message "$package is installed."
			echo "audit:INSTALLED" >> $RESULT_FILE
            
        else
            log_message "$package is not installed."
			echo "audit:NOT INSTALLED" >> $RESULT_FILE
		fi
}


check_audit_param_set() {
    log_message "Checking if 'audit=1' parameter is set in the kernel boot parameters..."
	
    # Check if audit=1 is already set in the kernel parameters
    
    audit_param_set=$(grubby --info=ALL | grep -Po '\baudit=1\b')

    if [[ -n "$audit_param_set" ]]; then
        log_message "'audit=1' parameter is already set."
		echo "AUDIT PARAMETER SET:OK" >> $RESULT_FILE
    else
        log_message "'audit=1' parameter is not set."
		echo "AUDIT PARAMETER SET:FAILED" >> $RESULT_FILE

    fi
}
############
check_audit_backlog_limit() {
    log_message "Checking if audit backlog parameter is set ..."
    
    # Extract the numerical part of the audit_backlog_limit parameter
    audit_backlog_limit=$(audit_backlog_limit=$(grubby --info=ALL | grep -Po 'audit_backlog_limit=\d+' | sed 's/audit_backlog_limit=//' | head -n 1))


    if [[ -n "$audit_backlog_limit" ]]; then
        log_message "Audit backlog limit parameter is set to $audit_backlog_limit."
        echo "AUDIT BACKLOG LIMIT: $audit_backlog_limit" >> $RESULT_FILE
    else
        log_message "Audit backlog limit parameter is not set."
        echo "AUDIT BACKLOG LIMIT: NOT SET" >> $RESULT_FILE
    fi
}

check_audit_enabled() {
    
    service_name="auditd"

    log_message "Checking if $service_name service is enabled..."

    # Get the service status
    service_status=$(systemctl is-enabled "$service_name")

    if [[ "$service_status" == "enabled" ]]; then
        log_message "$service_name is already enabled."
		echo "AUDITD:ENABLED" >> $RESULT_FILE
    else
        log_message "$service_name is not enabled."
		echo "AUDITD:NOT ENABLED" >> $RESULT_FILE
        
    fi
}




check_audit
check_audit_param_set
check_audit_enabled
check_audit_backlog_limit
