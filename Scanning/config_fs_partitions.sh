#!/usr/bin/bash

LOG_FILE="/var/log/hardening_scan.log"
RESULT_FILE="/var/tmp/scan_results.txt"


# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $LOG_FILE	  #output to both screen and log file
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
