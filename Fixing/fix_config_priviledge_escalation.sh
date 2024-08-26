#!/usr/bin/bash


LOG_FILE="/var/log/hardening_fix.log"
RESULT_FILE="/var/tmp/scan_results.txt"

# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $LOG_FILE
}

#install sudo
install_sudo() {
	
	if grep -q "SUDO:NOT INSTALLED" $RESULT_FILE; then
	read -p "Do you want to install sudo? (y/n)" answer
		if [[ answer = [Yy] ]]; then
			log_message "Installing sudo..."
			dnf install sudo
			log_message "Sudo installed."
		fi
	fi
}

#Fix to use_pty set in sudoers files
fix_use_pty() {
	if grep -q "USE_PTY:NOT CONFIGURED" $RESULT_FILE; then
	read -p "Do you want to ensure sudo commands use pty? (y/n)" answer
		if [[ answer = [Yy] ]]; then
			log_message "Ensuring sudo commands use pty..."
			
			
			
	

}

