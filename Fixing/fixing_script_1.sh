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
    if grep -q "crond:not_enabled_or_not_active" $RESULT_FILE; then
	read -p "Do you want to enable crond? (y/n)" answer
	if [[ "$answer" = [Yy] ]]; then
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
    if grep -q "crontab:incorrect_permissions" $RESULT_FILE; then
	read -p "Do you want to change crontab permissions? (y/n)" answer
	if [[ "$answer" = [Yy] ]]; then
        log_message "Applying remediation steps to change crontab permissions..."
        chown root:root $CRONTAB_FILE
        chmod og-rwx $CRONTAB_FILE
        log_message "Crontab permissions have been changed."
    else
		log_message "User chose not to change crontab permissions."
    fi
	fi
}

# Fix cron_hourly_permissions
fix_cron_hourly_permissions() {
	if grep -q "cron.hourly:incorrect_permissions" $RESULT_FILE; then
	read -p "Do you want to change cron.hourly permissions? (y/n)" answer
	if [[ "$answer" = [Yy] ]]; then
        log_message "Applying remediation steps to change cron.hourly permissions..."
        chown root:root $CRON_HOURLY_DIR
        chmod og-rwx $CRON_HOURLY_DIR
        log_message "Cron.hourly permissions have been changed."
       
	else
        log_message "User chose not to change cron.hourly permissions."
    fi
	fi
 }
 
 #Fix cron_daily_permissions
 fix_cron_daily_permissions() {
	if grep -q "cron.daily:incorrect_permissions" $RESULT_FILE; then
	read -p "Do you want to change cron.daily permissions? (y/n)" answer
	if [[ "$answer" = [Yy] ]]; then
        log_message "Applying remediation steps to change cron.daily permissions..."
        chown root:root $CRON_DAILY_DIR
        chmod og-rwx $CRON_DAILY_DIR
        log_message "Cron.daily permissions have been changed."
       
	else
        log_message "User chose not to change cron.daily permissions."
    fi
	fi
 
 }
 
#Fix cron_weekly_permissions
 fix_cron_weekly_permissions() {
	if grep -q "cron.weekly:incorrect_permissions" $RESULT_FILE; then
	read -p "Do you want to change cron.weekly permissions? (y/n)" answer
	if [[ "$answer" = [Yy] ]]; then
        log_message "Applying remediation steps to change cron.weekly permissions..."
        chown root:root $CRON_WEEKLY_DIR
        chmod og-rwx $CRON_WEEKLY_DIR
        log_message "Cron.weekly permissions have been changed."
       
	else
        log_message "User chose not to change cron.weekly permissions."
    fi
 fi
 }
 
 #Fix cron_monthly_permissions
 fix_cron_monthly_permissions() {
	if grep -q "cron.monthly:incorrect_permissions" $RESULT_FILE; then
	read -p "Do you want to change cron.monthly permissions? (y/n)" answer
	if [[ "$answer" = [Yy] ]]; then
        log_message "Applying remediation steps to change cron.monthly permissions..."
        chown root:root $CRON_MONTHLY_DIR
        chmod og-rwx $CRON_MONTHLY_DIR
        log_message "Cron.monthly permissions have been changed."
       
	else
        log_message "User chose not to change cron.monthly permissions."
    fi
 fi
 }
 
 
 #Fix cron_d_permissions
fix_crond_permissions() {
	if grep -q "cron.d:incorrect_permissions" $RESULT_FILE; then
	read -p "Do you want to change cron.d permissions? (y/n)" answer
	if [[ "$answer" = [Yy] ]]; then
        log_message "Applying remediation steps to change cron.d permissions..."
        chown root:root $CROND
        chmod og-rwx $CROND
        log_message "Cron.d permissions have been changed."
       
	else
        log_message "User chose not to change cron.d permissions."
    fi
 fi
 }
 
#Fix /tmp will be mounted at boot time
fix_systemd_status_tmp() {
	if grep -qE '(SYSTEMD TMP.MOUNT: DISABLED|SYSTEMD TMP.MOUNT: MASKED|SYSTEMD TMP.MOUNT: UNKNOWN)'  $RESULT_FILE; then
	read -p "Do you want to configure systemd to ensure that /tmp is mounted at boot time? (y/n)" answer
	if [[ "$answer" = [Yy] ]]; then
        log_message "Applying remediation steps to ensure /tmp is mounted at boot time..."
        systemctl unmask tmp.mount
        log_message "/tmp is set to mount at boot time."
		log_message "For specific configuration requirements of the /tmp mount for your environment, modify /etc/fstab."
       
	else
        log_message "User chose not to change systemd to ensure /tmp is mounted at boot time."
    fi
fi
}


# Function to update /etc/fstab for /tmp mount options
update_fstab_for_tmp() {
    fstab_file="/etc/fstab"

    # Check if /tmp is listed in /etc/fstab
    tmp_line=$(grep ' /tmp ' "$fstab_file")
    
    if grep -q "TMP IN FSTAB: NOT INCLUDED" $RESULT_FILE; then
        read -p "Do you want to include a new entry for /tmp in /etc/fstab? (y/n)" answer
		if [[ "$answer" = [Yy] ]]; then
        log_message "Adding new entry for /tmp in /etc/fstab..."
		read -p "Enter the device:" device
		read -p "Enter the required file system type:" fstype ##check if the entered file system is valid
	
        echo "<device> /tmp <fstype> defaults,rw,nosuid,nodev,noexec 0 0" >> "$fstab_file"
        
        log_message "Added entry for /tmp in /etc/fstab."
   
    fi
	fi

}

# Function to remount /tmp with updated options
remount_tmp() {
    log_message "Remounting /tmp with updated options..."
    sudo mount -o remount /tmp
    log_message "/tmp remounted with updated options."
}





#Fix options set on /tmp partition
fix_tmp_partition_options() {
	# Backup the original fstab file
    sudo cp "$FSTAB_FILE" "$FSTAB_FILE.bak"
	if grep -q "TMP IN FSTAB: INCLUDED"  $RESULT_FILE; then
	if grep -q "NODEV_OPTION_ON_TMP: NOT CONFIGURED" $RESULT_FILE; then
	read -p "Do you want to set nodev option on /tmp? (y/n)" answer
	if [[ "$answer" = [Yy] ]];then
		log_message "Applying remediation steps to ensure nodev option is set on /tmp ..."
		

        # Update the /tmp line to include nodev
        sudo sed -i '/ \/tmp / s/^\([^#].* \)\(defaults[^ ]*\)/\1\2,nodev/' "$FSTAB_FILE"

        log_message "/etc/fstab updated with 'nodev' option for /tmp."
	fi
	fi
	
	if grep -q "NOSUID_OPTION_IN_TMP: NOT CONFIGURED" $RESULT_FILE; then
	read -p "Do you want to set nosuid option on /tmp? (y/n)" answer
	if [[ "$answer" = [Yy] ]];then
		log_message "Applying remediation steps to ensure nosuid option is set on /tmp ..."
		

        # Update the /tmp line to include nosuid
		sudo sed -i '/ \/tmp / s/^\([^#].* \)\(defaults[^ ]*\)/\1\2,nosuid/' "$FSTAB_FILE"

        log_message "/etc/fstab updated with 'nosuid' option for /tmp."
	fi
	fi
	
	if grep -q "NOEXEC_OPTION_IN_TMP: NOT CONFIGURED" $RESULT_FILE; then
	read -p "Do you want to set noexec option on /tmp? (y/n)" answer
	if [[ "$answer" = [Yy] ]];then
		log_message "Applying remediation steps to ensure noexec option is set on /tmp ..."
		

        # Update the /tmp line to include noexec
		sudo sed -i '/ \/tmp / s/^\([^#].* \)\(defaults[^ ]*\)/\1\2,noexec/' "$FSTAB_FILE"

        log_message "/etc/fstab updated with 'noexec' option for /tmp."
	fi
	fi
	
remount_tmp			
fi
} 


update_fstab_for_dev_shm() {
    fstab_file="/etc/fstab"

    # Check if /tmp is listed in /etc/fstab
    tmp_line=$(grep ' /dev/shm ' "$fstab_file")
    
    if grep -q "DEV SHM IN FSTAB: NOT INCLUDED" $RESULT_FILE; then
        read -p "Do you want to include a new entry for /dev/shm in /etc/fstab? (y/n)" answer
		if [[ "$answer" = [Yy] ]]; then
        log_message "Adding new entry for /dev/shm in /etc/fstab..."
		read -p "Enter the device:" device
		read -p "Enter the required file system type:" fstype
	
        echo "<device> /dev/shm <fstype> defaults,rw,nosuid,nodev,noexec 0 0" >> "$fstab_file"
        
        log_message "Added entry for /dev/shm in /etc/fstab."
   
    fi
	fi
}

# Function to remount /dev/shm with updated options
remount_dev_shm() {
    log_message "Remounting /dev/shm with updated options..."
    sudo mount -o remount /dev/shm
    log_message "/dev/shm remounted with updated options."
}



#Fix options set on /dev/shm partition
fix_dev_shm_partition_options() {
	if grep -q "DEV SHM IN FSTAB: INCLUDED"  $RESULT_FILE; then
	if grep -q "NODEV_OPTION_IN_DEV_SHM: NOT CONFIGURED" $RESULT_FILE; then
	read -p "Do you want to set nodev option on /dev/shm? (y/n)" answer
	if [[ "$answer" = [Yy] ]];then
		log_message "Applying remediation steps to ensure nodev option is set on /dev/shm ..."
		

        # Update the /dev/shm line to include nodev
        sudo sed -i '/ \/dev/shm / s/^\([^#].* \)\(defaults[^ ]*\)/\1\2,nodev/' "$FSTAB_FILE"

        log_message "/etc/fstab updated with 'nodev' option for /dev/shm."
	fi
	fi
	
	if grep -q "NOSUID_OPTION_IN_DEV_SHM: NOT CONFIGURED" $RESULT_FILE; then
	read -p "Do you want to set nosuid option on /dev/shm? (y/n)" answer
	if [[ "$answer" = [Yy] ]];then
		log_message "Applying remediation steps to ensure nosuid option is set on /dev/shm ..."
		

        # Update the /tmp line to include nosuid
		sudo sed -i '/ \/dev/shm / s/^\([^#].* \)\(defaults[^ ]*\)/\1\2,nosuid/' "$FSTAB_FILE"

        log_message "/etc/fstab updated with 'nosuid' option for /dev/shm."
	fi
	fi
	
	if grep -q "NOEXEC_OPTION_IN_TMP: NOT CONFIGURED" $RESULT_FILE; then
	read -p "Do you want to set noexec option on /dev/shm? (y/n)" answer
	if [[ "$answer" = [Yy] ]];then
		log_message "Applying remediation steps to ensure noexec option is set on /dev/shm ..."
		

        # Update the /dev/shm line to include noexec
		sudo sed -i '/ \/dev/shm / s/^\([^#].* \)\(defaults[^ ]*\)/\1\2,noexec/' "$FSTAB_FILE"

        log_message "/etc/fstab updated with 'noexec' option for /dev/shm."
	fi
	fi
	
remount_dev_shm			
fi

} 


update_fstab_for_home() {
    fstab_file="/etc/fstab"

    # Check if /home is listed in /etc/fstab
    tmp_line=$(grep ' /home ' "$fstab_file")
    
    if grep -q "HOME IN FSTAB: NOT INCLUDED" $RESULT_FILE; then
        read -p "Do you want to include a new entry for /home in /etc/fstab? (y/n)" answer
		if [[ "$answer" = [Yy] ]]; then
        log_message "Adding new entry for /home in /etc/fstab..."
		read -p "Enter the device:" device
		read -p "Enter the required file system type:" fstype
	
        echo "<device> /home <fstype> defaults,rw,nosuid,nodev,noexec 0 0" >> "$fstab_file"
        
        log_message "Added entry for /home in /etc/fstab."
   
    fi
	fi
}

# Function to remount /home with updated options
remount_home() {
    log_message "Remounting /home with updated options..."
    sudo mount -o remount /home
    log_message "/home remounted with updated options."
}



#Fix options set on /home partition
fix_home_partition_options() {
	if grep -q "HOME IN FSTAB: INCLUDED"  $RESULT_FILE; then
	if grep -q "NODEV_OPTION_IN_HOME: NOT CONFIGURED" $RESULT_FILE; then
	read -p "Do you want to set nodev option on /home? (y/n)" answer
	if [[ "$answer" = [Yy] ]];then
		log_message "Applying remediation steps to ensure nodev option is set on /home ..."
		

        # Update the /dev/shm line to include nodev
        sudo sed -i '/ \/home / s/^\([^#].* \)\(defaults[^ ]*\)/\1\2,nodev/' "$FSTAB_FILE"

        log_message "/etc/fstab updated with 'nodev' option for /home."
	fi
	fi
	
	if grep -q "NOSUID_OPTION_IN_HOME: NOT CONFIGURED" $RESULT_FILE; then
	read -p "Do you want to set nosuid option on /home? (y/n)" answer
	if [[ "$answer" = [Yy] ]];then
		log_message "Applying remediation steps to ensure nosuid option is set on /home ..."
		

        # Update the /tmp line to include nosuid
		sudo sed -i '/ \/home / s/^\([^#].* \)\(defaults[^ ]*\)/\1\2,nosuid/' "$FSTAB_FILE"

        log_message "/etc/fstab updated with 'nosuid' option for /home."
	fi
	fi
	
	if grep -q "NOEXEC_OPTION_IN_HOME: NOT CONFIGURED" $RESULT_FILE; then
	read -p "Do you want to set noexec option on /home? (y/n)" answer
	if [[ "$answer" = [Yy] ]];then
		log_message "Applying remediation steps to ensure noexec option is set on /home ..."
		

        # Update the /home line to include noexec
		sudo sed -i '/ \/home / s/^\([^#].* \)\(defaults[^ ]*\)/\1\2,noexec/' "$FSTAB_FILE"

        log_message "/etc/fstab updated with 'noexec' option for /home."
	fi
	fi
	
remount_home			
fi
} 


update_fstab_for_var() {
    fstab_file="/etc/fstab"

    # Check if /var is listed in /etc/fstab
    tmp_line=$(grep ' /var ' "$fstab_file")
    
    if grep -q "VAR IN FSTAB: NOT INCLUDED" $RESULT_FILE; then
        read -p "Do you want to include a new entry for /var in /etc/fstab? (y/n)" answer
		if [[ "$answer" = [Yy] ]]; then
        log_message "Adding new entry for /var in /etc/fstab..."
		read -p "Enter the device:" device
		read -p "Enter the required file system type:" fstype
	
        echo "<device> /var <fstype> defaults,rw,nosuid,nodev,noexec 0 0" >> "$fstab_file"
        
        log_message "Added entry for /var in /etc/fstab."
   fi
    fi
}

# Function to remount /var with updated options
remount_var() {
    log_message "Remounting /var with updated options..."
    sudo mount -o remount /var
    log_message "/var remounted with updated options."
}



#Fix options set on /var partition
fix_var_partition_options() {
	if grep -q "VAR IN FSTAB: INCLUDED"  $RESULT_FILE; then
	if grep -q "NODEV_OPTION_IN_VAR: NOT CONFIGURED" $RESULT_FILE; then
	read -p "Do you want to set nodev option on /var? (y/n)" answer
	if [[ "$answer" = [Yy] ]];then
		log_message "Applying remediation steps to ensure nodev option is set on /var ..."
		

        # Update the /var line to include nodev
        sudo sed -i '/ \/var / s/^\([^#].* \)\(defaults[^ ]*\)/\1\2,nodev/' "$FSTAB_FILE"

        log_message "/etc/fstab updated with 'nodev' option for /var."
	fi
	fi
	
	if grep -q "NOSUID_OPTION_IN_VAR: NOT CONFIGURED" $RESULT_FILE; then
	read -p "Do you want to set nosuid option on /var? (y/n)" answer
	if [[ "$answer" = [Yy] ]];then
		log_message "Applying remediation steps to ensure nosuid option is set on /var ..."
		

        # Update the /var line to include nosuid
		sudo sed -i '/ \/var / s/^\([^#].* \)\(defaults[^ ]*\)/\1\2,nosuid/' "$FSTAB_FILE"

        log_message "/etc/fstab updated with 'nosuid' option for /var"
	fi
	fi
remount_var	
			
fi
} 


update_fstab_for_var_tmp() {
    fstab_file="/etc/fstab"

    # Check if /tmp is listed in /etc/fstab
    tmp_line=$(grep ' /var/tmp ' "$fstab_file")
    
    if grep -q "VAR TMP IN FSTAB: NOT INCLUDED" $RESULT_FILE; then
        read -p "Do you want to include a new entry for /var/tmp in /etc/fstab? (y/n)" answer
		if [[ "$answer" = [Yy] ]]; then
        log_message "Adding new entry for /var/tmp in /etc/fstab..."
		read -p "Enter the device:" device
		read -p "Enter the required file system type:" fstype
	
        echo "<device> /var/tmp <fstype> defaults,rw,nosuid,nodev,noexec 0 0" >> "$fstab_file"
        
        log_message "Added entry for /var/tmp in /etc/fstab."
   
    fi
	fi
}
# Function to remount /var/tmp with updated options
remount_var_tmp() {
    log_message "Remounting /var/tmp with updated options..."
    sudo mount -o remount /var/tmp
    log_message "/var/tmp remounted with updated options."
}


#Fix options set on /var/tmp partition
fix_var_tmp_partition_options() {
	if grep -q "VAR TMP IN FSTAB: INCLUDED"  $RESULT_FILE; then
	if grep -q "NODEV_OPTION_ON_VAR_TMP: NOT CONFIGURED" $RESULT_FILE; then
	read -p "Do you want to set nodev option on /home? (y/n)" answer
	if [[ "$answer" = [Yy] ]];then
		log_message "Applying remediation steps to ensure nodev option is set on /var/tmp ..."
		

        # Update the /dev/shm line to include nodev
        sudo sed -i '/ \/var/tmp / s/^\([^#].* \)\(defaults[^ ]*\)/\1\2,nodev/' "$FSTAB_FILE"

        log_message "/etc/fstab updated with 'nodev' option for /var/tmp."
	fi
	fi
	
	if grep -q "NOSUID_OPTION_IN_VAR_TMP: NOT CONFIGURED" $RESULT_FILE; then
	read -p "Do you want to set nosuid option on /var/tmp? (y/n)" answer
	if [[ "$answer" = [Yy] ]];then
		log_message "Applying remediation steps to ensure nosuid option is set on /var/tmp ..."
		

        # Update the /tmp line to include nosuid
		sudo sed -i '/ \/var/tmp / s/^\([^#].* \)\(defaults[^ ]*\)/\1\2,nosuid/' "$FSTAB_FILE"

        log_message "/etc/fstab updated with 'nosuid' option for /var/tmp."
	fi
	fi
	
	if grep -q "NOEXEC_OPTION_IN_VAR_TMP: NOT CONFIGURED" $RESULT_FILE; then
	read -p "Do you want to set noexec option on /var/tmp? (y/n)" answer
	if [[ "$answer" = [Yy] ]];then
		log_message "Applying remediation steps to ensure noexec option is set on /var/tmp ..."
		

        # Update the /home line to include noexec
		sudo sed -i '/ \/var/tmp / s/^\([^#].* \)\(defaults[^ ]*\)/\1\2,noexec/' "$FSTAB_FILE"

        log_message "/etc/fstab updated with 'noexec' option for /var/tmp."
	fi
	fi
	

remount_var_tmp			
fi
} 


update_fstab_for_var_log() {
    fstab_file="/etc/fstab"

    # Check if /var/log is listed in /etc/fstab
    tmp_line=$(grep ' /var/log ' "$fstab_file")
    
    if grep -q "VAR LOG IN FSTAB: NOT INCLUDED" $RESULT_FILE; then
        read -p "Do you want to include a new entry for /var/log in /etc/fstab? (y/n)" answer
		if [[ "$answer" = [Yy] ]]; then
        log_message "Adding new entry for /var/log in /etc/fstab..."
		read -p "Enter the device:" device
		read -p "Enter the required file system type:" fstype
	
        echo "<device> /var/log <fstype> defaults,rw,nosuid,nodev,noexec 0 0" >> "$fstab_file"
        
        log_message "Added entry for /var/log in /etc/fstab."
   fi
    fi
}

# Function to remount /var/log with updated options
remount_var_log() {
    log_message "Remounting /var/log with updated options..."
    sudo mount -o remount /var/log
    log_message "/var/log remounted with updated options."
}


#Fix options set on /var/log partition
fix_var_log_partition_options() {
	if grep -q "VAR LOG IN FSTAB: INCLUDED"  $RESULT_FILE; then
	if grep -q "NODEV_OPTION_ON_VAR_LOG: NOT CONFIGURED" $RESULT_FILE; then
	read -p "Do you want to set nodev option on /var/log? (y/n)" answer
	if [[ "$answer" = [Yy] ]];then
		log_message "Applying remediation steps to ensure nodev option is set on /var/log ..."
		

        # Update the /dev/shm line to include nodev
        sudo sed -i '/ \/var/log / s/^\([^#].* \)\(defaults[^ ]*\)/\1\2,nodev/' "$FSTAB_FILE"

        log_message "/etc/fstab updated with 'nodev' option for /var/log."
	fi
	fi
	
	if grep -q "NOSUID_OPTION_IN_VAR_LOG: NOT CONFIGURED" $RESULT_FILE; then
	read -p "Do you want to set nosuid option on /var/log? (y/n)" answer
	if [[ "$answer" = [Yy] ]];then
		log_message "Applying remediation steps to ensure nosuid option is set on /var/log ..."
		

        # Update the /var/log line to include nosuid
		sudo sed -i '/ \/var/log / s/^\([^#].* \)\(defaults[^ ]*\)/\1\2,nosuid/' "$FSTAB_FILE"

        log_message "/etc/fstab updated with 'nosuid' option for /var/log."
	fi
	fi
	
	if grep -q "NOEXEC_OPTION_IN_VAR_TMP: NOT CONFIGURED" $RESULT_FILE; then
	read -p "Do you want to set noexec option on /var/log? (y/n)" answer
	if [[ "$answer" = [Yy] ]];then
		log_message "Applying remediation steps to ensure noexec option is set on /var/log ..."
		

        # Update the /home line to include noexec
		sudo sed -i '/ \/var/log / s/^\([^#].* \)\(defaults[^ ]*\)/\1\2,noexec/' "$FSTAB_FILE"

        log_message "/etc/fstab updated with 'noexec' option for /var/log."
	fi
	fi
remount_var_log	
			
fi
} 


update_fstab_for_var_log_audit() {
    fstab_file="/etc/fstab"

    # Check if /var/log/audit is listed in /etc/fstab
    tmp_line=$(grep ' /var/log/audit ' "$fstab_file")
    
    if grep -q "VAR LOG AUDIT IN FSTAB: NOT INCLUDED" $RESULT_FILE; then
        read -p "Do you want to include a new entry for /var/log/audit in /etc/fstab? (y/n)" answer
		if [[ "$answer" = [Yy] ]]; then
        log_message "Adding new entry for /var/log/audit in /etc/fstab..."
		read -p "Enter the device:" device
		read -p "Enter the required file system type:" fstype
	
        echo "<device> /var/log/audit <fstype> defaults,rw,nosuid,nodev,noexec 0 0" >> "$fstab_file"
        
        log_message "Added entry for /var/log/audit in /etc/fstab."
   
    fi
	fi
}

# Function to remount /var/log/audit with updated options
remount_var_log_audit() {
    log_message "Remounting /var/log/audit with updated options..."
    sudo mount -o remount /var/log/audit
    log_message "/var/log/audit remounted with updated options."
}

#Fix options set on /var/log/audit partition
fix_var_log_audit_partition_options() {
	if grep -q "VAR LOG IN FSTAB: INCLUDED"  $RESULT_FILE; then
	if grep -q "NODEV_OPTION_ON_VAR_LOG_AUDIT: NOT CONFIGURED" $RESULT_FILE; then
	read -p "Do you want to set nodev option on /var/log/audit? (y/n)" answer
	if [[ "$answer" = [Yy] ]];then
		log_message "Applying remediation steps to ensure nodev option is set on /var/log/audit ..."
		

        # Update the /var/log/audit line to include nodev
        sudo sed -i '/ \/var/log/audit / s/^\([^#].* \)\(defaults[^ ]*\)/\1\2,nodev/' "$FSTAB_FILE"

        log_message "/etc/fstab updated with 'nodev' option for /var/log/audit."
	fi
	fi
	
	if grep -q "NOSUID_OPTION_IN_VAR_LOG_AUDIT: NOT CONFIGURED" $RESULT_FILE; then
	read -p "Do you want to set nosuid option on /var/log/audit? (y/n)" answer
	if [[ "$answer" = [Yy] ]];then
		log_message "Applying remediation steps to ensure nosuid option is set on /var/log/audit ..."
		

        # Update the /var/log line to include nosuid
		sudo sed -i '/ \/var/log/audit / s/^\([^#].* \)\(defaults[^ ]*\)/\1\2,nosuid/' "$FSTAB_FILE"

        log_message "/etc/fstab updated with 'nosuid' option for /var/log/audit."
	fi
	fi
	
	if grep -q "NOEXEC_OPTION_IN_VAR_LOG_AUDIT: NOT CONFIGURED" $RESULT_FILE; then
	read -p "Do you want to set noexec option on /var/log/audit? (y/n)" answer
	if [[ "$answer" = [Yy] ]];then
		log_message "Applying remediation steps to ensure noexec option is set on /var/log/audit ..."
		

        # Update the /home line to include noexec
		sudo sed -i '/ \/var/log/audit / s/^\([^#].* \)\(defaults[^ ]*\)/\1\2,noexec/' "$FSTAB_FILE"

        log_message "/etc/fstab updated with 'noexec' option for /var/log/audit."
	fi
	fi
remount_var_log_audit	
			
fi
} 


#Function to fix global gpg Check
fix_global_gpg_check() {
	
	
	if grep -q "gpg_check:FAILED" $RESULT_FILE; then
	read -p "Do you want to ensure gpgcheck is globally activated? (y/n)" answer
	if [[ answer = [Yy] ]]; then
	log_message "Fixing global gpg check..."
	sed -i 's/^gpgcheck\s*=\s*.*/gpgcheck=1/' /etc/dnf/dnf.conf
	
	find /etc/yum.repos.d/ -name "*.repo" -exec echo "Checking:" {} \; -exec sed -i 's/^gpgcheck\s*=\s*.*/gpgcheck=1/' {} \;

	
	log_message "GPG Check is globally activated."
	fi
fi

}


# Function to prompt for password and confirm
get_password() {
if grep -q "Bootloader_password_set:FAILED" $RESULT_FILE; then
read -p "Do you want to set bootloader password? (y/n)" answer
	if [[ answer = [Yy] ]]; then
log_message "Setting bootloader password..."
  while true; do
    read -sp "Enter GRUB password: " password
    echo
    read -sp "Confirm GRUB password: " confirm_password
    echo

    if [ "$password" == "$confirm_password" ]; then
		# Set the GRUB password
	echo "$password" | grub2-setpassword
      break
    else
      echo "Passwords do not match. Please try again."
    fi
  done
  # Inform the user that the password has been set
	log_message "GRUB password has been set successfully."
	fi
 fi
}

#Function to install SELinux
install_SELinux() {

if grep -q "libselinux:NOT INSTALLED" $RESULT_FILE; then
read -p "Do you want to install SELinux? (y/n)" answer
	if [[ answer = [Yy] ]]; then
	log_message "Installing SELinux..."
	dnf install libselinux
	log_message "SELinux installed."
	fi
fi
}

#Function to fix selinux disabled in bootloader configuration
fix_selinux_bootloader_config() {

if grep -q "SELinux:DISABLED" $RESULT_FILE; then
read -p "Do you want to enable SELinux in bootloader configuration? (y/n)" answer
	if [[ answer = [Yy] ]]; then
	log_message "Fixing SELinux disabled in bootloader configuration..."
	grubby --update-kernel ALL --remove-args "selinux=0 enforcing=0"
	log_message "SELinux enabled in bootloader configuration."
	fi
fi
}

#Function to fix selinux policy
fix_selinux_policy() {
if grep -q '(SELINUXTYPE:CHANGE REQUIRED|SELINUXTYPE:INVALID)' $RESULT_FILE; then
read -p "Do you want to configure SELinux policy? (y/n)" answer
	if [[ answer = [Yy] ]]; then
	log_message "Fixing SELinux policy..."
	sed -i "s/^SELINUXTYPE=.*/SELINUXTYPE=targeted/" /etc/selinux/config
	log_message "SELinux policy set to targeted."
	fi
	
fi
}

#Function to ensure SELinux mode is not disabled
fix_selinux_mode() {

if grep -q "SELINUXMODE:REQUIRES CHANGE" $RESULT_FILE; then
read -p "Do you want to configure SELinux mode to Enforcing? (y/n)" answer
	if [[ answer = [Yy] ]]; then
	log_message "Fixing SELinux policy..."
	setenforce 1
	sed -i "s/^SELINUX=.*/SELINUX=enforcing/" /etc/selinux/config
	log_message "SELinux mode is not disabled."
	fi
fi
}

#Function to notify that unconfined services are present
notify_unconfined_services_are_present() {
log_message "Notifying unconfined services..."
if grep -q "unconfined_services:EXIST" $RESULT_FILE; then
 echo "Unconfined services are present. Please assign security contexts or add policies to them."
fi
}

#Function to uninstall mcstrans
uninstall_mcstrans() {
if grep -q "mcstrans:INSTALLED" $RESULT_FILE; then
	read -p "Do you want to uninstall mcstrans? (y/n)" answer
	if [[ answer = [Yy] ]]; then
	log_message "Fixing mcstrans..."
	dnf remove mcstrans
	log_message "mcstrans uninstalled."
	fi
fi
}


#Function to uninstall setroubleshoot
uninstall_setroubleshoot() {

if grep -q "setroubleshoot:INSTALLED" $RESULT_FILE; then
	read -p "Do you want to uninstall setroubleshoot? (y/n)" answer
	if [[ answer = [Yy] ]]; then
	log_message "Fixing setroubleshoot..."
	dnf remove setroubleshoot
	log_message "setroubleshoot uninstalled."
	fi
fi
}

##########################################


#Function to fix motd config
fix_motd_config() {

if grep -q "MOTD_CONFIG:FAIL" $RESULT_FILE; then
	log_message "Fixing message of the day configuration..."
	read -p "You can remove the /etc/motd file if it is not used. Do you want to remove it? (y/n)" answer
	if [[ answer = [Yy] ]]; then
	rm /etc/motd
	log_message "message of the day configured properly."
	else
	You can edit the /etc/motd with the appropriate contents related to your site policy.
	fi
	fi
}


#Function to fix local login banner warning configuration
fix_local_login_warning_banner_config() {
if grep -q "LOCAL_LOGIN_WARNING_CONFIG:FAIL" $RESULT_FILE; then
	log_message "Fixing local login warning banner configuration..."
	read -p "Do you want to configure local login banner warning? (y/n)" answer
	if [[ answer = [Yy] ]]; then
	echo  "Authorized users only. All activity may be monitored and reported." > /etc/issue
	log_message "Local login banner warning configured."
	fi
fi
}

#Function to fix remote login banner warning configuration
fix_remote_login_warning_banner_config() {
if grep -q "REMOTE_LOGIN_WARNING_CONFIG:FAIL" $RESULT_FILE; then
	log_message "Fixing remote login warning banner configuration..."
	read -p "Do you want to configure remote login banner warning? (y/n)" answer
	if [[ answer = [Yy] ]]; then
	echo  "Authorized users only. All activity may be monitored and reported." > /etc/issue
	log_message "Remote login banner warning configured."
	fi
fi
}


#Fixing access to /etc/motd/
fix_access_etc_motd() {
if grep -q "/etc/motd permissions:INCORRECT" $RESULT_FILE; then
	if [ -e /etc/motd ]; then
	log_message "Changing permissions for /etc/motd..."
	read -p "Do you want to change permissions for /etc/motd? (y/n)" answer
	if [[ answer = [Yy] ]]; then
	chown root:root $(readlink -e /etc/motd)
	chmod u-x,go-wx $(readlink -e /etc/motd)
	log_message "Permissions changed for /etc/motd."
	else
	read -p "Do you want to remove /etc/motd file? (y/n)" answer
	if [[ answer = [Yy] ]]; then
	log_message "Removing /etc/motd..."
	rm /etc/motd
	log_message "/etc/motd has been removed."
	
	fi
	fi
	fi

fi
}

#Fixing access to /etc/issue
fix_access_to_etc_issue() {
if grep -q "/etc/issue permissions:INCORRECT" $RESULT_FILE; then
	if [ -e /etc/issue ]; then
	log_message "Changing permissions for /etc/issue..."
	read -p "Do you want to change permissions for /etc/issue? (y/n)" answer
	if [[ answer = [Yy] ]]; then
	chown root:root $(readlink -e /etc/issue)
	chmod u-x,go-wx $(readlink -e /etc/issue)
	log_message "Permissions changed for /etc/issue."
	
	fi

fi
fi

}

#Fixing access to /etc/issue.net
fix_access_to_etc_issue_net() {
if grep -q "/etc/issue permissions:INCORRECT" $RESULT_FILE; then
if [ -e /etc/issue.net ]; then
	log_message "Changing permissions for /etc/issue.net..."
	read -p "Do you want to change permissions for /etc/issue.net? (y/n)" answer
	if [[ answer = [Yy] ]]; then
	chown root:root $(readlink -e /etc/issue.net)
	chmod u-x,go-wx $(readlink -e /etc/issue.net)
	log_message "Permissions changed for /etc/issue.net"
	
	fi

fi
fi
}

#Remove GDM
remove_gdm() {
if grep -q "GDM:INSTALLED" $RESULT_FILE; then
	read -p "Do you want to uninstall GDM? (y/n)" answer
	if [[ answer = [Yy] ]]; then
	log_message "Removing GDM..."
	dnf remove gdm
	log_message "GDM removed."
	fi
fi
}

#fix xdcmp
fix_xdcmp() {
file="/etc/gdm/custom.conf"
if grep -q "XDCMP: ENABLED" $RESULT_FILE; then
	
	read -p "Do you want to disable XDCMP? (y/n)" answer
	if [[ answer = [Yy] ]]; then
	log_message "Removing XDCMP..."	
        cp "$file" "$file.bak"
		sed -i '/^\s*Enable\s*=\s*true/d' "$file"
		log_message "XDCMP disabled."
		
	fi
fi
		
}






















log_message "Starting configuration fixes..."

fix_crond_status
fix_crontab_permissions
fix_cron_hourly_permissions
fix_cron_daily_permissions
fix_cron_weekly_permissions
fix_cron_monthly_permissions
fix_crond_permissions
fix_systemd_status_tmp
update_fstab_for_tmp
fix_tmp_partition_options

update_fstab_for_dev_shm
fix_dev_shm_partition_options

update_fstab_for_home
fix_home_partition_options

update_fstab_for_var
fix_var_partition_options

update_fstab_for_var_tmp
fix_var_tmp_partition_options

update_fstab_for_var_log
fix_var_log_partition_options

update_fstab_for_var_log_audit
fix_var_log_audit_partition_options

fix_global_gpg_check
get_password
install_SELinux
fix_selinux_bootloader_config
fix_selinux_policy
fix_selinux_mode
notify_unconfined_services_are_present
uninstall_mcstrans
uninstall_setroubleshoot
fix_motd_config
fix_local_login_warning_banner_config
fix_remote_login_warning_banner_config
fix_access_etc_motd
fix_access_to_etc_issue
fix_access_to_etc_issue_net
remove_gdm
fix_xdcmp



