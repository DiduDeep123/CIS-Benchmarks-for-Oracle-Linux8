#!/usr/bin/bash


LOG_FILE="/var/log/hardening_scan.log"
RESULT_FILE="/var/tmp/scan_results.txt"

# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $LOG_FILE	  #output to both screen and log file
}

 l_output="" l_output2=""
 l_smask='01000'
 a_path=(); a_arr=(); a_file=(); a_dir=() # Initialize arrays
 a_path=(! -path "/run/user/*" -a ! -path "/proc/*" -a ! -path "*/containerd/*" -a ! -path "*/kubelet/pods/*" -a ! -path "/sys/kernel/security/apparmor/*" -a ! -path "/snap/*" -a ! -path "/sys/fs/cgroup/memory/*" -a ! -path "/sys/fs/selinux/*")
 while read -r l_bfs; do
 a_path+=( -a ! -path ""$l_bfs"/*")
 done < <(findmnt -Dkerno fstype,target | awk '$1 ~ /^\s*(nfs|proc|smb)/ {print $2}')
 # Populate array with files that will possibly fail one of the audits
 while IFS= read -r -d $'\0' l_file; do
 [ -e "$l_file" ] && a_arr+=("$(stat -Lc '%n^%#a' "$l_file")")
 done < <(find / \( "${a_path[@]}" \) \( -type f -o -type d \) -perm -0002 -print0 2>/dev/null)
 while IFS="^" read -r l_fname l_mode; do # Test files in the array
 [ -f "$l_fname" ] && a_file+=("$l_fname") # Add WR files
 if [ -d "$l_fname" ]; then # Add directories w/o sticky bit
 [ ! $(( $l_mode & $l_smask )) -gt 0 ] && a_dir+=("$l_fname")
 fi
 done < <(printf '%s\n' "${a_arr[@]}")
 if ! (( ${#a_file[@]} > 0 )); then
 l_output="$l_output\n - No world writable files exist on the local filesystem."
 else
 l_output2="$l_output2\n - There are \"$(printf '%s' "${#a_file[@]}")\" World writable files on the system.\n - The following is a list of World writable files:\n$(printf '%s\n' "${a_file[@]}")\n - end of list\n"
 fi
 if ! (( ${#a_dir[@]} > 0 )); then
 l_output="$l_output\n - Sticky bit is set on world writable directories on the local 
filesystem."
 else
 l_output2="$l_output2\n - There are \"$(printf '%s' "${#a_dir[@]}")\" World writable 
directories without the sticky bit on the system.\n - The following is a list of World writable 
directories without the sticky bit:\n$(printf '%s\n' "${a_dir[@]}")\n - end of list\n"
 fi
 unset a_path; unset a_arr; unset a_file; unset a_dir # Remove arrays
 # If l_output2 is empty, we pass
 if [ -z "$l_output2" ]; then
 echo -e "\n- Audit Result:\n ** PASS **\n - * Correctly configured * :\n$l_output\n"
 echo "WORLD WRITABLE FILES AND DIRECTORIES:SECURED" >> $RESULT_FILE
 log_message "No world writable files or world writable directories without the sticky bit exist."
 else
 echo -e "\n- Audit Result:\n ** FAIL **\n - * Reasons for audit failure * :\n$l_output2"
 [ -n "$l_output" ] && echo -e "- * Correctly configured * :\n$l_output\n"
 echo "WORLD WRITABLE FILES AND DIRECTORIES:NOT SECURED" >> $RESULT_FILE
 log_message "World writable files or world writable directories without the sticky bit exist."
 fi

