#!/bin/bash
#
# Tech and Me, 2016 - www.techandme.se
#
device='/dev/sda'
SDCARD='/dev/mmcblk0'
ROOT_PROFILE='/root/.profile'
ADDRESS=$(ip route get 1 | awk '{print $NF;exit}')

# Use external harddrive to mount os and sd card to boot
function ask_yes_or_no() {
    read -p "$1 ([y]es or [N]o): "
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}
if [[ "yes" == $(ask_yes_or_no "Verify that you only have 1 externally powered USB Harddrive/SSD plugged in") ]]
then
        # Format and create partition

# Disable swap if it is setup before
if 		[ -f /swapfile ];
	then
      		swapoff -a
      		rm /swapfile
      		sed -i 's|/swapfile none swap defaults 0 0|#/swapfile none swap defaults 0 0|g' /etc/fstab
      	else
      		sleep 1
fi

# Step 1
fdisk $device << EOF
wipefs
EOF

fdisk $device << EOF
o
n
p
1

+4000M
w
EOF

fdisk $device << EOF
n
p
2


w
EOF
sync
partprobe

# Swap
mkswap -L PI_SWAP /dev/sda1 # format as swap
swapon /dev/sda1 # announce to system
echo "/dev/sda1 none swap sw 0 0" >> /etc/fstab
sync
partprobe

# Set cmdline.txt
mount /dev/mmcblk0p1 /mnt
sed -i 's|root=/dev/mmcblk0p2|root=/dev/sda2|g' /mnt/cmdline.txt
sed -i 's| rootwait||g' /mnt/cmdline.txt
sed -i 's| rootdelay|rootdelay=5|g' /mnt/cmdline.txt
umount /mnt

# External HD
echo -e "\e[32m"
echo "This might take a while, copying everything from SD card to HD. Just wait untill system continues."
echo -e "\e[0m"
sleep 2
sed -i 's|/dev/mmcblk0p2|#/dev/mmcblk0p2|g' /etc/fstab # change ROOT device so the system will know which one to use as ROOT
echo "/dev/sda2 / ext4 errors=remount-ro 0 1" >> /etc/fstab # fix for the update to 16.04 xenial
echo -ne '\n' | sudo mke2fs -t ext4 -b 4096 -L 'PI_ROOT' /dev/sda2 # make ext4 partition to hold ROOT
#dd bs=4M conv=sync,noerror if=/dev/mmcblk0p2 of=/dev/sda2 # copy the content of the SD ROOT partition to the new HD ROOT partition
mount /dev/sda2 /mnt
sudo rsync -aAXv / /mnt
umount /mnt

# Remove SD card ROOT partition
#fdisk /dev/mmcblk0 << EOF
#d
#2
#w
#EOF
#sync
#partprobe

echo -e "\e[32m"
echo    "+--------------------------------------------------------------------+"
echo    "| Your ip is $ADDRESS ssh is now installed so you can disconnect your|"
echo    "| Monitor and continue the installation over ssh, after the reboot.  |"
echo    "| After this reboot log back in with ocadmin///owncloud              |"
echo    "| The installation will then automatically begin.                    |"
echo    "|                                                                    |"
echo    "|                        ***SSH***                                   |"
echo    "| 1. Open a terminal on laptop/desktop (ctrl + alt + T for linux)    |"
echo    "| 2. Execute the command: sudo apt-get install openssh-client        |"
echo    "| 3. Execute the command: ssh -l ocadmin $ADDRESS                    |"
echo    "| 4. Type password: owncloud                                         |"
echo    "| 5. Follow the instructions                                         |"
echo    "+--------------------------------------------------------------------+"
echo
read -p "Press any key to continue..." -n1 -s
echo -e "\e[0m"
echo

reboot

else
        # Want to do this later? 
echo -e "\e[32m"
echo    "+--------------------------------------------------------------------+"
echo    "| Ok, you have chosen to not use an external HD/SSD                  |"
echo    "| This is not only a performance limitation but it could             |"
echo    "| Also mean that your Micro SDCard could die soon because            |"
echo    "| Of the intense writing to the SDCard.                              |"
echo    "|                                                                    |"
echo    "| If you do want to use a Harddisk run:                              |"
echo    "|                         sudo bash /var/scripts/external_usb.sh     |"
echo    "+--------------------------------------------------------------------+"
echo
read -p "Press any key to continue..." -n1 -s
echo -e "\e[0m"
echo

# Resize sd card
fdisk $SDCARD << EOF
d
2
w
EOF
sync

fdisk $SDCARD << EOF
n
p
2


w
EOF
sync
partprobe

# Install swapfile of 2 GB
if 		[ -f /swapfile ];
	then
      		sleep 1
      	else
      		fallocate -l 2048M /swapfile # create swapfile and set size
      		chmod 600 /swapfile # give it the right permissions
      		mkswap /swapfile # format as swap
      		swapon /swapfile # announce to system
      		echo "/swapfile none swap defaults 0 0" >> /etc/fstab # let the system know what file to use as swap after reboot
fi

clear

# Success!
echo -e "\e[32m"
echo    "+--------------------------------------------------------------------+"
echo    "| Your ip is $ADDRESS ssh is now installed so you can disconnect your|"
echo    "| Monitor and continue the installation over ssh, after the reboot.  |"
echo    "| After this reboot log back in with ocadmin///owncloud              |"
echo    "| The installation will then automatically begin.                    |"
echo    "|                                                                    |"
echo    "|                        ***SSH***                                   |"
echo    "| 1. Open a terminal on laptop/desktop (ctrl + alt + T for linux)    |"
echo    "| 2. Execute the command: sudo apt-get install openssh-client        |"
echo    "| 3. Execute the command: ssh -l ocadmin $ADDRESS                    |"
echo    "| 4. Type password: owncloud                                         |"
echo    "| 5. Follow the instructions                                         |"
echo    "+--------------------------------------------------------------------+"
echo
read -p "Press any key to continue..." -n1 -s
echo -e "\e[0m"
echo
clear

reboot

fi

exit 0
