#!/usr/bin/bash


LOG_FILE="/var/log/hardening_scan.log"
RESULT_FILE="/var/tmp/scan_results.txt"

# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $LOG_FILE	  #output to both screen and log file
}

 l_output="" l_output2="" l_fwd_status="" l_nft_status="" l_fwutil_status=""
 # Determine FirewallD utility Status
 rpm -q firewalld > /dev/null 2>&1 && l_fwd_status="$(systemctl is-enabled firewalld.service):$(systemctl is-active firewalld.service)"
 # Determine NFTables utility Status
 rpm -q nftables > /dev/null 2>&1 && l_nft_status="$(systemctl is-enabled nftables.service):$(systemctl is-active nftables.service)"
 l_fwutil_status="$l_fwd_status:$l_nft_status"
 case $l_fwutil_status in
 enabled:active:masked:inactive|enabled:active:disabled:inactive) 
 l_output="\n - FirewallD utility is in use, enabled and active\n -NFTables utility is correctly disabled or masked and inactive" ;;
 masked:inactive:enabled:active|disabled:inactive:enabled:active) 
 l_output="\n - NFTables utility is in use, enabled and active\n -FirewallD utility is correctly disabled or masked and inactive" ;;
 enabled:active:enabled:active)
 l_output2="\n - Both FirewallD and NFTables utilities are enabled and active" ;;
 enabled:*:enabled:*)
 l_output2="\n - Both FirewallD and NFTables utilities are enabled" ;;
 *:active:*:active) 
 l_output2="\n - Both FirewallD and NFTables utilities are enabled" ;;
 :enabled:active) 
 l_output="\n - NFTables utility is in use, enabled, and active\n -FirewallD package is not installed" ;;
 :) 
 l_output2="\n - Neither FirewallD or NFTables is installed." ;;
 *:*:) 
 l_output2="\n - NFTables package is not installed on the system" ;;
 *) 
 l_output2="\n - Unable to determine firewall state" ;;
 esac
 if [ -z "$l_output2" ]; then
 echo -e "\n- Audit Results:\n ** Pass **\n$l_output\n"
 echo "single firewall configuration utility: IN USE" >> $RESULT_FILE
 log_message "Single firewall configuration utility is in use."

 else
 echo -e "\n- Audit Results:\n ** Fail **\n$l_output2\n"
 echo "single firewall configuration utility: NOT IN USE" >> $RESULT_FILE
 log_message "Single firewall configuration utility is not in use."

 fi

