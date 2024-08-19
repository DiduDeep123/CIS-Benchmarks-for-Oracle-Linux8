#!/usr/bin/bash

LOG_FILE="/var/log/hardening_scan.log"
RESULT_FILE="/var/tmp/scan_results.txt"
ETC_PASSWD="/etc/passwd"
ETC_PASSWD_="/etc/passwd-"
ETC_GROUP="/etc/group"
ETC_GROUP_="/etc/group-"
ETC_SHADOW="/etc/shadow"
ETC_SHADOW_="/etc/shadow-"
ETC_GSHADOW="/etc/gshadow"
ETC_GSHADOW_="/etc/gshadow-"
ETC_SHELLS="/etc/shells"

log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $LOG_FILE
}

check_etc_passwd_permissions() {
	#check current permissions,current user and group
	current_access_permissions=$(stat -Lc '%a' $ETC_PASSWD)
	current_user=$(stat -Lc '%U' $ETC_PASSWD)
	current_group=$(stat -Lc '%G' $ETC_PASSWD)
	
	#desired permissions,user and group
	desired_access_permissions="644"
	desired_user="root"
	desired_group="root"
	
	log_message "Checking /etc/passwd permissions..."
	
	if [[ "$current_access_permissions" -le "$desired_access_permissions" && "$current_user" == "$desired_user" && "$current_group" == "$desired_group" ]]; then
		log_message "/etc/passwd permissions are already configured."
		echo "/etc/passwd permissions:CORRECT" >> $RESULT_FILE
        
	else
		log_message "/etc/passwd permissions are not properly configured."
		echo "/etc/passwd permissions:INCORRECT" >> $RESULT_FILE
		
	fi
}


check_etc_passwd__permissions() {
	#check current permissions,current user and group
	current_access_permissions=$(stat -Lc '%a' $ETC_PASSWD_)
	current_user=$(stat -Lc '%U' $ETC_PASSWD_)
	current_group=$(stat -Lc '%G' $ETC_PASSWD_)
	
	#desired permissions,user and group
	desired_access_permissions="644"
	desired_user="root"
	desired_group="root"
	
	log_message "Checking /etc/passwd- permissions..."
	
	if [[ "$current_access_permissions" -le "$desired_access_permissions" && "$current_user" == "$desired_user" && "$current_group" == "$desired_group" ]]; then
		log_message "/etc/passwd- permissions are already configured."
		echo "/etc/passwd- permissions:CORRECT" >> $RESULT_FILE
	else
		log_message "/etc/passwd- permissions are not properly configured."
		echo "/etc/passwd- permissions:INCORRECT" >> $RESULT_FILE
		
		fi
		
	fi
}

check_etc_group_permissions() {
	#check current permissions,current user and group
	current_access_permissions=$(stat -Lc '%a' $ETC_GROUP)
	current_user=$(stat -Lc '%U' $ETC_GROUP)
	current_group=$(stat -Lc '%G' $ETC_GROUP)
	
	#desired permissions,user and group
	desired_access_permissions="644"
	desired_user="root"
	desired_group="root"
	
	log_message "Checking /etc/group permissions..."
	
	if [[ "$current_access_permissions" -le "$desired_access_permissions" && "$current_user" == "$desired_user" && "$current_group" == "$desired_group" ]]; then
		log_message "/etc/group permissions are already configured."
		echo "/etc/group permissions:CORRECT" >> $RESULT_FILE
	else
		log_message "/etc/group permissions are not properly configured."
		echo "/etc/group permissions:INCORRECT" >> $RESULT_FILE
		
		fi
		
	fi
}

check_etc_group__permissions() {
	#check current permissions,current user and group
	current_access_permissions=$(stat -Lc '%a' $ETC_GROUP_)
	current_user=$(stat -Lc '%U' $ETC_GROUP_)
	current_group=$(stat -Lc '%G' $ETC_GROUP_)
	
	#desired permissions,user and group
	desired_access_permissions="644/-rw-r--r--"
	desired_user="0/root"
	desired_group="0/root"
	
	log_message "Checking /etc/group- permissions..."
	
	if [[ "$current_access_permissions" -le "$desired_access_permissions" && "$current_user" == "$desired_user" && "$current_group" == "$desired_group" ]]; then
		log_message "/etc/group- permissions are already configured."
		echo "/etc/group- permissions:CORRECT" >> $RESULT_FILE
	else
		log_message "/etc/group- permissions are not properly configured."
		echo "/etc/group- permissions:INCORRECT" >> $RESULT_FILE
		
		fi
		
	fi
}



check_etc_shadow_permissions() {
	#check current permissions,current user and group
	current_access_permissions=$(stat -Lc '%a' $ETC_SHADOW)
	current_user=$(stat -Lc '%U' $ETC_SHADOW)
	current_group=$(stat -Lc '%G' $ETC_SHADOW)
	
	#desired permissions,user and group
	desired_access_permissions="0"
	desired_user="root"
	desired_group="root"
	
	log_message "Checking /etc/shadow permissions..."
	
if [[ "$current_access_permissions" -le "$desired_access_permissions" && "$current_user" == "$desired_user" && "$current_group" == "$desired_group" ]]; then
		log_message "/etc/shadow permissions are already configured."
		echo "/etc/shadow permissions:CORRECT" >> $RESULT_FILE
	else
		log_message "/etc/shadow permissions are not properly configured."
		echo "/etc/shadow permissions:INCORRECT" >> $RESULT_FILE
		
		fi
		
	fi
}

check_etc_shadow__permissions() {
	#check current permissions,current user and group
	current_access_permissions=$(stat -Lc '%a' $ETC_SHADOW_)
	current_user=$(stat -Lc '%U' $ETC_SHADOW_)
	current_group=$(stat -Lc '%G' $ETC_SHADOW_)
	
	#desired permissions,user and group
	desired_access_permissions="0"
	desired_user="root"
	desired_group="root"
	
	log_message "Checking /etc/shadow- permissions..."
	
	if [[ "$current_access_permissions" -le "$desired_access_permissions" && "$current_user" == "$desired_user" && "$current_group" == "$desired_group" ]]; then
		log_message "/etc/shadow- permissions are already configured."
		echo "/etc/shadow- permissions:CORRECT" >> $RESULT_FILE
	else
		log_message "/etc/shadow- permissions are not properly configured."
		echo "/etc/shadow- permissions:INCORRECT" >> $RESULT_FILE
		
		fi
		
	fi
}

check_etc_gshadow_permissions() {
	#check current permissions,current user and group
	current_access_permissions=$(stat -Lc '%a' $ETC_GSHADOW)
	current_user=$(stat -Lc '%U' $ETC_GSHADOW)
	current_group=$(stat -Lc '%G' $ETC_GSHADOW)
	
	#desired permissions,user and group
	desired_access_permissions="0"
	desired_user="root"
	desired_group="root"
	
	log_message "Checking /etc/gshadow permissions..."
	
	if [[ "$current_access_permissions" -le "$desired_access_permissions" && "$current_user" == "$desired_user" && "$current_group" == "$desired_group" ]]; then
		log_message "/etc/gshadow permissions are already configured."
		echo "/etc/gshadow permissions:CORRECT" >> $RESULT_FILE
	else
		log_message "/etc/gshadow permissions are not properly configured."
		echo "/etc/gshadow permissions:INCORRECT" >> $RESULT_FILE
		
		fi
		
	fi
}

check_etc_gshadow__permissions() {
	#check current permissions,current user and group
	current_access_permissions=$(stat -Lc '%a' $ETC_GSHADOW_)
	current_user=$(stat -Lc '%U' $ETC_GSHADOW_)
	current_group=$(stat -Lc '%G' $ETC_GSHADOW_)
	
	#desired permissions,user and group
	desired_access_permissions="0"
	desired_user="root"
	desired_group="root"
	
	log_message "Checking /etc/gshadow- permissions..."
	
	if [[ "$current_access_permissions" -le "$desired_access_permissions" && "$current_user" == "$desired_user" && "$current_group" == "$desired_group" ]]; then
		log_message "/etc/gshadow- permissions are already configured."
		echo "/etc/gshadow- permissions:CORRECT" >> $RESULT_FILE
	else
		log_message "/etc/gshadow- permissions are not properly configured."
		echo "/etc/gshadow- permissions:INCORRECT" >> $RESULT_FILE
		
		fi
		
	fi
}

check_etc_shells_permissions() {
	#check current permissions,current user and group
	current_access_permissions=$(stat -Lc '%a' $ETC_SHELLS)
	current_user=$(stat -Lc '%U' $ETC_SHELLS)
	current_group=$(stat -Lc '%G' $ETC_SHELLS)
	
	#desired permissions,user and group
	desired_access_permissions="0"
	desired_user="root"
	desired_group="root"
	
	log_message "Checking /etc/shells permissions..."
	
	if [[ "$current_access_permissions" -le "$desired_access_permissions" && "$current_user" == "$desired_user" && "$current_group" == "$desired_group" ]]; then
		log_message "/etc/shells permissions are already configured."
		echo "/etc/shells permissions:CORRECT" >> $RESULT_FILE
	else
		log_message "/etc/shells permissions are not properly configured."
		echo "/etc/shells permissions:INCORRECT" >> $RESULT_FILE
		
		fi
		
	fi
}

check_etc_passwd_permissions
check_etc_passwd__permissions
check_etc_group_permissions
check_etc_group__permissions
check_etc_shadow_permissions
check_etc_shadow__permissions
check_etc_gshadow_permissions
check_etc_gshadow__permissions
check_etc_shells_permissions
