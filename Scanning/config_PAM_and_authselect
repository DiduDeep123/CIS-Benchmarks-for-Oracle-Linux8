#!/usr/bin/bash

LOG_FILE="/var/log/hardening_scan.log"
RESULT_FILE="/var/tmp/scan_results.txt"

# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $LOG_FILE	  #output to both screen and log file
}

# Function to check deny parameter in faillock configuration
check_faillock_deny() {

    log_message "Checking the deny parameter in faillock configuration..."

    # Search for deny argument in the faillock configuration file
    deny_found=$(grep -Pi -- '^\s*deny\s*=\s*[1-5]\b' /etc/security/faillock.conf)

    if [[ -n "$deny_found" ]]; then
        log_message "Deny parameter set to a value between 1 and 5 in faillock configuration."
        echo "FAILLOCK DENY ARGUMENT:CORRECT" >> "$RESULT_FILE"
    else
        log_message "Deny parameter not set correctly in faillock configuration."
        echo "FAILLOCK DENY ARGUMENT:INCORRECT" >> "$RESULT_FILE"
    fi
}

# Function to check unlock_time parameter in faillock configuration
check_faillock_unlock_time() {

    log_message "Checking the unlock_time parameter in faillock configuration..."

    # Search for unlock_time argument in the faillock configuration file
    unlock_time_found=$(grep -Pi -- '^\s*unlock_time\s*=\s*(0|9[0-9][0-9]|[1-9][0-9]{3,})\b' /etc/security/faillock.conf)

    if [[ -n "$unlock_time_found" ]]; then
        log_message "Unlock time is set to 0 or 900 or more seconds in faillock configuration."
        echo "FAILLOCK UNLOCK TIME:CORRECT" >> "$RESULT_FILE"
    else
        log_message "Unlock time is not set to 0 or 900 or more seconds in faillock configuration."
        echo "FAILLOCK UNLOCK TIME:INCORRECT" >> "$RESULT_FILE"
    fi
}

# Function to check for even_deny_root and root_unlock_time settings
check_faillock_settings() {
   
    log_message "Checking faillock configuration for even_deny_root and root_unlock_time..."

    # Check if either even_deny_root or root_unlock_time is set
    faillock_check=$(grep -Pi -- '^\s*(even_deny_root|root_unlock_time\s*=\s*\d+)\b' /etc/security/faillock.conf)

    if [[ -n "$faillock_check" ]]; then
        log_message "even_deny_root and/or root_unlock_time is set in faillock configuration."
        echo "FAILLOCK CONFIGURATION:SET" >> "$RESULT_FILE"
    else
        log_message "Neither even_deny_root nor root_unlock_time is set in faillock configuration."
        echo "FAILLOCK CONFIGURATION:NOT SET" >> "$RESULT_FILE"
    fi
}
# Function to verify root_unlock_time is set to 60 or more
verify_root_unlock_time() {
   
    log_message "Checking root_unlock_time setting in faillock configuration..."

    # Check if root_unlock_time is set to 60 or more
    unlock_time_check=$(grep -Pi -- '^\s*root_unlock_time\s*=\s*([1-9]|[1-5][0-9])\b' /etc/security/faillock.conf)

    if [[ -z "$unlock_time_check" ]]; then
        log_message "root_unlock_time is set to 60 or more."
        echo "ROOT UNLOCK TIME:CORRECT" >> "$RESULT_FILE"
    else
        log_message "root_unlock_time is set to less than 60."
        echo "ROOT UNLOCK TIME:INCORRECT" >> "$RESULT_FILE"
    fi
}

# Function to check pam_faillock.so configuration for root_unlock_time
check_pam_faillock_root_unlock_time() {
  
    log_message "Checking PAM configuration for root_unlock_time setting..."

    # Check PAM configuration files for root_unlock_time set to 60 or more
    pam_faillock_check=$(grep -Pi -- '^\s*auth\s+[^#\n\r]+\s+pam_faillock\.so\s+[^#\n\r]*\s+root_unlock_time\s*=\s*([1-9]|[1-5][0-9])\b' /etc/pam.d/system-auth /etc/pam.d/password-auth)

    if [[ -z "$pam_faillock_check" ]]; then
        log_message "PAM configuration correctly sets root_unlock_time to 60 or more."
        echo "PAM ROOT UNLOCK TIME:CORRECT" >> "$RESULT_FILE"
    else
        log_message "PAM configuration incorrectly sets root_unlock_time to less than 60."
        echo "PAM ROOT UNLOCK TIME:INCORRECT" >> "$RESULT_FILE"
    fi
}

# Function to check minlen setting in pwquality configuration
check_minlen_setting() {
    
    log_message "Checking minlen setting in pwquality configuration..."

    # Search for minlen option in pwquality configuration files
    minlen_check=$(grep -Psi -- '^\s*minlen\s*=\s*(1[4-9]|[2-9][0-9]|[1-9][0-9]{2,})\b' /etc/security/pwquality.conf /etc/security/pwquality.conf.d/*.conf)

    if [[ -n "$minlen_check" ]]; then
        log_message "minlen option is set to 14 or more in pwquality configuration."
        echo "PWQUALITY MINLEN SETTING:CORRECT" >> "$RESULT_FILE"
    else
        log_message "minlen option is not set correctly in pwquality configuration."
        echo "PWQUALITY MINLEN SETTING:INCORRECT" >> "$RESULT_FILE"
    fi
}

# Function to check pwquality settings in PAM configuration
check_pwquality_settings() {
   
    log_message "Checking pwquality settings in PAM configuration..."

    # Search for minclass or credit options in PAM configuration files
    pwquality_check=$(grep -Psi -- '^\s*password\s+(requisite|required|sufficient)\s+pam_pwquality\.so\s+([^#\n\r]+\s+)?(minclass=[0-3]|[dulo]credit=[^-]\d*)\b' /etc/pam.d/system-auth /etc/pam.d/password-auth)

    if [[ -z "$pwquality_check" ]]; then
        log_message "minclass is set to 4 or more and dcredit, ucredit, lcredit, ocredit are not set to 0 or greater."
        echo "PWQUALITY SETTINGS:CORRECT" >> "$RESULT_FILE"
    else
        log_message "minclass is less than 4 or dcredit, ucredit, lcredit, ocredit are set to 0 or greater."
        echo "PWQUALITY SETTINGS:INCORRECT" >> "$RESULT_FILE"
    fi
}

# Function to check maxrepeat setting in pwquality configuration
check_maxrepeat_setting() {
    
    log_message "Checking maxrepeat setting in pwquality configuration..."

    # Search for maxrepeat option in pwquality configuration files
    maxrepeat_check=$(grep -Psi -- '^\s*maxrepeat\s*=\s*[1-3]\b' /etc/security/pwquality.conf /etc/security/pwquality.conf.d/*.conf)

    if [[ -n "$maxrepeat_check" ]]; then
        log_message "maxrepeat option is set to 3 or less, and not 0 in pwquality configuration."
        echo "PWQUALITY MAXREPEAT SETTING:CORRECT" >> "$RESULT_FILE"
    else
        log_message "maxrepeat option is not set correctly in pwquality configuration."
        echo "PWQUALITY MAXREPEAT SETTING:INCORRECT" >> "$RESULT_FILE"
    fi
}

# Function to check maxsequence setting in pwquality configuration
check_maxsequence_setting() {
   
    log_message "Checking maxsequence setting in pwquality configuration..."

    # Search for maxsequence option in pwquality configuration files
    maxsequence_check=$(grep -Psi -- '^\s*maxsequence\s*=\s*[1-3]\b' /etc/security/pwquality.conf /etc/security/pwquality.conf.d/*.conf)

    if [[ -n "$maxsequence_check" ]]; then
        log_message "maxsequence option is set to 3 or less, and not 0 in pwquality configuration."
        echo "PWQUALITY MAXSEQUENCE SETTING:CORRECT" >> "$RESULT_FILE"
    else
        log_message "maxsequence option is not set correctly in pwquality configuration."
        echo "PWQUALITY MAXSEQUENCE SETTING:INCORRECT" >> "$RESULT_FILE"
    fi
}

# Function to check dictcheck option in pwquality configuration and PAM files
check_dictcheck_setting() {
    
    log_message "Checking dictcheck setting in pwquality configuration and PAM files..."

    # Check in pwquality configuration files
    dictcheck_config=$(grep -Psi -- '^\s*dictcheck\s*=\s*0\b' /etc/security/pwquality.conf /etc/security/pwquality.conf.d/*.conf)

    # Check in PAM files
    dictcheck_pam=$(grep -Psi -- '^\s*password\s+(requisite|required|sufficient)\s+pam_pwquality\.so\s+([^#\n\r]+\s+)?dictcheck\s*=\s*0\b' /etc/pam.d/system-auth /etc/pam.d/password-auth)

    if [[ -z "$dictcheck_config" && -z "$dictcheck_pam" ]]; then
        log_message "dictcheck option is not set to 0 in pwquality configuration and PAM files."
        echo "DICTCHECK SETTING:CORRECT" >> "$RESULT_FILE"
    else
        log_message "dictcheck option is incorrectly set to 0 in pwquality configuration or PAM files."
        echo "DICTCHECK SETTING:INCORRECT" >> "$RESULT_FILE"
    fi
}

# Function to check enforce_for_root setting in pwquality configuration files
check_enforce_for_root_pwquality() {
  
    log_message "Checking enforce_for_root setting in pwquality configuration files..."

    # Search for enforce_for_root option in pwquality configuration files
    enforce_check=$(grep -Psi -- '^\s*enforce_for_root\b' /etc/security/pwquality.conf /etc/security/pwquality.conf.d/*.conf)

    if [[ -n "$enforce_check" ]]; then
        log_message "enforce_for_root option is enabled in pwquality configuration files."
        echo "ENFORCE_FOR_ROOT SETTING_PWQUALITY:ENABLED" >> "$RESULT_FILE"
    else
        log_message "enforce_for_root option is not enabled in pwquality configuration files."
        echo "ENFORCE_FOR_ROOT SETTING_PWQUALITY:NOT ENABLED" >> "$RESULT_FILE"
    fi
}

# Function to check the remember option in pwhistory configuration and PAM files
check_remember_option() {

    log_message "Checking remember option in pwhistory configuration and PAM files..."

    # Check /etc/security/pwhistory.conf for remember option
    remember_conf_check=$(grep -Pi -- '^\s*remember\s*=\s*(2[4-9]|[3-9][0-9]|[1-9][0-9]{2,})\b' /etc/security/pwhistory.conf)

    if [[ -n "$remember_conf_check" ]]; then
        log_message "The remember option is correctly set to 24 or more in /etc/security/pwhistory.conf."
        echo "REMEMBER OPTION CONF:VALID" >> "$result_file"
    else
        log_message "The remember option is not set correctly in /etc/security/pwhistory.conf."
        echo "REMEMBER OPTION CONF:INVALID" >> "$result_file"
    fi

    # Check PAM configuration files for remember option
    remember_pam_check=$(grep -Pi -- '^\s*password\s+(requisite|required|sufficient)\s+pam_pwhistory\.so\s+([^#\n\r]+\s+)?remember=(2[0-3]|1[0-9]|[0-9])\b' /etc/pam.d/system-auth /etc/pam.d/password-auth)

    if [[ -z "$remember_pam_check" ]]; then
        log_message "The remember option is set correctly in PAM files."
        echo "REMEMBER OPTION PAM:VALID" >> "$RESULT_FILE"
    else
        log_message "The remember option is incorrectly set to less than 24 in PAM files."
        echo "REMEMBER OPTION PAM:INVALID" >> "$RESULT_FILE"
    fi
}

# Function to check the enforce_for_root setting in pwhistory configuration
check_enforce_for_root_pwhistory() {
  

    log_message "Checking enforce_for_root setting in /etc/security/pwhistory.conf..."

    # Search for enforce_for_root option in pwhistory configuration file
    enforce_check=$(grep -Pi -- '^\s*enforce_for_root\b' /etc/security/pwhistory.conf)

    if [[ -n "$enforce_check" ]]; then
        log_message "The enforce_for_root option is enabled in /etc/security/pwhistory.conf."
        echo "ENFORCE_FOR_ROOT SETTING_PWHISTORY:ENABLED" >> "$RESULT_FILE"
    else
        log_message "The enforce_for_root option is not enabled in /etc/security/pwhistory.conf."
        echo "ENFORCE_FOR_ROOT SETTING_PWHISTORY:NOT ENABLED" >> "$RESULT_FILE"
    fi
}

# Function to check use_authtok in pam_pwhistory.so module lines
check_use_authtok() {

    log_message "Checking use_authtok option in PAM configuration files..."

    # Search for use_authtok option in PAM configuration files
    use_authtok_check=$(grep -P -- '^\s*password\s+([^#\n\r]+)\s+pam_pwhistory\.so\s+([^#\n\r]+\s+)?use_authtok\b' /etc/pam.d/{password-auth,system-auth})

    if [[ -n "$use_authtok_check" ]]; then
        log_message "The use_authtok option is correctly set in PAM configuration files."
        echo "USE_AUTHTOK OPTION:VALID" >> "$RESULT_FILE"
    else
        log_message "The use_authtok option is not set correctly in PAM configuration files."
        echo "USE_AUTHTOK OPTION:INVALID" >> "$RESULT_FILE"
    fi
}



check_faillock_deny
check_faillock_unlock_time
check_faillock_settings
verify_root_unlock_time
check_pam_faillock_root_unlock_time
check_minlen_setting
check_pwquality_settings
check_maxrepeat_setting
check_maxsequence_setting
check_dictcheck_setting
check_enforce_for_root_pwquality
check_remember_option
check_enforce_for_root_pwhistory
check_use_authtok

