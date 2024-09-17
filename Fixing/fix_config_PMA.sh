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


# Function to set the 'deny' option in /etc/security/faillock.conf
set_faillock_deny() {
    local config_file="/etc/security/faillock.conf"
    if grep -q "FAILLOCK DENY ARGUMENT:INCORRECT" $RESULT_FILE; then
	read -p "Do you want to set the 'deny' option in /etc/security/faillock.conf? (y/n)" answer
	if [[ answer = [Yy] ]]; then
  log_message "Setting the 'deny' option in /etc/security/faillock.conf..."
    read -p "Enter a value for 'deny' (must be 5 or less): " deny_value
    
    if ! [[ "$deny_value" =~ ^[0-5]$ ]]; then
        echo "Invalid input. Please enter a number between 0 and 5."
        return 1
    fi

    # Ensure the deny option is set correctly
    if grep -Pi -- '^\h*deny\h*=' "$config_file" > /dev/null 2>&1; then
        # Edit the existing line to set deny to the specified value
        sed -i -r "s/^\h*deny\h*=\h*[0-9]+/\deny = $deny_value/" "$config_file"
        echo "Updated 'deny' option to $deny_value in $config_file."
    else
        # Add the deny option if it does not exist
        echo "deny = $deny_value" >> "$config_file"
        echo "Added 'deny = $deny_value' to $config_file."
    fi
    else
    select_no "FAILLOCK DENY ARGUMENT:INCORRECT:REQUIRES CHANGE"
		
	fi

 fi
}


# Function to remove the deny argument from the pam_faillock.so module in PAM files
remove_deny_argument() {
 if grep -q "PAM DENY ARGUMENT:INCORRECT" $RESULT_FILE; then
	read -p "Do you want to remove the deny argument from the pam_faillock.so? (y/n)" answer
	if [[ answer = [Yy] ]]; then
  log_message "Removing the deny argument from the pam_faillock.so..."
    for l_pam_file in system-auth password-auth; do
        # Construct the path to the PAM file
        l_authselect_file="/etc/authselect/$(head -1 /etc/authselect/authselect.conf | grep 'custom/')/$l_pam_file"

        # Remove the deny argument from the pam_faillock.so line
        sed -ri 's/(^\s*auth\s+(requisite|required|sufficient)\s+pam_faillock\.so.*)(\s+deny\s*=\s*\S+)(.*$)/\1\4/' "$l_authselect_file"
    done
    
    # Apply changes with authselect
    authselect apply-changes

   else
    select_no "PAM DENY ARGUMENT:INCORRECT:REQUIRES CHANGE"
		
	fi

 fi
}


# Function to update or add the unlock_time line in /etc/security/faillock.conf
update_unlock_time() {
    local file_path="/etc/security/faillock.conf"
if grep -q "FAILLOCK CONFIGURATION:NOT SET" $RESULT_FILE; then
	read -p "Do you want to update or add the unlock_time line in /etc/security/faillock.conf? (y/n)" answer
	if [[ answer = [Yy] ]]; then
  log_message "Updating or adding the unlock_time line in /etc/security/faillock.conf..."
    read -p "Enter the unlock_time value (0 or 900 or greater): " unlock_time

    if [[ ! "$unlock_time" =~ ^[0-9]+$ ]] || [ "$unlock_time" -lt 0 ]; then
        echo "Invalid input. Please enter a number 0 or 900 or greater."
        return 1
    elif [ "$unlock_time" -ne 0 ] && [ "$unlock_time" -lt 900 ]; then
        echo "Invalid input. Please enter 0 or 900 or greater."
        return 1
    fi

    # Backup the original file
    cp "$file_path" "${file_path}.bak"

    # Update or add the unlock_time line
    if grep -q '^unlock_time' "$file_path"; then
        # Update existing line
        sed -i "s/^unlock_time.*/unlock_time = $unlock_time/" "$file_path"
    else
        # Add new line
        echo "unlock_time = $unlock_time" >> "$file_path"
    fi

    echo "Updated $file_path with unlock_time = $unlock_time."

    else
    select_no "FAILLOCK CONFIGURATION:NOT SET:REQUIRES CHANGE"
		
	fi

 fi
}


# Function to remove the unlock_time argument from pam_faillock.so
remove_unlock_time_argument() {
    if grep -q "PAM UNLOCK TIME:INCORRECT" "$RESULT_FILE"; then
        read -p "Do you want to remove the unlock_time argument from the pam_faillock.so? (y/n): " answer
        if [[ $answer =~ ^[Yy]$ ]]; then
            log_message "Removing the unlock_time argument from the pam_faillock.so..."

            for l_pam_file in system-auth password-auth; do
                # Construct the path to the PAM file
                local l_authselect_file="/etc/authselect/$(head -1 /etc/authselect/authselect.conf | grep 'custom/')/$l_pam_file"

                # Check if the PAM file exists before attempting to modify it
                if [ -f "$l_authselect_file" ]; then
                    # Remove the unlock_time argument from the pam_faillock.so line
                    sed -ri 's/(^\s*auth\s+(requisite|required|sufficient)\s+pam_faillock\.so.*)(\s+unlock_time\s*=\s*\S+)(.*$)/\1\4/' "$l_authselect_file"
                else
                    log_message "PAM file $l_authselect_file does not exist."
                fi
            done

            # Apply changes with authselect
            authselect apply-changes
            log_message "Unlock time argument removed and changes applied."

        else
            select_no "PAM UNLOCK TIME ARGUMENT:INCORRECT:REQUIRES CHANGE"
        fi
    fi
}








set_faillock_deny
remove_deny_argument
update_unlock_time
remove_unlock_time
remove_unlock_time_argument
