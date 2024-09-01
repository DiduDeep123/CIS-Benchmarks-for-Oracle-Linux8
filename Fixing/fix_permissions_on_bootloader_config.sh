#!usr/bin/bash

# Function to update UEFI settings in /etc/fstab
update_uefi_fstab() {
    echo "Updating /etc/fstab for UEFI system..."

    # Ensure the /etc/fstab file exists
    if [ ! -f /etc/fstab ]; then
        echo "/etc/fstab not found. Exiting."
        exit 1
    fi
    
    # Check if the entry already exists
    grep -q '/boot/efi' /etc/fstab
    if [ $? -ne 0 ]; then
        echo "Adding UEFI /boot/efi entry to /etc/fstab..."
        echo "<device> /boot/efi vfat defaults,umask=0027,fmask=0077,uid=0,gid=0 0 0" >> /etc/fstab
        echo "Please reboot the system for the changes to take effect."
    else
        echo "/boot/efi entry already exists in /etc/fstab."
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


