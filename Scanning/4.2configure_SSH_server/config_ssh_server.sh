#!/usr/bin/bash

LOG_FILE="/var/log/hardening_scan.log"
RESULT_FILE="/var/tmp/scan_results.txt"

# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $LOG_FILE	  #output to both screen and log file
}

check_ssh_config() {
    log_message "Checking SSHD configuration for allowed or denied users/groups..."

    # Get the hostname and IP address
    hostname=$(hostname)
    ip_address=$(grep "$hostname" /etc/hosts | awk '{print $1}')


    sshd_output=$(sshd -T -C user=root -C host="$hostname" -C addr="$ip_address" | grep -Pi '^\s*(allow|deny)(users|groups)\s+\S+(\s+.*)?$')

    
    if echo "$sshd_output" | grep -Eq '^\s*(allow|deny)(users|groups)\s+\S+(\s+.*)?$'; then
        log_message "SSHD configuration has correct allow/deny users/groups settings."
        echo "SSH_CONFIG_BANNER:CORRECT" >> "$RESULT_FILE"
    else
        log_message "SSHD configuration does not have the correct allow/deny users/groups settings."
        echo "SSH_CONFIG_BANNER:INCORRECT" >> "$RESULT_FILE"
    fi

    # Check the configuration files directly
    sshd_config_files="/etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf"
    config_output=$(grep -Pis '^\s*(allow|deny)(users|groups)\s+\S+(\s+.*)?$' $sshd_config_files)


    if echo "$config_output" | grep -Eq '^\s*(allow|deny)(users|groups)\s+\S+(\s+.*)?$'; then
        log_message "SSH configuration files have correct allow/deny users/groups settings."
        echo "SSH_CONFIG_FILES:CORRECT" >> "$RESULT_FILE"
    else
        log_message "SSH configuration files do not have the correct allow/deny users/groups settings."
        echo "SSH_CONFIG_FILES:INCORRECT" >> "$RESULT_FILE"
    fi
}

check_ssh_banner() {
    log_message "Checking SSH banner configuration..."

    # Get the hostname and IP address
    hostname=$(hostname)
    ip_address=$(grep "$hostname" /etc/hosts | awk '{print $1}')

    # get banner configuration
    sshd_output=$(sshd -T -C user=root -C host="$hostname" -C addr="$ip_address" | grep -i 'banner')

    # Verify the output
    if echo "$sshd_output" | grep -q '^banner /etc/issue.net'; then
        result="SSHD banner configuration is correct."
        echo "SSH_BANNER:CONFIGURED" >> "$RESULT_FILE"
    else
        result="SSHD banner configuration is not correct."
        echo "SSH_BANNER:NOT CONFIGURED" >> "$RESULT_FILE"
    fi

    log_message "$result"
}

check_ssh_ciphers() {
    log_message "Checking SSH ciphers configuration..."

    # Get the hostname and IP address
    hostname=$(hostname)
    ip_address=$(grep "$hostname" /etc/hosts | awk '{print $1}')

    sshd_output=$(sshd -T -C user=root -C host="$hostname" -C addr="$ip_address" | grep -i 'ciphers')

    # Define weak ciphers
    weak_ciphers="3des-cbc|aes128-cbc|aes192-cbc|aes256-cbc|rijndael-cbc@lysator.liu.se"

    # Check if any weak cipher is present
    if echo "$sshd_output" | grep -Pq "$weak_ciphers"; then
        result="SSHD configuration contains weak ciphers."
        echo "SSH_CIPHERS:WEAK" >> "$RESULT_FILE"
    else
        result="SSHD configuration does not contain weak ciphers."
        echo "SSH_CIPHERS:SECURE" >> "$RESULT_FILE"
    fi

    log_message "$result"
}


# Check SSH ClientAliveInterval and ClientAliveCountMax
check_ssh_alive_settings() {
    log_message "Checking SSH ClientAliveInterval and ClientAliveCountMax settings..."

    # Get the hostname and IP address
    hostname=$(hostname)
    ip_address=$(grep "$hostname" /etc/hosts | awk '{print $1}')

    # Check ClientAliveInterval
    client_alive_interval=$(sshd -T -C user=root -C host="$hostname" -C addr="$ip_address" | grep -i 'clientaliveinterval' | awk '{print $2}')
    
    if [ -n "$client_alive_interval" ] && [ "$client_alive_interval" -gt 0 ]; then
        result="ClientAliveInterval is set to $client_alive_interval, which is greater than zero."
        echo "CLIENT_ALIVE_INTERVAL:OK" >> "$RESULT_FILE"
    else
        result="ClientAliveInterval is not set correctly or is zero."
        echo "CLIENT_ALIVE_INTERVAL:FAIL" >> "$RESULT_FILE"
    fi

    log_message "$result"

    # Check ClientAliveCountMax
    client_alive_count_max=$(sshd -T -C user=root -C host="$hostname" -C addr="$ip_address" | grep -i 'clientalivecountmax' | awk '{print $2}')
    
    if [ -n "$client_alive_count_max" ] && [ "$client_alive_count_max" -gt 0 ]; then
        result="ClientAliveCountMax is set to $client_alive_count_max, which is greater than zero."
        echo "CLIENT_ALIVE_COUNT_MAX:OK" >> "$RESULT_FILE"
    else
        result="ClientAliveCountMax is not set correctly or is zero."
        echo "CLIENT_ALIVE_COUNT_MAX:FAIL" >> "$RESULT_FILE"
    fi

    log_message "$result"

    # Check for ClientAliveCountMax set to zero in configuration files
    if grep -Pis '^\s*ClientAliveCountMax\s+"?0\b' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf > /dev/null; then
        result="ClientAliveCountMax is set to zero in one or more configuration files."
        echo "CLIENT_ALIVE_COUNT_MAX_ZERO:FAIL" >> "$RESULT_FILE"
    else
        result="ClientAliveCountMax is not set to zero in configuration files."
        echo "CLIENT_ALIVE_COUNT_MAX_ZERO:OK" >> "$RESULT_FILE"
    fi

    log_message "$result"
}



# Check SSH disableforwarding setting
check_ssh_disableforwarding() {
    log_message "Checking SSH DisableForwarding setting..."

    # Get the hostname and IP address
    hostname=$(hostname)
    ip_address=$(grep "$hostname" /etc/hosts | awk '{print $1}')

    # Check the DisableForwarding setting
    disable_forwarding=$(sshd -T -C user=root -C host="$hostname" -C addr="$ip_address" | grep -i 'disableforwarding')

    if [[ "$disable_forwarding" =~ ^disableforwarding\s+yes$ ]]; then
        result="DisableForwarding is set to 'yes' in the SSH daemon configuration."
        echo "DISABLE_FORWARDING:OK" >> "$RESULT_FILE"
    else
        result="DisableForwarding is not set to 'yes' in the SSH daemon configuration."
        echo "DISABLE_FORWARDING:FAIL" >> "$RESULT_FILE"
    fi

    log_message "$result"

    # Check for DisableForwarding set to 'no' in configuration files
    if grep -Pis '^\s*DisableForwarding\s+"?no\b' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf > /dev/null; then
        result="DisableForwarding is set to 'no' in one or more configuration files."
        echo "DISABLE_FORWARDING_SET_TO_NO:FOUND" >> "$RESULT_FILE"
    else
        result="DisableForwarding is not set to 'yes' in all configuration files."
        echo "DISABLE_FORWARDING_SET_TO_NO:NOT FOUND" >> "$RESULT_FILE"
    fi

    log_message "$result"
}

# Check SSH HostbasedAuthentication setting
check_ssh_hostbased_authentication() {
    log_message "Checking SSH HostbasedAuthentication setting..."

    # Get the hostname and IP address
    hostname=$(hostname)
    ip_address=$(grep "$hostname" /etc/hosts | awk '{print $1}')

    # Check the HostbasedAuthentication setting
    hostbased_auth=$(sshd -T -C user=root -C host="$hostname" -C addr="$ip_address" | grep -i 'hostbasedauthentication')

    if [[ "$hostbased_auth" =~ ^hostbasedauthentication\s+no$ ]]; then
        result="HostbasedAuthentication is set to 'no' in the SSH daemon configuration."
        echo "HOSTBASED_AUTHENTICATION:DISABLED" >> "$RESULT_FILE"
    else
        result="HostbasedAuthentication is set to 'yes' in the SSH daemon configuration."
        echo "HOSTBASED_AUTHENTICATION:ENABLED" >> "$RESULT_FILE"
    fi

    log_message "$result"

    # Check for HostbasedAuthentication set to 'yes' in configuration files
    if grep -Pis '^\s*HostbasedAuthentication\s+"?yes"?\b' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf > /dev/null; then
        result="HostbasedAuthentication is set to 'yes' in one or more configuration files."
        echo "HOSTBASED_AUTHENTICATION_SET_TO_YES:FOUND" >> "$RESULT_FILE"
    else
        result="HostbasedAuthentication is set to 'no' in any configuration files."
        echo "HOSTBASED_AUTHENTICATION_SET_TO_YES:NOT FOUND" >> "$RESULT_FILE"
    fi

    log_message "$result"
}

check_ssh_ignore_rhosts() {
    log_message "Checking SSH IgnoreRhosts setting..."

    # Get the hostname and IP address
    hostname=$(hostname)
    ip_address=$(grep "$hostname" /etc/hosts | awk '{print $1}')

    # Check the IgnoreRhosts setting
    ignore_rhosts=$(sshd -T -C user=root -C host="$hostname" -C addr="$ip_address" | grep -i 'ignorerhosts')

    if [[ "$ignore_rhosts" =~ ^ignorerhosts\s+yes$ ]]; then
        result="IgnoreRhosts is set to 'yes' in the SSH daemon configuration."
        echo "IGNORE_RHOSTS:ENABLED" >> "$RESULT_FILE"
    else
        result="IgnoreRhosts is set to 'no' in the SSH daemon configuration."
        echo "IGNORE_RHOSTS:DISABLED" >> "$RESULT_FILE"
    fi

    log_message "$result"

    # Check for IgnoreRhosts set to 'no' in configuration files
    if grep -Pis '^\s*IgnoreRhosts\s+"?no"?\b' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf > /dev/null; then
        result="IgnoreRhosts is set to 'no' in one or more configuration files."
        echo "IGNORE_RHOSTS_SET_TO_NO:FOUND" >> "$RESULT_FILE"
    else
        result="IgnoreRhosts is set to 'yes' in all configuration files."
        echo "IGNORE_RHOSTS_SET_TO_NO:NOT FOUND" >> "$RESULT_FILE"
    fi

    log_message "$result"
}

check_ssh_kex_algorithms() {
    log_message "Checking SSH Key Exchange Algorithms..."

    # Get the hostname and IP address
    hostname=$(hostname)
    ip_address=$(grep "$hostname" /etc/hosts | awk '{print $1}')

    # Check the Key Exchange Algorithms
    kex_algorithms=$(sshd -T -C user=root -C host="$hostname" -C addr="$ip_address" | grep -i 'kexalgorithms')

    # List of weak KEX algorithms
    weak_kex_algorithms=(
        "diffie-hellman-group1-sha1"
        "diffie-hellman-group14-sha1"
        "diffie-hellman-group-exchange-sha1"
    )

    weak_found=false

    for weak_algo in "${weak_kex_algorithms[@]}"; do
        if echo "$kex_algorithms" | grep -qi "$weak_algo"; then
            weak_found=true
            break
        fi
    done

    if $weak_found; then
        result="Weak Key Exchange algorithms are present in the SSH configuration."
        echo "KEX_ALGORITHMS:WEAK" >> "$RESULT_FILE"
    else
        result="No weak Key Exchange algorithms are present in the SSH configuration."
        echo "KEX_ALGORITHMS:OK" >> "$RESULT_FILE"
    fi

    log_message "$result"
}

check_login_gracetime() {
    log_message "Checking SSH LoginGraceTime configuration..."

    # Get the hostname and IP address
    hostname=$(hostname)
    ip_address=$(grep "$hostname" /etc/hosts | awk '{print $1}')

    # Check the LoginGraceTime using sshd -T
    login_gracetime=$(sshd -T -C user=root -C host="$hostname" -C addr="$ip_address" | grep -i 'logingracetime')

    # Desired range of LoginGraceTime
    if [[ "$login_gracetime" =~ ^logingracetime\ ([1-5]?[0-9]|60|1m)$ ]]; then
        result="LoginGraceTime is within the acceptable range."
        echo "LOGIN_GRACE_TIME:OK" >> "$RESULT_FILE"
    else
        result="LoginGraceTime is outside the acceptable range or not set correctly."
        echo "LOGIN_GRACE_TIME:FAIL" >> "$RESULT_FILE"
    fi

    log_message "$result"

    # Check sshd_config files for invalid LoginGraceTime values
    invalid_values=$(grep -Pis '^\h*LoginGraceTime\h+"?(0|6[1-9]|[7-9][0-9]|[1-9][0-9][0-9]+|[^1]m)\b' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf)

    if [[ -z "$invalid_values" ]]; then
        log_message "SSH configuration files do not contain invalid LoginGraceTime values."
        echo "LOGIN_GRACE_TIME_CONFIG:OK" >> "$RESULT_FILE"
    else
        log_message "SSH configuration files contain invalid LoginGraceTime values."
        echo "LOGIN_GRACE_TIME_CONFIG:FAIL" >> "$RESULT_FILE"
    fi
}


# Check SSH LogLevel
check_loglevel() {
    log_message "Checking SSH LogLevel configuration..."

    # Get the hostname and IP address
    hostname=$(hostname)
    ip_address=$(grep "$hostname" /etc/hosts | awk '{print $1}')

    # Check the LogLevel using sshd -T
    loglevel_output=$(sshd -T -C user=root -C host="$hostname" -C addr="$ip_address" | grep -i 'loglevel')

    # Check if LogLevel is either VERBOSE or INFO
    if [[ "$loglevel_output" =~ ^loglevel\ (VERBOSE|INFO)$ ]]; then
        result="LogLevel is correctly set to VERBOSE or INFO."
        echo "LOGLEVEL:OK" >> "$RESULT_FILE"
    else
        result="LogLevel is not set to VERBOSE or INFO."
        echo "LOGLEVEL:FAIL" >> "$RESULT_FILE"
    fi

    log_message "$result"

    # Check sshd_config files for invalid LogLevel values
    invalid_loglevels=$(grep -Pis '^\h*LogLevel\h+' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf | grep -Pvi '(VERBOSE|INFO)')

    if [[ -z "$invalid_loglevels" ]]; then
        log_message "SSH configuration files do not contain invalid LogLevel values."
        echo "LOGLEVEL_CONFIG:OK" >> "$RESULT_FILE"
    else
        log_message "SSH configuration files contain invalid LogLevel values."
        echo "LOGLEVEL_CONFIG:FAIL" >> "$RESULT_FILE"
    fi
}

check_macs() {
    log_message "Checking SSH MACs configuration..."

    # Get hostname and IP address
    hostname=$(hostname)
    ip_address=$(grep "$hostname" /etc/hosts | awk '{print $1}')

    # Get MACs from sshd -T
    macs_output=$(sshd -T -C user=root -C host="$hostname" -C addr="$ip_address" | grep -i 'macs')

    # List of weak MAC algorithms
    weak_macs=(
        "hmac-md5"
        "hmac-md5-96"
        "hmac-ripemd160"
        "hmac-sha1-96"
        "umac-64@openssh.com"
        "hmac-md5-etm@openssh.com"
        "hmac-md5-96-etm@openssh.com"
        "hmac-ripemd160-etm@openssh.com"
        "hmac-sha1-96-etm@openssh.com"
        "umac-64-etm@openssh.com"
    )

    # Check if any weak MACs are present
    weak_mac_found=false
    for weak_mac in "${weak_macs[@]}"; do
        if echo "$macs_output" | grep -q "$weak_mac"; then
            weak_mac_found=true
            break
        fi
    done

    if $weak_mac_found; then
        result="Weak MAC algorithms are present in SSH configuration."
        echo "MACS:FAIL" >> "$RESULT_FILE"
    else
        result="No weak MAC algorithms found in SSH configuration."
        echo "MACS:SUCCESS" >> "$RESULT_FILE"
    fi

    log_message "$result"
}

# Check MaxAuthTries configuration
check_max_auth_tries() {
    log_message "Checking MaxAuthTries configuration..."

    # Get hostname and IP address
    hostname=$(hostname)
    ip_address=$(grep "$hostname" /etc/hosts | awk '{print $1}')

    
    max_auth_tries_output=$(sshd -T -C user=root -C host="$hostname" -C addr="$ip_address" | grep -i 'maxauthtries')

    # Check if MaxAuthTries is 4 or less
    if echo "$max_auth_tries_output" | awk '{print $2}' | awk '$1 <= 4' > /dev/null; then
        result="MaxAuthTries is configured to 4 or fewer."
        echo "MAX_AUTH_TRIES:SUCCESS" >> "$RESULT_FILE"
    else
        result="MaxAuthTries is configured to more than 4."
        echo "MAX_AUTH_TRIES:FAIL" >> "$RESULT_FILE"
    fi

    log_message "$result"

    # Check configuration files for MaxAuthTries greater than 4
    if grep -Pis '^\s*MaxAuthTries\s+"?([5-9]|[1-9][0-9]+)\b' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf > /dev/null; then
        result="MaxAuthTries is set to more than 4 in one or more configuration files."
        echo "MAX_AUTH_TRIES:FAIL" >> "$RESULT_FILE"
    else
        result="MaxAuthTries is correctly configured in all files."
        echo "MAX_AUTH_TRIES:SUCCESS" >> "$RESULT_FILE"
    fi

    log_message "$result"
}

# Check MaxSessions configuration
check_max_sessions() {
    log_message "Checking MaxSessions configuration..."

    # Get hostname and IP address
    hostname=$(hostname)
    ip_address=$(grep "$hostname" /etc/hosts | awk '{print $1}')

    max_sessions_output=$(sshd -T -C user=root -C host="$hostname" -C addr="$ip_address" | grep -i 'maxsessions')

    # Check if MaxSessions is 10 or less
    if echo "$max_sessions_output" | awk '{print $2}' | awk '$1 <= 10' > /dev/null; then
        result="MaxSessions is configured to 10 or fewer."
        echo "MAX_SESSIONS:SUCCESS" >> "$RESULT_FILE"
    else
        result="MaxSessions is configured to more than 10."
        echo "MAX_SESSIONS:FAIL" >> "$RESULT_FILE"
    fi

    log_message "$result"

    # Check configuration files for MaxSessions greater than 10
    if grep -Pis '^\s*MaxSessions\s+"?(1[1-9]|[2-9][0-9]|[1-9][0-9][0-9]+)\b' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf > /dev/null; then
        result="MaxSessions is set to more than 10 in one or more configuration files."
        echo "MAX_SESSIONS:FAIL" >> "$RESULT_FILE"
    else
        result="MaxSessions is correctly configured in all files."
        echo "MAX_SESSIONS:SUCCESS" >> "$RESULT_FILE"
    fi

    log_message "$result"
}

# Check MaxStartups configuration
check_max_startups() {
    log_message "Checking MaxStartups configuration..."

    # Get hostname and IP address
    hostname=$(hostname)
    ip_address=$(grep "$hostname" /etc/hosts | awk '{print $1}')

    # Get MaxStartups from sshd -T
    max_startups_output=$(sshd -T -C user=root -C host="$hostname" -C addr="$ip_address" | grep -i 'maxstartups')

    # Check if MaxStartups is 10:30:60 or more restrictive
    if echo "$max_startups_output" | awk '{print $2}' | grep -P '^10:30:60|^[1-9][0-9]*:[0-9]+:[0-9]+$|^[1-9][0-9]*:[3-9][0-9]+:[0-9]+$|^[1-9][0-9]*:[0-9]+:[6-9][0-9]+$' > /dev/null; then
        result="MaxStartups is configured to 10:30:60 or more restrictive."
        echo "MAX_STARTUPS:SUCCESS" >> "$RESULT_FILE"
    else
        result="MaxStartups is not configured to 10:30:60 or more restrictive."
        echo "MAX_STARTUPS:FAIL" >> "$RESULT_FILE"
    fi

    log_message "$result"

    # Check configuration files for MaxStartups less restrictive than 10:30:60
    if grep -Pis '^\s*MaxStartups\s+"?((\d{1,2}:\d{1,2}:\d{1,2})|((\d{1,2}):([3-9][0-9]+):([0-9]+))|((\d{1,2}):([0-9]+):(6[1-9][0-9]+)))\b' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf | grep -Pv '^10:30:60' > /dev/null; then
        result="MaxStartups is set to a value less restrictive than 10:30:60 in one or more configuration files."
        echo "MAX_STARTUPS:FAIL" >> "$RESULT_FILE"
    else
        result="MaxStartups is correctly configured in all files."
        echo "MAX_STARTUPS:SUCCESS" >> "$RESULT_FILE"
    fi

    log_message "$result"
}

# Check PermitEmptyPasswords configuration
check_permit_empty_passwords() {
    log_message "Checking PermitEmptyPasswords configuration..."

    # Get hostname and IP address
    hostname=$(hostname)
    ip_address=$(grep "$hostname" /etc/hosts | awk '{print $1}')

    # Get PermitEmptyPasswords from sshd -T
    permit_empty_passwords_output=$(sshd -T -C user=root -C host="$hostname" -C addr="$ip_address" | grep -i 'permitemptypasswords')

    # Check if PermitEmptyPasswords is set to 'no'
    if echo "$permit_empty_passwords_output" | awk '{print $2}' | grep -i '^no$' > /dev/null; then
        result="PermitEmptyPasswords is correctly set to 'no'."
        echo "PERMIT_EMPTY_PASSWORDS:SUCCESS" >> "$RESULT_FILE"
    else
        result="PermitEmptyPasswords is set to 'yes'."
        echo "PERMIT_EMPTY_PASSWORDS:FAIL" >> "$RESULT_FILE"
    fi

    log_message "$result"

    # Check configuration files for PermitEmptyPasswords set to 'yes'
    if grep -Pis '^\s*PermitEmptyPasswords\s+"?yes\b' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf > /dev/null; then
        result="PermitEmptyPasswords is set to 'yes' in one or more configuration files."
        echo "PERMIT_EMPTY_PASSWORDS:FAIL" >> "$RESULT_FILE"
    else
        result="PermitEmptyPasswords is set to 'no' in all configuration file."
        echo "PERMIT_EMPTY_PASSWORDS:SUCCESS" >> "$RESULT_FILE"
    fi

    log_message "$result"
}

# Check PermitRootLogin configuration
check_permit_root_login() {
    log_message "Checking PermitRootLogin configuration..."

    # Get hostname and IP address
    hostname=$(hostname)
    ip_address=$(grep "$hostname" /etc/hosts | awk '{print $1}')

    # Get PermitRootLogin from sshd -T
    permit_root_login_output=$(sshd -T -C user=root -C host="$hostname" -C addr="$ip_address" | grep -i 'permitrootlogin')

    # Check if PermitRootLogin is set to 'no'
    if echo "$permit_root_login_output" | awk '{print $2}' | grep -i '^no$' > /dev/null; then
        result="PermitRootLogin is correctly set to 'no'."
        echo "PERMIT_ROOT_LOGIN:SUCCESS" >> "$RESULT_FILE"
    else
        result="PermitRootLogin is set to 'yes'."
        echo "PERMIT_ROOT_LOGIN:FAIL" >> "$RESULT_FILE"
    fi

    log_message "$result"

    # Check configuration files for PermitRootLogin values
    if grep -Pis '^\s*PermitRootLogin\s+"?(yes|prohibit-password|forced-commands-only)"?\b' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf > /dev/null; then
        result="PermitRootLogin is set to 'yes', 'prohibit-password', or 'forced-commands-only' in one or more configuration files."
        echo "PERMIT_ROOT_LOGIN:FAIL" >> "$RESULT_FILE"
    else
        result="PermitRootLogin is set to 'no', 'prohibit-password', or 'forced-commands-only' in any configuration file."
        echo "PERMIT_ROOT_LOGIN:SUCCESS" >> "$RESULT_FILE"
    fi

    log_message "$result"
}

# Check PermitUserEnvironment configuration
check_permit_user_environment() {
    log_message "Checking PermitUserEnvironment configuration..."

    # Get hostname and IP address
    hostname=$(hostname)
    ip_address=$(grep "$hostname" /etc/hosts | awk '{print $1}')

    # Get PermitUserEnvironment from sshd -T
    permit_user_environment_output=$(sshd -T -C user=root -C host="$hostname" -C addr="$ip_address" | grep -i 'permituserenvironment')

    # Check if PermitUserEnvironment is set to 'no'
    if echo "$permit_user_environment_output" | awk '{print $2}' | grep -i '^no$' > /dev/null; then
        result="PermitUserEnvironment is correctly set to 'no'."
        echo "PERMIT_USER_ENVIRONMENT:SUCCESS" >> "$RESULT_FILE"
    else
        result="PermitUserEnvironment is set to 'yes'."
        echo "PERMIT_USER_ENVIRONMENT:FAIL" >> "$RESULT_FILE"
    fi

    log_message "$result"

    # Check configuration files for PermitUserEnvironment values
    if grep -Pis '^\s*PermitUserEnvironment\s+"?yes"?\b' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf > /dev/null; then
        result="PermitUserEnvironment is set to 'yes' in one or more configuration files."
        echo "PERMIT_USER_ENVIRONMENT:FAIL" >> "$RESULT_FILE"
    else
        result="PermitUserEnvironment is set to 'no' in all configuration file."
        echo "PERMIT_USER_ENVIRONMENT:SUCCESS" >> "$RESULT_FILE"
    fi

    log_message "$result"
}

# Check UsePAM configuration
check_use_pam() {
    log_message "Checking UsePAM configuration..."

    # Get hostname and IP address
    hostname=$(hostname)
    ip_address=$(grep "$hostname" /etc/hosts | awk '{print $1}')

    # Get UsePAM from sshd -T
    use_pam_output=$(sshd -T -C user=root -C host="$hostname" -C addr="$ip_address" | grep -i 'usepam')

    # Check if UsePAM is set to 'yes'
    if echo "$use_pam_output" | awk '{print $2}' | grep -i '^yes$' > /dev/null; then
        result="UsePAM is correctly set to 'yes'."
        echo "USE_PAM:SUCCESS" >> "$RESULT_FILE"
    else
        result="UsePAM is not set to 'yes'."
        echo "USE_PAM:FAIL" >> "$RESULT_FILE"
    fi

    log_message "$result"

    # Check configuration files for UsePAM values
    if grep -Pis '^\s*UsePAM\s+"?no"?\b' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf > /dev/null; then
        result="UsePAM is set to 'no' in one or more configuration files."
        echo "USE_PAM:FAIL" >> "$RESULT_FILE"
    else
        result="UsePAM is set to 'yes' in all configuration file."
        echo "USE_PAM:SUCCESS" >> "$RESULT_FILE"
    fi

    log_message "$result"
}

# Check CRYPTO_POLICY in /etc/sysconfig/sshd
check_crypto_policy() {
    log_message "Checking CRYPTO_POLICY setting in /etc/sysconfig/sshd..."

    # Search for CRYPTO_POLICY
    if grep -Pi '^\s*CRYPTO_POLICY\s*=' /etc/sysconfig/sshd > /dev/null; then
        result="CRYPTO_POLICY is set in /etc/sysconfig/sshd."
        echo "CRYPTO_POLICY:FAIL" >> "$RESULT_FILE"
    else
        result="CRYPTO_POLICY is not set in /etc/sysconfig/sshd."
        echo "CRYPTO_POLICY:SUCCESS" >> "$RESULT_FILE"
    fi

    log_message "$result"
}
check_ssh_banner
check_ssh_config
check_ssh_ciphers
check_ssh_alive_settings
check_ssh_disableforwarding
check_ssh_hostbased_authentication
check_ssh_ignore_rhosts
check_ssh_kex_algorithms
check_login_gracetime
check_loglevel
check_macs
check_max_auth_tries
check_max_sessions
check_max_startups
check_permit_empty_passwords
check_permit_root_login
check_permit_user_environment
check_use_pam
check_crypto_policy
