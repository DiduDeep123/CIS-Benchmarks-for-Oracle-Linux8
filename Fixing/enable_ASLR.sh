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
	
	
	PARAMETER="kernel.randomize_va_space"
	VALUE="2"
	SYSCTL_CONF="/etc/sysctl.conf"
	SYSCTL_D_DIR="/etc/sysctl.d/ "
	
	
#Fix ASLR

enable_ASLR() {

if grep -q "ASLR:NOT ENABLED" $RESULT_FILE; then
	read -p "Do you want to enable Address Space Layout Randomization(ASLR)? (y/n)" answer
	if [[ answer = [Yy] ]]; then
	
	file="$1"
	param="$2"
	value="$3"
	
	# Check if the parameter already exists in the file
    if grep -qP "^\s*$param\s*=" "$file"; then
        # Update the existing parameter
        sed -i "s|^\s*$param\s*=.*|$param = $value|" "$file"
    else
        # Add the parameter to the end of the file
        echo "$param = $value" >> "$file"
    fi
	else
	
	select_no "ASLR NOT ENABLED:REQUIRES CHANGE"
	
	fi 
	
fi
	
}
	
	# Check if /etc/sysctl.conf exists and contains the parameter
if [[ -f "$SYSCTL_CONF" ]]; then
    if grep -qP "^\s*$PARAM\s*=" "$SYSCTL_CONF"; then
        echo "Updating $PARAM in $SYSCTL_CONF"
        enable_ASLR "$SYSCTL_CONF" "$PARAM" "$VALUE"
    else
        echo "Adding $PARAM to $SYSCTL_CONF"
        echo "$PARAM = $VALUE" >> "$SYSCTL_CONF"
    fi
else
    echo "$SYSCTL_CONF does not exist. Selecting a file in /etc/sysctl.d/"
    
    # List files in /etc/sysctl.d/ and ask user to select one
    files=("$SYSCTL_D_DIR"/*.conf)
    
    if [[ ${#files[@]} -eq 0 ]]; then
        echo "No .conf files found in $SYSCTL_D_DIR."
        
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

    
    echo "Adding $PARAM to $FILE_PATH"
    enable_ASLR "$FILE_PATH" "$PARAM" "$VALUE"
fi

# Apply the new kernel parameter
echo "Setting active kernel parameter $PARAM=$VALUE"
sysctl -w "$PARAM=$VALUE"

read -p "Do you want to reload sysctl configuration to apply changes now? (y/n)" answer
if [[ answer = [Yy] ]]; then
sysctl --system
else
echo "Please reload the syctl configuration later to apply changes."
fi
	
	
	
	
	
	
	
