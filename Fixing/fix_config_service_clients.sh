#!/usr/bin/bash


LOG_FILE="/var/log/hardening_fix.log"
RESULT_FILE="/var/tmp/scan_results.txt"


# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $LOG_FILE
}



#fix ftp
fix_ftp(){
if grep -q "ftp:INSTALLED" $RESULT_FILE; then
	read -p "Do you want to remove ftp? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		dnf remove ftp

	fi
fi

}

#fix ldap
fix_ldap(){
if grep -q "openldap-clients:INSTALLED" $RESULT_FILE; then
	read -p "Do you want to remove ldap? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		dnf remove openldap-clients

	fi
fi

}

#fix nis
fix_nis() {
if grep -q "openldap-clients:INSTALLED" $RESULT_FILE; then
	read -p "Do you want to remove ldap? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		dnf remove openldap-clients

	fi
fi
}

#fix telnet
fix_telnet() {
if grep -q "telnet:INSTALLED" $RESULT_FILE; then
	read -p "Do you want to remove telnet? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		dnf remove telnet

	fi
fi
}

#fix tftp
fix_tftp() {
if grep -q "tftp:INSTALLED" $RESULT_FILE; then
	read -p "Do you want to remove tftp? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		dnf remove tftp

	fi
fi

}


fix_ftp
fix_ldap
fix_nis
fix_telnet
fix_tftp
