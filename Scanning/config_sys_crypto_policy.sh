#!/usr/bin/bash

LOG_FILE="/var/log/hardening_scan.log"
RESULT_FILE="/var/tmp/scan_results.txt"


# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $LOG_FILE	  #output to both screen and log file
}



check_crypto_policy_sha1_hash() {
    log_message "Checking if system wide crypto policy disables sha1 hash and signature support..."

    
    if grep -Piq -- '^\h*(hash|sign)\h*=\h*([^\n\r#]+)?-sha1\b' /etc/crypto-policies/state/CURRENT.pol; then
        result="System wide crypto policy disables sha1 hash and signature support."
        echo "crypto policy sha1 hash :DISABLED" >> "$RESULT_FILE"
    else
        result="System wide crypto policy has sha1 hash and signature support."
        echo "crypto policy sha1 hash :NOT DISABLED" >> "$RESULT_FILE"
    fi
    
    log_message "$result"
}

check_crypto_policy_MACS() {
    log_message "Checking if system wide crypto policy disables mac less than 128 bits..."

    
    if grep -Piq -- '^\h*mac\h*=\h*([^#\n\r]+)?-64\b' /etc/crypto-policies/state/CURRENT.pol; then
        result="System wide crypto policy disables mac less than 128 bits."
        echo "crypto policy mac :DISABLED" >> "$RESULT_FILE"
    else
        result="System wide crypto policy does not disable mac less than 128 bits."
        echo "crypto policy mac :NOT DISABLED" >> "$RESULT_FILE"
    fi
    
    log_message "$result"
}
