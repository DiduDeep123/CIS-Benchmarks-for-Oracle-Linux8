#!/usr/bin/bash

LOG_FILE="/var/log/hardening_scan.log"
RESULT_FILE="/var/tmp/scan_results.txt"


# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $LOG_FILE	  #output to both screen and log file
}


check_config_special_purpose_services() {
    packages=("autofs" "avahi" "dhcp-server" "bind" "dnsmasq" "samba" "vsftpd" "dovecot cyrus-imapd" "nfs-utils" "ypserv" "cups" "rpcbind" "rsync-daemon" "net-snmp" "telnet-server" "tftp-server" "squid" "httpd nginx" "xinetd")
    services=("autofs.service" "avahi-daemon.socket avahi-daemon.service" "dhcpd.service dhcpd6.service" "named.service" "dnsmasq.service" "smb.service" "vsftpd.service" "dovecot.socket dovecot.service cyrus-imapd.service" "nfs-server.service" "ypserv.service" "cups.socket cups.service" "rpcbind.socket rpcbind.service" "rsyncd.socket rsyncd.service" "snmpd.service" "telnet.socket" "tftp.socket tftp.service" "squid.service" "httpd.socket httpd.service nginx.service" "xinetd.service")
    
    for i in "${!packages[@]}"; do
        package="${packages[$i]}"
        service_list="${services[$i]}"

        if rpm -q "$package" > /dev/null 2>&1; then
            log_message "$package is installed."
			echo ""$package"(SPECIAL PURPOSE SERVICE):INSTALLED" >> "$RESULT_FILE"
			

            for service in $service_list; do
                if systemctl is-enabled "$service" | grep -q 'enabled'; then
                    log_message "$service is enabled."
					echo ""$service"(SPECIAL PURPOSE SERVICE):ENABLED" >> "$RESULT_FILE"
                           
                else
                    log_message "$service is not enabled."
					echo ""$service"(SPECIAL PURPOSE SERVICE):NOT ENABLED" >> "$RESULT_FILE"
                fi

                if systemctl is-active "$service" | grep -q '^active'; then
                    log_message "$service is active."
					echo ""$service"(SPECIAL PURPOSE SERVICE):ACTIVE" >> "$RESULT_FILE"
                   
                else
                    log_message "$service is not active."
					echo ""$service"(SPECIAL PURPOSE SERVICE):NOT ACTIVE" >> "$RESULT_FILE"
                fi
            done
        else
            log_message "$package is not installed."
			echo ""$package"(SPECIAL PURPOSE SERVICE):NOT INSTALLED" >> "$RESULT_FILE"
        fi
    done
}


check_config_special_purpose_services
