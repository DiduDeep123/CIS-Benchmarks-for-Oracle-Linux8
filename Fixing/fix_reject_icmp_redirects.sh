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

        
        if grep -q "^${key}=" "$file"; then
           
            sed -i "s/^${key}=.*/${key}=${value}/" "$file"
        else
        
            echo "${key}=${value}" >> "$file"
        fi
    done
}


apply_sysctl_settings() {
    params=("$@")
    
    for param in "${params[@]}"; do
        sysctl -w "$param"
    done
}


apply_sysctl() {
    # IPv4 parameters
    local ipv4_params=("net.ipv4.conf.all.accept_redirects=0" "net.ipv4.conf.default.accept_redirects=0")
    # IPv6 parameters
    local ipv6_params=("net.ipv6.conf.all.accept_redirects=0" "net.ipv6.conf.default.accept_redirects=0")

   
    local sysctl_conf="/etc/sysctl.conf"
    local sysctl_d_dir="/etc/sysctl.d/"

    # Update /etc/sysctl.conf
	if grep -q "ICMP REDIRECTS: ACCEPTED" $RESULT_FILE; then
	read -p "Do you want to disable ip forwarding ? (y/n)" answer
	if [[ answer = [Yy] ]]; then
    if grep -q "^net.ipv4.conf.all.accept_redirects=" "$sysctl_conf"; then
        update_sysctl_conf "$sysctl_conf" "${ipv4_params[@]}"
    else
        echo -e "${ipv4_params[*]}" >> "$sysctl_conf"
    fi

    # Apply IPv4 settings
    apply_sysctl_settings "${ipv4_params[@]}" "net.ipv4.route.flush=1"

    
    if sysctl net.ipv6.conf.all.accept_redirects &>/dev/null; then
        if grep -q "^net.ipv6.conf.all.accept_redirects=" "$sysctl_conf"; then
            update_sysctl_conf "$sysctl_conf" "${ipv6_params[@]}"
        else
            echo -e "${ipv6_params[*]}" >> "$sysctl_conf"
        fi

        # Apply IPv6 settings
        apply_sysctl_settings "${ipv6_params[@]}" "net.ipv6.route.flush=1"
    fi

    # Check /etc/sysctl.d/ directory
    local conf_files=($(find "$sysctl_d_dir" -type f -name '*.conf'))

    for file in "${conf_files[@]}"; do
        if ! grep -q "^net.ipv4.conf.all.accept_redirects=" "$file"; then
            echo "net.ipv4.conf.all.accept_redirects=0" >> "$file"
        fi

        if ! grep -q "^net.ipv4.conf.default.accept_redirects=" "$file"; then
            echo "net.ipv4.conf.default.accept_redirects=0" >> "$file"
        fi

        if sysctl net.ipv6.conf.all.accept_redirects &>/dev/null; then
            if ! grep -q "^net.ipv6.conf.all.accept_redirects=" "$file"; then
                echo "net.ipv6.conf.all.accept_redirects=0" >> "$file"
            fi

            if ! grep -q "^net.ipv6.conf.default.accept_redirects=" "$file"; then
                echo "net.ipv6.conf.default.accept_redirects=0" >> "$file"
            fi
        fi
    done


    sysctl --system
	
	else
	
		select_no "ICMP REDIRECTS ACCEPTED:REQUIRES CHANGE"
	fi
	fi
}


apply_sysctl
