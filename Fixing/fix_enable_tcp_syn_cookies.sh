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
	

set_sysctl_ip_forward() {
    param="net.ipv4.tcp_syncookies"
    value="1"
    sysctl_conf="/etc/sysctl.conf"
    sysctl_conf_dir="/etc/sysctl.d/"
    
    
    # Function to update or add the parameter
    update_sysctl_conf() {
	if grep -q "TCP SYN COOKIES: DISABLED" $RESULT_FILE; then
	read -p "Do you want to enable ? (y/n)" answer
	if [[ answer = [Yy] ]]; then
        file="$1"
        if grep -qP "^\s*$param\s*=" "$file"; then
            # Update existing parameter
            sed -i "s|^\s*$param\s*=.*|$param=$value|" "$file"
        else
            # Add the parameter if it does not exist
            echo "$param=$value" >> "$file"
        fi
		else
	
		select_no "TCP SYN COOKIES DISABLED: REQUIRES CHANGE"
		fi
		
		fi
    }
    
    # Check if /etc/sysctl.conf exists and update it
    if [[ -f "$sysctl_conf" ]]; then
        echo "Updating $sysctl_conf"
        update_sysctl_conf "$sysctl_conf"
    else
        echo "$sysctl_conf does not exist. Selecting a file in $sysctl_conf_dir/"
        
        # List files in /etc/sysctl.d/ and select one if available
        local files=("$sysctl_conf_dir"/*.conf)
        
        if [[ ${#files[@]} -eq 0 ]]; then
            # No .conf files found
            echo "No .conf files found. 
        else
            # Prompt the user to select a file
            echo "Select a file to update from the following list:"
            select file in "${files[@]}"; do
                if [[ -n "$file" ]]; then
                    echo "Updating $file"
                    update_sysctl_conf "$file"
                    break
                else
                    echo "Invalid selection. Please try again."
                fi
            done
        fi
    fi

    echo "Applying sysctl changes"
    sysctl -w $param=$value
    sysctl -w net.ipv4.route.flush=1
}

set_sysctl_ip_forward
