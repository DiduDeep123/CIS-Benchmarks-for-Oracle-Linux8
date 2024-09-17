#!/usr/bin/bash

LOG_FILE="/var/log/hardening_scan.log"
RESULT_FILE="/var/tmp/scan_results.txt"

# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $LOG_FILE	  #output to both screen and log file
}


# Function to check if sudo is installed
check_sudo_installed() {
    # Run the dnf command to list installed packages
    if dnf list installed sudo > /dev/null 2>&1; then
       log_message "sudo is installed."
       echo "SUDO:INSTALLED" >> "$RESULT_FILE"
    else
        log_message "sudo is not installed."
        echo "SUDO:NOT INSTALLED" >> "$RESULT_FILE"
    fi
}


# Function to check if sudo is configured to use a pseudo terminal
check_sudo_use_pty() {
    
    if grep -rPi '^\h*Defaults\h+([^#\n\r]+,)?use_pty(,\h*\h+\h*)*\h*(#.*)?$' /etc/sudoers* > /dev/null 2>&1; then
        log_message "sudo is configured to use a pseudo terminal."
        echo "USE_PTY:CONFIGURED" >> "$RESULT_FILE"
    else
        log_message "sudo is not configured to use a pseudo terminal."
         echo "USE_PTY:NOT CONFIGURED" >> "$RESULT_FILE"
    fi
}


# Function to check if sudo has a custom log file configured
check_sudo_logfile() {
    # Search for the 'Defaults logfile' setting in /etc/sudoers and included files
    if grep -rPsi '^\h*Defaults\h+([^#]+,\h*)?logfile\h*=\h*(\"|\')?\H+(\"|\')?(,\h*\H+\h*)*\h*(#.*)?$' /etc/sudoers* > /dev/null 2>&1; then
        log_message "sudo has a custom log file configured."
        echo "SUDO_CUSTOM_LOG_FILE:CONFIGURED" >> "$RESULT_FILE"
    else
        log_message "sudo does not have a custom log file configured."
        echo "SUDO_CUSTOM_LOG_FILE:NOT CONFIGURED" >> "$RESULT_FILE"
    fi
}


# Function to check if passwordless sudo is allowed
check_sudo_nopasswd() {
   
    if grep -r "^[^#].*NOPASSWD" /etc/sudoers* > /dev/null 2>&1; then
        log_message "Passwordless sudo (NOPASSWD) is allowed."
        echo "NOPASSWD:ALLOWED" >> "$RESULT_FILE"
    else
        log_message "Password is required for sudo privilege escalation."
        echo "NOPASSWD:NOT ALLOWED" >> "$RESULT_FILE"
    fi
}


# Function to check if authentication is not required for sudo privilege escalation
check_sudo_no_authentication() {
   
    if grep -r "^[^#].*\!authenticate" /etc/sudoers* > /dev/null 2>&1; then
        log_message "Sudo does not require re-authentication (authentication is disabled)."
        echo "REAUTHENTICATION:DISABLED" >> "$RESULT_FILE"
    else
        log_message "Sudo requires re-authentication for privilege escalation."
        echo "REAUTHENTICATION:ENABLED" >> "$RESULT_FILE"
    fi
}


# Function to check if sudo caching timeout is no more than 15 minutes
check_sudo_timeout() {
    # Search for timestamp_timeout in /etc/sudoers and included files
    local timeout=$(grep -roP "timestamp_timeout=\K[0-9]*" /etc/sudoers* 2>/dev/null)
    
    if [ -n "$timeout" ]; then
       
        if [ "$timeout" -le 15 ]; then
            log_message  "Sudo caching timeout is set to ${timeout} minutes, which is within the acceptable range."
            echo "SUDO_AUTHENTICATION_TIMEOUT:ACCEPTABLE" >> "$RESULT_FILE"
        else
            log_message  "Sudo caching timeout is set to ${timeout} minutes, which exceeds the 15-minute limit."
             echo "SUDO_AUTHENTICATION_TIMEOUT:NOT ACCEPTABLE" >> "$RESULT_FILE"
        fi
    else
        # If no timestamp_timeout is configured, check the default timeout
        default_timeout=$(sudo -V 2>/dev/null | grep "Authentication timestamp timeout:" | awk '{print $5}')
        
        if [ "$default_timeout" = "-1" ]; then
            log_message  "Sudo caching timeout is disabled (value -1)."
             echo "SUDO_AUTHENTICATION_TIMEOUT:NOT ACCEPTABLE" >> "$RESULT_FILE"
        elif [ "$default_timeout" -le 15 ]; then
            log_message  "Default sudo caching timeout is ${default_timeout} minutes, which is within the acceptable range."
            echo "SUDO_AUTHENTICATION_TIMEOUT:ACCEPTABLE" >> "$RESULT_FILE"
        else
            log_message  "Default sudo caching timeout is ${default_timeout} minutes, which exceeds the 15-minute limit."
             echo "SUDO_AUTHENTICATION_TIMEOUT:NOT ACCEPTABLE" >> "$RESULT_FILE"
        fi
    fi
}



# Function to verify PAM configuration for 'su' and check group membership
check_su_access_restriction() {
    local pam_file="/etc/pam.d/su"

    # Ask the user for the group name
    read -p "Enter the group name to check: " group_name

    # Check PAM configuration
    local pam_pattern='^\h*auth\h+(?:required|requisite)\h+pam_wheel\.so\h+(?:[^#\n\r]+\h+)?((?!\2) (use_uid\b|group=\H+\b))\h+(?:[^#\n\r]+\h+)?((?!\1)(use_uid\b|group=\H+\b))(\h+.*)?$'
    if grep -Pi "$pam_pattern" "$pam_file" | grep -q "auth required pam_wheel.so use_uid group=$group_name"; then
        log_message "PAM configuration for 'su' is correct."
        echo "SU_ACCESS:CONFIGURED" >> "$RESULT_FILE"
    else
        log_message "PAM configuration for 'su' does not match the required settings."
       echo "SU_ACCESS:NOT CONFIGURED" >> "$RESULT_FILE"
    fi

    # Check group membership
    if grep -q "^$group_name:x:[0-9]*:$" /etc/group; then
        log_message "Group '$group_name' contains no users."
         echo "SU_ACCESS:CONFIGURED" >> "$RESULT_FILE"
    else
        log_message "Group '$group_name' contains users or does not exist."
       echo "SU_ACCESS:NOT CONFIGURED" >> "$RESULT_FILE"
    fi


}













check_sudo_installed
check_sudo_use_pty
check_sudo_logfile
check_sudo_nopasswd
check_sudo_no_authentication
check_sudo_timeout
check_su_access_restriction
