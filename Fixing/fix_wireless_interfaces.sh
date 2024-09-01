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


 module_fix()
 {
 if ! modprobe -n -v "$l_mname" | grep -P -- '^\h*install \/bin\/(true|false)'; then
 echo -e " - setting module: \"$l_mname\" to be un-loadable"
 echo -e "install $l_mname /bin/false" >> /etc/modprobe.d/"$l_mname".conf
 fi
 if lsmod | grep "$l_mname" > /dev/null 2>&1; then
 echo -e " - unloading module \"$l_mname\""
 modprobe -r "$l_mname"
 fi
 if ! grep -Pq -- "^\h*blacklist\h+$l_mname\b" /etc/modprobe.d/*; then
 echo -e " - deny listing \"$l_mname\""
 echo -e "blacklist $l_mname" >> /etc/modprobe.d/"$l_mname".conf
 fi
 }
if grep -q "WIRELESS INTERFACES: NOT DISABLED" "$RESULT_FILE"; then
	read -p "Do you want to disable wireless interfaces? (y/n)" answer
	if [[ answer = [Yy] ]]; then

 if [ -n "$(find /sys/class/net/*/ -type d -name wireless)" ]; then
 l_dname=$(for driverdir in $(find /sys/class/net/*/ -type d -name wireless | xargs -0 dirname); do basename "$(readlink -f "$driverdir"/device/driver/module)";done | sort -u)
 for l_mname in $l_dname; do
 module_fix
 done
 fi
else
select_no "WIRELESS INTERFACES NOT DISABLED: REQUIRES CHANGE"
fi
fi

