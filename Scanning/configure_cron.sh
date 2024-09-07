#!/usr/bin/bash

LOG_FILE="/var/log/hardening_scan.log"
RESULT_FILE="/var/tmp/scan_results.txt"
CRONTAB_FILE="/etc/crontab"
CRON_HOURLY_DIR="/etc/cron.hourly/"
CRON_DAILY_DIR="/etc/cron.daily/"
CRON_WEEKLY_DIR="/etc/cron.weekly/"
CRON_MONTHLY_DIR="/etc/cron.monthly"
CROND="/etc/cron.d"

# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $LOG_FILE	  #output to both screen and log file
}

# Check crond status
check_crond_status() {
    enabled_status=$(systemctl is-enabled crond 2>/dev/null)	#direct any error messages so that it does not clutter the output
    active_status=$(systemctl is-active crond 2>/dev/null)

    if [[ $enabled_status == "enabled" && $active_status == "active" ]]; then
        echo "crond:enabled:active" > $RESULT_FILE
        log_message "crond is enabled and active."
    else
        echo "crond:not_enabled_or_not_active" > $RESULT_FILE
        log_message "crond is NOT enabled or active."
    fi
}

# Check crontab file permissions
check_crontab_permissions() {
    # Check current permissions, user, and group
    current_access_permissions=$(stat -Lc '%a' $CRONTAB_FILE)
    current_user=$(stat -Lc '%U' $CRONTAB_FILE)
    current_group=$(stat -Lc '%G' $CRONTAB_FILE)
    
    # Desired permissions, user, and group
    desired_access_permissions="600"
    desired_user="root"
    desired_group="root"
    
    if [[ "$current_access_permissions" == "$desired_access_permissions" && "$current_user" == "$desired_user" && "$current_group" == "$desired_group" ]]; then
        echo "crontab:correct_permissions" >> $RESULT_FILE
        log_message "Crontab permissions are correctly configured."
    else
        echo "crontab:incorrect_permissions" >> $RESULT_FILE
        log_message "Crontab permissions need to be changed."
    fi
}

# Check cron_hourly permissions
check_cron_hourly_permissions() {
    # Check current permissions, user, and group
    current_access_permissions=$(stat -Lc '%a' $CRON_HOURLY_DIR)
    current_user=$(stat -Lc '%U' $CRON_HOURLY_DIR)
    current_group=$(stat -Lc '%G' $CRON_HOURLY_DIR)
    
    # Desired permissions, user, and group
    desired_access_permissions="700"
    desired_user="root"
    desired_group="root"
    
    if [[ "$current_access_permissions" == "$desired_access_permissions" && "$current_user" == "$desired_user" && "$current_group" == "$desired_group" ]]; then
        echo "cron.hourly:correct_permissions" >> $RESULT_FILE
        log_message ""$CRON_HOURLY_DIR" permissions are correctly configured."
    else
        echo "cron.hourly:incorrect_permissions" >> $RESULT_FILE
        log_message ""$CRON_HOURLY_DIR" permissions need to be changed."
    fi
}

# Check cron_daily_permissions
check_cron_daily_permissions() {
    # Check current permissions, user, and group
    current_access_permissions=$(stat -Lc '%a' $CRON_DAILY_DIR)
    current_user=$(stat -Lc '%U' $CRON_DAILY_DIR)
    current_group=$(stat -Lc '%G' $CRON_DAILY_DIR)
    
    # Desired permissions, user, and group
    desired_access_permissions="700"
    desired_user="root"
    desired_group="root"
    
    
    if [[ "$current_access_permissions" == "$desired_access_permissions" && "$current_user" == "$desired_user" && "$current_group" == "$desired_group" ]]; then
        echo "cron.daily:correct_permissions" >> $RESULT_FILE
        log_message ""$CRON_DAILY_DIR" permissions are correctly configured."
    else
        echo "cron.daily:incorrect_permissions" >> $RESULT_FILE
        log_message ""$CRON_DAILY_DIR" permissions need to be changed."
    fi
}

# Check cron_weekly_permissions
check_cron_weekly_permissions() {
    # Check current permissions, user, and group
    current_access_permissions=$(stat -Lc '%a' $CRON_WEEKLY_DIR)
    current_user=$(stat -Lc '%U' $CRON_WEEKLY_DIR)
    current_group=$(stat -Lc '%G' $CRON_WEEKLY_DIR)
    
    # Desired permissions, user, and group
    desired_access_permissions="700"
    desired_user="root"
    desired_group="root"
    
    
    
    if [[ "$current_access_permissions" == "$desired_access_permissions" && "$current_user" == "$desired_user" && "$current_group" == "$desired_group" ]]; then
        echo "cron.weekly:correct_permissions" >> $RESULT_FILE
        log_message ""$CRON_WEEKLY_DIR" permissions are correctly configured."
    else
        echo "cron.weekly:incorrect_permissions" >> $RESULT_FILE
        log_message ""$CRON_WEEKLY_DIR" permissions need to be changed."
    fi
}

# Check cron_monthly_permissions
check_cron_monthly_permissions() {
    # Check current permissions, user, and group
    current_access_permissions=$(stat -Lc '%a' $CRON_MONTHLY_DIR)
    current_user=$(stat -Lc '%U' $CRON_MONTHLY_DIR)
    current_group=$(stat -Lc '%G' $CRON_MONTHLY_DIR)
    
    # Desired permissions, user, and group
    desired_access_permissions="700"
    desired_user="root"
    desired_group="root"
    
    
    
    if [[ "$current_access_permissions" == "$desired_access_permissions" && "$current_user" == "$desired_user" && "$current_group" == "$desired_group" ]]; then
        echo "cron.monthly:correct_permissions" >> $RESULT_FILE
        log_message ""$CRON_MONTHLY_DIR" permissions are correctly configured."
    else
        echo "cron.monthly:incorrect_permissions" >> $RESULT_FILE
        log_message ""$CRON_MONTHLY_DIR" permissions need to be changed."
    fi
}

# Check crond_permissions
check_crond_permissions() {
    # Check current permissions, user, and group
    current_access_permissions=$(stat -Lc '%a' $CROND)
    current_user=$(stat -Lc '%U' $CROND)
    current_group=$(stat -Lc '%G' $CROND)
    
    # Desired permissions, user, and group
    desired_access_permissions="700"
    desired_user="root"
    desired_group="root"
    
   
    
    if [[ "$current_access_permissions" == "$desired_access_permissions" && "$current_user" == "$desired_user" && "$current_group" == "$desired_group" ]]; then
        echo "cron.d:correct_permissions" >> $RESULT_FILE
        log_message ""$CROND" permissions are correctly configured."
    else
        echo "cron.d:incorrect_permissions" >> $RESULT_FILE
        log_message ""$CROND" permissions need to be changed."
    fi
}

# Check if crontab is restricted for authorized users

check_file() {
    local file_path=$1
    local expected_mode=$2

    if [ -e "$file_path" ]; then
        echo "Checking $file_path..."

        # Get file properties
        file_stat=$(stat -Lc 'Access: (%a/%A) Owner: (%U) Group: (%G)' "$file_path")
        echo "$file_stat"

        # Extract mode, owner, and group from stat output
        local mode=$(echo "$file_stat" | awk -F' ' '{print $2}' | cut -d'/' -f1)
        local owner=$(echo "$file_stat" | awk -F' ' '{print $4}')
        local group=$(echo "$file_stat" | awk -F' ' '{print $6}')

        # Check if mode is 0640 or more restrictive
        if [ "$mode" -le "$expected_mode" ] && [ "$owner" = "root" ] && [ "$group" = "root" ]; then
            echo "$file_path is configured correctly."
	    echo "$file_path:correctly configured" >> $RESULT_FILE
        else
            echo "$file_path does not meet the required configuration."
	    echo "$file_path:incorrectly configured" >> $RESULT_FILE
            echo "Expected mode: 0640 or more restrictive, Owner: root, Group: root."
        fi
    else
        echo "$file_path does not exist."
	echo "$file_path:DOES NOT EXIST" >> $RESULT_FILE
    fi
}

# Function to check cron configuration
check_cron_configuration() {
    echo "Checking /etc/cron.allow:"
    check_file "/etc/cron.allow" 640

    echo "Checking /etc/cron.deny:"
    if [ -e "/etc/cron.deny" ]; then
        check_file "/etc/cron.deny" 640
    else
        echo "/etc/cron.deny does not exist, which is acceptable."
    fi
}


if command -v crond > /dev/null 2>&1; then
    log_message "Checking crond status..."
    check_crond_status
    log_message "Checking crontab permissions..."
    check_crontab_permissions
    log_message "Checking cron.hourly permissions..."
    check_cron_hourly_permissions
    log_message "Checking cron.daily permissions..."
    check_cron_daily_permissions
    log_message "Checking cron.weekly permissions..."
    check_cron_weekly_permissions
    log_message "Checking cron.monthly permissions..."
    check_cron_monthly_permissions
    log_message "Checking cron.d permissions..."
    check_crond_permissions
    log_message "Checking if crontab is restricted for authorized users..."
    check_cron_configuration
fi


