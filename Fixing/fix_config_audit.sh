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

#Functon to install audit
install_audit() {
if grep -q "audit:NOT INSTALLED" $RESULT_FILE; then
	read -p "Do you want to install audit ? (y/n)" answer
	if [[ $answer = [Yy] ]]; then
	log_message "Installing audit..."
	dnf install audit
	log_message "audit installed."
	
	else
	select_no "User opted not to install audit."
	echo "audit NOT INSTALLED: REQUIRES CHANGE" >> $NEW_LOG_FILE
fi
fi
}

#Function to Ensure auditing for processes that start prior to auditd is enabled
fix_grub2_configuration() {
if grep -q "AUDIT PARAMETER SET:FAILED" $RESULT_FILE; then
	read -p "Do you want to ensure auditing for processes that start prior to auditd is enabled  ? (y/n)" answer
	if [[ $answer = [Yy] ]]; then
	log_message "Updating the grub2 configuration with audit=1..."
	grubby --update-kernel ALL --args 'audit=1'
	log_message "Updated the grub2 configuration with audit=1..."
	
	else
	select_no "User opted not to update grub2 configuration."
	echo "AUDIT PARAMETER SET FAILED: REQUIRES CHANGE" >> $NEW_LOG_FILE
fi
fi
}

#Function to fix audit backlog limit
fix_audit_backlog_limit() {
if grep -q "AUDIT BACKLOG LIMIT: NOT SET" $RESULT_FILE; then
	read -p "Do you want to ensure audit_backlog_limit is sufficient  ? (y/n)" answer
	if [[ $answer = [Yy] ]]; then    
	
    read -p "Enter the audit_backlog_limit size (e.g., 8192): " backlog_size

    
    if [[ ! "$backlog_size" =~ ^[0-9]+$ ]] || [ "$backlog_size" -ge 8192 ]; then
        echo "Invalid input. Please enter a value greater than or equal to 8192 for the backlog size."
        exit 1
    fi

    
    log_message "Updating GRUB configuration to set audit_backlog_limit=${backlog_size}..."
    grubby --update-kernel ALL --args "audit_backlog_limit=${backlog_size}"

    
    if [[ $? -eq 0 ]]; then
        log_message "GRUB configuration updated successfully."
        echo "Please run 'sudo update-grub' to apply the changes and reboot your system for them to take effect."
    else
        echo "Failed to update GRUB configuration."
        exit 1
    fi
	
	else
	select_no "User opted not to update audit backlog limit."
	echo "AUDIT BACKLOG LIMIT NOT SET: REQUIRES CHANGE" >> $NEW_LOG_FILE
fi
fi
}

#Function to enable auditd
enable_auditd() {
if grep -q "AUDITD:NOT ENABLED" $RESULT_FILE; then
	read -p "Do you want to enable auditd ? (y/n)" answer
	if [[ $answer = [Yy] ]]; then
	log_message "Enabling auditd..."
	systemctl --now enable auditd
	log_message "auditd enabled."
	else
	select_no "User opted not to enable audit."
	echo "AUDITD NOT ENABLED: REQUIRES CHANGE" >> $NEW_LOG_FILE
fi
fi	
}



install_audit
fix_grub2_configuration
fix_audit_backlog_limit
enable_auditd
