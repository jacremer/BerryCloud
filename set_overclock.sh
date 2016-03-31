#!/bin/bash
#
# Tech and Me, 2016 - www.techandme.se
#
######################################
  function ask_yes_or_no() {
      read -p "$1 ([y]es or [N]o): "
      case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
          y|yes) echo "yes" ;;
          *)     echo "no" ;;
      esac
  }
  echo -e "\e[32m"
  if [[ "yes" == $(ask_yes_or_no "Do you want to supercharge your RPI? (safety is build in, warranty is void. Tech and me can't be held responsible for any loss/damage whatsoever.") ]]
  echo -e "\e[0m"
  then
    sync
    mount /dev/mmcblk0p1 /mnt
    rm /mnt/config.txt
    wget https://raw.githubusercontent.com/ezraholm50/BerryCloud/master/config_warranty_void.txt -P /tmp
    mv /tmp/config_warranty_void.txt /mnt/config.txt
    umount /mnt
  else
sleep 1
  fi

exit 0
