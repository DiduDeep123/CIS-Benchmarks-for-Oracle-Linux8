#!/usr/bin/bash

LOG_FILE="/var/log/hardening_scan.log"
RESULT_FILE="/var/tmp/scan_results.txt"

# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $LOG_FILE	  #output to both screen and log file
}


# Function to check if PAM modules are included in the active authselect profile
check_authselect_pam_modules() {
    log_message "Checking PAM modules in the active authselect profile..."

    # Get the active authselect profile
    active_profile=$(head -1 /etc/authselect/authselect.conf)

    if [[ -z "$active_profile" ]]; then
        result="Active authselect profile is not found."
        echo "AUTHSELECT_PROFILE:NOT FOUND" >> "$RESULT_FILE"
        log_message "$result"
        return
    fi

    # Define the path to PAM configuration files
    pam_files="/etc/authselect/${active_profile}/{system,password}-auth"

    # Check for required PAM modules
    if grep -P -- '\b(pam_pwquality\.so|pam_pwhistory\.so|pam_faillock\.so|pam_unix\.so)\b' $pam_files > /dev/null; then
        result="Required PAM modules are included in the active authselect profile."
        echo "PAM_MODULES:INCLUDED" >> "$RESULT_FILE"
    else
        result="Required PAM modules are not included in the active authselect profile."
        echo "PAM_MODULES:NOT INCLUDED" >> "$RESULT_FILE"
    fi

    log_message "$result"
}
check_pam_faillock() {
    log_message "Checking if pam_faillock is enabled in PAM configuration files..."

    if grep -Pq -- '\bpam_faillock.so\b' /etc/pam.d/{password,system}-auth; then
	result="PAM FAILOCK is enabled."
    echo "PAM_FAILOCK: ENABLED" >> "$RESULT_FILE"
  else
    echo "PAM_FAILOCK: DISABLED" >> "$RESULT_FILE"
	result="PAM FAILOCK is disabled."
  fi
    log_message "$result"
}

# Function to check if pam_pwquality is enabled
check_pam_pwquality() {
log_message "Checking if pam_pwquality is enabled in PAM configuration files..."
  if grep -Pq -- '\bpam_pwquality\.so\b' /etc/pam.d/{password,system}-auth; then
	result="pam_pwquality is enabled in PAM configuration files."
    echo "PAM_PWQUALITY: ENABLED" >> "$RESULT_FILE"
  else
	result="pam_pwquality is not enabled in PAM configuration files."
    echo "PAM_PWQUALITY: DISABLED" >> "$RESULT_FILE"
  fi
  log_message "$result"
}

# Function to check if pam_pwhistory is enabled
check_pam_pwhistory() {
log_message "Checking if pam_pwhistory is enabled in PAM configuration files..."
  if grep -Pq -- '\bpam_pwhistory\.so\b' /etc/pam.d/{password,system}-auth; then
    echo "PAM_PWHISTORY: ENABLED" >> "$RESULT_FILE"
	result="pam_pwhistory is enabled in PAM configuration files."
  else
	result="pam_pwhistory is not enabled in PAM configuration files."
    echo "PAM_PWHISTORY: DISABLED" >> "$RESULT_FILE"
  fi
  log_message "$result"
}

# Function to check if pam_unix is enabled
check_pam_unix() {
log_message "Checking if pam_unix is enabled in PAM configuration files..."

  if grep -Pq -- '\bpam_unix\.so\b' /etc/pam.d/{password,system}-auth; then
    echo "PAM_UNIX: ENABLED" >> "$RESULT_FILE"
	result="pam_unix is enabled in PAM configuration files."
  else
    echo "PAM_UNIX: DISABLED" >> "$RESULT_FILE"
	result="pam_unix is not enabled in PAM configuration files."
  fi
   log_message "$result"
}
# Function to check faillock configuration
check_faillock_config() {
  log_message "Checking /etc/security/faillock.conf for deny value..."

  if grep -Pi -- '^\h*deny\h*=\h*[1-5]\b' /etc/security/faillock.conf >/dev/null; then
    echo "FAILLOCK CONFIG:OK" >> "$RESULT_FILE"
	result="Number of failed logon attempts is set to 5 or less"
	
  else
    echo "FAILLOCK CONFIG:NOT CONFIGURED" >> "$RESULT_FILE"
	result="Number of failed logon attempts is not properly configured"
	
  fi
  log_message "result"
}


# Function to check unlock_time in /etc/security/faillock.conf
check_unlock_time_conf() {
  log_message "Checking /etc/security/faillock.conf for unlock_time value..."

  # Use grep to check if unlock_time is set to 0, 900, or more
  if grep -Pi -- '^\s*unlock_time\s*=\s*(0|9[0-9][0-9]|[1-9][0-9]{3,})\b' /etc/security/faillock.conf >/dev/null; then
    echo "FAILLOCK CONFIG:OK" >> "$RESULT_FILE"
	result="unlock_time is set to 0, 900, or more. Configuration is compliant."
  else
    echo "FAILLOCK CONFIG:REQUIRES CHANGE" >> "$RESULT_FILE" 
	result="unlock_time is not properly configured (should be 0, 900, or more)."
  fi
  log_message "$result"
}

# Function to check faillock.conf for even_deny_root and root_unlock_time
check_faillock_conf() {
  log_message "Checking /etc/security/faillock.conf for even_deny_root and root_unlock_time..."

  # Check for even_deny_root or root_unlock_time presence
  if grep -Pi -- '^\s*(even_deny_root|root_unlock_time\s*=\s*\d+)\b' /etc/security/faillock.conf >/dev/null; then
    echo "FAILLOCK CONFIG:OK" >> "$RESULT_FILE"
    result="even_deny_root or root_unlock_time is enabled. Configuration is compliant."
  else
    echo "FAILLOCK CONFIG:REQUIRES CHANGE" >> "$RESULT_FILE"
    result="Neither even_deny_root nor root_unlock_time is enabled."
  fi

  # Check if root_unlock_time is set to 60 seconds or more
  if grep -Pi -- '^\s*root_unlock_time\s*=\s*([1-9]|[1-5][0-9])\b' /etc/security/faillock.conf >/dev/null; then
    echo "FAILLOCK CONFIG:REQUIRES CHANGE" >> "$RESULT_FILE"
    result="root_unlock_time is set to less than 60 seconds."
  else
    echo "FAILLOCK CONFIG:OK" >> "$RESULT_FILE"
    result="root_unlock_time is either not set or set to 60 seconds or more. Configuration is compliant."
  fi

  log_message "$result"
}

# Function to check PAM configuration files for root_unlock_time
check_pam_root_unlock_time() {
  log_message "Checking PAM configuration files for root_unlock_time argument..."

  # Check if root_unlock_time is set to less than 60 in PAM configuration files
  if grep -Pi -- '^\s*auth\s+([^#\n\r]+\s+)?pam_faillock\.so\s+([^#\n\r]+\s+)?root_unlock_time\s*=\s*([1-9]|[1-5][0-9])\b' /etc/pam.d/system-auth /etc/pam.d/password-auth >/dev/null; then
    echo "PAM CONFIGURATION:REQUIRES CHANGE" >> "$RESULT_FILE"
    result="Found root_unlock_time set to less than 60 seconds in PAM configuration files."
  else
    echo "PAM CONFIGURATION:OK" >> "$RESULT_FILE"
    result="No root_unlock_time set to less than 60 seconds found in PAM configuration files."
  fi

  log_message "$result"
}

check_pam_version
check_authselect_version
check_authselect_pam_modules
check_pam_faillock
check_pam_pwquality
check_pam_pwhistory
check_pam_unix
check_faillock_config
check_unlock_time_conf
check_faillock_conf
check_pam_root_unlock_time
