#!/usr/bin/bash

LOG_FILE="/var/log/hardening_scan.log"
RESULT_FILE="/var/tmp/scan_results.txt"


# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $LOG_FILE	  #output to both screen and log file
}



check_SELinux() {
    package="libselinux"
  
        if rpm -q "$package" > /dev/null 2>&1; then
            log_message "$package is installed."
			echo ""$package":INSTALLED">> $RESULT_FILE
            
        else
            log_message "$package is not installed."
			echo ""$package":NOT INSTALLED">> $RESULT_FILE
			
		fi
}

check_SELinux_not_disabled() {
    log_message "Checking if SELinux is not disabled in bootloader configuration..."

    # Use grubby to get all kernel parameters and check for SELinux configuration
    if grubby --info=ALL | grep -Pq '(selinux=0|enforcing=0)\b'; then
        result="SELinux is disabled in bootloader configuration."
        echo "SELinux:DISABLED" >> "$RESULT_FILE"
    else
        result="SELinux is not disabled in bootloader configuration."
        echo "SELinux:NOT DISABLED" >> "$RESULT_FILE"
    fi
    
    log_message "$result"
}

check_selinux_policy() {
    config_file="/etc/selinux/config"
    result_file="${RESULT_FILE:-/var/log/selinux_check.log}"

    log_message "Checking SELinux policy type..."

    # Check the SELINUXTYPE in /etc/selinux/config
    
    selinux_type=$(grep -E '^\s*SELINUXTYPE=' "$config_file" | awk -F= '{print $2}' | tr -d '[:space:]')

    if [[ "$selinux_type" == "targeted" ]]; then
        echo "SELINUXTYPE:SUCCESS" >> "$RESULT_FILE"
        result="SELinux policy type is set to 'targeted'. Success."
    elif [[ "$selinux_type" == "mls" ]]; then
        echo "SELINUXTYPE:CHANGE REQUIRED" >> "$RESULT_FILE"
        result="SELinux policy type is set to 'mls'. Change required."
    else
        echo "SELINUXTYPE:INVALID" >> "$RESULT_FILE"
        result="SELinux policy type is not 'targeted' or 'mls'."
    fi

    # Check the loaded policy name with sestatus
    local loaded_policy_name
    loaded_policy_name=$(sestatus | grep 'Loaded policy name:' | awk '{print $4}' | tr -d '[:space:]')

    if [[ "$loaded_policy_name" == "targeted" ]]; then
        result="Loaded SELinux policy name is 'targeted'. Success."
    elif [[ "$loaded_policy_name" == "mls" ]]; then
        result="Loaded SELinux policy name is 'mls'. Change required."
    else
        result="Loaded SELinux policy name is not 'targeted' or 'mls'."
    fi
    
    log_message "$result"
}

selinux_mode() {
    log_message "Checking SELinux mode..."
    
    # Get the current mode of SELinux
    current_mode=$(getenforce)

    if [[ "$current_mode" == "Disabled" ]]; then
        log_message "SELinux is currently disabled."
		echo "SELINUXMODE:REQUIRES CHANGE" >> "$RESULT_FILE"
        
    elif [[ "$current_mode" == "Enforcing" ]]; then
        log_message "SELinux is already set to Enforcing mode."
		echo "SELINUXMODE:ENFORCING" >> "$RESULT_FILE"
    elif [[ "$current_mode" == "Permissive" ]]; then
        log_message "SELinux is currently in Permissive mode."
		echo "SELINUXMODE:REQUIRES CHANGE" >> "$RESULT_FILE"
        
    fi
}

# Check no unconfined services exist
check_unconfined_services() {

	log_message "Checking no unconfined services exist..."
	
    if ps -eZ | grep -q unconfined_service_t; then
        result="There are unconfined services"
        echo "unconfined_services:EXIST">> $RESULT_FILE
        log_message "$result"
    else
        result="There are no unconfined services"
        echo "unconfined_services:DO NOT EXIST">> $RESULT_FILE
        log_message "$result"
    fi
}

check_mcstrans() {
    package="mcstrans"
  
        if rpm -q "$package" > /dev/null 2>&1; then
            log_message "$package is installed."
			echo ""$package":INSTALLED">> $RESULT_FILE
            
        else
            log_message "$package is not installed."
			echo ""$package":NOT INSTALLED">> $RESULT_FILE
			
		fi
}

check_setroubleshoot() {
    package="setroubleshoot"
  
        if rpm -q "$package" > /dev/null 2>&1; then
            log_message "$package is installed."
			echo ""$package":INSTALLED">> $RESULT_FILE
            
        else
            log_message "$package is not installed."
			echo ""$package":NOT INSTALLED">> $RESULT_FILE
			
		fi
}

check_SELinux
check_SELinux_not_disabled
check_selinux_policy
check_unconfined_services
check_mcstrans
check_setroubleshoot
