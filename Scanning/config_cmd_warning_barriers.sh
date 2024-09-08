#!/usr/bin/bash

LOG_FILE="/var/log/hardening_scan.log"
RESULT_FILE="/var/tmp/scan_results.txt"


# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $LOG_FILE	  #output to both screen and log file
}



#Check motd
check_motd() {
    motd_file="/etc/motd"
    

    # Extract OS ID from /etc/os-release
    os_id=$(grep '^ID=' /etc/os-release | cut -d= -f2 | sed -e 's/"//g')

    # Define patterns to check for in /etc/motd
    patterns='\\\v|\\\r|\\\m|\\\s|'$(echo "$os_id")

    log_message "Checking /etc/motd...."


    if grep -E -i "$patterns" "$motd_file" > /dev/null; then
        result="/etc/motd is not configured properly."
        echo "MOTD_CONFIG:FAIL" >> "$RESULT_FILE"
    else
        result="/etc/motd is configured properly."
        echo "MOTD_CONFIG:SUCCESS" >> "$RESULT_FILE"
    fi

    log_message "$result"
}

#Check local login warning banner is configured properly
check_local_login_warning() {
    local_login_file="/etc/issue"
    

    # Extract OS ID from /etc/os-release
    os_id=$(grep '^ID=' /etc/os-release | cut -d= -f2 | sed -e 's/"//g')

    patterns='\\\v|\\\r|\\\m|\\\s|'$(echo "$os_id")

    log_message "Checking /etc/issue...."


    if grep -E -i "$patterns" "$local_login_file" > /dev/null; then
        result="/etc/issue is not configured properly."
        echo "LOCAL_LOGIN_WARNING_CONFIG:FAIL" >> "$RESULT_FILE"
    else
        result="/etc/issue is configured properly."
        echo "LOCAL_LOGIN_WARNING_CONFIG:SUCCESS" >> "$RESULT_FILE"
    fi

    log_message "$result"
}

check_remote_login_warning() {
    local_login_file="/etc/issue.net"
    

    # Extract OS ID from /etc/os-release
    os_id=$(grep '^ID=' /etc/os-release | cut -d= -f2 | sed -e 's/"//g')


    patterns='\\\v|\\\r|\\\m|\\\s|'$(echo "$os_id")

    log_message "Checking /etc/issue.net"


    if grep -E -i "$patterns" "$local_login_file" > /dev/null; then
        result="/etc/issue.net is not configured properly."
        echo "REMOTE_LOGIN_WARNING_CONFIG:FAIL" >> "$RESULT_FILE"
    else
        result="/etc/issue.net is configured properly."
        echo "REMOTE_LOGIN_WARNING_CONFIG:FAIL" >> "$RESULT_FILE"
    fi

    log_message "$result"
}


# Check etc_motd permissions
check_etc_motd_permissions() {
    # Check current permissions, user, and group
    current_access_permissions=$(stat -Lc '%a' /etc/motd)
    current_user=$(stat -Lc '%U' /etc/motd)
    current_group=$(stat -Lc '%G' /etc/motd)
    
    # Desired permissions, user, and group
    desired_access_permissions="644"
    desired_user="root"
    desired_group="root"
    
    log_message "Checking /etc/motd permissions..."
    
    if [[ "$current_access_permissions" == "$desired_access_permissions" && "$current_user" == "$desired_user" && "$current_group" == "$desired_group" ]]; then
        echo "/etc/motd permissions:CORRECT" >> $RESULT_FILE
        log_message "/etc/motd permissions are correctly configured."
    else
        echo "/etc/motd permissions:INCORRECT" >> $RESULT_FILE
        log_message "/etc/motd permissions need to be changed."
    fi
}

# Check etc_issue permissions
check_etc_issue_permissions() {
    # Check current permissions, user, and group
    current_access_permissions=$(stat -Lc '%a' /etc/issue)
    current_user=$(stat -Lc '%U' /etc/issue)
    current_group=$(stat -Lc '%G' /etc/issue)
    
    # Desired permissions, user, and group
    desired_access_permissions="644"
    desired_user="root"
    desired_group="root"
    
    log_message "Checking /etc/issue permissions..."
    
    if [[ "$current_access_permissions" == "$desired_access_permissions" && "$current_user" == "$desired_user" && "$current_group" == "$desired_group" ]]; then
        echo "/etc/issue permissions:CORRECT" >> $RESULT_FILE
        log_message "/etc/issue permissions are correctly configured."
    else
        echo "/etc/issue permissions:INCORRECT" >> $RESULT_FILE
        log_message "/etc/issue permissions need to be changed."
    fi
}

# Check etc_issue_net permissions
check_etc_issue_net_permissions() {
    # Check current permissions, user, and group
    current_access_permissions=$(stat -Lc '%a' /etc/issue.net)
    current_user=$(stat -Lc '%U' /etc/issue.net)
    current_group=$(stat -Lc '%G' /etc/issue.net)
    
    # Desired permissions, user, and group
    desired_access_permissions="644"
    desired_user="root"
    desired_group="root"
    
    log_message "Checking /etc/issue.net permissions..."
    
    if [[ "$current_access_permissions" == "$desired_access_permissions" && "$current_user" == "$desired_user" && "$current_group" == "$desired_group" ]]; then
        echo "/etc/issue.net permissions:CORRECT" >> $RESULT_FILE
        log_message "/etc/issue.net permissions are correctly configured."
    else
        echo "/etc/issue.net permissions:INCORRECT" >> $RESULT_FILE
        log_message "/etc/issue.net permissions need to be changed."
    fi
}
