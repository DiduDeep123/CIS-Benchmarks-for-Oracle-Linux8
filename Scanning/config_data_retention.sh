#!/usr/bin/bash

LOG_FILE="/var/log/hardening_scan.log"
RESULT_FILE="/var/tmp/scan_results.txt"

# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $LOG_FILE	  #output to both screen and log file
}



check_audit_log_storage_size() {
    log_message "Checking if audit log storage size is configured ..."

    # Extract the numerical part of the max_log_file parameter
    log_storage_size=$(grep -w "^\s*max_log_file\s*=" /etc/audit/auditd.conf | sed 's/max_log_file=//')

    if [[ -n "$log_storage_size" ]]; then
        log_message "Audit log storage size is set to $log_storage_size."
        echo "AUDIT LOG STORAGE SIZE: $log_storage_size" >> $RESULT_FILE
    else
        log_message "Audit log storage size is not set."
        echo "AUDIT LOG STORAGE SIZE: NOT SET" >> $RESULT_FILE
    fi
}

#Check audit logs are not automatically deleted
check_delete_audit_logs() {
	log_message "Checking if audit logs are not automatically deleted..."
	
	log_file_action=$(grep max_log_file_action /etc/audit/auditd.conf | awk -F'=' '{print $2}' | xargs)
	
	if [[ "$log_file_action" = "keep_logs" ]]; then
		log_message "Audit logs are not automatically deleted"
        echo "AUDIT LOGS AUTOMATICALLY DELETED:NO" >> $RESULT_FILE
		
	else
		log_message "Audit logs are automatically deleted"
        echo "AUDIT LOGS AUTOMATICALLY DELETED:YES" >> $RESULT_FILE
}

#Check disk full action is either set to single or halt
check_disk_full_action() {
	log_message "Checking if disk full action is either set to single or halt..."
	
	disk_full_action=$(grep -P -- '^\h*disk_full_action\h*=\h*(halt|single)\b' /etc/audit/auditd.conf | awk -F'=' '{print $2}' | xargs)
	
	if [[ "$disk_full_action" = "halt" || "$disk_full_action" = "single" ]]
		log_message "Disk full action is either set to single or halt."
        echo "DISK FULL ACTION:CONFIGURED" >> $RESULT_FILE
	else
		log_message "Disk full action is no in single or halt."
        echo "DISK FULL ACTION:NOT CONFIGURED" >> $RESULT_FILE
}

#Check disk error action
check_disk_error_action() {
	log_message "Checking if disk error action is set to syslog, single or halt..."
	
	disk_error=$(grep -P -- '^\h*disk_error_action\h*=\h*(syslog|single|halt)\b' /etc/audit/auditd.conf | awk -F'=' '{print $2}' | xargs)
	
	if [[ "$disk_error" = "syslog"  || "$disk_error" = "single" || "$disk_error" = "halt"]]
		log_message "Disk error action is set to syslog, single or halt."
        echo "DISK ERROR ACTION:CONFIGURED" >> $RESULT_FILE
	else
		log_message "Disk error action is not configured."
        echo "DISK ERROR ACTION:NOT CONFIGURED" >> $RESULT_FILE
	
	
}

check_space_left() {
	log_message "Checking if space left is set to email, exec, single or halt..."
	
	space_left=$(grep -P -- '^\h*space_left_action\h*=\h*(email|exec|single|halt)\b' /etc/audit/auditd.conf | awk -F'=' '{print $2}' | xargs)
	
	if [[ "$space_left" = "email" || "$space_left" = "exec" || "$space_left" = "single" || "$space_left" = "halt" ]]
		log_message "Space left is set to email, exec, single or halt."
		echo "SPACE LEFT WARNS:CONFIGURED" >> $RESULT_FILE
	else
		log_message "Space left is not configured."
        echo "SPACE LEFT WARNS:NOT CONFIGURED" >> $RESULT_FILE

}

check_admin_space_left() {
	log_message "Checking if admin space left is set to single or halt..."
	
	admin_space_left=$(grep -P -- '^\h*admin_space_left_action\h*=\h*(single|halt)\b'  /etc/audit/auditd.conf | awk -F'=' '{print $2}' | xargs)
	
	if [[ "$admin_space_left" = "single" || "$admin_space_left" = "halt" ]]
		log_message "Admin space left is set to single or halt."
		echo "ADMIN SPACE LEFT WARNS:CONFIGURED" >> $RESULT_FILE
	else
		log_message "Admin space left is not configured."
        echo "ADMIN SPACE LEFT WARNS:NOT CONFIGURED" >> $RESULT_FILE

}


check_audit_log_storage_size
check_delete_audit_logs
check_disk_full_action
check_disk_error_action
check_space_left
check_admin_space_left

