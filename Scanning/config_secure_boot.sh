#!/usr/bin/bash

LOG_FILE="/var/log/hardening_scan.log"
RESULT_FILE="/var/tmp/scan_results.txt"


# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $LOG_FILE	  #output to both screen and log file
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


check_bootloader_password
