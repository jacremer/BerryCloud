#!/bin/bash
#
# Tech and Me, 2016 - www.techandme.se
#
clear
cat << INST1
+-----------------------------------------------------------------------+
| Thank you for downloading this ownCloud .img made by Tech and Me!     |
|                                                                       |
INST1
echo -e "|"  "\e[32mTo run the startup script, just type: the sudo password\e[0m               |"
echo -e "|"  "\e[32mThe sudo password is: owncloud, or the PW you chose during install\e[0m    |"
cat << INST2
|        This script will take some time, about 30 minutes depending    |
|           on your overclock settings and connection                   |
|                                                                       |
| Here is a guide on how to set up auto updates:                        |
| https://www.techandme.se/set-automatic-owncloud-updates/              |
|                                                                       |
|  ####################### Tech and Me - 2016 ########################  |
+-----------------------------------------------------------------------+
INST2

exit 0
