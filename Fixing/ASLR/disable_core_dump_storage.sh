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


PARAM="Storage"
VALUE="none"
CORE_DUMP_CONF="/etc/systemd/coredump.conf"
CORE_DUMP_CONF_DIR="/etc/systemd/coredump.conf.d"


# Function to update or add the parameter
update_core_dump_conf() {
if grep -q "CORE DUMP STORAGE:NOT DISABLED" $RESULT_FILE; then
	read -p "Do you want to disable coredump backtraces? (y/n)" answer
	if [[ answer = [Yy] ]]; then
    local file="$1"
    local param="$2"
    local value="$3"
    
    # Check if the parameter already exists in the file
    if grep -qP "^\s*$param\s*=" "$file"; then
        # Update the existing parameter
        sed -i "s|^\s*$param\s*=.*|$param=$value|" "$file"
    else
        # Add the parameter to the end of the file
        echo "$param=$value" >> "$file"
    fi
	else
	select_no "CORE DUMP STORAGE NOT DISABLED: REQUIRES CHANGE"
	fi
	fi
}

# Check if /etc/systemd/coredump.conf exists and update it
if [[ -f "$CORE_DUMP_CONF" ]]; then
    echo "Updating $PARAM in $CORE_DUMP_CONF"
    update_core_dump_conf "$CORE_DUMP_CONF" "$PARAM" "$VALUE"
else
    echo "$CORE_DUMP_CONF does not exist. Selecting a file in $CORE_DUMP_CONF_DIR/"

    # List files in /etc/systemd/coredump.conf.d/ and ask user to select one
    files=("$CORE_DUMP_CONF_DIR"/*.conf)
    
    if [[ ${#files[@]} -eq 0 ]]; then
        echo "No .conf files found in $CORE_DUMP_CONF_DIR."
		read -p "Do you want to create a new file? (y/n)" answer
		if [[ answer = [Yy] ]]; then
        echo "Creating a new file."
        FILE_PATH="$NEW_CONF_FILE"
		fi
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

    # Ensure the selected file is present and add/update the parameter
    echo "Adding $PARAM to $FILE_PATH"
    update_core_dump_conf "$FILE_PATH" "$PARAM" "$VALUE"
fi

read -p "Do you want to reload sysctl configuration to apply changes now? (y/n)" answer
if [[ answer = [Yy] ]]; then
echo "Reloading systemd configuration"
systemctl --system daemon-reload
else
echo "RELOAD SYSCTL CONFIGURATION:REQUIRED" >> $NEW_LOG_FILE
fi
