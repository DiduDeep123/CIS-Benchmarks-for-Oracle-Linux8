#!/usr/bin/bash


LOG_FILE="/var/log/hardening_fix.log"
RESULT_FILE="/var/tmp/scan_results.txt"

# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $LOG_FILE
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

