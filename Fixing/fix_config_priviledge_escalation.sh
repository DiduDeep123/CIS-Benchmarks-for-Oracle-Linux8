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



#install sudo
install_sudo() {
	
	if grep -q "SUDO:NOT INSTALLED" $RESULT_FILE; then
	read -p "Do you want to install sudo? (y/n)" answer
		if [[ answer = [Yy] ]]; then
			log_message "Installing sudo..."
			dnf install sudo
			log_message "Sudo installed."
		fi
	fi
}





# Function to add 'Defaults use_pty' to the /etc/sudoers file using visudo
add_sudoers_defaults_use_pty() {
    local sudoers_file="/etc/sudoers"
    local temp_file="/tmp/sudoers.tmp"

if grep -q "USE_PTY:NOT CONFIGURED" $RESULT_FILE; then
	read -p "Do you want to ensure sudo commands use pty? (y/n)" answer
		if [[ answer = [Yy] ]]; then
			log_message "Ensuring sudo commands use pty..."
    # Create a temporary file for editing
    sudo cp "$sudoers_file" "$temp_file"

    # Add the line 'Defaults use_pty' to the temporary file
    echo "Defaults use_pty" | sudo tee -a "$temp_file" > /dev/null

    # Use visudo to validate and apply changes from the temporary file
    sudo visudo -c -f "$temp_file" && sudo mv "$temp_file" "$sudoers_file"

    if [ $? -eq 0 ]; then
        echo "'Defaults use_pty' has been added to $sudoers_file successfully."
    else
        echo "Failed to add 'Defaults use_pty' to $sudoers_file. Restoring original file."
        sudo rm "$temp_file"
    fi
else
    select_no "USE_PTY:REQUIRES CHANGE"
		
	fi

 fi
    
}


# Function to add 'Defaults logfile="<PATH TO CUSTOM LOG FILE>"' to /etc/sudoers using visudo
add_sudoers_logfile() {
    local sudoers_file="/etc/sudoers"
    local temp_file="/tmp/sudoers.tmp"
if grep -q "SUDO_CUSTOM_LOG_FILE:NOT CONFIGURED" $RESULT_FILE; then
	read -p "Do you want to ensure sudo log file exists? (y/n)" answer
		if [[ answer = [Yy] ]]; then
			log_message "Ensuring sudo log file exists..."
    # Prompt the user for the custom log file path
    read -p "Enter the path to the custom log file: " log_file_path

    # Create a temporary file for editing
    sudo cp "$sudoers_file" "$temp_file"

    # Add the line 'Defaults logfile="<PATH TO CUSTOM LOG FILE>"' to the temporary file
    echo "Defaults logfile=\"$log_file_path\"" | sudo tee -a "$temp_file" > /dev/null

    # Use visudo to validate and apply changes from the temporary file
    if sudo visudo -c -f "$temp_file"; then
        sudo mv "$temp_file" "$sudoers_file"
        echo "'Defaults logfile=\"$log_file_path\"' has been added to $sudoers_file successfully."
    else
        echo "Failed to add 'Defaults logfile=\"$log_file_path\"' to $sudoers_file. Restoring original file."
        sudo rm "$temp_file"
        return 1
    fi

else
    select_no "SUDO_CUSTOM_LOG_FILE:NOT CONFIGURED:REQUIRES CHANGE"
		
	fi

 fi
}


# Function to remove lines with 'NOPASSWD' tags from a specified sudoers file using visudo
remove_nopasswd_lines() {
    local sudoers_file="$1"
    local temp_file="/tmp/sudoers.tmp"
if grep -q "NOPASSWD:ALLOWED" $RESULT_FILE; then
	read -p "Do you want to ensure users must provide password for escalation? (y/n)" answer
		if [[ answer = [Yy] ]]; then
			log_message "Ensuring users must provide password for escalation..."
    # Check if the file path is provided
    if [ -z "$sudoers_file" ]; then
        echo "Error: No file path provided."
        return 1
    fi

    # Verify that the specified file exists
    if [ ! -f "$sudoers_file" ]; then
        echo "Error: File '$sudoers_file' does not exist."
        return 1
    fi

    # Create a temporary file for editing
    sudo cp "$sudoers_file" "$temp_file"

    # Remove lines with 'NOPASSWD' from the temporary file
    sudo sed -i '/NOPASSWD/d' "$temp_file"

    # Use visudo to validate and apply changes from the temporary file
    if sudo visudo -c -f "$temp_file"; then
        sudo mv "$temp_file" "$sudoers_file"
        echo "Lines with 'NOPASSWD' have been removed from '$sudoers_file' successfully."
    else
        echo "Failed to apply changes to '$sudoers_file'. Restoring original file."
        sudo rm "$temp_file"
        return 1
    fi

    else
    select_no "NOPASSWD:ALLOWED:REQUIRES CHANGE"
		
	fi

 fi
}


# Function to remove lines with '!authenticate' tags from a specified sudoers file using visudo
require_reauthentication() {
    local sudoers_file="$1"
    local temp_file="/tmp/sudoers.tmp"
if grep -q "REAUTHENTICATION:DISABLED" $RESULT_FILE; then
	read -p "Do you want to ensure re-authentication for privilege escalation is not disabled globally? (y/n)" answer
		if [[ answer = [Yy] ]]; then
			log_message "Ensuring re-authentication for privilege escalation is not disabled globally..."
    # Check if the file path is provided
    if [ -z "$sudoers_file" ]; then
        echo "Error: No file path provided."
        return 1
    fi

    # Verify that the specified file exists
    if [ ! -f "$sudoers_file" ]; then
        echo "Error: File '$sudoers_file' does not exist."
        return 1
    fi

    # Create a temporary file for editing
    sudo cp "$sudoers_file" "$temp_file"

    # Remove lines with '!authenticate' from the temporary file
    sudo sed -i '/!authenticate/d' "$temp_file"

    # Use visudo to validate and apply changes from the temporary file
    if sudo visudo -c -f "$temp_file"; then
        sudo mv "$temp_file" "$sudoers_file"
        echo "Occurrences of '!authenticate' have been removed from '$sudoers_file' successfully."
    else
        echo "Failed to apply changes to '$sudoers_file'. Restoring original file."
        sudo rm "$temp_file"
        return 1
    fi

     else
    select_no "REAUTHENTICATION:DISABLED:REQUIRES CHANGE"
		
	fi

 fi
}


########




# Function to create an empty group and update /etc/pam.d/su
configure_su_group() {
    local group_name="$1"
    
    if [ -z "$group_name" ]; then
        echo "Error: No group name provided."
        return 1
    fi

    # Check if the group already exists
    if getent group "$group_name" > /dev/null 2>&1; then
        echo "Group '$group_name' already exists."
    else
        # Create the group
        sudo groupadd "$group_name"
        if [ $? -eq 0 ]; then
            echo "Group '$group_name' created successfully."
        else
            echo "Error: Failed to create group '$group_name'."
            return 1
        fi
    fi

    # Update /etc/pam.d/su to include the new group
    local pam_file="/etc/pam.d/su"
    if grep -q "pam_wheel.so" "$pam_file"; then
        # Check if the line already exists
        if grep -q "group=$group_name" "$pam_file"; then
            echo "The PAM configuration for 'su' already includes the group '$group_name'."
        else
            # Add the group to the pam_wheel.so line
            sudo sed -i -E "/^auth\s+required\s+pam_wheel.so/s/(group=[^ ]*)/group=$group_name/" "$pam_file"
            echo "Updated PAM configuration to include the group '$group_name'."
        fi
    else
        # Add the line to the PAM file if it does not exist
        echo "auth required pam_wheel.so use_uid group=$group_name" | sudo tee -a "$pam_file"
        echo "Added PAM configuration for 'su' with group '$group_name'."
    fi
}

fix_su_access() {
if grep -q "SU_ACCESS:NOT CONFIGURED" $RESULT_FILE; then
	read -p "Do you want to ensure access to the su command is restricted? (y/n)" answer
		if [[ answer = [Yy] ]]; then
			log_message "Ensure access to the su command is restricted..."
echo "Enter the group name for use with the 'su' command:"
read -r user_group_name


configure_su_group "$user_group_name"

else
    select_no SU_ACCESS:NOT CONFIGURED:REQUIRES CHANGE"
		
	fi

 fi

}




install_sudo
add_sudoers_defaults_use_pty
add_sudoers_logfile
remove_nopasswd_lines /etc/sudoers
require_reauthentication /etc/sudoers
####
fix_su_access
