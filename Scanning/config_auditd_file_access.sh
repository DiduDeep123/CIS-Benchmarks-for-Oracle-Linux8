#!/usr/bin/bash

LOG_FILE="/var/log/hardening_scan.log"
RESULT_FILE="/var/tmp/scan_results.txt"

# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $LOG_FILE	  #output to both screen and log file
}

check_audit_log_files_groups() {
	log_message "Checking if only authorized groups are assigned ownership of audit log files..."
	
	log_group_param=$(grep -Piw -- '^\h*log_group\h*=\h*(adm|root)\b' /etc/audit/auditd.conf | awk-F'=' '{print $2}' | xargs)
	
	if [[ "$log_group_param" = "adm" || "$log_group_param" = "root" ]]; then
		log_message "Only authorized groups are assigned ownership of audit log files."
		echo "AUDIT LOG FILE OWNERSHIP:AUTHORIZED" >> $RESULT_FILE
		 
	else
		log_message "Unauthorized groups are assigned ownership of audit log files."
		echo "AUDIT LOG FILE OWNERSHIP:UNAUTHORIZED" >> $RESULT_FILE
	fi
}


# Function to check if audit configuration files have mode 640 or more restrictive
check_audit_file_permissions() {
    log_message "Checking if audit configuration files have mode 640 or more restrictive and are owned by root..."

    find /etc/audit/ -type f \( -name '*.conf' -o -name '*.rules' \) -exec stat -Lc "%n %a %U %G" {} + | while read -r file perm owner group; do
        # Check ownership
        if [[ "$owner" != "root" || "$group" != "root" ]]; then
            log_message "File $file is not owned by root:root."
            echo "AUDIT FILE OWNERSHIP:UNAUTHORIZED" >> "$RESULT_FILE"
            continue
        fi
        
        # Check permissions
        if [[ "$perm" -lt 640 ]]; then
            log_message "File $file has permissions $perm which are less restrictive than 640."
            echo "AUDIT FILE PERMISSIONS:NOT RESTRICTIVE" >> "$RESULT_FILE"
        fi
    done

    # If no unauthorized files are found, write success to result file
    if [[ ! -s "$RESULT_FILE" ]]; then
        log_message "All audit configuration files have mode 640 or more restrictive and are owned by root:root."
        echo "AUDIT FILE OWNERSHIP AND PERMISSIONS:AUTHORIZED" >> "$RESULT_FILE"
    fi
}

# Function to check permissions and ownership of audit tools
check_audit_tool_permissions() {


    log_message "Checking if audit tools have mode 755 or more restrictive and are owned by root..."

    # Files to check
    files=(
        "/sbin/auditctl"
        "/sbin/aureport"
        "/sbin/ausearch"
        "/sbin/autrace"
        "/sbin/auditd"
        "/sbin/augenrules"
    )

    # Loop through each file
    for file in "${files[@]}"; do
        if [ -e "$file" ]; then
            # Get file permissions and ownership
            file_info=$(stat -c "%n %a %U %G" "$file")
            file_name=$(echo "$file_info" | awk '{print $1}')
            file_perm=$(echo "$file_info" | awk '{print $2}')
            file_owner=$(echo "$file_info" | awk '{print $3}')
            file_group=$(echo "$file_info" | awk '{print $4}')

            # Check ownership
            if [[ "$file_owner" != "root" || "$file_group" != "root" ]]; then
                log_message "File $file_name is not owned by root."
                echo "TOOL OWNERSHIP:UNAUTHORIZED" >> "$RESULT_FILE"
                continue
            fi

            # Check permissions
            if ! echo "$file_perm" | grep -Pq '^7[5][5]$|^[0-7][0-5][0-5]$'; then
                log_message "File $file_name has permissions $file_perm which are not 755 or more restrictive."
                echo "TOOL PERMISSIONS:NOT RESTRICTIVE" >> "$RESULT_FILE"
            fi
        else
            log_message "File $file does not exist."
            echo "TOOL FILE:NOT FOUND" >> "$RESULT_FILE"
        fi
    done

    # If there are no issues, write success to result file
    if [[ ! -s "$result_file" ]]; then
        log_message "All audit tools have mode 755 or more restrictive and are owned by root:root."
        echo "TOOL OWNERSHIP AND PERMISSIONS:AUTHORIZED" >> "$RESULT_FILE"
    fi
}




check_audit_log_files_groups
check_audit_file_permissions
check_audit_tool_permissions
