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
 
 if grep -q "LOCAL INTERACTIVE USER DIRECTORIES:NOT CONFIGURED" $RESULT_FILE; then
	read -p "Do you want to ensure local interactive user home directories are configured? (y/n)" answer
	if [[ answer = [Yy] ]]; then
  log_message "Ensuring local interactive user home directories are configured..."
   l_output2="" 
   l_valid_shells="^($( awk -F\/ '$NF != "nologin" {print}' /etc/shells | sed -rn '/^\//{s,/,\\\\/,g;p}' | paste -s -d '|' - ))$" 
   unset a_uarr && a_uarr=() # Clear and initialize array 
   while read -r l_epu l_eph; do # Populate array with users and user home location 
      a_uarr+=("$l_epu $l_eph") 
   done <<< "$(awk -v pat="$l_valid_shells" -F: '$(NF) ~ pat { print $1 " " $(NF-1) }' /etc/passwd)" 
   l_asize="${#a_uarr[@]}" # Here if we want to look at number of users before proceeding  
   [ "$l_asize " -gt "10000" ] && echo -e "\n  ** INFO **\n  - \"$l_asize\" Local interactive users found on the system\n  - This may be a long running process\n" 
   while read -r l_user l_home; do 
      if [ -d "$l_home" ]; then 
         l_mask='0027' 
         l_max="$( printf '%o' $(( 0777 & ~$l_mask)) )" 
         while read -r l_own l_mode; do 
            if [ "$l_user" != "$l_own" ]; then 
               l_output2="$l_output2\n  - User: \"$l_user\" Home \"$l_home\" is owned by: \"$l_own\"\n  -  changing ownership to: \"$l_user\"\n" 
               chown "$l_user" "$l_home" 
            fi 
            if [ $(( $l_mode & $l_mask )) -gt 0 ]; then 
               l_output2="$l_output2\n  - User: \"$l_user\" Home \"$l_home\" is mode: \"$l_mode\" should be mode: \"$l_max\" or more restrictive\n  -  removing excess permissions\n" 
               chmod g-w,o-rwx "$l_home" 
            fi 
         done <<< "$(stat -Lc '%U %#a' "$l_home")" 
      else 
         l_output2="$l_output2\n  - User: \"$l_user\" Home \"$l_home\" Doesn't exist\n  -  Please create a home in accordance with local site policy" 
      fi 
   done <<< "$(printf '%s\n' "${a_uarr[@]}")" 
   if [ -z "$l_output2" ]; then # If l_output2 is empty, we pass 
      echo -e " - No modification needed to local interactive users home directories" 
   else 
      echo -e "\n$l_output2" 
   fi 
else
    select_no "LOCAL INTERACTIVE USER DIRECTORIES:NOT CONFIGURED"
		
	fi

 fi
