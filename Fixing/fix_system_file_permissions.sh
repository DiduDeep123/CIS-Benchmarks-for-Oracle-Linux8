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

#Function to fix /etc/passwd permissions
fix_etc_passwd_permissions() {
log_message "Fixing /etc/passwd permissions... "
if grep -q "/etc/passwd permissions:INCORRECT" $RESULT_FILE; then
	read -p "Do you want to change /etc/passwd permissions? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		chmod u-x,go-wx /etc/passwd
		chown root:root /etc/passwd
		log_message "/etc/passwd permissions fixed. "
		
	fi
fi


}

#Function to fix /etc/passwd- permissions
fix_etc_passwd__permissions() {
log_message "Fixing /etc/passwd- permissions... "
if grep -q "/etc/passwd- permissions:INCORRECT" $RESULT_FILE; then
	read -p "Do you want to change /etc/passwd- permissions? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		chmod u-x,go-wx /etc/passwd-
		chown root:root /etc/passwd-
		log_message "/etc/passwd- permissions fixed. "
	fi
fi


}

#Function to fix /etc/group permissions
fix_etc_group_permissions() {
log_message "Fixing /etc/group permissions... "
if grep -q "/etc/group permissions:INCORRECT" $RESULT_FILE; then
	read -p "Do you want to change /etc/group permissions? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		chmod u-x,go-wx /etc/group
		chown root:root /etc/group
		log_message "/etc/group permissions fixed. "
		
	fi
fi

}

#Function to fix /etc/group- permissions
fix_etc_group__permissions() {
log_message "Fixing /etc/group- permissions... "
if grep -q "/etc/group- permissions:INCORRECT" $RESULT_FILE; then
	read -p "Do you want to change /etc/group- permissions? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		chmod u-x,go-wx /etc/group-
		chown root:root /etc/group-
		log_message "/etc/group- permissions fixed. "
		
	fi
fi

}

fix_etc_shadow_permissions() {
log_message "Fixing /etc/shadow permissions... "
if grep -q "/etc/shadow permissions:INCORRECT" $RESULT_FILE; then
	read -p "Do you want to change /etc/shadow permissions? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		chown root:root /etc/shadow
		chmod 0000 /etc/shadow
		log_message "/etc/shadow permissions fixed. "
	fi
fi

}


fix_etc_shadow__permissions() {
log_message "Fixing /etc/shadow- permissions... "
if grep -q "/etc/shadow- permissions:INCORRECT" $RESULT_FILE; then
	read -p "Do you want to change /etc/shadow- permissions? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		chown root:root /etc/shadow-
		chmod 0000 /etc/shadow-
		log_message "/etc/shadow- permissions fixed. "
		
	fi
fi

}

fix_etc_gshadow_permissions() {
log_message "Fixing /etc/gshadow permissions... "
if grep -q "/etc/gshadow permissions:INCORRECT" $RESULT_FILE; then
	read -p "Do you want to change /etc/gshadow permissions? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		chown root:root /etc/gshadow
		chmod 0000 /etc/gshadow
		log_message "/etc/gshadow permissions fixed. "
		
	fi
fi
}

fix_etc_gshadow__permissions() {
log_message "Fixing /etc/gshadow- permissions... "
if grep -q "/etc/gshadow- permissions:INCORRECT" $RESULT_FILE; then
	read -p "Do you want to change /etc/gshadow- permissions? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		chown root:root /etc/gshadow-
		chmod 0000 /etc/gshadow-
		log_message "/etc/gshadow- permissions fixed. "
		
	fi
fi
}

fix_etc_shells_permissions() {
log_message "Fixing /etc/shells permissions... "
if grep -q "/etc/shells permissions:INCORRECT" $RESULT_FILE; then
	read -p "Do you want to change /etc/shells permissions? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		chmod u-x,go-wx /etc/shells
		chown root:root /etc/shells
		log_message "/etc/shells permissions fixed. "
		
	fi
fi

}


fix_etc_passwd_permissions
fix_etc_passwd__permissions
fix_etc_group_permissions
fix_etc_group__permissions
fix_etc_shadow_permissions
fix_etc_shadow__permissions
fix_etc_gshadow_permissions
fix_etc_gshadow__permissions
fix_etc_shells_permissions
