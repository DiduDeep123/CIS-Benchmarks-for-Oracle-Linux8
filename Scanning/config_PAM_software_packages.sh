#!/usr/bin/bash

LOG_FILE="/var/log/hardening_scan.log"
RESULT_FILE="/var/tmp/scan_results.txt"

# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $LOG_FILE	  #output to both screen and log file
}

# Function to check PAM version
check_pam_version() {
    log_message "Checking PAM version..."

    # Run the command to get the PAM version
    pam_version=$(rpm -q pam 2>/dev/null)

    if [[ $? -ne 0 ]]; then
        result="PAM package is not installed."
        echo "PAM:NOT INSTALLED" >> "$RESULT_FILE"
        log_message "$result"
        return
    fi

    # Extract the version from the output
    version=$(echo "$pam_version" | awk -F'-' '{print $1"-"$2}')

    if [[ "$version" == "pam-1.3.1" ]] || [[ "$version" == "pam-1.3.1"* ]]; then
        result="PAM version is $version, which is acceptable."
        echo "PAM:VERSION OK" >> "$RESULT_FILE"
    else
        result="PAM version is $version, which does not meet the required criteria."
        echo "PAM:VERSION NEEDS UPGRADE" >> "$RESULT_FILE"
    fi

    log_message "$result"
}

check_authselect_version() {
    log_message "Checking authselect version..."

    authselect_version=$(rpm -q authselect 2>/dev/null)

    if [[ $? -ne 0 ]]; then
        result="Authselect package is not installed."
        echo "AUTHSELECT:NOT INSTALLED" >> "$RESULT_FILE"
        log_message "$result"
        return
    fi

    # Extract the version from the output
    version=$(echo "$authselect_version" | awk -F'-' '{print $1"-"$2}')

    if [[ "$version" == "authselect-1.2.6" ]] || [[ "$version" == "authselect-1.2.6"* ]]; then
        result="Authselect version is $version, which is acceptable."
        echo "AUTHSELECT:VERSION OK ($version)" >> "$RESULT_FILE"
    else
        result="Authselect version is $version, which does not meet the required criteria."
        echo "AUTHSELECT:VERSION NOT OK ($version)" >> "$RESULT_FILE"
    fi

    log_message "$result"
}

check_pam_version
check_authselect_version
