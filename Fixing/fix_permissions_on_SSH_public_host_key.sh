#!/usr/bin/bash


LOG_FILE="/var/log/hardening_fix.log"
RESULT_FILE="/var/tmp/scan_results.txt"
NEW_LOG_FILE="/var/log/user_select.log"

# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $LOG_FILE
}

#User opted not to apply remediation function
select_no() {
	log_message "User opted not to apply remediation."
	echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $NEW_LOG_FILE
}

if grep -q "SSH_public_host_key_file_permissions:NOT CONFIGURED" $RESULT_FILE; then
	read -p "Do you want to configure correct pemissions on SSH public host key file ? (y/n)" answer
	if [[ answer = [Yy] ]]; then
   l_output="" l_output2="" 
   l_skgn="$(grep -Po -- '^(ssh_keys|_?ssh)\b' /etc/group)" # Group designated to own openSSH keys 
   l_skgid="$(awk -F: '($1 == "'"$l_skgn"'"){print $3}' /etc/group)" # Get gid of group 
   l_mfix="u-x,go-wx" 
   unset a_skarr && a_skarr=() # Clear and initialize array 
   if [ -d /etc/ssh ]; then 
      while IFS= read -r -d $'\0' l_file; do # Loop to populate array 
         if grep -Pq ':\h+OpenSSH\h+(\H+\h+)public\h+key\b' <<< "$(file "$l_file")"; then 
            a_skarr+=("$(stat -Lc '%n^%#a^%U^%G^%g' "$l_file")") 
         fi 
      done < <(find -L /etc/ssh -xdev -type f -print0) 
      while IFS="^" read -r l_file l_mode l_owner l_group l_gid; do 
         l_out2="" 
         l_pmask="0133" 
         l_maxperm="$( printf '%o' $(( 0777 & ~$l_pmask )) )" 
         if [ $(( $l_mode & $l_pmask )) -gt 0 ]; then 
            l_out2="$l_out2\n  - Mode: \"$l_mode\" should be mode: \"$l_maxperm\" or more restrictive\n   - Revoking excess permissions" 
            chmod "$l_mfix" "$l_file" 
         fi 
         if [ "$l_owner" != "root" ]; then 
            l_out2="$l_out2\n  - Owned by: \"$l_owner\" should be owned by \"root\"\n   - Changing ownership to \"root\"" 
            chown root "$l_file" 
         fi 
         if [[ ! "$l_group" =~ $l_agroup ]]; then 
            l_out2="$l_out2\n  - Owned by group \"$l_group\" should be group owned by: \"${l_agroup//|/ or }\"\n   - Changing group ownership to \"$l_sgroup\"" 
            chgrp "$l_sgroup" "$l_file" 
         fi 
         [ -n "$l_out2" ] && l_output2="$l_output2\n - File: \"$l_file\"$l_out2" 
      done <<< "$(printf '%s\n' "${a_skarr[@]}")" 
   else 
      l_output="  - openSSH keys not found on the system" 
   fi 
   unset a_skarr 
   if [ -z "$l_output2" ]; then 
      echo -e "\n- No access changes required\n" 
   else 
      echo -e "\n- Remediation results:\n$l_output2\n" 
   fi 
else
		select_no "SSH public host key file PERMISSIONS:REQUIRES CHANGE"
		
	fi
fi
