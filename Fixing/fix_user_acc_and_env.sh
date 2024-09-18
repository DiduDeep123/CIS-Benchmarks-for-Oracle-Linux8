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



set_crypt_style_sha512() {
    local config_file="/etc/libuser.conf"
    local crypt_style="crypt_style = sha512"
     if grep -q "CRYPT STYLE:WEAK" $RESULT_FILE; then
	read -p "Do you want to set the crypt style to sha512 in /etc/libuser.conf? (y/n)" answer
	if [[ answer = [Yy] ]]; then
  log_message "Setting the crypt style to sha512 in /etc/libuser.conf..."
    if [ ! -f "$config_file" ]; then
        echo "Error: $config_file not found!"
        return 1
    fi
    
   
    if grep -q "^crypt_style" "$config_file"; then
       
        sed -i "s/^crypt_style.*/$crypt_style/" "$config_file"
        echo "Updated crypt_style to sha512 in $config_file."
    else
      
        echo "$crypt_style" >> "$config_file"
        echo "Added crypt_style = sha512 to $config_file."
    fi

     else
    select_no "CRYPT STYLE:WEAK:REQUIRES CHANGE"
		
	fi

 fi
}


set_encrypt_method_sha512() {
    local config_file="/etc/login.defs"
    local encrypt_method="ENCRYPT_METHOD SHA512"
 if grep -q "ENCRYPT_METHOD:WEAK" $RESULT_FILE; then
	read -p "Do you want to set the encrypt method to sha512 in /etc/login.defs? (y/n)" answer
	if [[ answer = [Yy] ]]; then
  log_message "Setting the encrypt method to sha512 in /etc/login.defs..."
    if [ ! -f "$config_file" ]; then
        echo "Error: $config_file not found!"
        return 1
    fi

    if grep -q "^ENCRYPT_METHOD" "$config_file"; then
        sed -i "s/^ENCRYPT_METHOD.*/$encrypt_method/" "$config_file"
        echo "Updated ENCRYPT_METHOD to SHA512 in $config_file."
    else
        echo "$encrypt_method" >> "$config_file"
        echo "Added ENCRYPT_METHOD = SHA512 to $config_file."
    fi
      else
    select_no "ENCRYPT_METHOD:WEAK:REQUIRES CHANGE"
		
	fi

 fi
}


set_pass_max_days() {
    local config_file="/etc/login.defs"
    local pass_max_days="PASS_MAX_DAYS 365"
 if grep -q "PASS_MAX_DAYS:REQUIRES CHANGE" $RESULT_FILE; then
	read -p "Do you want to set the PASS_MAX_DAYS in /etc/login.defs? (y/n)" answer
	if [[ answer = [Yy] ]]; then
  log_message "Setting the PASS_MAX_DAYS in /etc/login.defs..."
    if [ ! -f "$config_file" ]; then
        echo "Error: $config_file not found!"
        return 1
    fi

    if grep -q "^PASS_MAX_DAYS" "$config_file"; then
        # Update the PASS_MAX_DAYS line to 365
        sed -i "s/^PASS_MAX_DAYS.*/$pass_max_days/" "$config_file"
        echo "Updated PASS_MAX_DAYS to 365 in $config_file."
    else
        # Add the PASS_MAX_DAYS line to the file
        echo "$pass_max_days" >> "$config_file"
        echo "Added PASS_MAX_DAYS = 365 to $config_file."
    fi
     else
    select_no "PASS_MAX_DAYS:REQUIRES CHANGE"
		
	fi

 fi
}


modify_multiple_users_pass_maxdays() {
 if grep -q "PASS_MAX_DAYS_ETC_SHADOW:REQUIRES CHANGE" $RESULT_FILE; then
	read -p "Do you want to set the PASS_MAX_DAYS in /etc/shadow? (y/n)" answer
	if [[ answer = [Yy] ]]; then
  log_message "Setting the PASS_MAX_DAYS in /etc/shadow..."
    read -p "How many users do you want to modify PASS_MAX_DAYS for? " user_count

    # Validate input
    if ! [[ "$user_count" =~ ^[0-9]+$ ]] || [ "$user_count" -le 0 ]; then
        echo "Error: Please enter a valid number of users."
        exit 1
    fi

    for ((i = 1; i <= user_count; i++)); do
        # Prompt the user for each username
        read -p "Enter username $i: " username

        # Check if the user exists
        if id "$username" &>/dev/null; then
            # Modify PASS_MAX_DAYS for the user to 365
            sudo chage --maxdays 365 "$username"
            if [ $? -eq 0 ]; then
                echo "Successfully updated PASS_MAX_DAYS to 365 for user: $username"
            else
                echo "Failed to update PASS_MAX_DAYS for user: $username"
            fi
        else
            echo "Error: User $username does not exist."
        fi
    done

     else
    select_no "PASS_MAX_DAYS_ETC_SHADOW:REQUIRES CHANGE"
		
	fi

 fi
}


set_pass_warn_age() {
    local config_file="/etc/login.defs"
    local required_warn_age=7
if grep -q "PASS_WARN_AGE:REQUIRES CHANGE" $RESULT_FILE; then
	read -p "Do you want to set the PASS_WARN_AGE in /etc/login.defs? (y/n)" answer
	if [[ answer = [Yy] ]]; then
  log_message "Setting the PASS_WARN_AGE in /etc/login.defs..."

    if [ ! -f "$config_file" ]; then
        echo "Error: $config_file not found!"
        return 1
    fi

 
    if grep -qE '^\s*PASS_WARN_AGE\s+' "$config_file"; then
       
        sudo sed -i "s/^\s*PASS_WARN_AGE\s\+[0-9]\+/PASS_WARN_AGE $required_warn_age/" "$config_file"
        echo "PASS_WARN_AGE updated to $required_warn_age in $config_file."
    else
       
        echo "PASS_WARN_AGE $required_warn_age" | sudo tee -a "$config_file" >/dev/null
        echo "PASS_WARN_AGE set to $required_warn_age in $config_file."
    fi
    else
    select_no "PASS_WARN_AGE:REQUIRES CHANGE"
		
	fi

 fi
}



# Function to set PASS_WARN_AGE to 7 days for all users with a password set
modify_users_pass_warn_age() {
    local warn_days=7
if grep -q "PASS_WARN_AGE_ETC_SHADOW:REQUIRES CHANGE" $RESULT_FILE; then
	read -p "Do you want to set the PASS_WARN_AGE in /etc/shadow? (y/n)" answer
	if [[ answer = [Yy] ]]; then
  log_message "Setting the PASS_WARN_AGE in /etc/shadow..."
    users=$(grep -E '^[^:]+:[^!*]' /etc/shadow | cut -d: -f1)

    if [ -z "$users" ]; then
        echo "No users with passwords set found."
        return 1
    fi

   
    for user in $users; do
        echo "Updating PASS_WARN_AGE to $warn_days days for user: $user"
        sudo chage --warndays "$warn_days" "$user"
        
        if [ $? -eq 0 ]; then
            echo "Successfully updated PASS_WARN_AGE for user: $user"
        else
            echo "Failed to update PASS_WARN_AGE for user: $user"
        fi
    done
     else
    select_no "PASS_WARN_AGE_ETC_SHADOW:REQUIRES CHANGE"
		
	fi

 fi
}


set_default_password_inactivity() {
    local inactivity_period=30
if grep -q "INACTIVE:REQUIRES CHANGE" $RESULT_FILE; then
	read -p "Do you want to set INACTIVE ? (y/n)" answer
	if [[ answer = [Yy] ]]; then
  log_message "Setting INACTIVE..."
    sudo useradd -D -f "$inactivity_period"

    if [ $? -eq 0 ]; then
        echo "Successfully set default password inactivity period to $inactivity_period days."
    else
        echo "Failed to set default password inactivity period."
    fi
    else
    select_no "INACTIVE:REQUIRES CHANGE"
		
	fi

 fi
}


# Function to set password inactivity period for all users with a password set
modify_users_pass_inactivity() {
    local inactivity_days=30
if grep -q "INACTIVE_ETC_SHADOW:REQUIRES CHANGE" $RESULT_FILE; then
	read -p "Do you want to set INACTIVE in /etc/shadow? (y/n)" answer
	if [[ answer = [Yy] ]]; then
  log_message "Setting INACTIVE in /etc/shadow..."
   
    users=$(grep -E '^[^:]+:[^!*]' /etc/shadow | cut -d: -f1)

    if [ -z "$users" ]; then
        echo "No users with passwords set found."
        return 1
    fi

    for user in $users; do
        echo "Updating password inactivity period to $inactivity_days days for user: $user"
        sudo chage --inactive "$inactivity_days" "$user"
        
        if [ $? -eq 0 ]; then
            echo "Successfully updated password inactivity period for user: $user"
        else
            echo "Failed to update password inactivity period for user: $user"
        fi
    done
      else
    select_no "INACTIVE_ETC_SHADOW:REQUIRES CHANGE"
		
	fi

 fi
}



# Function to set the root user's default group ID to 0
set_root_group_id() {
    local new_gid=0
if grep -q "ROOT GID CONFIG:REQUIRES CHANGE" $RESULT_FILE; then
	read -p "Do you want to set the root user's default group ID to 0? (y/n)" answer
	if [[ answer = [Yy] ]]; then
  log_message "Setting the root user's default group ID to 0..."
    sudo usermod -g "$new_gid" root

    if [ $? -eq 0 ]; then
        echo "Successfully set the root user's default group ID to $new_gid."
    else
        echo "Failed to set the root user's default group ID."
        return 1
    fi

    # Verify the change
    current_gid=$(id -g root)
    if [ "$current_gid" -eq "$new_gid" ]; then
        echo "Verification successful: Root user's group ID is set to $current_gid."
    else
        echo "Verification failed: Root user's group ID is $current_gid."
        return 1
    fi

    else
    select_no "ROOT GID CONFIG:REQUIRES CHANGE"
		
	fi

 fi
}




# Function to edit /root/.bash_profile and /root/.bashrc based on user input
edit_bash_files() {
    local profile_file="/root/.bash_profile"
    local rc_file="/root/.bashrc"
    local umask_value="0027"
if grep -q "UMASK CONFIG:REQUIRES CHANGE" $RESULT_FILE; then
	read -p "Do you want to configure root user umask? (y/n)" answer
	if [[ answer = [Yy] ]]; then
  log_message "Configuring root user umask..."
   
    
    echo "Would you like to:"
    echo "1. Comment out lines with umask set to 0027 or more restrictive"
    echo "2. Set umask to 0027 in the files"
    read -p "Enter your choice (1 or 2): " user_choice

    # Function to comment out umask lines
    comment_umask_lines() {
        local file=$1
        sudo sed -i '/^umask\s\+[0-7]\{3\}/ s/^/#/' "$file"
        echo "Commented out umask lines in $file."
    }

    # Function to set umask to 0027
    set_umask_value() {
        local file=$1
        sudo sed -i '/^umask\s\+/c\umask 0027' "$file"
        echo "Set umask to 0027 in $file."
    }

    # Perform actions based on user choice
    case "$user_choice" in
        1)
            comment_umask_lines "$profile_file"
            comment_umask_lines "$rc_file"
            ;;
        2)
            set_umask_value "$profile_file"
            set_umask_value "$rc_file"
            ;;
        *)
            echo "Invalid choice. Please enter 1 or 2."
            return 1
            ;;
    esac

     else
    select_no "UMASK CONFIG:REQUIRES CHANGE"
		
	fi

 fi
}


# Function to set the root password
set_root_password() {
if grep -q "ROOT PASSWORD CONFIG:REQUIRES CHANGE" $RESULT_FILE; then
	read -p "Do you want to configure root password? (y/n)" answer
	if [[ answer = [Yy] ]]; then
  log_message "Configuring root password..."
    echo "You will now set a new password for the root user."

    
    read -s -p "Enter new root password: " password1
    echo
    read -s -p "Confirm new root password: " password2
    echo

    # Check if both passwords match
    if [ "$password1" != "$password2" ]; then
        echo "Passwords do not match. Try again."
        return 1
    fi

    # Use a temporary file to store the password input
    temp_file=$(mktemp)
    echo -e "$password1\n$password1" > "$temp_file"

    # Set the root password using the temporary file
    sudo passwd root < "$temp_file"

    # Check if the passwd command was successful
    if [ $? -eq 0 ]; then
        echo "Root password has been successfully changed."
    else
        echo "Failed to change the root password."
        return 1
    fi

    rm -f "$temp_file"

     else
    select_no "ROOT PASSWORD CONFIG:REQUIRES CHANGE"
		
	fi

 fi
}



# Function to remove lines containing 'nologin' from /etc/shells
remove_nologin_lines() {
    local shells_file="/etc/shells"
    local backup_file="/etc/shells.bak"
if grep -q "NO LOGIN CONFIG:REQUIRES CHANGE" $RESULT_FILE; then
	read -p "Do you want to remove lines containing 'nologin' from /etc/shells ? (y/n)" answer
	if [[ answer = [Yy] ]]; then
  log_message "Removing lines containing 'nologin' from /etc/shells..."
    # Backup the original /etc/shells file
    sudo cp "$shells_file" "$backup_file"
    echo "Backup created at $backup_file."

    # Remove lines containing 'nologin' from /etc/shells
    sudo sed -i '/nologin/d' "$shells_file"

    # Verify if the removal was successful
    if grep -q 'nologin' "$shells_file"; then
        echo "Failed to remove all lines containing 'nologin'."
        return 1
    else
        echo "Successfully removed lines containing 'nologin' from $shells_file."
    fi

     else
    select_no "NO LOGIN CONFIG:REQUIRES CHANGE"
		
	fi

 fi
}


















set_crypt_style_sha512
set_encrypt_method_sha512
set_pass_max_days
modify_multiple_users_pass_maxdays
set_pass_warn_age
modify_users_pass_warn_age
set_default_password_inactivity
modify_users_pass_inactivity
set_root_group_id
edit_bash_files
set_root_password
remove_nologin_lines
