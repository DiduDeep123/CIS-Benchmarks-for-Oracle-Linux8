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
	

declare -A SYSCTL_PARAMS
SYSCTL_PARAMS=(
    ["net.ipv4.conf.all.send_redirects"]="0"
    ["net.ipv4.conf.default.send_redirects"]="0"
)

SYSCTL_CONF="/etc/sysctl.conf"
SYSCTL_CONF_DIR="/etc/sysctl.d/"


# Function to update or add parameters
update_sysctl_conf() {
if grep -q "PACKET REDIRECT SENDING:ENABLED" $RESULT_FILE; then
	read -p "Do you want to enable ? (y/n)" answer
	if [[ $answer = [Yy] ]]; then
		file="$1"
    
    for param in "${!SYSCTL_PARAMS[@]}"; do
        value="${SYSCTL_PARAMS[$param]}"
        
        
        if grep -qP "^\s*$param\s*=" "$file"; then
            # Update the existing parameter
            sed -i "s|^\s*$param\s*=.*|$param=$value|" "$file"
        else
            # Add the parameter to the end of the file
            echo "$param=$value" >> "$file"
        fi
    done
	else
	
	select_no "PACKET REDIRECT SENDING ENABLED:REQUIRES CHANGE"
	
	fi
fi
}


if [[ -f "$SYSCTL_CONF" ]]; then
    echo "Updating parameters in $SYSCTL_CONF"
    update_sysctl_conf "$SYSCTL_CONF"
else
    echo "$SYSCTL_CONF does not exist. Selecting a file in $SYSCTL_CONF_DIR/"

    # List files in /etc/sysctl.d/ and ask user to select one
    files=("$SYSCTL_CONF_DIR"/*.conf)
    
    if [[ ${#files[@]} -eq 0 ]]; then
        echo "No .conf files found in $SYSCTL_CONF_DIR."

    else
        echo "Select a file from the following list:"
        select file in "${files[@]}"; do
            if [[ -n "$file" ]]; then
                FILE_PATH="$file"
                break
            else
                echo "Invalid selection. Please try again."
            fi
        done
    fi

   
    echo "Adding parameters to $FILE_PATH"
    update_sysctl_conf "$FILE_PATH"
fi


echo "Applying sysctl changes"
sysctl -p "$SYSCTL_CONF" 2>/dev/null || true
