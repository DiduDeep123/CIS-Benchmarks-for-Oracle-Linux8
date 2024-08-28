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

# Function to add or update sysctl parameters in a specified file
update_sysctl_conf() {
    file="$1"
    params=("${@:2}")

    for param in "${params[@]}"; do
        key="${param%%=*}"
        value="${param#*=}"

        # Check if the parameter already exists in the file
        if grep -q "^${key}=" "$file"; then
           
            sed -i "s/^${key}=.*/${key}=${value}/" "$file"
        else
            
            echo "${key}=${value}" >> "$file"
        fi
    done
}

# Function to apply sysctl settings
apply_sysctl_settings() {
    params=("$@")
    
    for param in "${params[@]}"; do
        sysctl -w "$param"
    done
}

apply_sysctl() {
    # Parameters to set
    params=("net.ipv6.conf.all.accept_ra = 0" "net.ipv6.conf.default.accept_ra = 0")

    # File paths
    sysctl_conf="/etc/sysctl.conf"
    sysctl_d_dir="/etc/sysctl.d/"

    # Update /etc/sysctl.conf
	if grep -q "IPV6 ROUTER ADVERTISEMENTS: NOT ACCEPTED" $RESULT_FILE; then
	read -p "Do you want to ensure ipv6 router advertisements are not accepted ? (y/n)" answer
	if [[ answer = [Yy] ]]; then
    for param in "${params[@]}"; do
        key="${param%%=*}"
        value="${param#*=}"

        if grep -q "^${key}=" "$sysctl_conf"; then
            # Update the existing parameter
            sed -i "s/^${key}=.*/${key}=${value}/" "$sysctl_conf"
        else
            # Add the new parameter
            echo "${param}" >> "$sysctl_conf"
        fi
    done

    # Apply IPv4 settings
    apply_sysctl_settings "${params[@]}" "net.ipv4.route.flush=1"

    # Check /etc/sysctl.d/ directory
    local conf_files=($(find "$sysctl_d_dir" -type f -name '*.conf'))

    for file in "${conf_files[@]}"; do
        for param in "${params[@]}"; do
            if ! grep -q "^${param%%=*}=" "$file"; then
                echo "${param}" >> "$file"
            fi
        done
    done
	

    # Reapply sysctl settings from all files
    sysctl --system
	
	else
	select_no "IPV6 ROUTER ADVERTISEMENTS NOT ACCEPTED: REQUIRES CHANGE"
	fi
	fi
}



apply_sysctl
