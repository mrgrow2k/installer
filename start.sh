#!/bin/bash

##
##
##

RED='\033[1;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
YELLOW='\033[1;33m'
BROWN='\033[0;34m'
NC='\033[0m' # No Color

## Black        0;30     Dark Gray     1;30
## Red          0;31     Light Red     1;31
## Green        0;32     Light Green   1;32
## Brown/Orange 0;33     Yellow        1;33
## Blue         0;34     Light Blue    1;34
## Purple       0;35     Light Purple  1;35
## Cyan         0;36     Light Cyan    1;36
## Light Gray   0;37     White         1;37

echo && echo
cat << "EOF"
  
   ██████╗ ██████╗  ██████╗ ██╗    ██╗      ██╗███████╗██╗  ██╗
  ██╔════╝ ██╔══██╗██╔═══██╗██║    ██║      ██║██╔════╝██║  ██║
  ██║  ███╗██████╔╝██║   ██║██║ █╗ ██║█████╗██║███████╗███████║
  ██║   ██║██╔══██╗██║   ██║██║███╗██║╚════╝██║╚════██║██╔══██║
  ╚██████╔╝██║  ██║╚██████╔╝╚███╔███╔╝      ██║███████║██║  ██║
   ╚═════╝ ╚═╝  ╚═╝ ╚═════╝  ╚══╝╚══╝       ╚═╝╚══════╝╚═╝  ╚═╝
                                      ╚╗ @mrgrow2k 2019-2020 ╔╝

EOF
echo ""
echo -e "${BLUE}****************************************************************${NC}"
echo -e "${WHITE}${NC}Multi Bash Script Creaated by ${GREEN}MrGrow2k${GREEN} ${WHITE}Main Menu  "
echo -e "${BLUE}****************************************************************${NC}"
echo ""
echo -e "${GREEN}1:${NC}${FgLtYellow} Install 1 or more masternode(s) for Ragna${NC}"
echo -e "${GREEN}2:${NC}${FgLtYellow} Install 1 or more masternode(s) for Worx${NC}"
echo -e "${GREEN}3:${NC}${NC}${FgLtYellow} Quit and returh to main ${NC}"
echo -e "${BLUE}****************************************************************${NC}"
read OPTION
# echo ${OPTION}

clear

if [[ ${OPTION} == "1" ]] ; then
  wget https://raw.githubusercontent.com/mrgrow2k/installer/master/rag_install.sh -O rag_install.sh > /dev/null 2>&1
  chmod 777 rag_install.sh
  # dos2unix rag_install.sh > /dev/null 2>&1
  /bin/bash ./rag_install.sh
elif [[ ${OPTION} == "2" ]] ; then  
  wget https://raw.githubusercontent.com/mrgrow2k/installer/master/worx/worx_install.sh -O worx_install.sh > /dev/null 2>&1
  chmod 777 worx_install.sh
  # dos2unix worx_install.sh > /dev/null 2>&1
  /bin/bash ./worx_install.sh
elif [[ ${OPTION} == "3" ]] ; then
  exit 0
fi
###
/bin/bash ./start.sh
