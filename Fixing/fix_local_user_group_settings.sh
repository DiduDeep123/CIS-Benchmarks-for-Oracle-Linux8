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




# Function to set accounts to use shadowed passwords
set_shadowed_passwords() {
    local passwd_file="/etc/passwd"
 if grep -q "PASSWORD SHADOWING CONFIG:REQUIRES CHANGE" $RESULT_FILE; then
	read -p "Do you want to set accounts to use shadowed passwords? (y/n)" answer
	if [[ answer = [Yy] ]]; then

   log_message "Updating $passwd_file to use shadowed passwords..."

    # Backup the original /etc/passwd file
    sudo cp "$passwd_file" "${passwd_file}.bak"
    if [ $? -ne 0 ]; then
        echo "Failed to create backup. Exiting."
        return 1
    fi
    
    sudo sed -e 's/^\([a-zA-Z0-9_]*\):[^:]*:/\1:x:/' -i "$passwd_file"
    if [ $? -ne 0 ]; then
        echo "Failed to modify $passwd_file. Exiting."
        return 1
    fi

    # Verify the changes
    if grep -q '^[^:]*:x:' "$passwd_file"; then
        echo "Successfully updated $passwd_file to use shadowed passwords."
    else
        echo "Failed to update $passwd_file. Check the file manually."
        return 1
    fi

    else
    select_no "PASSWORD SHADOWING CONFIG:REQUIRES CHANGE"
		
	fi

 fi
}



# Function to lock accounts with no passwords in /etc/shadow
lock_accounts_without_passwords() {
    local shadow_file="/etc/shadow"
    local users_locked=""
 if grep -q "PASSWORD FIELD CONFIG:REQUIRES CHANGE" $RESULT_FILE; then
	read -p "Do you want to lock accounts with no passwords in /etc/shadow? (y/n)" answer
	if [[ answer = [Yy] ]]; then

   log_message "Checking $shadow_file for accounts with no passwords......"
   

    while IFS=: read -r username password _; do
        # Check if the password field is empty or contains '*'
        if [ -z "$password" ] || [ "$password" = "!" ] || [ "$password" = "*" ]; then
          
            sudo passwd -l "$username"
            if [ $? -eq 0 ]; then
                users_locked+="$username "
                echo "Locked account: $username"
            else
                echo "Failed to lock account: $username"
            fi
        fi
    done < "$shadow_file"

 
    if [ -n "$users_locked" ]; then
        echo -e "\nAccounts locked due to no password: $users_locked"
    else
        echo -e "\nNo accounts without passwords were found."
    fi

    else
    select_no "PASSWORD FIELD CONFIG:REQUIRES CHANGE"
		
	fi

 fi
}



set_shadowed_passwords
lock_accounts_without_passwords
