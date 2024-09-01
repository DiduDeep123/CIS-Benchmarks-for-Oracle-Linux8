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



# Function to update UEFI settings in /etc/fstab
update_uefi_fstab() {
    echo "Updating /etc/fstab for UEFI system..."

    # Ensure the /etc/fstab file exists
    if [ ! -f /etc/fstab ]; then
        echo "/etc/fstab not found. Exiting."
        exit 1
    fi
    
    read -p "Enter the device identifier for the EFI partition (e.g., /dev/sda1): " device

    # Check if the entry already exists
    if grep -q '/boot/efi' /etc/fstab; then
        echo "/boot/efi entry already exists in /etc/fstab."
    else
        echo "Adding UEFI /boot/efi entry to /etc/fstab..."
        echo "$device /boot/efi vfat defaults,umask=0027,fmask=0077,uid=0,gid=0 0 0" >> /etc/fstab
        echo "Please reboot the system for the changes to take effect."
    fi
}

# Function to update BIOS settings for /boot/grub2/
update_bios_grub() {
    echo "Updating BIOS bootloader configuration..."

    # List of files to be checked and updated
    files=(
        "/boot/grub2/grub.cfg"
        "/boot/grub2/grubenv"
        "/boot/grub2/user.cfg"
    )

    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            echo "Updating $file..."
            chown root:root "$file"
            chmod u-x,go-rwx "$file"
        else
            echo "$file not found."
        fi
    done
}

if grep -q "PERMISSIONS ON BOOTLOADER CONFIG:NOT CONFIGURED" $RESULT_FILE; then
	read -p "Do you want to edit permissions on bootloader config? (y/n)" answer
	if [[ answer = [Yy] ]]; then
	
# Check if UEFI system
if [ -d /sys/firmware/efi ]; then
  
    read -p "Do you want to update the /etc/fstab for UEFI? (Y/y for Yes, any other key to skip): " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        update_uefi_fstab
    else
        echo "User opted not to update /etc/fstab"
    fi
else
    read -p "Do you want to update the bootloader configuration for BIOS? (Y/y for Yes, any other key to skip): " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        update_bios_grub
    else
        echo "User opted not to update BIOS bootloader configuration."
    fi
fi
else
	select_no "PERMISSIONS ON BOOTLOADER CONFIG: REQUIRES CHANGE"
 fi
 fi



