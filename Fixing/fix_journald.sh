!/usr/bin/bash


LOG_FILE="/var/log/hardening_fix.log"
RESULT_FILE="/var/tmp/scan_results.txt"
NEW_LOG_FILE="/var/log/user_select.log"

# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $LOG_FILE
}

#User opted not to apply remediation function
select_no() {
	log_message "User opted not to apply remediation."
	echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $NEW_LOG_FILE
}
	
	
#Functon to install journald-remote
install_journald_remote() {
if grep -q "SYSTEMD-JOURNAL-REMOTE: NOT INSTALLED" $RESULT_FILE; then
	read -p "Do you want to install systemd-journal-remote ? (y/n)" answer
	if [[ $answer = [Yy] ]]; then
	log_message "Installing systemd-journal-remote..."
	dnf install systemd-journal-remote
	log_message "systemd-journal-remote installed."
	
	else
	select_no "User opted not to install systemd-journal-remote."
	echo "systemd-journal-remote NOT INSTALLED: REQUIRES CHANGE" >> $NEW_LOG_FILE
fi
fi
}

#Function to enable systemd journal remote
enable_journald_remote() {
if grep -q "SYSTEMD-JOURNAL-UPLOAD.SERVICE: NOT ENABLED" $RESULT_FILE; then
	read -p "Do you want to enable systemd-journal-remote ? (y/n)" answer
	if [[ $answer = [Yy] ]]; then
	log_message "Enabling systemd-journal-remote..."
	systemctl --now enable systemd-journal-upload.service
	log_message "systemd-journal-remote enabled."
	else
	select_no "User opted not to enable systemd-journal-remote."
	echo "systemd-journal-remote NOT ENABLED: REQUIRES CHANGE" >> $NEW_LOG_FILE
fi
fi	
}



#Function to configure the service properly
configure_journald_remote_socket() {

if grep -q "SYSTEMD-JOURNAL-REMOTE.SOCKET: ENABLED" $RESULT_FILE; then
	read -p "Do you want to disable systemd-journal-remote ? (y/n)" answer
	if [[ $answer = [Yy] ]]; then
	log_message "Disabling systemd-journal-remote socket..."
	systemctl --now mask systemd-journal-remote.socket
	log_message "systemd-journal-remote socket Disabled."
	else
	select_no "User opted not to disable systemd-journal-remote."
	echo "systemd-journal-remote socket ENABLED: REQUIRES CHANGE" >> $NEW_LOG_FILE
fi
fi	

}


#Function to fix compress large log files
configure_compress_log_files() {
if grep -q "JOURNALD LOG FILE COMPRESS: NO" $RESULT_FILE; then
	read -p "Do you want to ensure journald to compress large log files? (y/n)" answer
	if [[ $answer = [Yy] ]]; then
	log_message "Editing /etc/systemd/journald.conf ..."
	echo "Compress=yes" >> /etc/systemd/journald.conf
	log_message "/etc/systemd/journald.conf edited."
	log_message "Restarting systemd-journald.service... "
	systemctl restart systemd-journald.service
	log_message "systemd-journald.service restarted"
	else
	select_no "User opted not to edit /etc/systemd/journald.conf "
	echo "JOURNALD LOG FILE COMPRESS NO: REQUIRES CHANGE" >> $NEW_LOG_FILE
fi
fi	
}

#Function to fix persistent storage
configure_persistent_storage() {
if grep -q "JOURNALD PERSISTENT DISKS: NO" $RESULT_FILE; then
	read -p "Do you want to ensure journald to write logfiles to persistent storage? (y/n)" answer
	if [[ $answer = [Yy] ]]; then
	log_message "Editing /etc/systemd/journald.conf ..."
	echo "Storage=persistent" >> /etc/systemd/journald.conf
	log_message "/etc/systemd/journald.conf edited."
	log_message "Restarting systemd-journald.service... "
	systemctl restart systemd-journald.service
	log_message "systemd-journald.service restarted"
	else
	select_no "User opted not to edit /etc/systemd/journald.conf "
	echo "JOURNALD PERSISTENT DISKS NO: REQUIRES CHANGE" >> $NEW_LOG_FILE
fi
fi	
}
#Function to not sent logs to rsyslog
configure_logs_to_rsyslog() {
if grep -q "JOURNALD RSYSLOG: YES" $RESULT_FILE; then
	read -p "Do you want to ensure journald is not configured to send logs to rsyslog ? (y/n)" answer
	if [[ $answer = [Yy] ]]; then
	log_message "Editing /etc/systemd/journald.conf ..."
	sed -i '/^ForwardToSyslog=yes/d' "$CONFIG_FILE"
	log_message "/etc/systemd/journald.conf edited."
	log_message "Restarting systemd-journald.service... "
	systemctl restart systemd-journald.service
	log_message "systemd-journald.service restarted"
	else
	select_no "User opted not to edit /etc/systemd/journald.conf "
	echo "JOURNALD RSYSLOG YES: REQUIRES CHANGE" >> $NEW_LOG_FILE
fi
fi	
}


install_journald_remote
enable_journald_remote
configure_journald_remote_socket
configure_compress_log_files
configure_persistent_storage
configure_logs_to_rsyslog

