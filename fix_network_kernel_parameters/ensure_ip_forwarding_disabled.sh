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
	

# Function to add or update sysctl parameter in a specified file
update_sysctl_conf() {
    file="$1"
    param="$2"
    value="$3"

   
    
	if grep -q "^${param}=" "$file"; then
        # Update the existing parameter
        sed -i "s/^${param}=.*/${param}=${value}/" "$file"
    else
        # Add the new parameter
        echo "${param}=${value}" >> "$file"
    fi
	
}

# Function to apply sysctl settings
apply_sysctl_settings() {
    param1="$1"
    param2="$2"
    
    sysctl -w "$param1"
    sysctl -w "$param2"
}


apply_sysctl() {
   
    ipv4_param="net.ipv4.ip_forward"
    ipv6_param="net.ipv6.conf.all.forwarding"
    
    
    sysctl_conf="/etc/sysctl.conf"
    sysctl_d_dir="/etc/sysctl.d/"
    
  
	if grep -q "IP FORWARDING:ENABLED" $RESULT_FILE; then
	read -p "Do you want to disable ip forwarding ? (y/n)" answer
	if [[ $answer = [Yy] ]]; then
    if grep -q "^${ipv4_param}=" "$sysctl_conf"; then
        update_sysctl_conf "$sysctl_conf" "$ipv4_param" "0"
    else
        echo "${ipv4_param}=0" >> "$sysctl_conf"
    fi

    
    apply_sysctl_settings "$ipv4_param=0" "net.ipv4.route.flush=1"
    

    if sysctl net.ipv6.conf.all.forwarding &>/dev/null; then
        if grep -q "^${ipv6_param}=" "$sysctl_conf"; then
            update_sysctl_conf "$sysctl_conf" "$ipv6_param" "0"
        else
            echo "${ipv6_param}=0" >> "$sysctl_conf"
        fi

        # Apply IPv6 settings
        apply_sysctl_settings "$ipv6_param=0" "net.ipv6.route.flush=1"
    fi

    # Check /etc/sysctl.d/ directory
    local conf_files=($(find "$sysctl_d_dir" -type f -name '*.conf'))

    for file in "${conf_files[@]}"; do
        if ! grep -q "^${ipv4_param}=" "$file"; then
            echo "${ipv4_param}=0" >> "$file"
        fi

        if ! grep -q "^${ipv6_param}=" "$file" && sysctl net.ipv6.conf.all.forwarding &>/dev/null; then
            echo "${ipv6_param}=0" >> "$file"
        fi
    done

    
    sysctl --system
	
	else
	
		select_no "IP FORWARDING NOT DISABLED:REQUIRES CHANGE"
	fi
	fi
}


apply_sysctl

