#!/usr/bin/bash


LOG_FILE="/var/log/hardening_fix.log"
RESULT_FILE="/var/tmp/scan_results.txt"


# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $LOG_FILE
}


#fix_autofs
fix_autofs() {
if grep -q "autofs(SPECIAL PURPOSE SERVICE):INSTALLED" $RESULT_FILE; then
	read -p "Is autofs required as a dependency? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		systemctl stop autofs.service
		systemctl mask autofs.service
		
	else 
	read -p "Do you want to remove autofs package? (y/n)" answer
		systemctl stop autofs.service
		dnf remove autofs
		
	fi 
	fi
fi
}

#fix avahi deamon services
fix_avahi() {
if grep -q "avahi(SPECIAL PURPOSE SERVICE):INSTALLED" $RESULT_FILE; then
	read -p "Is avahi required as a dependency? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		systemctl stop avahi-daemon.socket avahi-daemon.service
		systemctl mask avahi-daemon.socket avahi-daemon.service
	
	else 
	read -p "Do you want to remove autofs package? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		systemctl stop avahi-daemon.socket avahi-daemon.service
		dnf remove avahi
		fi 
		fi
fi

}

#fix dhcp server services
fix_dhcp_services() {
if grep -q "dhcp-server(SPECIAL PURPOSE SERVICE):INSTALLED" $RESULT_FILE; then
	read -p "Is dhcp-server required as a dependency? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		systemctl stop dhcpd.service dhcpd6.service
		systemctl mask dhcpd.service dhcpd6.service
	
	else 
	read -p "Do you want to remove dhcp-server package? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		systemctl stop dhcpd.service dhcpd6.service
		dnf remove dhcp-server
		fi 
		fi
fi
}

#fix dns server services
fix_bind() {
if grep -q "bind(SPECIAL PURPOSE SERVICE):INSTALLED" $RESULT_FILE; then
	read -p "Is dns server services required as a dependency? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		systemctl stop named.service
		systemctl mask named.service
		
	else 
	read -p "Do you want to remove dhcp-server package? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		systemctl stop named.service
		dnf remove bind
		fi 
		fi
fi
}

#dnsmasq
fix_dnsmasq() {
if grep -q "dnsmasq(SPECIAL PURPOSE SERVICE):INSTALLED" $RESULT_FILE; then
	read -p "Is dns server services required as a dependency? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		systemctl stop dnsmasq.service
		systemctl mask dnsmasq.service
		
	else 
	read -p "Do you want to remove dns server package? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		systemctl stop dnsmasq.service
		dnf remove dnsmasq
		
			fi 
			fi
fi

}

#samba
fix_samba() {
if grep -q "samba(SPECIAL PURPOSE SERVICE):INSTALLED" $RESULT_FILE; then
	read -p "Is samba file server services required as a dependency? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		systemctl stop smb.service
		systemctl mask smb.service
		
	else 
	read -p "Do you want to remove samba file server package? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		systemctl stop dnsmasq.service
		dnf remove dnsmasq
	fi 
	fi
fi
}

#ftp server services
fix_ftp_server_services() {
if grep -q "vsftpd(SPECIAL PURPOSE SERVICE):INSTALLED" $RESULT_FILE; then
	read -p "Is vsftpd services required as a dependency? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		systemctl stop vsftpd.service
		systemctl mask vsftpd.service
		
	else 
	read -p "Do you want to remove vsftpd services package? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		systemctl stop vsftpd.service
		dnf remove vsftpd
	fi 
	fi
fi
}

#fix message access server services
fix_message_access_server_services() {
if grep -q "dovecot cyrus-imapd(SPECIAL PURPOSE SERVICE):INSTALLED" $RESULT_FILE; then
	read -p "Is dovecot required as a dependency? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		systemctl stop vsftpd.service
		systemctl mask vsftpd.service
		
	else 
	read -p "Do you want to remove samba file server package? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		systemctl stop vsftpd.service
		dnf remove vsftpd
	fi 
	fi
fi

}

#fix nfs utills
fix_nfs_utills() {
if grep -q "nfs-utils(SPECIAL PURPOSE SERVICE):INSTALLED" $RESULT_FILE; then
	read -p "Is nfs-utils required as a dependency? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		systemctl stop nfs-server.service
		systemctl mask nfs-server.service
		
	else 
	read -p "Do you want to remove nfs-utils package? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		systemctl stop nfs-server.service
		dnf remove nfs-utils
	fi 
	fi
fi

}


#fix nis server services
fix_nis_services() {
if grep -q "ypserv(SPECIAL PURPOSE SERVICE):INSTALLED" $RESULT_FILE; then
	read -p "Is ypserv required as a dependency? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		systemctl stop ypserv.service
		systemctl mask ypserv.service
		
	else 
	read -p "Do you want to remove ypserv package? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		systemctl stop ypserv.service
		dnf remove ypserv
	fi 
	fi
fi


}

#fix print server services
fix_print_server_services_cups() {
if grep -q "cups(SPECIAL PURPOSE SERVICE):INSTALLED" $RESULT_FILE; then
	read -p "Is cups required as a dependency? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		systemctl stop cups.socket cups.service
		systemctl mask cups.socket cups.service
		
	else 
	read -p "Do you want to remove cups package? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		systemctl stop cups.socket cups.service
		dnf remove cups
	fi 
	fi
fi



}


#fix rpcbind services
fix_print_server_services_rpcbind() {
if grep -q "rpcbind(SPECIAL PURPOSE SERVICE):INSTALLED" $RESULT_FILE; then
	read -p "Is rpcbind required as a dependency? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		systemctl stop rpcbind.socket rpcbind.service
		systemctl mask rpcbind.socket rpcbind.service
		
	else 
	read -p "Do you want to remove rpcbind package? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		systemctl stop rpcbind.socket rpcbind.service
		dnf remove rpcbind
	fi 
	fi
fi

}

#fix rsync-daemon
fix_rsync_services() {
if grep -q "rsync-daemon(SPECIAL PURPOSE SERVICE):INSTALLED" $RESULT_FILE; then
	read -p "Is rsync-daemon required as a dependency? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		systemctl stop rsyncd.socket rsyncd.service
		systemctl mask rsyncd.socket rsyncd.service
		
	else 
	read -p "Do you want to remove rsync-daemon package? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		systemctl stop rsyncd.socket rsyncd.service
		dnf remove rsync-daemon
	fi 
	fi
fi
}

#fix snmp services
fix_snmp_services() {
if grep -q "net-snmp(SPECIAL PURPOSE SERVICE):INSTALLED" $RESULT_FILE; then
	read -p "Is net-snmp required as a dependency? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		systemctl stop snmpd.service
		systemctl mask snmpd.service
		
	else 
	read -p "Do you want to remove net-snmp package? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		systemctl stop snmpd.service
		dnf remove net-snmp
	fi 
	fi
fi
}

#fix telnet server
fix_telnet_services() {
if grep -q "telnet-server(SPECIAL PURPOSE SERVICE):INSTALLED" $RESULT_FILE; then
	read -p "Is telnet-server required as a dependency? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		systemctl stop telnet.socket
		systemctl mask telnet.socket
		
	else 
	read -p "Do you want to remove telnet-server package? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		systemctl stop telnet.socket
		dnf remove telnet-server
	fi 
	fi
fi

}

#fix tftp services
fix_tftp_services() {
if grep -q "tftp-server(SPECIAL PURPOSE SERVICE):INSTALLED" $RESULT_FILE; then
	read -p "Is tftp-server required as a dependency? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		systemctl stop tftp.socket tftp.service
		systemctl mask tftp.socket tftp.service
		
	else 
	read -p "Do you want to remove telnet-server package? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		systemctl stop tftp.socket tftp.service
		dnf remove tftp-server

	fi 
	fi
fi

}

#fix squid
fix_squid() {
if grep -q "squid(SPECIAL PURPOSE SERVICE):INSTALLED" $RESULT_FILE; then
	read -p "Is squid required as a dependency? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		systemctl stop squid.service
		systemctl mask tftp.socket tftp.service
		
	else 
	read -p "Do you want to remove squid package? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		systemctl stop tftp.socket tftp.service
		dnf remove tftp-server

	fi 
	fi
fi

}

#fix nginx
fix_nginx() {
if grep -q "httpd nginx(SPECIAL PURPOSE SERVICE):INSTALLED" $RESULT_FILE; then
	read -p "Is httpd nginx required as a dependency? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		systemctl stop httpd.socket httpd.service nginx.service
		systemctl mask httpd.socket httpd.service nginx.service

		
	else 
	read -p "Do you want to remove httpd nginx package? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		systemctl stop httpd.socket httpd.service nginx.service
		dnf remove httpd nginx

	fi 
	fi
fi

}

#fix xinetd
fix_xinetd() {
if grep -q "xinetd(SPECIAL PURPOSE SERVICE):INSTALLED" $RESULT_FILE; then
	read -p "Is xinetd required as a dependency? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		systemctl stop xinetd.service
		systemctl mask xinetd.service
	
	else 
	read -p "Do you want to remove httpd nginx package? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		systemctl stop xinetd.service
		dnf remove xinetd
	fi 
	fi
fi

}

#fix xorg
fix_xorg_x11_server_common() {
if grep -q "xorg_x11_server_common(SPECIAL PURPOSE SERVICE):INSTALLED" $RESULT_FILE; then
	read -p "Do you want to remove xorg_x11_server_common? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		dnf remove xorg-x11-server-common
	fi
fi

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

#fix bluez
fix_bluez() {
if grep -q ""BLUEZ:INSTALLED"" $RESULT_FILE; then
	read -p "Is bluez required as a dependency? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		systemctl stop bluetooth.service
		systemctl mask bluetooth.service
	
	else 
	read -p "Do you want to remove bluez package? (y/n)" answer
	if [[ answer = [Yy] ]]; then
		systemctl stop bluetooth.service
		dnf remove bluez
		fi 
		fi
fi

}


fix_chrony
fix_chrony_run_as_root_user
fix_bind
fix_autofs
fix_avahi
fix_dhcp_services
fix_dnsmasq
fix_samba
fix_ftp_server_services
fix_message_access_server_services
fix_nfs_utills
fix_nis_services
fix_print_server_services_cups
fix_print_server_services_rpcbind`
fix_rsync_services
fix_snmp_services
fix_telnet_services
fix_tftp_services
fix_squid
fix_nginx
fix_xinetd
fix_xorg_x11_server_common
fix_ftp
fix_ldap
fix_nis
fix_telnet
fix_tftp
fix_bluez

