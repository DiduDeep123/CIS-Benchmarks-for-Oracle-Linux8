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

#fix chrony installation
fix_chrony() {
 if grep -q "CHRONY:NOT INSTALLED" $RESULT_FILE; then
	read -p "Do you want to install chrony? (y/n)" answer
	if [[ answer = [Yy] ]]; then
	dnf install chrony
	log_message "Chrony is installed."
	fi
fi
}

#fix chrony run as root user
fix_chrony_run_as_root_user() {
config_file="/etc/sysconfig/chronyd"
new_option='OPTIONS="-u chrony"'
if grep -q "CHRONY_NOT_RUN_AS_ROOT_USER:FAIL" $RESULT_FILE; then
	read -p "Do you want to set chrony to not run as root user? (y/n)" answer
	if [[ answer = [Yy] ]]; then
	if grep -q '^OPTIONS=' "$config_file"; then
        
        sed -i 's/^OPTIONS=.*/'"$new_option"'/' "$config_file"
    else
        echo "$new_option" >> "$config_file"
    fi
    
	read -p "Do you want to reload the chronyd.service configuration? (y/n)" answer
	if [[ answer = [Yy] ]]; then
    log_message "Reloading chronyd service configuration..."
    systemctl try-reload-or-restart chronyd.service
	
	else
	log_message "Please reload the chronyd.service configuration to update the settings. "
	
	fi
	fi
fi
}

fix_chrony
fix_chrony_run_as_root_user
