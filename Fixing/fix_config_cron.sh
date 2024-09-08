#!/usr/bin/bash

LOG_FILE="/var/log/hardening_fix.log"
RESULT_FILE="/var/tmp/scan_results.txt"
CRONTAB_FILE="/etc/crontab"
CRON_HOURLY_DIR="/etc/cron.hourly/"
CRON_DAILY_DIR="/etc/cron.daily/"
CRON_WEEKLY_DIR="/etc/cron.weekly/"
CRON_MONTHLY_DIR="/etc/cron.monthly"
CROND="/etc/cron.d"
FSTAB_FILE="/etc/fstab"

# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $LOG_FILE
}

# Fix crond status
fix_crond_status() {
    if grep -q "crond:not_enabled_or_not_active" "$RESULT_FILE"; then
        read -p "Do you want to enable crond? (y/n): " answer
        if [[ "$answer" =[Yy] ]]; then
            systemctl unmask crond
            
            log_message "Starting crond..."
            systemctl start crond
            log_message "crond has been started."
            
            log_message "Enabling crond..."
            systemctl --now enable crond
            log_message "crond has been enabled."
        else
            log_message "User chose not to enable crond."
        fi
    fi
}

# Fix crontab file permissions
fix_crontab_permissions() {
    if grep -q "crontab:incorrect_permissions" "$RESULT_FILE"; then
        read -p "Do you want to change crontab permissions? (y/n): " answer
        if [[ "$answer" =[Yy] ]]; then
            log_message "Applying remediation steps to change crontab permissions..."
            chown root:root "$CRONTAB_FILE"
            chmod og-rwx "$CRONTAB_FILE"
            log_message "Crontab permissions have been changed."
        else
            log_message "User chose not to change crontab permissions."
        fi
    fi
}

# Fix cron.hourly permissions
fix_cron_hourly_permissions() {
    if grep -q "cron.hourly:incorrect_permissions" "$RESULT_FILE"; then
        read -p "Do you want to change cron.hourly permissions? (y/n): " answer
        if [[ "$answer" =[Yy] ]]; then
            log_message "Applying remediation steps to change cron.hourly permissions..."
            chown root:root "$CRON_HOURLY_DIR"
            chmod og-rwx "$CRON_HOURLY_DIR"
            log_message "Cron.hourly permissions have been changed."
        else
            log_message "User chose not to change cron.hourly permissions."
        fi
    fi
}

# Fix cron.daily permissions
fix_cron_daily_permissions() {
    if grep -q "cron.daily:incorrect_permissions" "$RESULT_FILE"; then
        read -p "Do you want to change cron.daily permissions? (y/n): " answer
        if [[ "$answer" =[Yy] ]]; then
            log_message "Applying remediation steps to change cron.daily permissions..."
            chown root:root "$CRON_DAILY_DIR"
            chmod og-rwx "$CRON_DAILY_DIR"
            log_message "Cron.daily permissions have been changed."
        else
            log_message "User chose not to change cron.daily permissions."
        fi
    fi
}

# Fix cron.weekly permissions
fix_cron_weekly_permissions() {
    if grep -q "cron.weekly:incorrect_permissions" "$RESULT_FILE"; then
        read -p "Do you want to change cron.weekly permissions? (y/n): " answer
        if [[ "$answer" =[Yy] ]]; then
            log_message "Applying remediation steps to change cron.weekly permissions..."
            chown root:root "$CRON_WEEKLY_DIR"
            chmod og-rwx "$CRON_WEEKLY_DIR"
            log_message "Cron.weekly permissions have been changed."
        else
            log_message "User chose not to change cron.weekly permissions."
        fi
    fi
}

# Fix cron.monthly permissions
fix_cron_monthly_permissions() {
    if grep -q "cron.monthly:incorrect_permissions" "$RESULT_FILE"; then
        read -p "Do you want to change cron.monthly permissions? (y/n): " answer
        if [[ "$answer" =[Yy] ]]; then
            log_message "Applying remediation steps to change cron.monthly permissions..."
            chown root:root "$CRON_MONTHLY_DIR"
            chmod og-rwx "$CRON_MONTHLY_DIR"
            log_message "Cron.monthly permissions have been changed."
        else
            log_message "User chose not to change cron.monthly permissions."
        fi
    fi
}

# Fix cron.d permissions
fix_crond_permissions() {
    if grep -q "cron.d:incorrect_permissions" "$RESULT_FILE"; then
        read -p "Do you want to change cron.d permissions? (y/n): " answer
        if [[ "$answer" =[Yy] ]]; then
            log_message "Applying remediation steps to change cron.d permissions..."
            chown root:root "$CROND"
            chmod og-rwx "$CROND"
            log_message "Cron.d permissions have been changed."
        else
            log_message "User chose not to change cron.d permissions."
        fi
    fi
}

# Function to remediate /etc/cron.allow
fix_cron_allow() {
    local file_path="/etc/cron.allow"
    if grep -q "/etc/cron.allow:incorrectly configured" "$RESULT_FILE" || grep -q "/etc/cron.allow:DOES NOT EXIST" "$RESULT_FILE"; then
        read -p "Do you want to reconfigure /etc/cron.allow? (y/n): " answer
        if [[ "$answer" =[Yy] ]]; then
            if ! [ -e "$file_path" ]; then
                touch "$file_path"
            fi
            chown root:root "$file_path"
            chmod 640 "$file_path"
            log_message "Reconfigured /etc/cron.allow."
        else
            log_message "User chose not to reconfigure /etc/cron.allow."
        fi
    fi
}

# Function to remediate /etc/cron.deny
fix_cron_deny() {
    local file_path="/etc/cron.deny"
    if grep -q "/etc/cron.deny:incorrectly configured" "$RESULT_FILE"; then
        read -p "Do you want to reconfigure /etc/cron.deny? (y/n): " answer
        if [[ "$answer" =[Yy] ]]; then
            if [ -e "$file_path" ]; then
                chown root:root "$file_path"
                chmod 640 "$file_path"
                log_message "$file_path has been remediated."
            else
                log_message "$file_path does not exist. No remediation needed."
            fi
        else
            log_message "User chose not to reconfigure /etc/cron.deny."
        fi
    fi
}

if command -v crond > /dev/null 2>&1; then
    fix_crond_status
    fix_crontab_permissions
    fix_cron_hourly_permissions
    fix_cron_daily_permissions
    fix_cron_weekly_permissions
    fix_cron_monthly_permissions
    fix_cron_allow
    fix_cron_deny
fi
