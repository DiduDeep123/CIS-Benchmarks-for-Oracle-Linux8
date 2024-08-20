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

#Functon to install aide
install_aide() {
if grep -q "AIDE:NOT INSTALLED" $RESULT_FILE; then
	read -p "Do you want to install AIDE ? (y/n)" answer
	if [[ $answer = [Yy] ]]; then
	log_message "Installing AIDE..."
	dnf install aide
	log_message "AIDE installed."
	log_message "Initializing AIDE..."
	aide --init
	mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
	log_message "AIDE initialized."
	else
	select_no "User opted not to install AIDE."
	echo "AIDE NOT INSTALLED: REQUIRES CHANGE" >> $NEW_LOG_FILE
fi
fi
}

#Function to fix cryptographic mechanisms

CONF_DIR="/etc/aide.conf.d/"
CONF_FILE="/etc/aide.conf"
AIDE_RULES=(
    "/sbin/auditctl p+i+n+u+g+s+b+acl+xattrs+sha512"
    "/sbin/auditd p+i+n+u+g+s+b+acl+xattrs+sha512"
    "/sbin/ausearch p+i+n+u+g+s+b+acl+xattrs+sha512"
    "/sbin/aureport p+i+n+u+g+s+b+acl+xattrs+sha512"
    "/sbin/autrace p+i+n+u+g+s+b+acl+xattrs+sha512"
    "/sbin/augenrules p+i+n+u+g+s+b+acl+xattrs+sha512"
)

update_aide_config() {
    local file_path="$1"

    echo "Updating $file_path with audit tool integrity rules..."

    # Loop through the AIDE rules
    for rule in "${AIDE_RULES[@]}"; do
        # Check if the rule is already present in the file
        if grep -q "^${rule%% *}" "$file_path"; then
            echo "Rule '${rule}' already exists in $file_path."
        else
            # Add the rule to the file
            echo "$rule" >> "$file_path"
            echo "Added rule '${rule}' to $file_path."
        fi
    done
}

# Function to update AIDE configuration based on the presence of the main file
update_aide_configs() {
if grep -q "AIDE CONFIGURATION:INCOMPLETE" $RESULT_FILE; then
	read -p "Do you want to complete AIDE configuration ? (y/n)" answer
	if [[ $answer = [Yy] ]]; then
    if [[ -f $CONF_FILE ]]; then
        # If the main configuration file exists, update it
        update_aide_config "$CONF_FILE"
    else
        # If the main configuration file does not exist, update all .conf files in the directory
        if [[ -d $CONF_DIR ]]; then
            echo "$CONF_FILE not found. Updating all .conf files in $CONF_DIR..."
            for conf_file in "$CONF_DIR"*.conf; do
                update_aide_config "$conf_file"
            done
        else
            echo "$CONF_DIR does not exist. No configuration files to update."
        fi
    fi
	
	else
	select_no "User opted not to update AIDE configuration."
	echo "AIDE CONFIGURATION INCOMPLETE: REQUIRES CHANGE" >> $NEW_LOG_FILE
fi
fi
}
install_aide
update_aide_configs


