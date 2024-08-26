#!/usr/bin/bash


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
	
	
#Functon to install rsyslog
install_rsyslog() {
if grep -q "rsyslog:NOT INSTALLED" $RESULT_FILE; then
	read -p "Do you want to install rsyslog ? (y/n)" answer
	if [[ $answer = [Yy] ]]; then
	log_message "Installing rsyslog..."
	dnf install rsyslog
	log_message "rsyslog installed."
	
	else
	select_no "User opted not to install rsyslog."
	echo "rsyslog NOT INSTALLED: REQUIRES CHANGE" >> $NEW_LOG_FILE

}

#Functon to enable rsyslog
enable_rsyslog() {

if grep -q "rsyslog:NOT ENABLED" $RESULT_FILE; then
	read -p "Do you want to enable rsyslog ? (y/n)" answer
	if [[ $answer = [Yy] ]]; then
	log_message "Enabling rsyslog ..."
	systemctl --now enable rsyslog
	log_message "rsyslog enabled."
	
	else
	select_no "User opted not to enable rsyslog."
	echo "rsyslog NOT ENABLED: REQUIRES CHANGE" >> $NEW_LOG_FILE


}

#Function to fix filecreate mode
fix_filecreate_mode() {
    local config_file="/etc/rsyslog.conf"
    local config_dir="/etc/rsyslog.d/"
    local mode="0640"

    
	if grep -q "FILECREATEMODE:NOT 640 OR MORE RESTRICTIVE" $RESULT_FILE; then
	read -p "Do you want to change file create mode permissions ? (y/n)" answer
	if [[ $answer = [Yy] ]]; then
	log_message "Changing file create mode permissions ..."
    if [[ -f $config_file ]]; then
        echo "Updating $config_file..."
        
        
        if grep -q '^$FileCreateMode' "$config_file"; then
            sed -i "s/^$FileCreateMode .*/\$FileCreateMode $mode/" "$config_file"
        else
            echo "\$FileCreateMode $mode" >> "$config_file"
        fi
    else
        echo "$config_file does not exist."
        return 1
    fi

    
    if [[ -d $config_dir ]]; then
        echo "Updating files in $config_dir..."

        
        for file in "$config_dir"*.conf; do
            if [[ -f $file ]]; then
                if grep -q '^$FileCreateMode' "$file"; then
                    sed -i "s/^$FileCreateMode .*/\$FileCreateMode $mode/" "$file"
                else
                    echo "\$FileCreateMode $mode" >> "$file"
                fi
            fi
        done
    else
        echo "$config_dir does not exist."
        return 1
    fi

    
    echo "Restarting rsyslog service..."
    systemctl restart rsyslog

    if [[ $? -eq 0 ]]; then
        echo "rsyslog service restarted successfully."
    else
        echo "Failed to restart rsyslog service."
        return 1
    fi

    return 0
	else
	select_no "User opted not to change file create mode permissions."
	echo "FILECREATEMODE PERMISSIONS: REQUIRES CHANGE" >> $NEW_LOG_FILE
	fi
	fi
}

fix_logging() {
if grep -q "/VAR/LOG:NOT CONFIGURED" $RESULT_FILE; then
	log_message "Please edit /etc/rsyslog.conf and /etc/rsyslog.d/*.conf according to your environment."
	echo "/VAR/LOG NOT CONFIGURED: REQUIRES CHANGE" >> $NEW_LOG_FILE
fi
	

}

fix_logs_from_remote() {
if grep -q 'INCOMING LOGS: ACCEPTED' $RESULT_FILE || grep -q 'INCOMING LOGS_PORT514: ACCEPTED' $RESULT_FILE; then
	read -p "Do you want to ensure rsyslog is not configured to receive logs from a remote client ? (y/n)" answer
	if [[ $answer = [Yy] ]]; then

    local config_file="/etc/rsyslog.conf"
    local config_dir="/etc/rsyslog.d/"
    local patterns=("module(load=\"imtcp\")" "input(type=\"imtcp\" port=\"514\")")

    remove_patterns() {
        local file=$1
        for pattern in "${patterns[@]}"; do
            sed -i "/${pattern//\//\\/}/d" "$file"
        done
    }

    
    if [[ -f $config_file ]]; then
        echo "Cleaning $config_file..."
        remove_patterns "$config_file"
    else
        echo "$config_file does not exist."
    fi

    
    if [[ -d $config_dir ]]; then
        echo "Cleaning files in $config_dir..."
        for file in "$config_dir"*.conf; do
            if [[ -f $file ]]; then
                remove_patterns "$file"
            fi
        done
    else
        echo "$config_dir does not exist."
    fi

    
    echo "Restarting rsyslog service..."
    systemctl restart rsyslog

    if [[ $? -eq 0 ]]; then
        echo "rsyslog service restarted successfully."
    else
        echo "Failed to restart rsyslog service."
        return 1
    fi

    return 0
}


install_rsyslog
enable_rsyslog
fix_filecreate_mode
fix_logging
fix_logs_from_remote
