#!/usr/bin/bash


LOG_FILE="/var/log/hardening_fix.log"
RESULT_FILE="/var/tmp/scan_results.txt"


# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $LOG_FILE
}

#User opted not to apply remediation function
select_no() {
	log_message "User opted not to apply remediation."
	echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $NEW_LOG_FILE
}


# Fix ipv6 status
fix_ipv6_status() {
    if grep -q "IPv6 status:IPv6 is disabled" $RESULT_FILE; then
	read -p "Do you want to enable IPv6? (y/n)" answer
	if [[ "$answer" = [Yy] ]]; then
		if grep -q "net.ipv6.conf.all.disable_ipv6" "$SYSCTL_CONF"; then
        sudo sed -i 's/net.ipv6.conf.all.disable_ipv6=.*/net.ipv6.conf.all.disable_ipv6=0/' "$SYSCTL_CONF"
    else
        echo "net.ipv6.conf.all.disable_ipv6=0" | sudo tee -a "$SYSCTL_CONF"
    fi

    if grep -q "net.ipv6.conf.default.disable_ipv6" "$SYSCTL_CONF"; then
        sudo sed -i 's/net.ipv6.conf.default.disable_ipv6=.*/net.ipv6.conf.default.disable_ipv6=0/' "$SYSCTL_CONF"
    else
        echo "net.ipv6.conf.default.disable_ipv6=0" | sudo tee -a "$SYSCTL_CONF"
    fi

    if grep -q "net.ipv6.conf.lo.disable_ipv6" "$SYSCTL_CONF"; then
        sudo sed -i 's/net.ipv6.conf.lo.disable_ipv6=.*/net.ipv6.conf.lo.disable_ipv6=0/' "$SYSCTL_CONF"
    else
        echo "net.ipv6.conf.lo.disable_ipv6=0" | sudo tee -a "$SYSCTL_CONF"
    fi

    
    sudo sysctl -p

    echo "IPv6 has been enabled permanently."

else
select_no "User opted not to enable IPv6"

    fi
    
    fi

        if grep -q "IPv6 status:IPv6 is enabled" $RESULT_FILE; then
	read -p "Do you want to disable IPv6? (y/n)" answer
	if [[ "$answer" = [Yy] ]]; then
		if grep -q "net.ipv6.conf.all.disable_ipv6" "$SYSCTL_CONF"; then
        sudo sed -i 's/net.ipv6.conf.all.disable_ipv6=.*/net.ipv6.conf.all.disable_ipv6=1/' "$SYSCTL_CONF"
    else
        echo "net.ipv6.conf.all.disable_ipv6=1" | sudo tee -a "$SYSCTL_CONF"
    fi

    if grep -q "net.ipv6.conf.default.disable_ipv6" "$SYSCTL_CONF"; then
        sudo sed -i 's/net.ipv6.conf.default.disable_ipv6=.*/net.ipv6.conf.default.disable_ipv6=1/' "$SYSCTL_CONF"
    else
        echo "net.ipv6.conf.default.disable_ipv6=1" | sudo tee -a "$SYSCTL_CONF"
    fi

    if grep -q "net.ipv6.conf.lo.disable_ipv6" "$SYSCTL_CONF"; then
        sudo sed -i 's/net.ipv6.conf.lo.disable_ipv6=.*/net.ipv6.conf.lo.disable_ipv6=1/' "$SYSCTL_CONF"
    else
        echo "net.ipv6.conf.lo.disable_ipv6=1" | sudo tee -a "$SYSCTL_CONF"
    fi

    
    sudo sysctl -p

    echo "IPv6 has been disabled permanently.".

else
select_no "User opted not to disable IPv6"

    fi
    
    fi
}

fix_ipv6_status
