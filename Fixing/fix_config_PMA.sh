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



# Function to edit the /etc/security/faillock.conf
edit_faillock_conf() {
    local faillock_conf="/etc/security/faillock.conf"
if grep -q "FAILLOCK CONFIGURATION:NOT SET" "$RESULT_FILE" || "ROOT UNLOCK TIME:INCORRECT" "$RESULT_FILE"; then
        read -p "Do you want to edit the /etc/security/faillock.conf by setting the root unlock time? (y/n): " answer
        if [[ $answer =~ ^[Yy]$ ]]; then
    
    while true; do
        read -p "Enter root_unlock_time value (60 or more): " root_unlock_time
        if [[ "$root_unlock_time" =~ ^[0-9]+$ ]] && [ "$root_unlock_time" -ge 60 ]; then
            break
        else
            echo "Invalid input. Please enter a numeric value of 60 or more."
        fi
    done

    # Check if the faillock.conf file exists
    if [ -f "$faillock_conf" ]; then
        log_message "Editing $faillock_conf..."

        # Remove or update root_unlock_time
        if grep -q "^root_unlock_time" "$faillock_conf"; then
            sed -ri "s/^root_unlock_time\s*=\s*[0-9]+/root_unlock_time=$root_unlock_time/" "$faillock_conf"
            log_message "Updated root_unlock_time to $root_unlock_time."
        else
            echo "root_unlock_time=$root_unlock_time" >> "$faillock_conf"
            log_message "Added root_unlock_time=$root_unlock_time."
        fi

        # Check if the even_deny_root parameter is present; if not, add it
        if grep -q "^even_deny_root" "$faillock_conf"; then
            log_message "even_deny_root is already present."
        else
            echo "even_deny_root" >> "$faillock_conf"
            log_message "Added even_deny_root to $faillock_conf."
        fi
    else
        log_message "$faillock_conf file not found."
    fi

     else
            select_no "FAILLOCK CONFIGURATION:NOT SET:REQUIRES CHANGE"
        fi
    fi
}


remove_even_deny_root_and_root_unlock_time() {

if grep -q "PAM ROOT UNLOCK TIME:INCORRECT" "$RESULT_FILE" || "ROOT UNLOCK TIME:INCORRECT" "$RESULT_FILE"; then
        read -p "Do you want to remove even deny root and root unlock time? (y/n): " answer
        if [[ $answer =~ ^[Yy]$ ]]; then
	 log_message "Removing even deny root and root unlock time..."
  for l_pam_file in system-auth password-auth; do
    # Construct the path to the PAM file
    l_authselect_file="/etc/authselect/$(head -1 /etc/authselect/authselect.conf | grep 'custom/')/$l_pam_file"
    
    # Remove the even_deny_root argument from pam_faillock.so line
    sed -ri 's/(^\s*auth\s+(.*)\s+pam_faillock\.so.*)(\s+even_deny_root)(.*$)/\1\4/' "$l_authselect_file"
    
    # Remove the root_unlock_time argument from pam_faillock.so line
    sed -ri 's/(^\s*auth\s+(.*)\s+pam_faillock\.so.*)(\s+root_unlock_time\s*=\s*\S+)(.*$)/\1\4/' "$l_authselect_file"
  done
  

  authselect apply-changes

  else
            select_no "PAM ROOT UNLOCK TIME:INCORRECT:REQUIRES CHANGE"
        fi
    fi
}

set_difok_value() {
  local pwquality_file="/etc/security/pwquality.conf"
  if grep -q "DIFOK:NOT CONFIGURED" "$RESULT_FILE"; then
        read -p "Do you want to Ensure password number of changed characters is configured? (y/n): " answer
        if [[ $answer =~ ^[Yy]$ ]]; then
	 log_message "Ensuring password number of changed characters is configured..."
  while true; do
    read -p "Please enter a value for difok (2 or more): " difok_value
    if [[ "$difok_value" =~ ^[2-9]$|^[1-9][0-9]+$ ]]; then
      break
    else
      echo "Invalid input. Please enter a number that is 2 or greater."
    fi
  done

  # Check if difok is already set in the pwquality.conf file
  if grep -q "^difok" "$pwquality_file"; then
    # If difok is present, update the value
    sed -ri "s/^\s*difok\s*=\s*\S+/difok = $difok_value/" "$pwquality_file"
    echo "Updated difok value to $difok_value in $pwquality_file."
  else
    # If difok is not present, append it to the file
    echo "difok = $difok_value" >> "$pwquality_file"
    echo "Added difok = $difok_value to $pwquality_file."
  fi
  else
            select_no "DIFOK:NOT CONFIGURED:REQUIRES CHANGE"
        fi
    fi
}

remove_difok_argument() {
    
    if grep -q "DIFOK_PAM:NOT CONFIGURED" "$RESULT_FILE"; then
        read -p "Do you want to remove setting difok on the pam_pwquality.so module? (y/n): " answer
        if [[ $answer =~ ^[Yy]$ ]]; then
	 log_message "Removing setting difok on the pam_pwquality.so module..."
    for l_pam_file in system-auth password-auth; do
        # Construct the path to the authselect custom profile
        l_authselect_file="/etc/authselect/$(head -1 /etc/authselect/authselect.conf | grep 'custom/')/$l_pam_file"

        # Use sed to remove the difok argument from pam_pwquality.so lines
        sed -ri 's/(^\s*password\s+(requisite|required|sufficient)\s+pam_pwquality\.so.*)(\s+difok\s*=\s*\S+)(.*$)/\1\4/' "$l_authselect_file"
    done


    authselect apply-changes
 else
            select_no "DIFOK_PAM:NOT CONFIGURED:REQUIRES CHANGE"
        fi
    fi
   
}

update_minlen() {
   
    CONFIG_FILE="/etc/security/pwquality.conf"
  if grep -q "PWQUALITY MINLEN SETTING:INCORRECT" "$RESULT_FILE"; then
        read -p "Do you want to update password length in /etc/security/pwquality.conf? (y/n): " answer
        if [[ $answer =~ ^[Yy]$ ]]; then
	 log_message "Updating password length in /etc/security/pwquality.conf..."
    while true; do
        read -p "Enter the minimum password length (14 or more): " user_minlen
        
        # Check if the input is a valid number and meets the requirement
        if [[ "$user_minlen" =~ ^[0-9]+$ ]] && [ "$user_minlen" -ge 14 ]; then
            MIN_LENGTH=$user_minlen
            break
        else
            echo "Invalid input. Please enter a number that is 14 or more."
        fi
    done

    # Check if minlen is set to the user-defined value or more
    if grep -Psi -- "^\h*minlen\h*=\h*([0-9]|1[0-3])\b" "$CONFIG_FILE" > /dev/null; then
        echo "Checking minlen in $CONFIG_FILE..."

        # Get current minlen value
        current_minlen=$(grep -Psi -- "^\h*minlen\h*=\h*[0-9]+\b" "$CONFIG_FILE" | awk -F '=' '{print $2}' | tr -d '[:space:]')

        if [ "$current_minlen" -lt "$MIN_LENGTH" ]; then
            echo "Current minlen ($current_minlen) is less than $MIN_LENGTH. Updating configuration..."
        else
            echo "Current minlen ($current_minlen) is compliant ($MIN_LENGTH or more)."
            return
        fi
    else
        echo "No minlen setting found in $CONFIG_FILE. Adding it..."
    fi

    # Backup the configuration file
    cp "$CONFIG_FILE" "${CONFIG_FILE}.bak"

    # Update or add the minlen setting
    sed -i -r "/^\s*minlen\s*=/d" "$CONFIG_FILE"   # Remove any existing minlen line
    echo "minlen = $MIN_LENGTH" >> "$CONFIG_FILE"  # Add the new minlen line

    echo "Updated $CONFIG_FILE to set minlen to $MIN_LENGTH."

    else
            select_no "PWQUALITY MINLEN SETTING:INCORRECT:REQUIRES CHANGE"
        fi
    fi
}


# Function to remove minlen argument from PAM files
remove_minlen_argument() {
 if grep -q "PAM MINLEN SETTING:INCORRECT" "$RESULT_FILE"; then
        read -p "Do you want to remove minlen argument from PAM files? (y/n): " answer
        if [[ $answer =~ ^[Yy]$ ]]; then
    log_message "Removing minlen argument from PAM files..."

    for l_pam_file in system-auth password-auth; do
        # Construct the path to the PAM file
        l_authselect_file="/etc/authselect/$(head -1 /etc/authselect/authselect.conf | grep 'custom/')/$l_pam_file"

        if [ -f "$l_authselect_file" ]; then
            # Remove the minlen argument from the pam_pwquality.so line
            sed -ri 's/(^\s*password\s+(requisite|required|sufficient)\s+pam_pwquality\.so.*)(\s+minlen\s*=\s*[0-9]+)(.*$)/\1\4/' "$l_authselect_file"
            echo "Updated $l_authselect_file"
        else
            echo "File $l_authselect_file does not exist."
        fi
    done

   
    authselect apply-changes
    log_message "Changes applied with authselect."
      else
            select_no "PAM MINLEN SETTING:INCORRECT:REQUIRES CHANGE"
        fi
    fi
}


update_pwquality_conf() {
 if grep -q "PWQUALITY SETTINGS:INCORRECT" "$RESULT_FILE"; then
        read -p "Do you want to ensure password complexity is configured? (y/n): " answer
        if [[ $answer =~ ^[Yy]$ ]]; then
    log_message "Ensuring password complexity is configured..."
    local config_file="/etc/security/pwquality.conf"
    local minclass
    local dcredit
    local ucredit
    local ocredit
    local lcredit

    # Get user input
    read -p "Enter the minclass value (4 or more): " minclass
    read -p "Enter the dcredit value (negative number, e.g., -1): " dcredit
    read -p "Enter the ucredit value (negative number, e.g., -1): " ucredit
    read -p "Enter the ocredit value (negative number, e.g., -1): " ocredit
    read -p "Enter the lcredit value (negative number, e.g., -1): " lcredit

    # Validate input values
    if [[ ! "$minclass" =~ ^[4-9][0-9]*$ ]]; then
        echo "Invalid minclass value. It should be 4 or more."
        return 1
    fi

    if [[ ! "$dcredit" =~ ^-?[0-9]+$ ]]; then
        echo "Invalid dcredit value. It should be a negative number."
        return 1
    fi

    if [[ ! "$ucredit" =~ ^-?[0-9]+$ ]]; then
        echo "Invalid ucredit value. It should be a negative number."
        return 1
    fi

    if [[ ! "$ocredit" =~ ^-?[0-9]+$ ]]; then
        echo "Invalid ocredit value. It should be a negative number."
        return 1
    fi

    if [[ ! "$lcredit" =~ ^-?[0-9]+$ ]]; then
        echo "Invalid lcredit value. It should be a negative number."
        return 1
    fi

    # Update or add lines in /etc/security/pwquality.conf
    sudo sed -i "/^minclass\s*=.*/c\minclass = $minclass" "$config_file"
    sudo sed -i "/^dcredit\s*=.*/c\dcredit = $dcredit" "$config_file"
    sudo sed -i "/^ucredit\s*=.*/c\ucredit = $ucredit" "$config_file"
    sudo sed -i "/^ocredit\s*=.*/c\ocredit = $ocredit" "$config_file"
    sudo sed -i "/^lcredit\s*=.*/c\lcredit = $lcredit" "$config_file"

    # Add lines if they don't exist
    [[ ! $(grep -q '^minclass' "$config_file") ]] && echo "minclass = $minclass" | sudo tee -a "$config_file"
    [[ ! $(grep -q '^dcredit' "$config_file") ]] && echo "dcredit = $dcredit" | sudo tee -a "$config_file"
    [[ ! $(grep -q '^ucredit' "$config_file") ]] && echo "ucredit = $ucredit" | sudo tee -a "$config_file"
    [[ ! $(grep -q '^ocredit' "$config_file") ]] && echo "ocredit = $ocredit" | sudo tee -a "$config_file"
    [[ ! $(grep -q '^lcredit' "$config_file") ]] && echo "lcredit = $lcredit" | sudo tee -a "$config_file"

   log_message "Password complexity Configuration updated successfully."

   else
            select_no "PWQUALITY SETTINGS:INCORRECT:REQUIRES CHANGE"
        fi
    fi
}




# Function to update the maxrepeat setting
update_maxrepeat() {
    local pwquality_conf="/etc/security/pwquality.conf"
 if grep -q "PWQUALITY MAXREPEAT SETTING:INCORRECT" "$RESULT_FILE"; then
        read -p "Do you want to update the maxrepeat setting in /etc/security/pwquality.conf? (y/n): " answer
        if [[ $answer =~ ^[Yy]$ ]]; then
    log_message "Updating the maxrepeat setting in /etc/security/pwquality.conf..."
    
    while true; do
        read -p "Enter a value for maxrepeat (3 or less, but not 0): " maxrepeat_value

        # Validate the input
        if [[ "$maxrepeat_value" =~ ^[1-3]$ ]]; then
            echo "Valid value: $maxrepeat_value"
            break
        else
            echo "Invalid value. Please enter a number between 1 and 3."
        fi
    done

    # Backup the original file
    cp "$pwquality_conf" "${pwquality_conf}.bak"

    # Update or add the maxrepeat line in pwquality.conf
    if grep -q "^maxrepeat" "$pwquality_conf"; then
        # Modify existing line
        sed -i "s/^maxrepeat.*/maxrepeat = $maxrepeat_value/" "$pwquality_conf"
    else
        # Add new line
        echo "maxrepeat = $maxrepeat_value" >> "$pwquality_conf"
    fi

   log_message "Updated $pwquality_conf with maxrepeat = $maxrepeat_value."
   else
            select_no "PWQUALITY MAXREPEAT SETTING:INCORRECT:REQUIRES CHANGE"
        fi
    fi
}


# Function to remove the maxrepeat argument from PAM files
remove_maxrepeat_argument() {
if grep -q "PAM MAXREPEAT SETTING:INCORRECT" "$RESULT_FILE"; then
        read -p "Do you want to remove the maxrepeat argument from PAM files? (y/n): " answer
        if [[ $answer =~ ^[Yy]$ ]]; then
    log_message "Removing the maxrepeat argument from PAM files..."
    for l_pam_file in system-auth password-auth; do
        
        l_authselect_file="/etc/authselect/$(head -1 /etc/authselect/authselect.conf | grep 'custom/')/$l_pam_file"
        
        
        if [[ -f "$l_authselect_file" ]]; then
            
            sed -ri 's/(^\s*password\s+(requisite|required|sufficient)\s+pam_pwquality\.so.*)(\s+maxrepeat\s*=\s*\S+)(.*$)/\1\4/' "$l_authselect_file"
            log_message "Updated $l_authselect_file to remove the maxrepeat argument."
        else
            log_message "File $l_authselect_file does not exist, skipping."
        fi
    done

    
    authselect apply-changes
    else
            select_no "PAM MAXREPEAT SETTING:INCORRECT:REQUIRES CHANGE"
        fi
    fi
}



# Function to add or modify the maxsequence setting in pwquality.conf
update_maxsequence() {
    local config_file="/etc/security/pwquality.conf"
    

    if grep -q "PWQUALITY MAXSEQUENCE SETTING:INCORRECT" "$RESULT_FILE"; then
        read -p "Do you want to add or modify the maxsequence setting in pwquality.conf? (y/n): " answer
        if [[ $answer =~ ^[Yy]$ ]]; then
    log_message "Updating the maxsequence setting in pwquality.conf..."

   
    while true; do
        read -p "Enter a value for maxsequence (3 or less, and not 0): " user_value
        
       
        if [[ "$user_value" =~ ^[1-3]$ ]]; then
            break
        else
            echo "Invalid input. Please enter a value between 1 and 3, inclusive."
        fi
    done

    
    # Update or add the maxsequence line
    if grep -q '^maxsequence' "$config_file"; then
        sed -i "s/^maxsequence\s*=.*/maxsequence = $user_value/" "$config_file"
    else
        echo "maxsequence = $user_value" >> "$config_file"
    fi
    
    echo "Updated maxsequence to $user_value in $config_file"
    else
            select_no "PWQUALITY MAXSEQUENCE SETTING:INCORRECT:REQUIRES CHANGE"
        fi
    fi
}




# Function to remove maxsequence setting from PAM files
remove_maxsequence() {
    if grep -q "PAM MAXSEQUENCE SETTING:INCORRECT" "$RESULT_FILE"; then
        read -p "Do you want to remove maxsequence setting from PAM files? (y/n): " answer
        if [[ $answer =~ ^[Yy]$ ]]; then
    log_message "Removing maxsequence setting from PAM files..."

    for l_pam_file in system-auth password-auth; do
     
        l_authselect_file="/etc/authselect/$(head -1 /etc/authselect/authselect.conf | grep 'custom/')/$l_pam_file"
        
       
        if [[ -f "$l_authselect_file" ]]; then
            echo "Processing $l_authselect_file..."
            
            # Remove the maxsequence parameter from the pam_pwquality.so line
            sed -ri 's/(^\s*password\s+(requisite|required|sufficient)\s+pam_pwquality\.so.*)(\s+maxsequence\s*=\s*\S+)(.*$)/\1\4/' "$l_authselect_file"
        else
            echo "File $l_authselect_file does not exist, skipping..."
        fi
    done
    
  
    authselect apply-changes
    
    echo "Changes applied successfully."

     else
            select_no "PAM MAXSEQUENCE SETTING:INCORRECT:REQUIRES CHANGE"
        fi
    fi
}



# Function to comment out or remove dictcheck = 0 in /etc/security/pwquality.conf
modify_dictcheck() {
    local file="/etc/security/pwquality.conf"
    
    if grep -q "DICTCHECK SETTING:INCORRECT" "$RESULT_FILE"; then
        read -p "Do you want to remove dictcheck = 0 in /etc/security/pwquality.conf? (y/n): " answer
        if [[ $answer =~ ^[Yy]$ ]]; then
    log_message "Removing dictcheck = 0 in /etc/security/pwquality.conf..."

    if [[ ! -f "$file" ]]; then
        echo "File $file does not exist. Exiting."
        return 1
    fi

    echo "Modifying $file to comment out or remove dictcheck = 0..."

   
    sed -i.bak '/^\s*dictcheck\s*=\s*0\s*$/s/^/#/' "$file"

   
    if grep -q '^\s*dictcheck\s*=\s*0\s*$' "$file"; then
        echo "Modification failed: dictcheck = 0 is still present."
    else
        echo "Modification successful: dictcheck = 0 has been commented out."
    fi

     else
            select_no "DICTCHECK SETTING:INCORRECT:REQUIRES CHANGE"
        fi
    fi
}


# Function to remove dictcheck argument from PAM configuration files
remove_dictcheck_argument() {
    if grep -q "PAM DICTCHECK SETTING:INCORRECT" "$RESULT_FILE"; then
        read -p "Do you want to remove dictcheck argument from PAM configuration files? (y/n): " answer
        if [[ $answer =~ ^[Yy]$ ]]; then
    log_message "Removing dictcheck argument from PAM configuration files..."

    for l_pam_file in system-auth password-auth; do
        # Construct the path to the PAM file
        l_authselect_file="/etc/authselect/$(head -1 /etc/authselect/authselect.conf | grep 'custom/')/$l_pam_file"

        if [[ -f "$l_authselect_file" ]]; then
            echo "Processing $l_authselect_file..."

            sed -ri 's/(^\s*password\s+(requisite|required|sufficient)\s+pam_pwquality\.so.*)(\s+dictcheck\s*=\s*\S+)(.*$)/\1\4/' "$l_authselect_file"
        else
            echo "File $l_authselect_file does not exist. Skipping."
        fi
    done

    authselect apply-changes
 else
            select_no "PAM DICTCHECK SETTING:INCORRECT:REQUIRES CHANGE"
        fi
    fi
}



# Function to add 'enforce_for_root' to /etc/security/pwquality.conf
add_enforce_for_root() {
    local config_file="/etc/security/pwquality.conf"
        if grep -q "ENFORCE_FOR_ROOT SETTING_PWQUALITY:NOT ENABLED" "$RESULT_FILE"; then
        read -p "Do you want to add 'enforce_for_root' to /etc/security/pwquality.conf? (y/n): " answer
        if [[ $answer =~ ^[Yy]$ ]]; then
    log_message "Adding 'enforce_for_root' to /etc/security/pwquality.conf..."
   
        if ! grep -q "^enforce_for_root" "$config_file"; then
            
            printf '\n%s\n' "enforce_for_root" >> "$config_file"
            echo "'enforce_for_root' added to $config_file."
        else
            echo "'enforce_for_root' is already present in $config_file."
        fi
    else
        echo "$config_file does not exist. Creating the file and adding 'enforce_for_root'."
        # Create the file and add the line
        printf '%s\n' "enforce_for_root" > "$config_file"
        echo "'enforce_for_root' added to newly created $config_file."
    fi

     else
            select_no "ENFORCE_FOR_ROOT SETTING_PWQUALITY:NOT ENABLED:REQUIRES CHANGE"
        fi
    fi
}



# Function to edit or add 'remember = 24' in /etc/security/pwhistory.conf
edit_or_add_remember_option() {
    local config_file="/etc/security/pwhistory.conf"
    local new_value="remember = 24"
 if grep -q "REMEMBER OPTION CONF:INVALID" "$RESULT_FILE"; then
        read -p "Do you want to edit or add 'remember = 24' in /etc/security/pwhistory.conf? (y/n): " answer
        if [[ $answer =~ ^[Yy]$ ]]; then
    log_message "Updating 'remember = 24' in /etc/security/pwhistory.conf..."
   
   
    if grep -q '^remember\s*=' "$config_file"; then
        sed -i "s/^remember\s*=.*/$new_value/" "$config_file"
    else
     
        echo "$new_value" >> "$config_file"
    fi
else
            select_no "REMEMBER OPTION CONF:INVALID:REQUIRES CHANGE"
        fi
    fi
  
}




# Function to update PAM configuration files for 'pam_pwhistory.so' module
update_pam_pwhistory() {
     if grep -q "REMEMBER OPTION PAM:INVALID" "$RESULT_FILE"; then
        read -p "Do you want to update PAM configuration files for 'pam_pwhistory.so' module? (y/n): " answer
        if [[ $answer =~ ^[Yy]$ ]]; then
    log_message "Updating PAM configuration files for 'pam_pwhistory.so' module..."
    for l_pam_file in system-auth password-auth; do
      
        l_authselect_file="/etc/authselect/$(head -1 /etc/authselect/authselect.conf | grep 'custom/')/$l_pam_file"

       
            sed -ri 's/(^\s*password\s+(requisite|required|sufficient)\s+pam_pwhistory\.so.*)(\s+remember\s*=\s*\S+)(.*$)/\1\4/' "$l_authselect_file"
        else
            echo "File $l_authselect_file does not exist. Skipping..."
        fi
    done

    authselect apply-changes
else
            select_no "REMEMBER OPTION PAM:INVALID:REQUIRES CHANGE"
        fi
    fi
  
}



# Function to update or add 'enforce_for_root' line in /etc/security/pwhistory.conf
update_pwhistory_conf() {
    local conf_file="/etc/security/pwhistory.conf"
    local setting="enforce_for_root"
if grep -q "ENFORCE_FOR_ROOT SETTING_PWHISTORY:NOT ENABLED" "$RESULT_FILE"; then
        read -p "Do you want to update or add 'enforce_for_root' line in /etc/security/pwhistory.conf? (y/n): " answer
        if [[ $answer =~ ^[Yy]$ ]]; then
    log_message"Updating 'enforce_for_root' line in /etc/security/pwhistory.conf..."


    if grep -q "^$setting" "$conf_file"; then
       
        echo "The line '$setting' already exists in $conf_file."
    else
       
        echo "$setting" >> "$conf_file"
    fi
else
            select_no "ENFORCE_FOR_ROOT SETTING_PWHISTORY:NOT ENABLED:REQUIRES CHANGE"
        fi
    fi
  
}
































set_faillock_deny
remove_deny_argument
update_unlock_time
remove_unlock_time
remove_unlock_time_argument
edit_faillock_conf
remove_even_deny_root_and_root_unlock_time
set_difok_value
remove_difok_argument
update_minlen
remove_minlen_argument
update_pwquality_conf
update_maxrepeat
remove_maxrepeat_argument
update_maxsequence
remove_maxsequence
modify_dictcheck
remove_dictcheck_argument
add_enforce_for_root
edit_or_add_remember_option
update_pam_pwhistory
update_pwhistory_conf
