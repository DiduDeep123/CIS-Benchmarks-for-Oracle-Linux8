#!/usr/bin/bash

LOG_FILE="/var/log/hardening_scan.log"
RESULT_FILE="/var/tmp/scan_results.txt"

# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" | tee -a $LOG_FILE	  #output to both screen and log file
}

# Function to check if all passwords are shadowed
check_shadowed_passwords() {
  log_message "Checking if all user accounts have shadowed passwords..."

  # Run the awk command and capture the output
  non_shadowed_users=$(awk -F: '($2 != "x") { print $1 " is not set to shadowed passwords "}' /etc/passwd)

  # Check if any non-shadowed user accounts were found
  if [ -z "$non_shadowed_users" ]; then
    echo "PASSWORD SHADOWING CONFIG:OK" >> $RESULT_FILE
    result="All user accounts have shadowed passwords. Configuration is compliant."
  else
    echo "PASSWORD SHADOWING CONFIG:REQUIRES CHANGE" >> $RESULT_FILE
    result="Some user accounts do not have shadowed passwords. Configuration requires change."
    log_message "$non_shadowed_users" # Log details of non-compliant accounts
  fi

  log_message "$result"
}

# Function to check if any password fields in /etc/shadow are empty
check_empty_password_fields() {
  log_message "Checking if any password fields in /etc/shadow are empty..."

  # Run the awk command and capture the output
  empty_passwords=$(awk -F: '($2 == "") { print $1 " does not have a password "}' /etc/shadow)

  # Check if any empty password fields were found
  if [ -z "$empty_passwords" ]; then
    echo "PASSWORD FIELD CONFIG:OK" >> $RESULT_FILE
    result="All password fields in /etc/shadow are properly set. Configuration is compliant."
  else
    echo "PASSWORD FIELD CONFIG:REQUIRES CHANGE" >> $RESULT_FILE
    result="Some password fields in /etc/shadow are empty. Configuration requires change."
    log_message "$empty_passwords" # Log details of non-compliant accounts
  fi

  log_message "$result"
}

# Function to check if all groups in /etc/passwd exist in /etc/group
check_groups_in_passwd() {
  log_message "Checking if all groups in /etc/passwd exist in /etc/group..."

  missing_groups=""
  all_groups_exist=true

  # Iterate over each GID in /etc/passwd
  for i in $(cut -s -d: -f4 /etc/passwd | sort -u); do
    if ! grep -q -P "^.*?:[^:]*:$i:" /etc/group; then
      missing_groups+="$i "
      all_groups_exist=false
      log_message "Group $i is referenced by /etc/passwd but does not exist in /etc/group"
    fi
  done

  # Log result based on findings
  if [ "$all_groups_exist" = true ]; then
    echo "GROUP CONFIG:OK" >> $RESULT_FILE
    result="All groups in /etc/passwd exist in /etc/group. Configuration is compliant."
  else
    echo "GROUP CONFIG:REQUIRES CHANGE" >> $RESULT_FILE
    result="Groups referenced in /etc/passwd but missing in /etc/group: $missing_groups"
  fi

  log_message "$result"
}

check_duplicate_uids() {
  log_message "Checking for duplicate UIDs in /etc/passwd..."

  duplicate_uids=""
  no_duplicates=true

  # Find duplicate UIDs
  while read -r l_count l_uid; do
    if [ "$l_count" -gt 1 ]; then
      duplicate_uids+="$l_uid "
      no_duplicates=false
      log_message "Duplicate UID: \"$l_uid\" Users: \"$(awk -F: '($3 == n) { print $1 }' n=$l_uid /etc/passwd | xargs)\""
    fi
  done < <(cut -f3 -d":" /etc/passwd | sort -n | uniq -c)

  # Log result based on findings
  if [ "$no_duplicates" = true ]; then
    echo "UID CONFIG:OK" >> $RESULT_FILE
    result="No duplicate UIDs found in /etc/passwd. Configuration is compliant."
  else
    echo "UID CONFIG:REQUIRES CHANGE" >> $RESULT_FILE
    result="Duplicate UIDs found in /etc/passwd: $duplicate_uids"
  fi

  log_message "$result"
}

# Function to check for duplicate GIDs in /etc/group
check_duplicate_gids() {
  log_message "Checking for duplicate GIDs in /etc/group..."

  duplicate_gids=""
  no_duplicates=true

  # Find duplicate GIDs
  while read -r l_count l_gid; do
    if [ "$l_count" -gt 1 ]; then
      duplicate_gids+="$l_gid "
      no_duplicates=false
      log_message "Duplicate GID: \"$l_gid\" Groups: \"$(awk -F: '($3 == n) { print $1 }' n=$l_gid /etc/group | xargs)\""
    fi
  done < <(cut -f3 -d":" /etc/group | sort -n | uniq -c)

  # Log result based on findings
  if [ "$no_duplicates" = true ]; then
    echo "GID CONFIG:OK" >> $RESULT_FILE
    result="No duplicate GIDs found in /etc/group. Configuration is compliant."
  else
    echo "GID CONFIG:REQUIRES CHANGE" >> $RESULT_FILE
    result="Duplicate GIDs found in /etc/group: $duplicate_gids"
  fi

  log_message "$result"
}

# Function to check for duplicate user names in /etc/passwd
check_duplicate_users() {
  log_message "Checking for duplicate user names in /etc/passwd..."

  duplicate_users=""
  no_duplicates=true

  # Find duplicate user names
  while read -r l_count l_user; do
    if [ "$l_count" -gt 1 ]; then
      duplicate_users+="$l_user "
      no_duplicates=false
      log_message "Duplicate User: \"$l_user\" Users: \"$(awk -F: '($1 == n) { print $1 }' n=$l_user /etc/passwd | xargs)\""
    fi
  done < <(cut -f1 -d":" /etc/passwd | sort -n | uniq -c)

  # Log result based on findings
  if [ "$no_duplicates" = true ]; then
    echo "USER CONFIG:OK" >> $RESULT_FILE
    result="No duplicate user names found in /etc/passwd. Configuration is compliant."
  else
    echo "USER CONFIG:REQUIRES CHANGE" >> $RESULT_FILE
    result="Duplicate user names found in /etc/passwd: $duplicate_users"
  fi

  log_message "$result"
}
# Function to check for duplicate group names in /etc/group
check_duplicate_groups() {
  log_message "Checking for duplicate group names in /etc/group..."

  duplicate_groups=""
  no_duplicates=true

  # Find duplicate group names
  while read -r l_count l_group; do
    if [ "$l_count" -gt 1 ]; then
      duplicate_groups+="$l_group "
      no_duplicates=false
      log_message "Duplicate Group: \"$l_group\" Groups: \"$(awk -F: '($1 == n) { print $1 }' n=$l_group /etc/group | xargs)\""
    fi
  done < <(cut -f1 -d":" /etc/group | sort -n | uniq -c)

  # Log result based on findings
  if [ "$no_duplicates" = true ]; then
    echo "GROUP CONFIG:OK" >> $RESULT_FILE
    result="No duplicate group names found in /etc/group. Configuration is compliant."
  else
    echo "GROUP CONFIG:REQUIRES CHANGE" >> $RESULT_FILE
    result="Duplicate group names found in /etc/group: $duplicate_groups"
  fi

  log_message "$result"
}
# Function to ensure root is the only UID 0 account
check_root_uid_0() {
  log_message "Checking that only 'root' has UID 0 in /etc/passwd..."

  # Find users with UID 0 other than 'root'
  local result=$(awk -F: '($3 == 0) { print $1 }' /etc/passwd | grep -v '^root$')

  # Check if there are any results
  if [ -z "$result" ]; then
    echo "UID CONFIG:OK" >> $RESULT_FILE
    result="Only 'root' has UID 0. Configuration is compliant."
  else
    echo "UID CONFIG:REQUIRES CHANGE" >> $RESULT_FILE
    result="Additional UID 0 accounts found: $result"
  fi

  log_message "$result"
}
check_shadowed_passwords
check_empty_password_fields
check_groups_in_passwd
check_duplicate_uids
check_duplicate_gids
check_duplicate_users
check_duplicate_groups
check_root_uid_0


