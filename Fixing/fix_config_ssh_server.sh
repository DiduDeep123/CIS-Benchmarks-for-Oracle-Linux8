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



# Function to modify /etc/ssh/sshd_config with multiple options
modify_sshd_config() {
    local option_choice
    local user_list=""
    local group_list=""

    # Array to store options
    declare -A options
    options=(
        [1]="AllowUsers"
        [2]="AllowGroups"
        [3]="DenyUsers"
        [4]="DenyGroups"
    )

    # Function to handle user input for each option
    set_option() {
        local option="$1"
        local list=""
        
        # Prompt for list input
        read -p "Enter the list of users/groups for $option (space-separated): " list
        
        # Append option and list to sshd_config
        echo "" | sudo tee -a /etc/ssh/sshd_config
        echo "# Added by script" | sudo tee -a /etc/ssh/sshd_config
        echo "$option $list" | sudo tee -a /etc/ssh/sshd_config
    }

    # Ask user for the options they want to enable
    echo "Please choose the options you want to enable (you can choose multiple, space-separated):"
    echo "1. AllowUsers"
    echo "2. AllowGroups"
    echo "3. DenyUsers"
    echo "4. DenyGroups"
    read -p "Enter the option numbers (e.g., 1 2 4): " option_choice

    # Backup existing sshd_config
    sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

    # Loop through user selections and apply changes
    for choice in $option_choice; do
        case "$choice" in
            1) set_option "AllowUsers" ;;
            2) set_option "AllowGroups" ;;
            3) set_option "DenyUsers" ;;
            4) set_option "DenyGroups" ;;
            *) echo "Invalid option number $choice. Skipping." ;;
        esac
    done

  
}

fix_sshd_config() {
if grep -q "SSH_CONFIG_FILES:INCORRECT" $RESULT_FILE; then
	read -p "Do you want to configure correct sshd access? (y/n)" answer
	if [[ answer = [Yy] ]]; then
   log_message "Configuring sshd access..."
    modify_sshd_config

  else
    select_no "/etc/ssh/sshd_config:REQUIRES CHANGE"
		
	fi

 fi
}


# Function to remediate Banner configuration above any Include entries
fix_sshd_banner() {
    local banner_file="/etc/issue.net"
    local sshd_config="/etc/ssh/sshd_config"

    # Backup the existing sshd_config file
    sudo cp "$sshd_config" "$sshd_config.bak"

    if grep -q "SSH_BANNER:NOT CONFIGURED" $RESULT_FILE; then
	read -p "Do you want to configure sshd banner? (y/n)" answer
	if [[ answer = [Yy] ]]; then
  log_message "Configuring sshd banner..."
    
    sudo sed -i "/^Include/i\\\n# Added by remediation script\nBanner $banner_file\n" "$sshd_config"

   
 else
    select_no "SSH_BANNER:REQUIRES CHANGE"
		
	fi

 fi
   
}


# Function to add/modify the Ciphers line with unapproved ciphers
fix_sshd_ciphers() {
    local weak_ciphers="-3des-cbc,aes128-cbc,aes192-cbc,aes256-cbc,rijndael-cbc@lysator.liu.se"
    local sshd_config="/etc/ssh/sshd_config"
 if grep -q "SSH_CIPHERS:WEAK" $RESULT_FILE; then
	read -p "Do you want to configure sshd ciphers? (y/n)" answer
	if [[ answer = [Yy] ]]; then
  log_message "Configuring sshd ciphers..."
    # Backup the existing sshd_config file
    sudo cp "$sshd_config" "$sshd_config.bak"

    # Insert or modify the Ciphers setting above any Include directive
   
    sudo sed -i "/^Include/i\\\n# Added by remediation script\nCiphers $weak_ciphers\n" "$sshd_config"

 else
    select_no "SSH_CIPHERS:REQUIRES CHANGE"
		
	fi

 fi
   
}



# Function to set ClientAliveInterval and ClientAliveCountMax above any Include entries
fix_client_alive_params() {
    local sshd_config="/etc/ssh/sshd_config"
    if grep -q "CLIENT_ALIVE_INTERVAL:FAIL" $RESULT_FILE; then
	read -p "Do you want to configure sshd  ClientAliveInterval and ClientAliveCountMax? (y/n)" answer
	if [[ answer = [Yy] ]]; then
  log_message "Configuring sshd ClientAliveInterval and ClientAliveCountMax "

    # Get user input for ClientAliveInterval and ClientAliveCountMax
    echo "Enter value for ClientAliveInterval (in seconds):"
    read client_alive_interval

    echo "Enter value for ClientAliveCountMax:"
    read client_alive_count_max

    # Backup the existing sshd_config file
    sudo cp "$sshd_config" "$sshd_config.bak"

    # Insert the ClientAliveInterval and ClientAliveCountMax settings above any Include directive
    sudo sed -i "/^Include/i\\\n# Added by script\nClientAliveInterval $client_alive_interval\nClientAliveCountMax $client_alive_count_max\n" "$sshd_config"
else
    select_no "CLIENT_ALIVE_INTERVAL:FAIL:REQUIRES CHANGE"
		
	fi

 fi
    

  
}


# Function to set DisableForwarding above any Include entries
fix_disable_forwarding() {
    local sshd_config="/etc/ssh/sshd_config"

    if grep -q "DISABLE_FORWARDING:FAIL" $RESULT_FILE || grep -q "DISABLE_FORWARDING_SET_TO_NO:FOUND" $RESULT_FILE; then
	read -p "Do you want to set DisableForwarding to yes ? (y/n)" answer
	if [[ answer = [Yy] ]]; then
  log_message "Setting disable forwarding to yes... "


    # Backup the existing sshd_config file
    sudo cp "$sshd_config" "$sshd_config.bak"

    # Insert the DisableForwarding setting above any Include directive
    sudo sed -i "/^Include/i\\\n# Added by script\nDisableForwarding yes\n" "$sshd_config"
else
  select_no "DISABLE_FORWARDING:REQUIRES CHANGE"
		
	fi

 fi
    

   
}



# Function to set HostbasedAuthentication above any Include entries
fix_hostbased_authentication() {
    local sshd_config="/etc/ssh/sshd_config"
     if grep -q "HOSTBASED_AUTHENTICATION:ENABLED" $RESULT_FILE || HOSTBASED_AUTHENTICATION_SET_TO_YES:FOUND $RESULT_FILE; then
	read -p "Do you want to set HostbasedAuthentication to no? (y/n)" answer
	if [[ answer = [Yy] ]]; then
  log_message "Setting HostbasedAuthentication to no... "

    # Backup the existing sshd_config file
    sudo cp "$sshd_config" "$sshd_config.bak"

    # Insert the HostbasedAuthentication setting above any Include directive
    
    sudo sed -i "/^Include/i\\\n# Added by script\nHostbasedAuthentication no\n" "$sshd_config"

    else
select_no "HOSTBASED_AUTHENTICATION:REQUIRES CHANGE"
		
	fi

 fi
   
}



# Function to set IgnoreRhosts above any Include entries
fix_ignore_rhosts() {
    local sshd_config="/etc/ssh/sshd_config"
if grep -q "IGNORE_RHOSTS:DISABLED" $RESULT_FILE || IGNORE_RHOSTS_SET_TO_NO:FOUND $RESULT_FILE; then
	read -p "Do you want to set IgnoreRhosts to yes? (y/n)" answer
	if [[ answer = [Yy] ]]; then
  log_message "Setting IgnoreRhosts to yes... "
    # Backup the existing sshd_config file
    sudo cp "$sshd_config" "$sshd_config.bak"

    # Insert or modify the IgnoreRhosts setting above any Include directive
    sudo sed -i "/^Include/i\\\n# Added by script\nIgnoreRhosts yes\n" "$sshd_config"

else
select_no "IGNORE_RHOSTS:REQUIRES CHANGE"
		
	fi

 fi
}



# Function to set KexAlgorithms above any Include entries
fix_kex_algorithms() {
    local sshd_config="/etc/ssh/sshd_config"
    local weak_algorithms="-diffie-hellman-group1-sha1,diffie-hellman-group14-sha1,diffie-hellman-group-exchange-sha1"
if grep -q "KEX_ALGORITHMS:WEAK" $RESULT_FILE; then
	read -p "Do you want to configure sshd KexAlgorithms? (y/n)" answer
	if [[ answer = [Yy] ]]; then
  log_message "Configuring sshd KexAlgorithms... "
    # Backup the existing sshd_config file
    sudo cp "$sshd_config" "$sshd_config.bak"

    # Insert or modify the KexAlgorithms setting above any Include directive
    sudo sed -i "/^Include/i\\\n# Added by script\nKexAlgorithms $weak_algorithms\n" "$sshd_config"

    else
select_no "KEX_ALGORITHMS:REQUIRES CHANGE"
		
	fi

 fi

    
}


# Function to set LoginGraceTime above any Include entries
fix_login_grace_time() {
    local sshd_config="/etc/ssh/sshd_config"
if grep -q "LOGIN_GRACE_TIME:FAIL" $RESULT_FILE || LOGIN_GRACE_TIME_CONFIG:FAIL $RESULT_FILE; then
	read -p "Do you want to configure LoginGraceTime ? (y/n)" answer
	if [[ answer = [Yy] ]]; then
  log_message "Configuring sshd LoginGraceTime... "
    read -p "Enter the value for LoginGraceTime (in seconds): " login_grace_time

    # ensure it's a positive integer
    if ! [[ "$login_grace_time" =~ ^[0-9]+$ ]]; then
        echo "Invalid input. Please enter a positive integer."
        exit 1
    fi

    # Backup the existing sshd_config file
    sudo cp "$sshd_config" "$sshd_config.bak"

    # Insert the LoginGraceTime setting above any Include directive
  
    sudo sed -i "/^Include/i\\\n# Added by script\nLoginGraceTime $login_grace_time\n" "$sshd_config"

   else
select_no "LOGIN_GRACE_TIME:REQUIRES CHANGE"
		
	fi

 fi

    

    
}



# Function to set LogLevel above any Include entries
fix_log_level() {
    local sshd_config="/etc/ssh/sshd_config"
if grep -q "LOGLEVEL:FAIL" $RESULT_FILE || LOGLEVEL_CONFIG:FAIL $RESULT_FILE; then
	read -p "Do you want to configure LoginGraceTime ? (y/n)" answer
	if [[ answer = [Yy] ]]; then
  log_message "Configuring sshd LogLevel... "
    # Prompt user to choose LogLevel
    echo "Choose the LogLevel to set:"
    echo "1. VERBOSE"
    echo "2. INFO"
    read -p "Enter the number corresponding to your choice (1 or 2): " choice

    # Determine the LogLevel based on user input
    case $choice in
        1)
            log_level="VERBOSE"
            ;;
        2)
            log_level="INFO"
            ;;
        *)
            echo "Invalid choice. Please enter 1 or 2."
            exit 1
            ;;
    esac

    # Backup the existing sshd_config file
    sudo cp "$sshd_config" "$sshd_config.bak"

    # Insert or modify the LogLevel setting above any Include directive

    sudo sed -i "/^Include/i\\\n# Added by script\nLogLevel $log_level\n" "$sshd_config"

 else
select_no "LOGLEVEL:REQUIRES CHANGE"
		
	fi

 fi
}



# Function to set MACs above any Include entries
fix_macs() {

    local sshd_config="/etc/ssh/sshd_config"
    local weak_macs="-hmac-md5,hmac-md5-96,hmac-ripemd160,hmac-sha1-96,umac64@openssh.com,hmac-md5-etm@openssh.com,hmac-md5-96-etm@openssh.com,hmac-ripemd160-etm@openssh.com,hmac-sha1-96-etm@openssh.com,umac-64-etm@openssh.com"
if grep -q "MACS:FAIL" $RESULT_FILE; then
	read -p "Do you want to configure sshd MACs ? (y/n)" answer
	if [[ answer = [Yy] ]]; then
  log_message "Configuring sshd MACs... "
    # Backup the existing sshd_config file
    sudo cp "$sshd_config" "$sshd_config.bak"

    # Insert the MACs setting above any Include directive
    sudo sed -i "/^Include/i\\\n# Added by script\nMACs $weak_macs\n" "$sshd_config"

 else
select_no "sshd MACs:REQUIRES CHANGE"
		
	fi

 fi

   
}

# Function to set MaxAuthTries above any Include entries
fix_max_auth_tries() {
    local sshd_config="/etc/ssh/sshd_config"
if grep -q "MAX_AUTH_TRIES:FAIL" $RESULT_FILE; then
	read -p "Do you want to configure sshd MaxAuthTries  ? (y/n)" answer
	if [[ answer = [Yy] ]]; then
  log_message "Configuring sshd MaxAuthTries... "
    # Prompt user for the MaxAuthTries value
    read -p "Enter the value for MaxAuthTries: " max_auth_tries

    # Validate the input to ensure it's a positive integer
    if ! [[ "$max_auth_tries" =~ ^[0-9]+$ ]]; then
        echo "Invalid input. Please enter a positive integer."
        exit 1
    fi

    # Backup the existing sshd_config file
    sudo cp "$sshd_config" "$sshd_config.bak"

    # Insert or modify the MaxAuthTries setting above any Include directive

    sudo sed -i "/^Include/i\\\n# Added by script\nMaxAuthTries $max_auth_tries\n" "$sshd_config"
else
select_no "MAX_AUTH_TRIES:REQUIRES CHANGE"
		
	fi

 fi

}


# Function to set MaxSessions above any Include entries
fix_max_sessions() {
    local sshd_config="/etc/ssh/sshd_config"
if grep -q "MAX_SESSIONS:FAIL" $RESULT_FILE; then
	read -p "Do you want to configure sshd MaxSessions  ? (y/n)" answer
	if [[ answer = [Yy] ]]; then
  log_message "Configuring sshd MaxSessions... "
    
    read -p "Enter the value for MaxSessions: " max_sessions

    # Validate the input to ensure it's a positive integer
    if ! [[ "$max_sessions" =~ ^[0-9]+$ ]]; then
        echo "Invalid input. Please enter a positive integer."
        exit 1
    fi

    # Backup the existing sshd_config file
    sudo cp "$sshd_config" "$sshd_config.bak"

    # Insert or modify the MaxSessions setting above any Include directive
   
    sudo sed -i "/^Include/i\\\n# Added by script\nMaxSessions $max_sessions\n" "$sshd_config"
else
select_no "MAX_SESSIONS:REQUIRES CHANGE"
		
	fi

 fi
}



# Function to set MaxStartups above any Include entries
fix_max_startups() {
    local sshd_config="/etc/ssh/sshd_config"
if grep -q "MAX_STARTUPS:FAIL" $RESULT_FILE; then
	read -p "Do you want to configure sshd MaxStartups  ? (y/n)" answer
	if [[ answer = [Yy] ]]; then
  log_message "Configuring sshd MaxStartups... "

    read -p "Enter the value for MaxStartups (format: <start>:<rate>:<full>): " max_startups

    # Validate the input to ensure it matches the format <start>:<rate>:<full>
    if ! [[ "$max_startups" =~ ^[0-9]+:[0-9]+:[0-9]+$ ]]; then
        echo "Invalid input. Please enter the value in the format <start>:<rate>:<full>, e.g., 10:30:60."
        exit 1
    fi

    # Backup the existing sshd_config file
    sudo cp "$sshd_config" "$sshd_config.bak"

    # Insert or modify the MaxStartups setting above any Include directive

    sudo sed -i "/^Include/i\\\n# Added by script\nMaxStartups $max_startups\n" "$sshd_config"
else
select_no "MAX_STARTUPS:REQUIRES CHANGE"
		
	fi

 fi
}



# Function to set PermitEmptyPasswords above any Include entries
fix_permit_empty_passwords() {
    local sshd_config="/etc/ssh/sshd_config"
    local permit_empty_passwords="no"

    if grep -q "PERMIT_EMPTY_PASSWORDS:FAIL" $RESULT_FILE; then
	read -p "Do you want to configure sshd PermitEmptyPasswords  ? (y/n)" answer
	if [[ answer = [Yy] ]]; then
  log_message "Configuring sshd PermitEmptyPasswords... "

    # Backup the existing sshd_config file
    sudo cp "$sshd_config" "$sshd_config.bak"

    # Insert or modify the PermitEmptyPasswords setting above any Include directive
   
    sudo sed -i "/^Include/i\\\n# Added by script\nPermitEmptyPasswords $permit_empty_passwords\n" "$sshd_config"
else
select_no "PERMIT_EMPTY_PASSWORDS:REQUIRES CHANGE"
		
	fi

 fi
}


# Function to set PermitRootLogin above any Include entries
fix_permit_root_login() {
    local sshd_config="/etc/ssh/sshd_config"
    local permit_root_login="no"
  if grep -q "PERMIT_ROOT_LOGIN:FAIL" $RESULT_FILE; then
	read -p "Do you want to configure sshd PermitRootLogin  ? (y/n)" answer
	if [[ answer = [Yy] ]]; then
  log_message "Configuring sshd PermitRootLogin... "
    # Backup the existing sshd_config file
    sudo cp "$sshd_config" "$sshd_config.bak"

    # Insert or modify the PermitRootLogin setting above any Include directive
    sudo sed -i "/^Include/i\\\n# Added by script\nPermitRootLogin $permit_root_login\n" "$sshd_config"
else
select_no "PERMIT_ROOT_LOGIN:REQUIRES CHANGE"
		
	fi

 fi
 
}


# Function to set PermitUserEnvironment above any Include entries
fix_permit_user_environment() {
    local sshd_config="/etc/ssh/sshd_config"
    local permit_user_environment="no"
if grep -q "PERMIT_USER_ENVIRONMENT:FAIL" $RESULT_FILE; then
	read -p "Do you want to configure sshd PermitUserEnvironment  ? (y/n)" answer
	if [[ answer = [Yy] ]]; then
 log_message "Configuring sshd PermitUserEnvironment... "
    # Backup the existing sshd_config file
    sudo cp "$sshd_config" "$sshd_config.bak"

    # Insert or modify the PermitUserEnvironment setting above any Include directive
   
    sudo sed -i "/^Include/i\\\n# Added by script\nPermitUserEnvironment $permit_user_environment\n" "$sshd_config"
else
select_no "PERMIT_USER_ENVIRONMENT:REQUIRES CHANGE"
		
	fi

 fi
   
}

# Function to set UsePAM above any Include entries
fix_use_pam() {
    local sshd_config="/etc/ssh/sshd_config"
    local use_pam="yes"
if grep -q "USE_PAM:FAIL" $RESULT_FILE; then
	read -p "Do you want to configure sshd UsePAM  ? (y/n)" answer
	if [[ answer = [Yy] ]]; then
 log_message "Configuring sshd UsePAM... "
    # Backup the existing sshd_config file
    sudo cp "$sshd_config" "$sshd_config.bak"

    # Insert or modify the UsePAM setting above any Include directive
    
    sudo sed -i "/^Include/i\\\n# Added by script\nUsePAM $use_pam\n" "$sshd_config"
else
select_no "USE_PAM:REQUIRES CHANGE"
		
	fi

 fi
    
}


# Function to comment out CRYPTO_POLICY lines in /etc/sysconfig/sshd
fix_sshd_crypto_policy() {
    local file="/etc/sysconfig/sshd"
if grep -q "CRYPTO_POLICY:FAIL" $RESULT_FILE; then
	read -p "Do you want to configure sshd CRYPTO_POLICY  ? (y/n)" answer
	if [[ answer = [Yy] ]]; then
 log_message "Configuring sshd CRYPTO_POLICY... "
  
    sudo sed -ri "s/^\s*(CRYPTO_POLICY\s*=.*)$/# \1/" "$file"
else
select_no "CRYPTO_POLICY:REQUIRES CHANGE"
		
	fi

 fi
    
}



fix_sshd_config
fix_sshd_banner
fix_sshd_ciphers 
set_client_alive_params
fix_disable_forwarding
fix_hostbased_authentication
fix_ignore_rhosts
fix_kex_algorithms
fix_login_grace_time
fix_log_level
fix_macs
fix_max_auth_tries
fix_max_sessions
fix_max_startups
fix_permit_empty_passwords
fix_permit_root_login
fix_permit_user_environment
fix_use_pam
fix_sshd_crypto_policy
# Restart the SSH service to apply changes
sudo systemctl restart sshd
