#!/usr/bin/bash


LOG_FILE="/var/log/hardening_fix.log"
RESULT_FILE="/var/tmp/scan_results.txt"


# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $LOG_FILE
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
