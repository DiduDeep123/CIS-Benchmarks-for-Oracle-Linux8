#!/usr/bin/bash


LOG_FILE="/var/log/hardening_fix.log"
RESULT_FILE="/var/tmp/scan_results.txt"


# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $LOG_FILE
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

install_SELinux
fix_selinux_bootloader_config
fix_selinux_policy
fix_selinux_mode
notify_unconfined_services_are_present
uninstall_mcstrans
uninstall_setroubleshoot
