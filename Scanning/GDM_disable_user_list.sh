#!/usr/bin/bash

LOG_FILE="/var/log/hardening_scan.log"
RESULT_FILE="/var/tmp/scan_results.txt"

# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $LOG_FILE	  #output to both screen and log file
}

log_message "Checking if GDM disable user list option is enabled..."


 l_pkgoutput=""
 if command -v dpkg-query > /dev/null 2>&1; then
 l_pq="dpkg-query -W"
 elif command -v rpm > /dev/null 2>&1; then
 l_pq="rpm -q"
 fi
 l_pcl="gdm gdm3" # Space seporated list of packages to check
 for l_pn in $l_pcl; do
 $l_pq "$l_pn" > /dev/null 2>&1 && l_pkgoutput="$l_pkgoutput\n - Package: \"$l_pn\" exists on the system\n - checking configuration"
 done
 if [ -n "$l_pkgoutput" ]; then
 output="" output2=""
 l_gdmfile="$(grep -Pril '^\h*disable-user-list\h*=\h*true\b' /etc/dconf/db)"
 if [ -n "$l_gdmfile" ]; then
 output="$output\n - The \"disable-user-list\" option is enabled in \"$l_gdmfile\""
 l_gdmprofile="$(awk -F\/ '{split($(NF-1),a,".");print a[1]}' <<< "$l_gdmfile")"
 if grep -Pq "^\h*system-db:$l_gdmprofile" /etc/dconf/profile/"$l_gdmprofile"; then
 output="$output\n - The \"$l_gdmprofile\" exists"
 else
 output2="$output2\n - The \"$l_gdmprofile\" doesn't exist"
 fi
 if [ -f "/etc/dconf/db/$l_gdmprofile" ]; then
 output="$output\n - The \"$l_gdmprofile\" profile exists in the dconf database"
 else
 output2="$output2\n - The \"$l_gdmprofile\" profile doesn't exist in the dconf database"
 fi
 else
 output2="$output2\n - The \"disable-user-list\" option is not enabled"
 fi
 if [ -z "$output2" ]; then
 echo -e "$l_pkgoutput\n- Audit result:\n *** PASS: ***\n$output\n"
 echo "GDM DISABLE USER LIST: ENABLED" >> $RESULT_FILE
 log_message "GDM disable user list option is enabled."
 else
 echo -e "$l_pkgoutput\n- Audit Result:\n *** FAIL: ***\n$output2\n"
 echo "GDM DISABLE USER LIST: NOT ENABLED" >> $RESULT_FILE
 log_message "GDM disable user list option is not enabled."
 [ -n "$output" ] && echo -e "$output\n"
 fi
 else
 echo -e "\n\n - GNOME Desktop Manager isn't installed\n - Recommendation is Not Applicable\n- Audit result:\n *** PASS ***\n"
 echo "GDM: NOT INSTALLED" >> $RESULT_FILE
 
 fi

