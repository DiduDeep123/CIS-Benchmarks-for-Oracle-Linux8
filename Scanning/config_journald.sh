#!/usr/bin/bash

LOG_FILE="/var/log/hardening_scan.log"
RESULT_FILE="/var/tmp/scan_results.txt"

# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $LOG_FILE  # Output to both screen and log file
}

check_systemd_journal_remote() {
    package="systemd-journal-remote"

    if rpm -q "$package" > /dev/null 2>&1; then
        log_message "$package is installed."
        echo "SYSTEMD-JOURNAL-REMOTE: INSTALLED" >> $RESULT_FILE
    else
        log_message "$package is not installed."
        echo "SYSTEMD-JOURNAL-REMOTE: NOT INSTALLED" >> $RESULT_FILE
    fi
}

check_systemd_journald_upload_service() {
    service_name="systemd-journal-upload.service"

    log_message "Checking if $service_name service is enabled..."

    service_status=$(systemctl is-enabled "$service_name")

    if [[ "$service_status" == "enabled" ]]; then
        log_message "$service_name is enabled."
        echo "SYSTEMD-JOURNAL-UPLOAD.SERVICE: ENABLED" >> $RESULT_FILE
    else
        log_message "$service_name is not enabled."
        echo "SYSTEMD-JOURNAL-UPLOAD.SERVICE: NOT ENABLED" >> $RESULT_FILE
    fi
}

check_systemd_journal_remote_socket() {
    service_name="systemd-journal-remote.socket"

    log_message "Checking if $service_name service is enabled..."

    service_status=$(systemctl is-enabled "$service_name")

    if [[ "$service_status" == "masked" ]]; then
        log_message "$service_name is masked (not enabled)."
        echo "SYSTEMD-JOURNAL-REMOTE.SOCKET: NOT ENABLED" >> $RESULT_FILE
    else
        log_message "$service_name is enabled."
        echo "SYSTEMD-JOURNAL-REMOTE.SOCKET: ENABLED" >> $RESULT_FILE
    fi
}

check_systemd_journald_service() {
    service_name="systemd-journald.service"

    log_message "Checking if $service_name is enabled..."

    service_status=$(systemctl is-enabled "$service_name")

    if [[ "$service_status" == "static" || "$service_status" == "enabled" ]]; then
        log_message "$service_name is configured properly."
        echo "SYSTEMD-JOURNALD.SERVICE: CONFIGURED PROPERLY" >> $RESULT_FILE
    else
        log_message "$service_name is not configured properly."
        echo "SYSTEMD-JOURNALD.SERVICE: NOT CONFIGURED PROPERLY" >> $RESULT_FILE
    fi
}

# Check if journald is configured to compress large log files
check_compress_large_log_files() {
    log_message "Checking if journald is configured to compress large log files..."

    if grep -q '^Compress=' /etc/systemd/journald.conf; then
        log_message "Journald is configured to compress large log files."
        echo "JOURNALD LOG FILE COMPRESS: YES" >> $RESULT_FILE
    else
        log_message "Journald is not configured to compress large log files."
        echo "JOURNALD LOG FILE COMPRESS: NO" >> $RESULT_FILE
    fi
}

# Check if journald is configured to write logfiles to persistent disks
check_journald_storage() {
    log_message "Checking if journald is configured to write logfiles to persistent disks..."

    if grep -q '^Storage=' /etc/systemd/journald.conf; then
        log_message "Journald is configured to write logfiles to persistent disks."
        echo "JOURNALD PERSISTENT DISKS: YES" >> $RESULT_FILE
    else
        log_message "Journald is not configured to write logfiles to persistent disks."
        echo "JOURNALD PERSISTENT DISKS: NO" >> $RESULT_FILE
    fi
}

#Check if journald is not configured to send logs to rsyslog
check_journald_rsyslog() {
	log_message "Checking if journald is not configured to send logs to rsyslog..."
	if  grep -q '^\s*ForwardToSyslog' /etc/systemd/journald.conf; then
		log_message "Journald is configured to send logs to rsyslog."
        echo "JOURNALD RSYSLOG: YES" >> $RESULT_FILE
		
	else
		log_message "Journald is not configured to send logs to rsyslog."
        echo "JOURNALD RSYSLOG: NO" >> $RESULT_FILE
		
	fi
}


check_systemd_journal_remote
check_systemd_journald_upload_service
check_systemd_journal_remote_socket
check_systemd_journald_service
check_compress_large_log_files
check_journald_storage
