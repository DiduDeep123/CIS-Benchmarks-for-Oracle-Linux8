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

if grep -q "GDM DISABLE USER LIST: NOT ENABLED" "$RESULT_FILE" && grep -q "GDM:INSTALLED" "$RESULT_FILE"; then
	read -p "Do you want to enable GDM disable user list option? (y/n)" answer
	if [[ answer = [Yy] ]]; then

 l_gdmprofile="gdm"
 if [ ! -f "/etc/dconf/profile/$l_gdmprofile" ]; then
 echo "Creating profile \"$l_gdmprofile\""
 echo -e "user-db:user\nsystem-db:$l_gdmprofile\nfiledb:/usr/share/$l_gdmprofile/greeter-dconf-defaults" > /etc/dconf/profile/$l_gdmprofile
 fi
 if [ ! -d "/etc/dconf/db/$l_gdmprofile.d/" ]; then
 echo "Creating dconf database directory 
\"/etc/dconf/db/$l_gdmprofile.d/\""
 mkdir /etc/dconf/db/$l_gdmprofile.d/
 fi
 if ! grep -Piq '^\h*disable-user-list\h*=\h*true\b' /etc/dconf/db/$l_gdmprofile.d/*; then
 echo "creating gdm keyfile for machine-wide settings"
 if ! grep -Piq -- '^\h*\[org\/gnome\/login-screen\]' /etc/dconf/db/$l_gdmprofile.d/*; then
 echo -e "\n[org/gnome/login-screen]\n# Do not show the user list\ndisable-user-list=true" >> /etc/dconf/db/$l_gdmprofile.d/00-loginscreen
 else
 sed -ri '/^\s*\[org\/gnome\/login-screen\]/ a\# Do not show the user list\ndisable-user-list=true' $(grep -Pil -- '^\h*\[org\/gnome\/loginscreen\]' /etc/dconf/db/$l_gdmprofile.d/*)
 fi
 fi
 dconf update
 echo "GDM banner message is enabled and set"
 else
 select_no "GDM banner message:REQUIRES CHANGE"
 fi
 echo -e "\n\n - GNOME Desktop Manager isn't installed\n - Recommendation is Not Applicable\n - No remediation required\n"
 fi

