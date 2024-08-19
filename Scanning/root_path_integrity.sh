#!/usr/bin/bash

LOG_FILE="/var/log/hardening_scan.log"
RESULT_FILE="/var/tmp/scan_results.txt"

# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $LOG_FILE	  #output to both screen and log file
}


 l_output2=""
 l_pmask="0022"
 l_maxperm="$( printf '%o' $(( 0777 & ~$l_pmask )) )"
 l_root_path="$(sudo -Hiu root env | grep '^PATH' | cut -d= -f2)"
 unset a_path_loc && IFS=":" read -ra a_path_loc <<< "$l_root_path"
 grep -q "::" <<< "$l_root_path" && l_output2="$l_output2\n - root's path contains a empty directory (::)"
 grep -Pq ":\h*$" <<< "$l_root_path" && l_output2="$l_output2\n - root's path contains a trailing (:)"
 grep -Pq '(\h+|:)\.(:|\h*$)' <<< "$l_root_path" && l_output2="$l_output2\n - root's path contains current working directory (.)"
 while read -r l_path; do
 if [ -d "$l_path" ]; then
 while read -r l_fmode l_fown; do
 [ "$l_fown" != "root" ] && l_output2="$l_output2\n - Directory: 
\"$l_path\" is owned by: \"$l_fown\" should be owned by \"root\""
 [ $(( $l_fmode & $l_pmask )) -gt 0 ] && l_output2="$l_output2\n -Directory: \"$l_path\" is mode: \"$l_fmode\" and should be mode: 
\"$l_maxperm\" or more restrictive"
 done <<< "$(stat -Lc '%#a %U' "$l_path")"
 else
 l_output2="$l_output2\n - \"$l_path\" is not a directory"
 fi
 done <<< "$(printf "%s\n" "${a_path_loc[@]}")"
 if [ -z "$l_output2" ]; then
 echo -e "\n- Audit Result:\n *** PASS ***\n - Root's path is correctly configured\n"
echo "ROOT PATH INTEGRITY:CONFIGURED" >> RESULT_FILE
 else
 echo -e "\n- Audit Result:\n ** FAIL **\n - * Reasons for audit 
failure * :\n$l_output2\n"
echo "ROOT PATH INTEGRITY:NOT CONFIGURED" >> RESULT_FILE
 fi

