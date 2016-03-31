#!/bin/bash
#
# Tech and Me, 2016 - www.techandme.se
#
WAN=$(curl -s checkip.dyndns.org | sed -e 's/.*Current IP Address: //' -e 's/<.*$//')
echo $WAN
exit 0
