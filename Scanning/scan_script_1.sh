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

    log_message "Checking crond status..."

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
    
    log_message "Checking crontab permissions..."
    
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
    
    log_message "Checking cron.hourly permissions..."
    
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
    
    log_message "Checking cron.daily permissions..."
    
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
    
    log_message "Checking cron.weekly permissions..."
    
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
    
    log_message "Checking cron.monthly permissions..."
    
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
    
    log_message "Checking cron.d permissions..."
    
    if [[ "$current_access_permissions" == "$desired_access_permissions" && "$current_user" == "$desired_user" && "$current_group" == "$desired_group" ]]; then
        echo "cron.d:correct_permissions" >> $RESULT_FILE
        log_message ""$CROND" permissions are correctly configured."
    else
        echo "cron.d:incorrect_permissions" >> $RESULT_FILE
        log_message ""$CROND" permissions need to be changed."
    fi
}


# Check if /tmp is mounted
check_tmp_mount() {
	log_message "Checking if /tmp is mounted..."
	
    mount_info=$(findmnt -nk /tmp)
    expected_filesystem="tmpfs"
    
    if [[ $mount_info == *"$expected_filesystem"* ]]; then
        result="/tmp is correctly mounted: $mount_info"
        echo "/tmp is correctly mounted." >> $RESULT_FILE
        log_message "$result"
    else
        result="/tmp is not correctly mounted: $mount_info"
        echo "/tmp is not correctly mounted." >> $RESULT_FILE
        log_message "$result"
    fi
}

# Check systemd status for /tmp mount
check_systemd_status_tmp() {

	log_message "Checking systemd status for /tmp mount..."
	
    systemd_status=$(systemctl is-enabled tmp.mount)

    if [[ $systemd_status == "generated" ]]; then
        result="systemd is configured to mount /tmp at boot time."
        echo "SYSTEMD TMP.MOUNT: GENERATED" >> $RESULT_FILE 
        log_message "$result"
    elif [[ $systemd_status == "enabled" ]]; then
        result="systemd is configured to mount /tmp at boot time."
        echo "SYSTEMD TMP.MOUNT: ENABLED" >> $RESULT_FILE 
        log_message "$result"
    elif [[ $systemd_status == "disabled" ]]; then
        result="systemd is not configured to mount /tmp at boot time. It is disabled."
        echo "SYSTEMD TMP.MOUNT: DISABLED" >> $RESULT_FILE
        log_message "$result"
    elif [[ $systemd_status == "masked" ]]; then
        result="systemd is not configured to mount /tmp at boot time. It is masked."
        echo "SYSTEMD TMP.MOUNT: MASKED" >> $RESULT_FILE
        log_message "$result"
    else
        result="Unknown systemd status for /tmp: $systemd_status"
        echo "SYSTEMD TMP.MOUNT: UNKNOWN" >> $RESULT_FILE
        log_message "$result"
    fi
}

#Check if /tmp is included in /etc/fstab
check_fstab_for_tmp() {
fstab_file="/etc/fstab"

    # Check if /tmp is listed in /etc/fstab
    tmp_line=$(grep ' /tmp ' "$fstab_file")
    
    if [[ -z "$tmp_line" ]]; then
        log_message "/tmp is not listed in /etc/fstab."
		echo "TMP IN FSTAB: NOT INCLUDED" >> $RESULT_FILE
	else
		log_message "/tmp is listed in /etc/fstab."
		echo "TMP IN FSTAB: INCLUDED" >> $RESULT_FILE
	fi
		
}



# Check if nodev option is set on /tmp partition
check_nodev_option_tmp() {

	log_message "Checking if nodev option is set on /tmp partition..."
	
    # Check if 'nodev' is among the mount options for /tmp
    if findmnt -kn /tmp | grep -q 'nodev'; then
        result="The 'nodev' option is set for /tmp."
        echo "NODEV_OPTION_ON_TMP: SET">> $RESULT_FILE
        log_message "$result"
    else
        result="The 'nodev' option is NOT set for /tmp."
        echo "NODEV_OPTION_ON_TMP: NOT CONFIGURED">> $RESULT_FILE
        log_message "$result"
    fi
}

# Check if nosuid option is set on /tmp partition
check_nosuid_option_tmp() {

	log_message "Checking if nosuid option is set on /tmp partition..."
	
    # Check if 'nosuid' is among the mount options for /tmp
    if findmnt -kn /tmp | grep -q 'nosuid'; then
        result="The 'nosuid' option is set for /tmp."
        echo "NOSUID_OPTION_IN_TMP: SET">> $RESULT_FILE
        log_message "$result"
    else
        result="The 'nosuid' option is NOT set for /tmp."
        echo "NOSUID_OPTION_IN_TMP: NOT CONFIGURED">> $RESULT_FILE
        log_message "$result"
    fi
}

# Check if noexec option is set on /tmp partition
check_noexec_option_tmp() {

	log_message "Checking if noexec option is set on /tmp partition..."
	
    # Check if 'noexec' is among the mount options for /tmp
    if findmnt -kn /tmp | grep -q 'noexec'; then
        result="The 'noexec' option is set for /tmp."
        echo "NOEXEC_OPTION_IN_TMP: SET">> $RESULT_FILE
        log_message "$result"
    else
        result="The 'noexec' option is NOT set for /tmp."
        echo "NOEXEC_OPTION_IN_TMP: NOT CONFIGURED">> $RESULT_FILE
        log_message "$result"
    fi
}

# Check if /dev/shm is a separate partition
check_dev_shm_mount() {
	log_message "Check if /dev/shm is a separate partition..."
	
    mount_info=$(findmnt -kn /dev/shm)
   
    
     if [ -n "$mount_info" ]; then
        result="/dev/shm is correctly mounted: $mount_info"
        echo "DEV SHM IN FSTAB: INCLUDED" >> $RESULT_FILE
        log_message "$result"
    else
        result="/dev/shm is not correctly mounted: $mount_info"
        echo "DEV SHM IN FSTAB: NOT INCLUDED" >> $RESULT_FILE
        log_message "$result"
    fi
}

# Check if nodev option is set on /dev/shm partition
check_nodev_option_dev_shm() {

	log_message "Checking if nodev option is set on /dev/shm partition..."
	
    # Check if 'nodev' is among the mount options for /dev/shm 
    if findmnt -kn /dev/shm | grep -q 'nodev'; then
        result="The 'nodev' option is set for /dev/shm."
        echo "NODEV_OPTION_IN_DEV_SHM: SET">> $RESULT_FILE
        log_message "$result"
    else
        result="The 'nodev' option is NOT set for /dev/shm."
        echo "NODEV_OPTION_IN_DEV_SHM: NOT CONFIGURED">> $RESULT_FILE
        log_message "$result"
    fi
}

# Check if nosuid option is set on /dev/shm partition
check_nosuid_option_dev_shm() {

	log_message "Checking if nosuid option is set on /dev/shm partition..."
	
    # Check if 'nosuid' is among the mount options for /dev/shm 
    if findmnt -kn /tmp | grep -q 'nosuid'; then
        result="The 'nosuid' option is set for /dev/shm ."
        echo "NOSUID_OPTION_IN_DEV_SHM: SET">> $RESULT_FILE
        log_message "$result"
    else
        result="The 'nosuid' option is NOT set for /dev/shm."
        echo "NOSUID_OPTION_IN_DEV_SHM: NOT_CONFIGURED">> $RESULT_FILE
        log_message "$result"
    fi
}

# Check if noexec option is set on /dev/shm partition
check_noexec_option_dev_shm() {

	log_message "Checking if noexec option is set on /dev/shm partition..."
	
    # Check if 'noexec' is among the mount options for /dev/shm
    if findmnt -kn /tmp | grep -q 'noexec'; then
        result="The 'noexec' option is set for /dev/shm."
        echo "NOEXEC_OPTION_IN_DEV_SHM: SET">> $RESULT_FILE
        log_message "$result"
    else
        result="The 'noexec' option is NOT set for /dev/shm."
        echo "NOEXEC_OPTION_IN_DEV_SHM: NOT CONFIGURED">> $RESULT_FILE
        log_message "$result"
    fi
}

# Check if /home is a separate partition
check_home_mount() {
	log_message "Check if /home is a separate partition..."
	
    mount_info=$(findmnt -kn /home)
   
    
     if [ -n "$mount_info" ]; then
        result="/home is correctly mounted: $mount_info"
        echo "HOME: MOUNTED" >> $RESULT_FILE
        log_message "$result"
    else
        result="/home is not correctly mounted: $mount_info"
        echo "HOME: NOT MOUNTED" >> $RESULT_FILE
        log_message "$result"
    fi
}

#Check if /home is included in /etc/fstab
check_fstab_for_home() {
fstab_file="/etc/fstab"

    # Check if /home is listed in /etc/fstab
    tmp_line=$(grep ' /tmp ' "$fstab_file")
    
    if [[ -z "$tmp_line" ]]; then
        log_message "/home is not listed in /etc/fstab."
		echo "HOME IN FSTAB: NOT INCLUDED" >> $RESULT_FILE
	else
		log_message "/tmp is listed in /etc/fstab."
		echo "HOME IN FSTAB: INCLUDED" >> $RESULT_FILE
	fi
		
}


# Check if nodev option is set on /home partition
check_nodev_option_home() {

	log_message "Checking if nodev option is set on /home partition..."
	
    # Check if 'nodev' is among the mount options for /home 
    if findmnt -kn /home | grep -q 'nodev'; then
        result="The 'nodev' option is set for /home."
        echo "NODEV_OPTION_IN_HOME: SET">> $RESULT_FILE
        log_message "$result"
    else
        result="The 'nodev' option is NOT set for /home."
        echo "NODEV_OPTION_IN_HOME: NOT CONFIGURED">> $RESULT_FILE
        log_message "$result"
    fi
}

# Check if nosuid option is set on /home partition
check_nosuid_option_home() {

	log_message "Checking if nosuid option is set on /home partition..."
	
    # Check if 'nosuid' is among the mount options for /home 
    if findmnt -kn /home | grep -q 'nosuid'; then
        result="The 'nosuid' option is set for /home ."
        echo "NOSUID_OPTION_IN_HOME: SET">> $RESULT_FILE
        log_message "$result"
    else
        result="The 'nosuid' option is NOT set for /home."
        echo "NOSUID_OPTION_IN_HOME: NOT CONFIGURED">> $RESULT_FILE
        log_message "$result"
    fi
}

# Check if noexec option is set on /home partition
check_noexec_option_home() {

	log_message "Checking if noexec option is set on /home partition..."
	
    # Check if 'noexec' is among the mount options for /home
    if findmnt -kn /home | grep -q 'noexec'; then
        result="The 'noexec' option is set for /home."
        echo "NOEXEC_OPTION_IN_HOME: SET">> $RESULT_FILE
        log_message "$result"
    else
        result="The 'noexec' option is NOT set for /home."
        echo "NOEXEC_OPTION_IN_HOME: NOT CONFIGURED">> $RESULT_FILE
        log_message "$result"
    fi
}

# Check if /var is a separate partition
check_var_mount() {
	log_message "Check if /var is a separate partition..."
	
    mount_info=$(findmnt -kn /var)
   
    
     if [ -n "$mount_info" ]; then
        result="/var is correctly mounted: $mount_info"
        echo "VAR: MOUNTED" >> $RESULT_FILE
        log_message "$result"
    else
        result="/var is not correctly mounted: $mount_info"
        echo "VAR: NOT MOUNTED" >> $RESULT_FILE
        log_message "$result"
    fi
}

# Check if nodev option is set on /var partition
check_nodev_option_var() {

	log_message "Checking if nodev option is set on /var partition..."
	
    # Check if 'nodev' is among the mount options for /var
    if findmnt -kn /var | grep -q 'nodev'; then
        result="The 'nodev' option is set for /var."
        echo "NODEV_OPTION_IN_VAR: SET">> $RESULT_FILE
        log_message "$result"
    else
        result="The 'nodev' option is NOT set for /var."
        echo "NODEV_OPTION_IN_VAR: NOT CONFIGURED">> $RESULT_FILE
        log_message "$result"
    fi
}

# Check if nosuid option is set on /var partition
check_nosuid_option_var() {

	log_message "Checking if nosuid option is set on /var partition..."
	
    # Check if 'nosuid' is among the mount options for /var 
    if findmnt -kn /var | grep -q 'nosuid'; then
        result="The 'nosuid' option is set for /var."
        echo "NOSUID_OPTION_IN_VAR: SET">> $RESULT_FILE
        log_message "$result"
    else
        result="The 'nosuid' option is NOT set for /var."
        echo "NOSUID_OPTION_IN_VAR: NOT CONFIGURED">> $RESULT_FILE
        log_message "$result"
    fi
}
#Check if /var/tmp is included in /etc/fstab
check_fstab_for_var_tmp() {
fstab_file="/etc/fstab"

    # Check if /var/tmp is listed in /etc/fstab
    tmp_line=$(grep ' /var/tmp ' "$fstab_file")
    
    if [[ -z "$tmp_line" ]]; then
        log_message "/var/tmp is not listed in /etc/fstab."
		echo "VAR TMP IN FSTAB: NOT INCLUDED" >> $RESULT_FILE
	else
		log_message "/tmp is listed in /etc/fstab."
		echo "VAR TMP IN FSTAB: INCLUDED" >> $RESULT_FILE
	fi
		
}



# Check if nodev option is set on /var/tmp partition
check_nodev_option_var_tmp() {

	log_message "Checking if nodev option is set on /var/tmp partition..."
	
    # Check if 'nodev' is among the mount options for /tmp
    if findmnt -kn /var/tmp | grep -q 'nodev'; then
        result="The 'nodev' option is set for /var/tmp."
        echo "NODEV_OPTION_ON_VAR_TMP: SET">> $RESULT_FILE
        log_message "$result"
    else
        result="The 'nodev' option is NOT set for /var/tmp."
        echo "NODEV_OPTION_ON_VAR_TMP: NOT CONFIGURED">> $RESULT_FILE
        log_message "$result"
    fi
}

# Check if nosuid option is set on /var/tmp partition
check_nosuid_option_var_tmp() {

	log_message "Checking if nosuid option is set on /var/tmp partition..."
	
    # Check if 'nosuid' is among the mount options for /var/tmp
    if findmnt -kn /var/tmp | grep -q 'nosuid'; then
        result="The 'nosuid' option is set for /var/tmp."
        echo "NOSUID_OPTION_IN_VAR_TMP: SET">> $RESULT_FILE
        log_message "$result"
    else
        result="The 'nosuid' option is NOT set for /var/tmp."
        echo "NOSUID_OPTION_IN_VAR_TMP: NOT CONFIGURED">> $RESULT_FILE
        log_message "$result"
    fi
}

# Check if noexec option is set on /var/tmp partition
check_noexec_option_var_tmp() {

	log_message "Checking if noexec option is set on /var/tmp partition..."
	
    # Check if 'noexec' is among the mount options for /var/tmp
    if findmnt -kn /var/tmp | grep -q 'noexec'; then
        result="The 'noexec' option is set for /var/tmp."
        echo "NOEXEC_OPTION_IN_VAR_TMP: SET">> $RESULT_FILE
        log_message "$result"
    else
        result="The 'noexec' option is NOT set for /var/tmp."
        echo "NOEXEC_OPTION_IN_VAR_TMP: NOT CONFIGURED">> $RESULT_FILE
        log_message "$result"
    fi
}
check_var_log_mount() {
	log_message "Check if /var/log is a separate partition..."
	
    mount_info=$(findmnt -kn /var/log)
   
    
     if [ -n "$mount_info" ]; then
        result="/var/log is correctly mounted: $mount_info"
        echo "VAR_LOG: MOUNTED" >> $RESULT_FILE
        log_message "$result"
    else
        result="/var/log is not correctly mounted: $mount_info"
        echo "VAR_LOG: NOT MOUNTED" >> $RESULT_FILE
        log_message "$result"
    fi
}

#Check if /var/log is included in /etc/fstab
check_fstab_for_var_tmp() {
fstab_file="/etc/fstab"

    # Check if /var/tmp is listed in /etc/fstab
    tmp_line=$(grep ' /var/log ' "$fstab_file")
    
    if [[ -z "$tmp_line" ]]; then
        log_message "/var/log is not listed in /etc/fstab."
		echo "VAR LOG IN FSTAB: NOT INCLUDED" >> $RESULT_FILE
	else
		log_message "/var/log is listed in /etc/fstab."
		echo "VAR LOG IN FSTAB: INCLUDED" >> $RESULT_FILE
	fi
		
}

# Check if nodev option is set on /var/log partition
check_nodev_option_var_log() {

	log_message "Checking if nodev option is set on /var/log partition..."
	
    # Check if 'nodev' is among the mount options for /var/log 
    if findmnt -kn /home | grep -q 'nodev'; then
        result="The 'nodev' option is set for /var/log."
        echo "NODEV_OPTION_ON_VAR_LOG: SET">> $RESULT_FILE
        log_message "$result"
    else
        result="The 'nodev' option is NOT set for /var/log."
        echo "NODEV_OPTION_ON_VAR_LOG: NOT CONFIGURED">> $RESULT_FILE
        log_message "$result"
    fi
}

# Check if nosuid option is set on /var/log partition
check_nosuid_option_var_log() {

	log_message "Checking if nosuid option is set on /var/log partition..."
	
    # Check if 'nosuid' is among the mount options for /var/log 
    if findmnt -kn /home | grep -q 'nosuid'; then
        result="The 'nosuid' option is set for /var/log ."
        echo "NOSUID_OPTION_ON_VAR_LOG: SET">> $RESULT_FILE
        log_message "$result"
    else
        result="The 'nosuid' option is NOT set for /var/log."
        echo "NOSUID_OPTION_ON_VAR_LOG: NOT CONFIGURED">> $RESULT_FILE
        log_message "$result"
    fi
}

# Check if noexec option is set on /var/log partition
check_noexec_option_var_log() {

	log_message "Checking if noexec option is set on /var/log partition..."
	
    # Check if 'noexec' is among the mount options for /var/log
    if findmnt -kn /home | grep -q 'noexec'; then
        result="The 'noexec' option is set for /var/log."
        echo "NOEXEC_OPTION_IN_VAR_TMP: SET">> $RESULT_FILE
        log_message "$result"
    else
        result="The 'noexec' option is NOT set for /var/log."
        echo "NOEXEC_OPTION_IN_VAR_TMP: NOT CONFIGURED">> $RESULT_FILE
        log_message "$result"
    fi
}

check_var_log_audit_mount() {
	log_message "Check if /var/log/audit is a separate partition..."
	
    mount_info=$(findmnt -kn /var/log/audit)
   
    
     if [ -n "$mount_info" ]; then
        result="/var/log/audit is correctly mounted: $mount_info"
        echo "/var/log/audit is correctly mounted." >> $RESULT_FILE
        log_message "$result"
    else
        result="/var/log/audit is not correctly mounted: $mount_info"
        echo "/var/log/audit is not correctly mounted." >> $RESULT_FILE
        log_message "$result"
    fi
}

# Check if nodev option is set on /var/log/audit partition
check_nodev_option_var_log_audit() {

	log_message "Checking if nodev option is set on /var/log/audit partition..."
	
    # Check if 'nodev' is among the mount options for /var/log/audit 
    if findmnt -kn /home | grep -q 'nodev'; then
        result="The 'nodev' option is set for /var/log/audit."
        echo "nodev_option: $result">> $RESULT_FILE
        log_message "$result"
    else
        result="The 'nodev' option is NOT set for /var/log/audit."
        echo "nodev_option: $result">> $RESULT_FILE
        log_message "$result"
    fi
}

# Check if nosuid option is set on /var/log/audit partition
check_nosuid_option_var_log_audit() {

	log_message "Checking if nosuid option is set on /var/log/audit partition..."
	
    # Check if 'nosuid' is among the mount options for /var/log/audit 
    if findmnt -kn /home | grep -q 'nosuid'; then
        result="The 'nosuid' option is set for /var/log/audit."
        echo "nosuid_option: $result">> $RESULT_FILE
        log_message "$result"
    else
        result="The 'nosuid' option is NOT set for /var/log/audit."
        echo "nosuid_option: $result">> $RESULT_FILE
        log_message "$result"
    fi
}

# Check if noexec option is set on /var/log/audit partition
check_noexec_option_var_log_audit() {

	log_message "Checking if noexec option is set on /var/log/audit partition..."
	
    # Check if 'noexec' is among the mount options for /var/log/audit
    if findmnt -kn /home | grep -q 'noexec'; then
        result="The 'noexec' option is set for /var/log/audit."
        echo "noexec_option: $result">> $RESULT_FILE
        log_message "$result"
    else
        result="The 'noexec' option is NOT set for /var/log/audit."
        echo "noexec_option: $result">> $RESULT_FILE
        log_message "$result"
    fi
}
#Global gpg check
global_gpgcheck() {
    dnf_conf_file="/etc/dnf/dnf.conf"

    log_message "Checking gpgcheck setting in $dnf_conf_file..."
    current_gpgcheck=$(grep -P '^gpgcheck\s*=' "$dnf_conf_file" | awk -F= '{print $2}' | tr -d '[:space:]')

    if [[ "$current_gpgcheck" == "1" ]]; then
        log_message "gpgcheck is already set to 1 in $dnf_conf_file."
		echo "gpg_check:SUCCESS">> $RESULT_FILE
    else
        log_message "gpgcheck is not set to 1 in $dnf_conf_file. Current value: $current_gpgcheck"
        echo "gpg_check:FAILED">> $RESULT_FILE
    fi
	
	if  grep -Prsq -- '^\h*gpgcheck\h*=\h*(0|[2-9]|[1-9][0-9]+|[a-zA-Z_]+)\b' /etc/yum.repos.d/; then
		log_message "gpgcheck is already set to 1 in $dnf_conf_file."
	fi
}


# verify if the bootloader password is set
check_bootloader_password() {
    grub_password_file=$(find /boot -type f -name 'user.cfg' ! -empty 2>/dev/null)

    if [ -f "$grub_password_file" ]; then
        
        password_setting=$(awk -F= '/^\s*GRUB2_PASSWORD=/ {print $2}' "$grub_password_file")

        if [[ "$password_setting" =~ ^grub\.pbkdf2\.sha512 ]]; then
			log_message "bootloader password is already set."
            echo "Bootloader_password_set:SUCCESS">> $RESULT_FILE
            
        else
            log_message "bootloader password is not set."
			echo "Bootloader_password_set:FAILED">> $RESULT_FILE
            
        fi
    else
        log_message "GRUB configuration file not found."
		echo "configuration file: NOT FOUND">> $RESULT_FILE
        return 2
    fi
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

check_crypto_policy() {
    log_message "Checking if system wide crypto policy is not set to legacy..."

    
    if grep -Piq '^\h*LEGACY\b' /etc/crypto-policies/config; then
        result="System wide crypto policy is not set to legacy."
        echo "crypto policy:SUCCESS" >> "$RESULT_FILE"
    else
        result="System wide crypto policy is set to legacy."
        echo "crypto policy:LEGACY" >> "$RESULT_FILE"
    fi
    
    log_message "$result"
}

check_crypto_policy_sha1_hash() {
    log_message "Checking if system wide crypto policy disables sha1 hash and signature support..."

    
    if grep -Piq -- '^\h*(hash|sign)\h*=\h*([^\n\r#]+)?-sha1\b' /etc/crypto-policies/state/CURRENT.pol; then
        result="System wide crypto policy disables sha1 hash and signature support."
        echo "crypto policy sha1 hash :DISABLED" >> "$RESULT_FILE"
    else
        result="System wide crypto policy has sha1 hash and signature support."
        echo "crypto policy sha1 hash :NOT DISABLED" >> "$RESULT_FILE"
    fi
    
    log_message "$result"
}

check_crypto_policy_MACS() {
    log_message "Checking if system wide crypto policy disables mac less than 128 bits..."

    
    if grep -Piq -- '^\h*mac\h*=\h*([^#\n\r]+)?-64\b' /etc/crypto-policies/state/CURRENT.pol; then
        result="System wide crypto policy disables mac less than 128 bits."
        echo "crypto policy mac :DISABLED" >> "$RESULT_FILE"
    else
        result="System wide crypto policy does not disable mac less than 128 bits."
        echo "crypto policy mac :NOT DISABLED" >> "$RESULT_FILE"
    fi
    
    log_message "$result"
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

check_GDM() {
    package="gdm"

    if rpm -q "$package" > /dev/null 2>&1; then
        log_message "$package is installed."
		echo "GDM:INSTALLED" >> $RESULT_FILE
        
    else
        log_message "$package is not installed."
		echo "GDM:NOT INSTALLED" >> $RESULT_FILE
    fi
}


check_xdmcp() {
    config_file="/etc/gdm/custom.conf"

    log_message "Checking XDMCP is not enabled..."

    
    if grep -Eis '^\s*Enable\s*=\s*true' "$config_file" > /dev/null; then
        result="XDMCP is not enabled."
        echo "XDCMP: NOT ENABLED" >> "$RESULT_FILE"
    else
        result="XDMCP is enabled."
        echo "XDCMP: ENABLED" >> "$RESULT_FILE"
    fi

    log_message "$result"
}


check_chrony(){
package="chrony"

	log_message "Checking if chrony is installed..."

if rpm -q "$package" > /dev/null 2>&1; then
	log_message "$package is installed."
	echo "CHRONY:INSTALLED" >> "$RESULT_FILE"
		
else
	echo "$package is not installed."
	echo "CHRONY:NOT INSTALLED" >> "$RESULT_FILE"
fi
}

check_chrony_configuration(){

	config_files="/etc/chrony.conf /etc/chrony.d/*"
	remote_server_pattern='^\h*(server|pool)\h+[^#\n\r]+'
	config_found="false"
	
	log_message "Checking chrony configuration for remote servers..."
	
	for file in $config_files; do 
	if [ -f "$file" ]; then
		if grep -Pq -- "$remote_server_pattern" "$file"; then
			log_message "chrony is configured in "$file"."
			config_found=true
		fi
	fi 
	done
	
if [ "$config_found" = "false" ]; then
	log_message " No remote servers are configured for time synchronization."
	echo "To configure remote servers, edit /etc/chrony.conf or files in /etc/chrony.d/ and add server or pool entries."
	fi
}

check_chrony_root_user() {
    local chrony_config="/etc/sysconfig/chronyd"
    local pattern='^\h*OPTIONS="?\h+-u\h+root\b'

    log_message "Checking if Chrony is not configured to run as root..."

    if grep -Psi -- "$pattern" "$chrony_config" > /dev/null; then
        result="Chrony is configured to run as the root user."
        echo "CHRONY_NOT_RUN_AS_ROOT_USER:FAIL" >> "$RESULT_FILE"
    else
        result="Chrony is not configured to run as the root user."
        echo "CHRONY_NOT_RUN_AS_ROOT_USER:SUCCESS" >> "$RESULT_FILE"
    fi

    log_message "$result"
}

check_config_special_purpose_services() {
    packages=("autofs" "avahi" "dhcp-server" "bind" "dnsmasq" "samba" "vsftpd" "dovecot cyrus-imapd" "nfs-utils" "ypserv" "cups" "rpcbind" "rsync-daemon" "net-snmp" "telnet-server" "tftp-server" "squid" "httpd nginx" "xinetd")
    services=("autofs.service" "avahi-daemon.socket avahi-daemon.service" "dhcpd.service dhcpd6.service" "named.service" "dnsmasq.service" "smb.service" "vsftpd.service" "dovecot.socket dovecot.service cyrus-imapd.service" "nfs-server.service" "ypserv.service" "cups.socket cups.service" "rpcbind.socket rpcbind.service" "rsyncd.socket rsyncd.service" "snmpd.service" "telnet.socket" "tftp.socket tftp.service" "squid.service" "httpd.socket httpd.service nginx.service" "xinetd.service")
    
    for i in "${!packages[@]}"; do
        package="${packages[$i]}"
        service_list="${services[$i]}"

        if rpm -q "$package" > /dev/null 2>&1; then
            log_message "$package is installed."
			echo ""$package"(SPECIAL PURPOSE SERVICE):INSTALLED" >> "$RESULT_FILE"
			

            for service in $service_list; do
                if systemctl is-enabled "$service" | grep -q 'enabled'; then
                    log_message "$service is enabled."
					echo ""$service"(SPECIAL PURPOSE SERVICE):ENABLED" >> "$RESULT_FILE"
                           
                else
                    log_message "$service is not enabled."
					echo ""$service"(SPECIAL PURPOSE SERVICE):NOT ENABLED" >> "$RESULT_FILE"
                fi

                if systemctl is-active "$service" | grep -q '^active'; then
                    log_message "$service is active."
					echo ""$service"(SPECIAL PURPOSE SERVICE):ACTIVE" >> "$RESULT_FILE"
                   
                else
                    log_message "$service is not active."
					echo ""$service"(SPECIAL PURPOSE SERVICE):NOT ACTIVE" >> "$RESULT_FILE"
                fi
            done
        else
            log_message "$package is not installed."
			echo ""$package"(SPECIAL PURPOSE SERVICE):NOT INSTALLED" >> "$RESULT_FILE"
        fi
    done
}

check_xorg_x11_server_common() {
    package="xorg-x11-server-common"

    if rpm -q "$package" > /dev/null 2>&1; then
        log_message "$package is installed."
		echo ""$package"(SPECIAL PURPOSE SERVICE):INSTALLED" >> "$RESULT_FILE"
        
    else
        log_message "$package is not installed."
		echo ""$package"(SPECIAL PURPOSE SERVICE):NOT INSTALLED" >> "$RESULT_FILE"
    fi
}

check_config_service_clients() {
    packages=("ftp" "openldap-clients" "ypbind" "telnet" "tftp" )
    
    for i in "${!packages[@]}"; do
        package="${packages[$i]}"
       

        if rpm -q "$package" > /dev/null 2>&1; then
            log_message "$package is installed."
			echo ""$package":INSTALLED" >> "$RESULT_FILE"
			

        else
            log_message "$package is not installed."
			echo ""$package":NOT INSTALLED" >> "$RESULT_FILE"
        fi
    done
}

check_ipv6_status() {


    log_message "Checking IPv6 status..."

    if grep -Pqs '^\s*0\b' /sys/module/ipv6/parameters/disable; then
        ipv6_status="IPv6 is disabled"
    else
        ipv6_status="IPv6 is enabled"
    fi
	
	log_message "$ipv6_status"
    echo "IPv6 status:$ipv6_status" >> $RESULT_FILE
}

check_config_bluetooth() {
    package="bluez"
    service="bluetooth.service"
    

        if rpm -q "$package" > /dev/null 2>&1; then
            log_message "$package is installed."
			echo "BLUEZ:INSTALLED" >> "$RESULT_FILE"
                if systemctl is-enabled "$service" | grep -q 'enabled'; then
                    log_message "$service is enabled."
					echo "$service:ENABLED" >> "$RESULT_FILE"
                    
                else
                    log_message "$service is not enabled."
					echo "$service:NOT ENABLED" >> "$RESULT_FILE"
                fi

                if systemctl is-active "$service" | grep -q '^active'; then
                    log_message "$service is active."
					echo "$service:ACTIVE" >> "$RESULT_FILE"
                    
                   
                else
                    log_message "$service is not active."
					echo "$service:NOT ACTIVE" >> "$RESULT_FILE"
                fi
            
        else
            log_message "$package is not installed."
			echo "BLUEZ:NOT INSTALLED" >> "$RESULT_FILE"
			
        fi
   
}

check_nftables(){
package="nftables"

	log_message "Checking if nftables is installed..."

if rpm -q "$package" > /dev/null 2>&1; then
	log_message "$package is installed."
	echo "nftables:INSTALLED" >> "$RESULT_FILE"
		
else
	echo "package is not installed."
	echo "nftables:NOT INSTALLED" >> "$RESULT_FILE"
fi
}

check_nft_base_chains() {
    log_message "Checking nftables base chains..."

    # Define the commands to check for base chains
    input_chain_check='type filter hook input'
    forward_chain_check='type filter hook forward'
    output_chain_check='type filter hook output'

    # Run nft command and capture output
    nft_output=$(nft list ruleset)

    # Check for INPUT filter hook
    if echo "$nft_output" | grep -q "$input_chain_check"; then
        log_message "Base chain for INPUT filter hook exists."
        echo "INPUT_FILTER_HOOK:EXISTS" >> "$RESULT_FILE"
    else
        log_message "Base chain for INPUT filter hook does not exist."
        echo "INPUT_FILTER_HOOK:NOT_EXISTS" >> "$RESULT_FILE"
    fi

    # Check for FORWARD filter hook
    if echo "$nft_output" | grep -q "$forward_chain_check"; then
        log_message "Base chain for FORWARD filter hook exists."
        echo "FORWARD_FILTER_HOOK:EXISTS" >> "$RESULT_FILE"
    else
        log_message "Base chain for FORWARD filter hook does not exist."
        echo "FORWARD_FILTER_HOOK:NOT_EXISTS" >> "$RESULT_FILE"
    fi

    # Check for OUTPUT filter hook
    if echo "$nft_output" | grep -q "$output_chain_check"; then
        log_message "Base chain for OUTPUT filter hook exists."
        echo "OUTPUT_FILTER_HOOK:EXISTS" >> "$RESULT_FILE"
    else
        log_message "Base chain for OUTPUT filter hook does not exist."
        echo "OUTPUT_FILTER_HOOK:NOT_EXISTS" >> "$RESULT_FILE"
    fi
}

check_nftables_rules() {
    log_message "Checking nftables rules ..."

    # Check if nftables service is enabled
    if systemctl is-enabled nftables.service | grep -q 'enabled'; then
        log_message "nftables service is enabled."

        # Extract nftables rules related to established connections
        nft_output=$(nft list ruleset | awk '/hook input/,/}/')

        # Define expected rules
        expected_rules=(
            "ip protocol tcp ct state established accept"
            "ip protocol udp ct state established accept"
            "ip protocol icmp ct state established accept"
        )

        # Check if each expected rule exists
        all_rules_present=true
        for rule in "${expected_rules[@]}"; do
            if echo "$nft_output" | grep -q "$rule"; then
                log_message "Rule for '$rule' is present."
                echo "RULE_PRESENT:$rule" >> "$RESULT_FILE"
            else
                log_message "Rule for '$rule' is missing."
                echo "RULE_MISSING:$rule" >> "$RESULT_FILE"
                all_rules_present=false
            fi
        done

        # Final result
        if [ "$all_rules_present" = true ]; then
            log_message "All expected rules for established connections are present."
            echo "ESTABLISHED_CONNECTIONS:ALL_RULES_PRESENT" >> "$RESULT_FILE"
        else
            log_message "Some expected rules for established connections are missing."
            echo "ESTABLISHED_CONNECTIONS:SOME_RULES_MISSING" >> "$RESULT_FILE"
        fi

    else
        log_message "nftables service is not enabled."
        echo "NFTABLES_SERVICE:NOT_ENABLED" >> "$RESULT_FILE"
    fi
}


check_nftables_base_chains_policy() {
    log_message "Checking nftables base chains policy..."

    # Check if nftables service is enabled
    if systemctl --quiet is-enabled nftables.service; then
        log_message "nftables service is enabled."

        # Check INPUT chain policy
        input_policy=$(nft list ruleset | awk '/hook input/,/}/' | grep -v 'policy drop')
        if [ -z "$input_policy" ]; then
            log_message "Base chain for INPUT hook has a policy of DROP."
            echo "INPUT_CHAIN_POLICY:DROP" >> "$RESULT_FILE"
        else
            log_message "Base chain for INPUT hook does not have a policy of DROP."
            echo "INPUT_CHAIN_POLICY:NOT DROP" >> "$RESULT_FILE"
        fi

        # Check FORWARD chain policy
        forward_policy=$(nft list ruleset | awk '/hook forward/,/}/' | grep -v 'policy drop')
        if [ -z "$forward_policy" ]; then
            log_message "Base chain for FORWARD hook has a policy of DROP or is correctly configured."
            echo "FORWARD_CHAIN_POLICY:DROP" >> "$RESULT_FILE"
        else
            log_message "Base chain for FORWARD hook does not have a policy of DROP."
            echo "FORWARD_CHAIN_POLICY:NOT DROP" >> "$RESULT_FILE"
        fi

    else
        log_message "nftables service is not enabled."
        echo "NFTABLES_SERVICE:NOT_ENABLED" >> "$RESULT_FILE"
    fi
}























log_message "Starting scan..."

check_crond_status
check_crontab_permissions
check_cron_hourly_permissions
check_cron_daily_permissions
check_cron_weekly_permissions
check_cron_monthly_permissions
check_crond_permissions
check_tmp_mount
check_systemd_status_tmp
check_fstab_for_tmp
check_nodev_option_tmp
check_nosuid_option_tmp
check_noexec_option_tmp
check_dev_shm_mount
check_nodev_option_dev_shm
check_nosuid_option_dev_shm
check_noexec_option_dev_shm
check_home_mount
check_nodev_option_home
check_nosuid_option_home
check_noexec_option_home
check_var_mount
check_nodev_option_var
check_nosuid_option_var
check_var_log_mount
check_nodev_option_var_log
check_nosuid_option_var_log
check_noexec_option_var_log
check_var_log_audit_mount
check_nodev_option_var_log_audit
check_nosuid_option_var_log_audit
check_noexec_option_var_log_audit
global_gpgcheck
check_bootloader_password
check_SELinux
check_SELinux_not_disabled
check_selinux_policy
selinux_mode
check_unconfined_services
check_mcstrans
check_setroubleshoot
check_crypto_policy
check_crypto_policy_sha1_hash
check_crypto_policy_MACS
check_motd
check_local_login_warning
check_remote_login_warning
check_etc_motd_permissions
check_etc_issue_permissions
check_etc_issue_net_permissions
check_GDM
check_xdmcp
check_chrony
check_chrony_configuration
check_chrony_root_user
check_config_special_purpose_services
check_xorg_x11_server_common
check_config_service_clients
check_ipv6_status
check_config_bluetooth
check_nft_base_chains
check_nftables_rules
check_nftables_base_chains_policy


