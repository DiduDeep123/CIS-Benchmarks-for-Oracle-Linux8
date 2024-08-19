#!/usr/bin/bash

LOG_FILE="/var/log/hardening_scan.log"
RESULT_FILE="/var/tmp/scan_results.txt"

# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $LOG_FILE	  #output to both screen and log file
}

check_rsyslog() {
    package="rsyslog"
  
        if rpm -q "$package" > /dev/null 2>&1; then
            log_message "$package is installed."
			echo "rsyslog:INSTALLED" >> $RESULT_FILE
            
        else
            log_message "$package is not installed."
			echo "rsyslog:NOT INSTALLED" >> $RESULT_FILE
		
		fi
}

ensure_rsyslog_enabled() {
    # Check if rsyslog service is enabled
    service_name="rsyslog"

    log_message "Checking if $service_name service is enabled..."

    service_status=$(systemctl is-enabled "$service_name")

    if [[ "$service_status" == "enabled" ]]; then
        log_message "$service_name is already enabled."
		echo "rsyslog:ENABLED" >> $RESULT_FILE
		
    else
		log_message "$service_name is not enabled."
		echo "rsyslog:NOT ENABLED" >> $RESULT_FILE
        
    fi
}

# Check FileCreateMode settings
check_file_create_mode() {
    search_pattern='^\h*\$FileCreateMode\h+0[0,2,4,6][0,2,4]0\b'
    config_files="/etc/rsyslog.conf /etc/rsyslog.d/*.conf"

    log_message "Checking $FileCreateMode settings..."

    if grep -Pqs "$search_pattern" $config_files | grep -Pq '^\h*\$FileCreateMode\h+0640\b'; then
        echo "FILECREATEMODE:640 OR MORE RESTRICTIVE" >> $RESULT_FILE
        log_message "$FileCreateMode setting is 0640 or more restrictive."
    else
        echo "FILECREATEMODE:NOT 640 OR MORE RESTRICTIVE" >> $RESULT_FILE
        log_message "$FileCreateMode setting is not 0640 or more restrictive."
    fi
}

#Check if logging is configured
check_logging_config() {
		log_message "Checking if logging is configured..."

		log=$( ls -l /var/log/)
		
		if [ -d /var/log/ ] && [ "$(ls -A /var/log/)" ]; then
		echo "/VAR/LOG:CONFIGURED" >> $RESULT_FILE
        log_message "Logging is configured."
		
		else
		echo "/VAR/LOG:NOT CONFIGURED" >> $RESULT_FILE
        log_message "Logging is not configured."
		
		fi

}

# Check if rsyslog is not configured to receive logs from a remote client
check_logs_from_remote() {
    log_message "Checking if rsyslog is not configured to receive logs from a remote client..."

    
    if grep -Pqs '^\h*module\(load="imtcp"\)' /etc/rsyslog.conf /etc/rsyslog.d/*.conf; then
        echo "INCOMING LOGS: ACCEPTED" >> $RESULT_FILE
        log_message "Rsyslog is configured to receive logs from a remote client (imtcp module is present)."
    else
        echo "INCOMING LOGS: BLOCKED" >> $RESULT_FILE
        log_message "Rsyslog is not configured to receive logs from a remote client (imtcp module is not present)."
    fi
	
	if grep -Pqs -- '^\h*input\(type="imtcp" port="514"\)' /etc/rsyslog.conf /etc/rsyslog.d/*.conf; then
	echo "INCOMING LOGS_PORT514: ACCEPTED" >> $RESULT_FILE
        log_message "Rsyslog is configured to receive logs from a remote client (imtcp module is present)."
    else
        echo "INCOMING LOGS_PORT514: BLOCKED" >> $RESULT_FILE
        log_message "Rsyslog is not configured to receive logs from a remote client (imtcp module is not present)."
    fi

}



check_rsyslog
ensure_rsyslog_enabled
check_file_create_mode
check_logging_config
check_logs_from_remote



