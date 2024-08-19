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
    echo "LIBUSER CONFIG:OK" >> "$RESULT_FILE"
    result="crypt_style is set to sha512 or yescrypt in /etc/libuser.conf. Configuration is compliant."
  else
    echo "LIBUSER CONFIG:REQUIRES CHANGE" >> "$RESULT_FILE"
    result="crypt_style is not set to sha512 or yescrypt in /etc/libuser.conf."
  fi

  log_message "$result"
}

# Function to check /etc/login.defs for ENCRYPT_METHOD
check_login_defs() {
  log_message "Checking /etc/login.defs for ENCRYPT_METHOD value..."

  # Check if ENCRYPT_METHOD is set to SHA512 or yescrypt
  if grep -Pi -- '^\s*ENCRYPT_METHOD\s+(SHA512|yescrypt)\b' /etc/login.defs >/dev/null; then
    echo "LOGIN DEFS CONFIG:OK" >> "$RESULT_FILE"
    result="ENCRYPT_METHOD is set to SHA512 or yescrypt in /etc/login.defs. Configuration is compliant."
  else
    echo "LOGIN DEFS CONFIG:REQUIRES CHANGE" >> "$RESULT_FILE"
    result="ENCRYPT_METHOD is not set to SHA512 or yescrypt in /etc/login.defs."
  fi

  log_message "$result"
}

# Function to check /etc/login.defs for PASS_MAX_DAYS
check_pass_max_days() {
  log_message "Checking /etc/login.defs for PASS_MAX_DAYS value..."

  # Check if PASS_MAX_DAYS is set to 365 or less
  if grep -E '^\s*PASS_MAX_DAYS\s+[0-9]+' /etc/login.defs | awk '{print $2}' | awk -v max_days=365 '$1 > max_days' >/dev/null; then
    echo "LOGIN DEFS CONFIG:REQUIRES CHANGE" >> "$RESULT_FILE"
    result="PASS_MAX_DAYS is set to more than 365 days in /etc/login.defs. Configuration requires change."
  else
    echo "LOGIN DEFS CONFIG:OK" >> "$RESULT_FILE"
    result="PASS_MAX_DAYS is set to 365 days or less in /etc/login.defs. Configuration is compliant."
  fi

  log_message "$result"
}

# Function to check users for PASS_WARN_AGE
check_user_warn_age() {
  log_message "Checking users' PASS_WARN_AGE in /etc/shadow..."

  # Check if any users have PASS_WARN_AGE set to less than 7 days
  awk -F: '/^[^:\n\r]+:[^!\*xX\n\r]/ {print $1 ":" $6}' /etc/shadow | while IFS=: read user warn_age; do
    if [[ "$warn_age" -lt 7 ]]; then
      echo "USER CONFIG:REQUIRES CHANGE - $user has PASS_WARN_AGE set to $warn_age which is less than 7 days." >> "$RESULT_FILE"
    fi
  done

  # Check if all users have PASS_WARN_AGE set to 7 or more days
  if awk -F: '/^[^:\n\r]+:[^!\*xX\n\r]/ {print $6}' /etc/shadow | awk -v min_warn=7 '$1 < min_warn' | read -r; then
    echo "USER CONFIG:REQUIRES CHANGE" >> "$RESULT_FILE"
    result="Some users have PASS_WARN_AGE set to less than 7 days."
  else
    echo "USER CONFIG:OK" >> "$RESULT_FILE"
    result="All users have PASS_WARN_AGE set to 7 days or more."
  fi

  log_message "$result"
}

# Function to check INACTIVE value in default user account settings
check_inactive_default() {
  log_message "Checking default INACTIVE value using useradd -D..."

  # Check the INACTIVE value set for new users
  if useradd -D | grep -E 'INACTIVE\s*=\s*[0-9]+' | awk -F= '{print $2}' | awk -v max_inactive=30 '$1 > max_inactive' >/dev/null; then
    echo "DEFAULT CONFIG:REQUIRES CHANGE" >> "$RESULT_FILE"
    result="INACTIVE is set to more than 30 days in default user settings. Configuration requires change."
  else
    echo "DEFAULT CONFIG:OK" >> "$RESULT_FILE"
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
      echo "USER CONFIG:REQUIRES CHANGE - $user has INACTIVE set to $inactive which is more than 30 days." >> "$RESULT_FILE"
    fi
  done

  # Check if all users have INACTIVE set to 30 days or less
  if awk -F: '/^[^#:]+:[^!\*:]*:[^:]*:[^:]*:[^:]*:[^:]*:(\s*|-1|3[1-9]|[4-9][0-9]|[1-9][0-9][0-9]+):[^:]*:[^:]*\s*$/ {print $7}' /etc/shadow | awk -v max_inactive=30 '$1 > max_inactive' | read -r; then
    echo "USER CONFIG:REQUIRES CHANGE" >> "$RESULT_FILE"
    result="Some users have INACTIVE set to more than 30 days."
  else
    echo "USER CONFIG:OK" >> "$RESULT_FILE"
    result="All users have INACTIVE set to 30 days or less."
  fi

  log_message "$result"
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
    log_message "SHELL CONFIG:REQUIRES CHANGE - /nologin is listed in /etc/shells"
    result="/nologin is listed in /etc/shells. Configuration requires change."
  else
    log_message "SHELL CONFIG:OK - /nologin is not listed in /etc/shells"
    result="/nologin is not listed in /etc/shells. Configuration is compliant."
  fi

  log_message "$result"
}


check_libuser_conf
check_login_defs
check_pass_max_days
check_user_inactive
check_user_warn_age
check_inactive_default
check_root_gid
check_root_password_set
check_nologin_in_shells
