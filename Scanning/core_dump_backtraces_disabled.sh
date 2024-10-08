#!/usr/bin/bash

LOG_FILE="/var/log/hardening_scan.log"
RESULT_FILE="/var/tmp/scan_results.txt"

# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $LOG_FILE	  #output to both screen and log file
}

 log_message "Checking if core dump backtraces are disabled..."
 l_output="" l_output2=""
 a_parlist=("ProcessSizeMax=0")
 l_systemd_config_file="/etc/systemd/coredump.conf" # Main systemd configuration file
 config_file_parameter_chk()
 {
 unset A_out; declare -A A_out # Check config file(s) setting
 while read -r l_out; do
 if [ -n "$l_out" ]; then
 if [[ $l_out =~ ^\s*# ]]; then
 l_file="${l_out//# /}"
 else
 l_systemd_parameter="$(awk -F= '{print $1}' <<< "$l_out" | xargs)"
 [ "${l_systemd_parameter^^}" = "${l_systemd_parameter_name^^}" ] && A_out+=(["$l_systemd_parameter"]="$l_file")
 fi
 fi
 done < <(/usr/bin/systemd-analyze cat-config "$l_systemd_config_file" | grep -Pio '^\h*([^#\n\r]+|#\h*\/[^#\n\r\h]+\.conf\b)')
 if (( ${#A_out[@]} > 0 )); then # Assess output from files and generate output
 while IFS="=" read -r l_systemd_file_parameter_name l_systemd_file_parameter_value; do
 l_systemd_file_parameter_name="${l_systemd_file_parameter_name// /}"
 l_systemd_file_parameter_value="${l_systemd_file_parameter_value// /}"
 if [ "${l_systemd_file_parameter_value^^}" = "${l_systemd_parameter_value^^}" ]; then
 l_output="$l_output\n - \"$l_systemd_parameter_name\" is correctly set to \"$l_systemd_file_parameter_value\" in \"$(printf '%s' "${A_out[@]}")\"\n"
 else
 l_output2="$l_output2\n - \"$l_systemd_parameter_name\" is incorrectly set to \"$l_systemd_file_parameter_value\" in \"$(printf '%s' "${A_out[@]}")\" and should have a value of: \"$l_systemd_parameter_value\"\n"
 fi
 done < <(grep -Pio -- "^\h*$l_systemd_parameter_name\h*=\h*\H+" "${A_out[@]}")
 else
 l_output2="$l_output2\n - \"$l_systemd_parameter_name\" is not set in an included file\n 
** Note: \"$l_systemd_parameter_name\" May be set in a file that's ignored by load procedure 
**\n"
 fi
 }
 while IFS="=" read -r l_systemd_parameter_name l_systemd_parameter_value; do # Assess and 
check parameters
 l_systemd_parameter_name="${l_systemd_parameter_name// /}"
 l_systemd_parameter_value="${l_systemd_parameter_value// /}"
 config_file_parameter_chk
 done < <(printf '%s\n' "${a_parlist[@]}")
 if [ -z "$l_output2" ]; then # Provide output from checks
 echo -e "\n- Audit Result:\n ** PASS **\n$l_output\n"
 echo "CORE DUMP BACKTRACES:DISABLED" >> $RESULT_FILE
 log_message "Core dump backtraces are disabled."
 else
 echo -e "\n- Audit Result:\n ** FAIL **\n - Reason(s) for audit failure:\n$l_output2\n"
 [ -n "$l_output" ] && echo -e "\n- Correctly set:\n$l_output\n"
 echo "CORE DUMP BACKTRACES:NOT DISABLED" >> $RESULT_FILE
 log_message "Core dump backtraces are not disabled."
 fi

