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

install_pam() {
 
 if grep -q "PAM:NOT INSTALLED" $RESULT_FILE; then
	read -p "Do you want to install PAM? (y/n)" answer
	if [[ answer = [Yy] ]]; then
   dnf install pam
   else
    select_no "PAM:NOT INSTALLED:REQUIRES CHANGE"
		
	fi

 fi
}

# Function to check and update PAM if necessary
update_pam() {
    if grep -q "PAM:VERSION NEEDS UPGRADE" $RESULT_FILE; then
	read -p "Do you want to update PAM? (y/n)" answer
	if [[ answer = [Yy] ]]; then
   log_message "Updating PAM..."
    dnf upgrade pam 
    log_message "PAM updated..."
 else
    select_no "PAM:VERSION NEEDS UPGRADE:REQUIRES CHANGE"
		
	fi

 fi
   
}

install_authselect() {
 
 if grep -q "AUTHSELECT:NOT INSTALLED" $RESULT_FILE; then
	read -p "Do you want to install AUTHSELECT? (y/n)" answer
	if [[ answer = [Yy] ]]; then
    dnf install authselect
   else
    select_no "AUTHSELECT:NOT INSTALLED:REQUIRES CHANGE"
		
	fi

 fi
}

# Function to check and update PAM if necessary
update_authselect() {
    if grep -q "AUTHSELECT:VERSION NEEDS UPGRADE" $RESULT_FILE; then
	read -p "Do you want to update AUTHSELECT? (y/n)" answer
	if [[ answer = [Yy] ]]; then
   log_message "Updating AUTHSELECT..."
    dnf upgrade pam 
    log_message "AUTHSELECT upgraded..."
 else
    select_no "AUTHSELECT:VERSION NEEDS UPGRADE:REQUIRES CHANGE"
		
	fi

 fi
   
}

install_pam
update_pam
install_authselect
update_authselect
