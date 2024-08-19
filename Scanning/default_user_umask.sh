#!/usr/bin/bash

LOG_FILE="/var/log/hardening_scan.log"
RESULT_FILE="/var/tmp/scan_results.txt"

# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $LOG_FILE	  #output to both screen and log file
}

log_message "Checking if default user umask is properly configured."

 l_output="" l_output2=""
 file_umask_chk()
 {
 if grep -Psiq -- '^\h*umask\h+(0?[0-7][2-7]7|u(=[rwx]{0,3}),g=([rx]{0,2}),o=)(\h*#.*)?$' 
"$l_file"; then
 l_output="$l_output\n - umask is set correctly in \"$l_file\""
 elif grep -Psiq -- '^\h*umask\h+(([0-7][0-7][01][0-7]\b|[0-7][0-7][0-7][0-6]\b)|([07][01][0-7]\b|[0-7][0-7][0-6]\b)|(u=[rwx{1,3},)?(((g=[rx]?[rxw[rx]?[rx]?\b)(,o=[rwx]{1,3})?)|((g=[wrx]{1,3},)?o=[wrx]{1,3}\b)))' "$l_file"; then
 l_output2="$l_output2\n - umask is incorrectly set in \"$l_file\""
 fi
 }
 while IFS= read -r -d $'\0' l_file; do
 file_umask_chk
 done < <(find /etc/profile.d/ -type f -name '*.sh' -print0)
 l_file="/etc/profile" && file_umask_chk
 l_file="/etc/bashrc" && file_umask_chk
 l_file="/etc/bash.bashrc" && file_umask_chk
 l_file="/etc/pam.d/postlogin"
 if grep -Psiq -- '^\h*session\h+[^#\n\r]+\h+pam_umask\.so\h+([^#\n\r]+\h+)?umask=(0?[0-7][2-7]7)\b' "$l_file"; then
 l_output1="$l_output1\n - umask is set correctly in \"$l_file\""
 elif grep -Psiq '^\h*session\h+[^#\n\r]+\h+pam_umask\.so\h+([^#\n\r]+\h+)?umask=(([0-7][0-7][01][0-7]\b|[0-7][0-7][0-7][0-6]\b)|([0-7][01][0-7]\b))'"$l_file"; then
 l_output2="$l_output2\n - umask is incorrectly set in \"$l_file\""
 fi
 l_file="/etc/login.defs" && file_umask_chk
 l_file="/etc/default/login" && file_umask_chk
 [[ -z "$l_output" && -z "$l_output2" ]] && l_output2="$l_output2\n - umask is not set"
 if [ -z "$l_output2" ]; then
 echo -e "\n- Audit Result:\n ** PASS **\n - * Correctly configured * :\n$l_output\n"
 echo "DEFAULT USER UMASK:CONFIGURED" >> RESULT_FILE
 log_message "Default user umask configured properly."
 else
 echo -e "\n- Audit Result:\n ** FAIL **\n - * Reasons for audit failure * :\n$l_output2"
 [ -n "$l_output" ] && echo -e "\n- * Correctly configured * :\n$l_output\n"
 echo "DEFAULT USER UMASK:NOT CONFIGURED" >> RESULT_FILE
 log_message "Default user umask not configured properly."
 fi

