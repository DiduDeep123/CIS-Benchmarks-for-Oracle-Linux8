#!/usr/bin/bash

LOG_FILE="/var/log/hardening_scan.log"
RESULT_FILE="/var/tmp/scan_results.txt"


# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $LOG_FILE	  #output to both screen and log file
}


check_nftables(){
package="nftables"

	log_message "Checking if nftables is installed..."

if rpm -q "$package" > /dev/null 2>&1; then
	log_message "$package is installed."
	echo "nftables:INSTALLED" >> "$RESULT_FILE"
		
else
	echo "package is not installed."
	echo "nftables:NOT INSTALLED" >> "$RESULT_FILE"
fi
}

check_nft_base_chains() {
    log_message "Checking nftables base chains..."

    # Define the commands to check for base chains
    input_chain_check='type filter hook input'
    forward_chain_check='type filter hook forward'
    output_chain_check='type filter hook output'

    # Run nft command and capture output
    nft_output=$(nft list ruleset)

    # Check for INPUT filter hook
    if echo "$nft_output" | grep -q "$input_chain_check"; then
        log_message "Base chain for INPUT filter hook exists."
        echo "INPUT_FILTER_HOOK:EXISTS" >> "$RESULT_FILE"
    else
        log_message "Base chain for INPUT filter hook does not exist."
        echo "INPUT_FILTER_HOOK:NOT_EXISTS" >> "$RESULT_FILE"
    fi

    # Check for FORWARD filter hook
    if echo "$nft_output" | grep -q "$forward_chain_check"; then
        log_message "Base chain for FORWARD filter hook exists."
        echo "FORWARD_FILTER_HOOK:EXISTS" >> "$RESULT_FILE"
    else
        log_message "Base chain for FORWARD filter hook does not exist."
        echo "FORWARD_FILTER_HOOK:NOT_EXISTS" >> "$RESULT_FILE"
    fi

    # Check for OUTPUT filter hook
    if echo "$nft_output" | grep -q "$output_chain_check"; then
        log_message "Base chain for OUTPUT filter hook exists."
        echo "OUTPUT_FILTER_HOOK:EXISTS" >> "$RESULT_FILE"
    else
        log_message "Base chain for OUTPUT filter hook does not exist."
        echo "OUTPUT_FILTER_HOOK:NOT_EXISTS" >> "$RESULT_FILE"
    fi
}

check_nftables_rules() {
    log_message "Checking nftables rules ..."

    # Check if nftables service is enabled
    if systemctl is-enabled nftables.service | grep -q 'enabled'; then
        log_message "nftables service is enabled."

        # Extract nftables rules related to established connections
        nft_output=$(nft list ruleset | awk '/hook input/,/}/')

        # Define expected rules
        expected_rules=(
            "ip protocol tcp ct state established accept"
            "ip protocol udp ct state established accept"
            "ip protocol icmp ct state established accept"
        )

        # Check if each expected rule exists
        all_rules_present=true
        for rule in "${expected_rules[@]}"; do
            if echo "$nft_output" | grep -q "$rule"; then
                log_message "Rule for '$rule' is present."
                echo "RULE_PRESENT:$rule" >> "$RESULT_FILE"
            else
                log_message "Rule for '$rule' is missing."
                echo "RULE_MISSING:$rule" >> "$RESULT_FILE"
                all_rules_present=false
            fi
        done

        # Final result
        if [ "$all_rules_present" = true ]; then
            log_message "All expected rules for established connections are present."
            echo "ESTABLISHED_CONNECTIONS:ALL_RULES_PRESENT" >> "$RESULT_FILE"
        else
            log_message "Some expected rules for established connections are missing."
            echo "ESTABLISHED_CONNECTIONS:SOME_RULES_MISSING" >> "$RESULT_FILE"
        fi

    else
        log_message "nftables service is not enabled."
        echo "NFTABLES_SERVICE:NOT_ENABLED" >> "$RESULT_FILE"
    fi
}


check_nftables_base_chains_policy() {
    log_message "Checking nftables base chains policy..."

    # Check if nftables service is enabled
    if systemctl --quiet is-enabled nftables.service; then
        log_message "nftables service is enabled."

        # Check INPUT chain policy
        input_policy=$(nft list ruleset | awk '/hook input/,/}/' | grep -v 'policy drop')
        if [ -z "$input_policy" ]; then
            log_message "Base chain for INPUT hook has a policy of DROP."
            echo "INPUT_CHAIN_POLICY:DROP" >> "$RESULT_FILE"
        else
            log_message "Base chain for INPUT hook does not have a policy of DROP."
            echo "INPUT_CHAIN_POLICY:NOT DROP" >> "$RESULT_FILE"
        fi

        # Check FORWARD chain policy
        forward_policy=$(nft list ruleset | awk '/hook forward/,/}/' | grep -v 'policy drop')
        if [ -z "$forward_policy" ]; then
            log_message "Base chain for FORWARD hook has a policy of DROP or is correctly configured."
            echo "FORWARD_CHAIN_POLICY:DROP" >> "$RESULT_FILE"
        else
            log_message "Base chain for FORWARD hook does not have a policy of DROP."
            echo "FORWARD_CHAIN_POLICY:NOT DROP" >> "$RESULT_FILE"
        fi

    else
        log_message "nftables service is not enabled."
        echo "NFTABLES_SERVICE:NOT_ENABLED" >> "$RESULT_FILE"
    fi
}

check_nftables
check_nft_base_chains
check_nftables_rules
check_nftables_base_chains_policy
