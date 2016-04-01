#!/bin/bash
#
# Tech and Me, 2016 - www.techandme.se
#
# Is the user using a RaspberryPI 2 or 3
# Lets check if /boot is mounted
if              [ -f /boot/config.txt ];
        then
                sleep 1
        else
                mount /dev/mmcblk0p1 /boot
fi

function ask_yes_or_no() {
    read -p "$1 ([y]es or [N]o): "
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}
if [[ "yes" == $(ask_yes_or_no "Is this a RaspberryPI 2") ]]
then

echo "you choose RPI2, if this was a mistake run: sudo bash /var/scripts/rpi_version.sh"
echo "because this will impact your performance if you do have an RPI3, and not in the good way..."
sleep 5

else

sed -i 's|arm_freq=1000|arm_freq=1300|g' /boot/config.txt
echo "RPI3 Arm_freq set to 1300"
sleep 3

fi
