#!/usr/bin/bash

LOG_FILE="/var/log/hardening_scan.log"
RESULT_FILE="/var/tmp/scan_results.txt"

# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $LOG_FILE	  #output to both screen and log file
}

 l_output="" l_output2=""
 if nft list ruleset | awk '/hook\s+input\s+/,/\}\s*(#.*)?$/' | grep -Pq --'\H+\h+"lo"\h+accept'; then
 l_output="$l_output\n - Network traffic to the loopback address is 
correctly set to accept"
 else
 l_output2="$l_output2\n - Network traffic to the loopback address is 
not set to accept"
 fi
 l_ipsaddr="$(nft list ruleset | awk '/filter_IN_public_deny|hook\s+input\s+/,/\}\s*(#.*)?$/' | grep -P --'ip\h+saddr')"
 if grep -Pq --'ip\h+saddr\h+127\.0\.0\.0\/8\h+(counter\h+packets\h+\d+\h+bytes\h+\d+\h+)?dr
op' <<< "$l_ipsaddr" || grep -Pq --'ip\h+daddr\h+\!\=\h+127\.0\.0\.1\h+ip\h+saddr\h+127\.0\.0\.1\h+drop' <<< "$l_ipsaddr"; then
 l_output="$l_output\n - IPv4 network traffic from loopback address 
correctly set to drop"
 else
 l_output2="$l_output2\n - IPv4 network traffic from loopback address 
not set to drop"
 fi
 if grep -Pq -- '^\h*0\h*$' /sys/module/ipv6/parameters/disable; then
 l_ip6saddr="$(nft list ruleset | awk '/filter_IN_public_deny|hook 
input/,/}/' | grep 'ip6 saddr')"
 if grep -Pq 'ip6\h+saddr\h+::1\h+(counter\h+packets\h+\d+\h+bytes\h+\d+\h+)?drop' <<< "$l_ip6saddr" || grep -Pq --'ip6\h+daddr\h+\!=\h+::1\h+ip6\h+saddr\h+::1\h+drop' <<< "$l_ip6saddr"; then
 l_output="$l_output\n - IPv6 network traffic from loopback address 
correctly set to drop"
 else
 l_output2="$l_output2\n - IPv6 network traffic from loopback address 
not set to drop"
 fi
 fi
 if [ -z "$l_output2" ]; then
 echo -e "\n- Audit Result:\n *** PASS ***\n$l_output"
 echo "firewall_loopback_traffic:CONFIGURED" >> $RESULT_FILE
 log_message "host based firewall loopback traffic is configured."
 else
 echo -e "\n- Audit Result:\n *** FAIL ***\n$l_output2\n\n - Correctly set:\n$l_output"
 echo "firewall_loopback_traffic:NOT CONFIGURED" >> $RESULT_FILE
 log_message "host based firewall loopback traffic is not configured."
 fi

