#!/usr/bin/bash

LOG_FILE="/var/log/hardening_scan.log"
RESULT_FILE="/var/tmp/scan_results.txt"

# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $LOG_FILE	  #output to both screen and log file
}

# Function to check /etc/libuser.conf for password hashing algorithm
check_libuser_conf() {
  log_message "Checking /etc/libuser.conf for crypt_style value..."

  # Check if crypt_style is set to sha512 or yescrypt
  if grep -Pi -- '^\s*crypt_style\s*=\s*(sha512|yescrypt)\b' /etc/libuser.conf >/dev/null; then
    echo "CRYPT STYLE:STRONG" >> "$RESULT_FILE"
    result="crypt_style is set to sha512 or yescrypt in /etc/libuser.conf. Configuration is compliant."
  else
    echo "CRYPT STYLE:WEAK" >> "$RESULT_FILE"
    result="crypt_style is not set to sha512 or yescrypt in /etc/libuser.conf."
  fi

  log_message "$result"
}

# Function to check /etc/login.defs for ENCRYPT_METHOD
check_login_defs() {
  log_message "Checking /etc/login.defs for ENCRYPT_METHOD value..."

  # Check if ENCRYPT_METHOD is set to SHA512 or yescrypt
  if grep -Pi -- '^\s*ENCRYPT_METHOD\s+(SHA512|yescrypt)\b' /etc/login.defs >/dev/null; then
    echo "ENCRYPT_METHOD:STRONG" >> "$RESULT_FILE"
    result="ENCRYPT_METHOD is set to SHA512 or yescrypt in /etc/login.defs. Configuration is compliant."
  else
    echo "ENCRYPT_METHOD:WEAK" >> "$RESULT_FILE"
    result="ENCRYPT_METHOD is not set to SHA512 or yescrypt in /etc/login.defs."
  fi

  log_message "$result"
}

# Function to check /etc/login.defs for PASS_MAX_DAYS
check_pass_max_days() {
  log_message "Checking /etc/login.defs for PASS_MAX_DAYS value..."

  # Check if PASS_MAX_DAYS is set to 365 or less
  if grep -E '^\s*PASS_MAX_DAYS\s+[0-9]+' /etc/login.defs | awk '{print $2}' | awk -v max_days=365 '$1 > max_days' >/dev/null; then
    echo "PASS_MAX_DAYS:REQUIRES CHANGE" >> "$RESULT_FILE"
    result="PASS_MAX_DAYS is set to more than 365 days in /etc/login.defs. Configuration requires change."
  else
    echo "PASS_MAX_DAYS:OK" >> "$RESULT_FILE"
    result="PASS_MAX_DAYS is set to 365 days or less in /etc/login.defs. Configuration is compliant."
  fi

  log_message "$result"
}


check_users_pass_max_days() {
    log_message "Checking /etc/shadow for users' PASS_MAX_DAYS values..."

    local non_compliant_found=false

    users_pass_max_days=$(grep -E '^[^:]+:[^!*]' /etc/shadow | cut -d: -f1,5)

    while IFS=: read -r user pass_max_days; do
        # If PASS_MAX_DAYS is empty default to unlimited (0)
        if [ -z "$pass_max_days" ]; then
            pass_max_days="0"
        fi

        # Check if PASS_MAX_DAYS is more than 365
        if [ "$pass_max_days" -gt 365 ]; then
            echo "User: $user, PASS_MAX_DAYS: $pass_max_days - REQUIRES CHANGE" >> "$RESULT_FILE"
            log_message "User $user has PASS_MAX_DAYS set to $pass_max_days, which exceeds 365."
            echo "PASS_MAX_DAYS_ETC_SHADOW:REQUIRES CHANGE" >> "$RESULT_FILE"
            non_compliant_found=true
        else
            echo "User: $user, PASS_MAX_DAYS: $pass_max_days - OK" >> "$RESULT_FILE"
            log_message "User $user has PASS_MAX_DAYS set to $pass_max_days, which is compliant."
            echo "PASS_MAX_DAYS_ETC_SHADOW:OK" >> "$RESULT_FILE"
        fi
    done <<< "$users_pass_max_days"

 
    if $non_compliant_found; then
        log_message "Some users have PASS_MAX_DAYS exceeding 365 days. Review required."
    else
        log_message "All users have PASS_MAX_DAYS within the policy (<= 365 days)."
    fi
}


check_pass_warn_age() {
    local config_file="/etc/login.defs"
    local min_warn_age=7

    # Check if the file exists
    if [ ! -f "$config_file" ]; then
        echo "Error: $config_file not found!"
        return 1
    fi

    # Extract the PASS_WARN_AGE value from /etc/login.defs
    pass_warn_age=$(grep -E '^\s*PASS_WARN_AGE\s+' "$config_file" | awk '{print $2}')

    # Check if PASS_WARN_AGE is set and whether it meets the minimum required value
    if [[ -n "$pass_warn_age" ]]; then
        if [[ "$pass_warn_age" -ge $min_warn_age ]]; then
            log_message "PASS_WARN_AGE is set to $pass_warn_age days and conforms to site policy."
            echo "PASS_WARN_AGE:OK" >> "$RESULT_FILE"
        else
             log_message "PASS_WARN_AGE is set to $pass_warn_age days and does not conform to site policy. Requires change."
              echo "PASS_WARN_AGE:REQUIRES CHANGE"
        fi
    else
        log_message "PASS_WARN_AGE is not set in $config_file. Configuration requires change."
         echo "PASS_WARN_AGE:REQUIRES CHANGE"
    fi
}


# Function to check users for PASS_WARN_AGE
check_user_warn_age() {
  log_message "Checking users' PASS_WARN_AGE in /etc/shadow..."

  # Check if any users have PASS_WARN_AGE set to less than 7 days
  awk -F: '/^[^:\n\r]+:[^!\*xX\n\r]/ {print $1 ":" $6}' /etc/shadow | while IFS=: read user warn_age; do
    if [[ "$warn_age" -lt 7 ]]; then
      echo "PASS_WARN_AGE_ETC_SHADOW:REQUIRES CHANGE - $user has PASS_WARN_AGE set to $warn_age which is less than 7 days." >> "$RESULT_FILE"
    fi
  done

  # Check if all users have PASS_WARN_AGE set to 7 or more days
  if awk -F: '/^[^:\n\r]+:[^!\*xX\n\r]/ {print $6}' /etc/shadow | awk -v min_warn=7 '$1 < min_warn' | read -r; then
    echo "PASS_WARN_AGE_ETC_SHADOW:REQUIRES CHANGE" >> "$RESULT_FILE"
    result="Some users have PASS_WARN_AGE set to less than 7 days."
  else
    echo "PASS_WARN_AGE_ETC_SHADOW:OK" >> "$RESULT_FILE"
    result="All users have PASS_WARN_AGE set to 7 days or more."
  fi

  log_message "$result"
}

# Function to check INACTIVE value in default user account settings
check_inactive_default() {
  log_message "Checking default INACTIVE value using useradd -D..."

  # Check the INACTIVE value set for new users
  if useradd -D | grep -E 'INACTIVE\s*=\s*[0-9]+' | awk -F= '{print $2}' | awk -v max_inactive=30 '$1 > max_inactive' >/dev/null; then
    echo "INACTIVE:REQUIRES CHANGE" >> "$RESULT_FILE"
    result="INACTIVE is set to more than 30 days in default user settings. Configuration requires change."
  else
    echo "INACTIVE:OK" >> "$RESULT_FILE"
    result="INACTIVE is set to 30 days or less in default user settings. Configuration is compliant."
  fi

  log_message "$result"
}

# Function to check users' INACTIVE values in /etc/shadow
check_user_inactive() {
  log_message "Checking users' INACTIVE values in /etc/shadow..."

  # Check if any users have INACTIVE set to more than 30 days
  awk -F: '/^[^#:]+:[^!\*:]*:[^:]*:[^:]*:[^:]*:[^:]*:(\s*|-1|3[1-9]|[4-9][0-9]|[1-9][0-9][0-9]+):[^:]*:[^:]*\s*$/ {print $1":"$7}' /etc/shadow | while IFS=: read user inactive; do
    if [[ "$inactive" -gt 30 ]]; then
      echo "INACTIVE_ETC_SHADOW:REQUIRES CHANGE - $user has INACTIVE set to $inactive which is more than 30 days." >> "$RESULT_FILE"
    fi
  done

  # Check if all users have INACTIVE set to 30 days or less
  if awk -F: '/^[^#:]+:[^!\*:]*:[^:]*:[^:]*:[^:]*:[^:]*:(\s*|-1|3[1-9]|[4-9][0-9]|[1-9][0-9][0-9]+):[^:]*:[^:]*\s*$/ {print $7}' /etc/shadow | awk -v max_inactive=30 '$1 > max_inactive' | read -r; then
    echo "INACTIVE_ETC_SHADOW:REQUIRES CHANGE" >> "$RESULT_FILE"
    result="Some users have INACTIVE set to more than 30 days."
  else
    echo "INACTIVE_ETC_SHADOW:OK" >> "$RESULT_FILE"
    result="All users have INACTIVE set to 30 days or less."
  fi

  log_message "$result"
}

verify_password_change_dates() {
    log_message "Ensuring all users last password change date is in the past..."
    while IFS= read -r l_user; do
        
        l_change=$(date -d "$(chage --list "$l_user" | grep '^Last password change' | cut -d: -f2 | grep -v 'never$')" +%s)
        
        
        if [[ "$l_change" -gt "$(date +%s)" ]]; then
          log_message "User: \"$l_user\" last password change was \"$(chage --list "$l_user" | grep '^Last password change' | cut -d: -f2)\""
        fi
    done < <(awk -F: '/^[^:\n\r]+:[^!*xX\n\r]/{print $1}' /etc/shadow)
}

# Function to check root's primary GID
check_root_gid() {
  log_message "Checking root's primary GID in /etc/passwd..."

  # Extract the GID of the root user
  root_gid=$(awk -F: '$1 == "root" {print $4}' /etc/passwd)

  # Check if the GID is 0
  if [ "$root_gid" -eq 0 ]; then
    echo "ROOT GID CONFIG:OK" >> "$RESULT_FILE"
    result="Root user's primary group ID is 0. Configuration is compliant."
  else
    echo "ROOT GID CONFIG:REQUIRES CHANGE" >> "$RESULT_FILE"
    result="Root user's primary group ID is not 0. Configuration requires change."
  fi

  log_message "$result"
}






# Function to check umask settings
check_umask() {
  log_message "Checking umask settings in /root/.bash_profile and /root/.bashrc..."

  # Patterns to check for umask settings that should not be present
  umask_pattern='^\s*umask\s+(([0-7][0-7][01][0-7]\b|[0-7][0-7][0-7][0-6]\b)|([0-7][01][0-7]\b|[0-7][0-7][0-6]\b)|(u=[rwx]{1,3},)?(((g=[rx]?[rx]?w[rx]?[rx]?\b)(,o=[rwx]{1,3})?)|((g=[wrx]{1,3},)?o=[wrx]{1,3}\b)))'

  # Check /root/.bash_profile and /root/.bashrc for inappropriate umask settings
  for file in /root/.bash_profile /root/.bashrc; do
    if grep -P "$umask_pattern" "$file" >/dev/null; then
      echo "UMASK CONFIG:REQUIRES CHANGE" >> "$RESULT_FILE"
      result="Inappropriate umask settings found in $file. Configuration requires change."
    else
      echo "UMASK CONFIG:OK" >> "$RESULT_FILE"
      result="No inappropriate umask settings found in $file. Configuration is compliant."
    fi
    log_message "$result"
  done
}

# Function to check if root password is set
check_root_password_set() {
  log_message "Checking if root password is set..."

  # Run the passwd -S root command and capture the output
  passwd_status=$(passwd -S root 2>&1)

  # Check if the output contains "Password set"
  if echo "$passwd_status" | grep -q "Password set"; then
    echo "ROOT PASSWORD CONFIG:OK" >> "$RESULT_FILE"
    result="Root password is set. Configuration is compliant."
  else
    echo "ROOT PASSWORD CONFIG:REQUIRES CHANGE" >> "$RESULT_FILE"
    result="Root password is not set or is not properly configured. Configuration requires change."
  fi

  log_message "$result"
}

# Function to check if nologin is listed in /etc/shells
check_nologin_in_shells() {
  log_message "Checking if /nologin is listed in /etc/shells..."

  # Search for '/nologin' in /etc/shells
  if grep -P '/nologin\b' /etc/shells >/dev/null; then
    echo "NO LOGIN CONFIG:REQUIRES CHANGE" >> "$RESULT_FILE"
    result="/nologin is listed in /etc/shells. Configuration requires change."
  else
    echo "NO LOGIN CONFIG:OK" >> "$RESULT_FILE"
    result="/nologin is not listed in /etc/shells. Configuration is compliant."
  fi

  log_message "$result"
}



# Function to check and report TMOUT configuration
check_tmout_configuration() {
    local output1=""
    local output2=""
    local BRC="/etc/bashrc"

    # Check if /etc/bashrc exists and set BRC
    [ -f "$BRC" ] && BRC="/etc/bashrc"

    # Check TMOUT settings in specified files
    for f in "$BRC" /etc/profile /etc/profile.d/*.sh; do
        if grep -Pq '^\s*([^#]+\s+)?TMOUT=(900|[1-8][0-9][0-9]|[1-9][0-9]|[1-9])\b' "$f" &&
           grep -Pq '^\s*([^#]+;\s*)?readonly\s+TMOUT(\s+|\s*;|\s*$|=(900|[1-8][0-9][0-9]|[1-9][0-9]|[1-9]))\b' "$f" &&
           grep -Pq '^\s*([^#]+;\s*)?export\s+TMOUT(\s+|\s*;|\s*$|=(900|[1-8][0-9][0-9]|[1-9][0-9]|[1-9]))\b' "$f"; then
            output1="$f"
        fi
    done

    # Check for incorrect TMOUT settings
    grep -Pq '^\s*([^#]+\s+)?TMOUT=(9[0-9][1-9]|9[1-9][0-9]|0+|[1-9]\d{3,})\b' /etc/profile /etc/profile.d/*.sh "$BRC" &&
    output2=$(grep -Ps '^\s*([^#]+\s+)?TMOUT=(9[0-9][1-9]|9[1-9][0-9]|0+|[1-9]\d{3,})\b' /etc/profile /etc/profile.d/*.sh "$BRC")

    # Report results
    if [ -n "$output1" ] && [ -z "$output2" ]; then
        echo -e "\nPASSED\n\nTMOUT is configured correctly in: \"$output1\"\n"
    else
        [ -z "$output1" ] && echo -e "\nFAILED\n\nTMOUT is not configured correctly\n"
        [ -n "$output2" ] && echo -e "\nFAILED\n\nTMOUT is incorrectly configured in: \"$output2\"\n"
    fi
}




check_libuser_conf
check_login_defs
check_pass_max_days
check_users_pass_max_days
check_user_inactive
check_pass_warn_age
check_user_warn_age
check_inactive_default
verify_password_change_dates
check_root_gid
check_root_password_set
check_nologin_in_shells
check_tmout_configuration
