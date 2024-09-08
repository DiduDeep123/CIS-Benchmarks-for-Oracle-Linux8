#!/usr/bin/bash


LOG_FILE="/var/log/hardening_fix.log"
RESULT_FILE="/var/tmp/scan_results.txt"

# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $LOG_FILE
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
