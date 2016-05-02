#!/bin/bash
#
# Tech and Me, 2016 - www.techandme.se
#
function ask_yes_or_no() {
    read -p "$1 ([y]es or [N]o): "
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}
if [[ "yes" == $(ask_yes_or_no "Do you have a Harddisk with more storage then 2TB???") ]]
then
sed -i 's|||g' /var/scripts/external_usb.sh
else
sleep 1
fi

exit 0
