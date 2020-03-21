#!/bin/bash

RED='\033[1;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
YELLOW='\033[1;33m'
BROWN='\033[0;34m'
NC='\033[0m' # No Color
WHITE="\033[0;37m"
CYAN="\033[0;36m"
Off='\E[0m'
Bold='\E[1m'
Dim='\E[2m'
Underline='\E[4m'
Blink='\E[5m'
FgLtRed='\E[91m'
FgLtBlue='\E[94m'
FgLtWhite='\E[97m'
BgLtBlue='\E[104m'

# CONFIGURATION
PARAM1=$*
NAME="ragnarok"
NAMEALIAS="ragna"

# ADDITINAL CONFIGURATION
COIN_TGZ='https://github.com/ragnaproject/Ragnarok/releases/download/3.0.1.0/Ragnarok-3.0.1.0-DAEMON.zip'
COIN_ZIP=$(echo $COIN_TGZ | awk -F'/' '{print $NF}')
CONF_FILE="ragnrok.conf"
CONF_DIR_TMP=~/"${NAME}_tmp"
# BOOTSTRAP_URL='http://159.65.64.248/files/bootstrap.zip'
BOOTSTRAP_URL='https://github.com/ragnaproject/bootstraps/releases/download/760590/bootstrap.zip'
COIN_PATH='/usr/bin/'
COIN_DAEMON='ragnarokd'
COIN_CLI='ragnarok-cli'
PORT=8853
RPCPORT=8854
NODEIP=$(curl -s4 icanhazip.com)
LATESTWALLETVERSION=3000100

# 
GETLASTBLOCK=$(curl -s4 http://159.65.64.248:88/api/getblockcount)
BLOCKHASH=$(curl -s4 http://159.65.64.248:88/api/getblockhash?index=${GETLASTBLOCK})


function install_binaries() {

if [ -d "$CONF_DIR_TMP" ]; then
  rm -rfd $CONF_DIR_TMP
fi

mkdir -p $CONF_DIR_TMP   
cd $CONF_DIR_TMP   
wget -q $COIN_TGZ
compile_error
unzip $COIN_ZIP >/dev/null 2>&1
compile_error
chmod +x $COIN_DAEMON
chmod +x $COIN_CLI
cp $COIN_DAEMON $COIN_PATH
cp $COIN_DAEMON /root/
cp $COIN_CLI $COIN_PATH
cp $COIN_CLI /root/
cd ~ >/dev/null 2>&1
rm -rf $TMP_FOLDER >/dev/null 2>&1
rm -rf $COIN_ZIP >/dev/null 2>&1
mkdir -p ~/bin
echo 'export PATH=~/bin:$PATH' > ~/.bash_aliases
source ~/.bashrc
clear
echo -e "* Done installing binaries."
}

# function memorycheck() {

# echo -e "${GREEN}* Checking Memory${NC}"
# FREEMEM=$(free -m |sed -n '2,2p' |awk '{ print $4 }')
# SWAPS=$(free -m |tail -n1 |awk '{ print $2 }')

# if [[ $FREEMEM -lt 3096 ]]; then 
#   if [[ $SWAPS -eq 0 ]]; then
#     echo -e "${GREEN}* Adding swap${NC}"
#     fallocate -l 4G /swapfile
#     sleep 2
#     chmod 600 /swapfile
#     mkswap /swapfile
#     swapon /swapfile
#     echo -e "/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab > /dev/null 2>&1
#     sudo sysctl vm.swappiness=10
#     sudo sysctl vm.vfs_cache_pressure=50
#     echo -e "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf > /dev/null 2>&1
#     echo -e "vm.vfs_cache_pressure=50" | sudo tee -a /etc/sysctl.conf > /dev/null 2>&1
#   else
#   echo -e "${GREEN}* Enough free ram available, not checking swap${NC}"
# fi
# }

function configure_nodes() {

mkdir -p ~/bin
rm ~/bin/masternode_config.txt &>/dev/null &
COUNTER=1

MNCOUNT=""
REBOOTRESTART=""
re='^[0-9]+$'

while ! [[ $MNCOUNT =~ $re ]] ; do
   echo -e "${YELLOW}* How many nodes do you want to create on this server?, followed by [ENTER]:${NC}" 
   read MNCOUNT  
   # echo -e "${YELLOW}* Do you want wallets to restart on reboot? [y/n]${NC}"
   # read REBOOTRESTART
done

for (( ; ; ))
do  
   #echo "Enter alias for new node. Name must be unique! (Don't use same names as for previous nodes on old chain if you didn't delete old chain folders!)"
   echo -e "${YELLOW}* Enter alphanumeric alias for new nodes.[default: mn]${NC}"
   read ALIAS1

   if [ -z "$ALIAS1" ]; then
      ALIAS1="mn"
   fi   

   ALIAS1=${ALIAS1,,}  

   if [[ "$ALIAS1" =~ [^0-9A-Za-z]+ ]] ; then
      echo -e "${RED}* $ALIAS has characters which are not alphanumeric. Only alphanumeric characters.${NC}"
   elif [ -z "$ALIAS1" ]; then
      echo -e "${RED}* $ALIAS1 in empty!${NC}"
   else
      CONF_DIR=~/.${COIN_NAME}_$ALIAS1
      if [ -d "$CONF_DIR" ]; then
         echo -e "${RED}* $ALIAS1 is already used. $CONF_DIR already exists!${NC}"
      else
         # OK !!!
         break
      fi  
   fi  
done

if [ -d "$CONF_DIR_TMP" ]; then
   rm -rfd $CONF_DIR_TMP
fi

mkdir -p $CONF_DIR_TMP   
cd $CONF_DIR_TMP  
echo "* Bootstraping Blockchain without conf files"
wget ${BOOTSTRAP_URL} -O bootstrap.zip  >/dev/null 2>&1
cd ~

for STARTNUMBER in `seq 1 1 $MNCOUNT`; do 
   for (( ; ; ))
   do  
      echo "************************************************************"
      echo ""
      EXIT='NO'
      ALIAS="$ALIAS1$STARTNUMBER"
      ALIAS0="${ALIAS1}0${STARTNUMBER}"
      ALIAS=${ALIAS,,}  
      echo $ALIAS
      echo "" 

      # check ALIAS
      if [[ "$ALIAS" =~ [^0-9A-Za-z]+ ]] ; then
         echo -e "${RED}* $ALIAS has characters which are not alphanumeric. Only alphanumeric characters.${NC}"
         EXIT='YES'
     elif [ -z "$ALIAS" ]; then
        echo -e "${RED}$ALIAS in empty!${NC}"
         EXIT='YES'
      else
        CONF_DIR=~/.${NAME}_${ALIAS}
         CONF_DIR0=~/.${NAME}_${ALIAS0}
    
         if [ -d "$CONF_DIR" ]; then
            echo -e "${RED}* $ALIAS is already used. $CONF_DIR already exists!${NC}"
            STARTNUMBER=$[STARTNUMBER + 1]
         elif  [ -d "$CONF_DIR0" ]; then
            echo -e "${RED}* $ALIAS is already used. $CONF_DIR0 already exists!${NC}"
            STARTNUMBER=$[STARTNUMBER + 1]            
         else
            # OK !!!
            break
         fi 
      fi  
   done   

   if [ $EXIT == 'YES' ]
   then
      exit 1
   fi
  
   PORT1=""
   for (( ; ; ))
   do
      PORT1=$(netstat -peanut | grep -i listen | grep -i $PORT)

      if [ -z "$PORT1" ]; then
         break
      else
         PORT=$[PORT + 2]
      fi
   done  
   echo "PORT "$PORT 

   RPCPORT1=""
   for (( ; ; ))
   do
      RPCPORT1=$(netstat -peanut | grep -i listen | grep -i $RPCPORT)

      if [ -z "$RPCPORT1" ]; then
         break
      else
         RPCPORT=$[RPCPORT + 2]
      fi
   done  
   echo "RPCPORT "$RPCPORT

   PRIVKEY=""
   echo ""
  
   if [[ "$COUNTER" -lt 2 ]]; then
      ALIASONE=$(echo $ALIAS)
   fi  
   echo "ALIASONE="$ALIASONE

   # Create scripts
   echo '#!/bin/bash' > ~/bin/${NAME}d_$ALIAS.sh
   echo "${NAME}d -daemon -conf=$CONF_DIR/${NAME}.conf -datadir=$CONF_DIR "'$*' >> ~/bin/${NAME}d_$ALIAS.sh
   echo "${NAME}-cli -conf=$CONF_DIR/${NAME}.conf -datadir=$CONF_DIR "'$*' > ~/bin/${NAME}-cli_$ALIAS.sh
   chmod 755 ~/bin/${NAME}*.sh

   mkdir -p $CONF_DIR
   echo "rpcuser=user"`shuf -i 100000-10000000 -n 1` >> ${NAME}.conf_TEMP
   echo "rpcpassword=pass"`shuf -i 100000-10000000 -n 1` >> ${NAME}.conf_TEMP
   echo "rpcallowip=127.0.0.1" >> ${NAME}.conf_TEMP
   echo "rpcport=$RPCPORT" >> ${NAME}.conf_TEMP
   echo "listen=1" >> ${NAME}.conf_TEMP
   echo "server=1" >> ${NAME}.conf_TEMP
   echo "daemon=1" >> ${NAME}.conf_TEMP
   echo "logtimestamps=1" >> ${NAME}.conf_TEMP
   echo "maxconnections=256" >> ${NAME}.conf_TEMP
   echo "" >> ${NAME}.conf_TEMP
   echo "port=$PORT" >> ${NAME}.conf_TEMP
  
   if [ -z "$PRIVKEY" ]; then
      echo ""
   else
      echo "masternode=1" >> ${NAME}.conf_TEMP
      echo "masternodeprivkey=$PRIVKEY" >> ${NAME}.conf_TEMP
      echo "" >> ${NAME}.conf_TEMP
      echo "#AddNodes" >> ${NAME}.conf_TEMP
      echo "addnode=174.138.9.14" >> ${NAME}.conf_TEMP
      echo "addnode=174.138.14.163" >> ${NAME}.conf_TEMP
      echo "addnode=139.180.197.202:8853" >> ${NAME}.conf_TEMP
      echo "addnode=149.28.33.252:8853" >> ${NAME}.conf_TEMP
      echo "addnode=174.138.14.163:8853" >> ${NAME}.conf_TEMP
      echo "addnode=178.239.225.246:8853" >> ${NAME}.conf_TEMP
      echo "addnode=198.23.139.109:8853" >> ${NAME}.conf_TEMP
      echo "addnode=207.148.103.115:8853" >> ${NAME}.conf_TEMP
      echo "addnode=209.250.229.110:8853" >> ${NAME}.conf_TEMP
      echo "addnode=3.211.80.4:8853" >> ${NAME}.conf_TEMP
      echo "addnode=45.32.44.238:8853" >> ${NAME}.conf_TEMP
      echo "addnode=45.63.60.61:8853" >> ${NAME}.conf_TEMP
      echo "addnode=45.77.111.228:8853" >> ${NAME}.conf_TEMP
      echo "addnode=51.15.233.35:8853" >> ${NAME}.conf_TEMP
      echo "addnode=51.15.246.53:8853" >> ${NAME}.conf_TEMP
      echo "addnode=51.158.72.104:8853" >> ${NAME}.conf_TEMP
      echo "addnode=54.36.172.186:8853" >> ${NAME}.conf_TEMP
      echo "addnode=60.227.24.188:8853" >> ${NAME}.conf_TEMP
      echo "addnode=79.68.158.105:8853" >> ${NAME}.conf_TEMP
      echo "addnode=80.211.24.110:8853" >> ${NAME}.conf_TEMP
      echo "addnode=85.217.170.186:8853" >> ${NAME}.conf_TEMP
   fi

   sudo ufw allow $PORT/tcp >/dev/null 2>&1
   mv ${NAME}.conf_TEMP $CONF_DIR/ragnarok.conf

 
   if [ -z "$PRIVKEY" ]; then
     PID=`ps -ef | grep -i ${NAME} | grep -i ${ALIASONE}/ | grep -v grep | awk '{print $2}'`
  
     if [ -z "$PID" ]; then
         # start wallet
         sh ~/bin/${NAME}d_$ALIASONE.sh  
        sleep 1
     fi
  
     for (( ; ; ))
     do  
        echo "* Please wait ..."
         sleep 2
        PRIVKEY=$(~/bin/ragnarok-cli_${ALIASONE}.sh masternode genkey)
        echo "PRIVKEY=$PRIVKEY"
        if [ -z "$PRIVKEY" ]; then
           echo "PRIVKEY is null"
        else
           break
         fi
     done
  
     sleep 1
  
     for (( ; ; ))
     do
       PID=`ps -ef | grep -i ${NAME} | grep -i ${ALIAS}/ | grep -v grep | awk '{print $2}'`
       if [ -z "$PID" ]; then
          echo ""
       else
          #STOP 
          ~/bin/ragnarok-cli_$ALIAS.sh stop
       fi
       echo "Please wait ..."
       sleep 2 # wait 2 seconds 
       PID=`ps -ef | grep -i ${NAME} | grep -i ${ALIAS}/ | grep -v grep | awk '{print $2}'`
       echo "PID="$PID  
    
       if [ -z "$PID" ]; then
        sleep 1 # wait 1 second
        echo "masternode=1" >> ${NAME}.conf_TEMP
        echo "masternodeprivkey=$PRIVKEY" >> $CONF_DIR/ragnarok.conf
        echo "" >> ${NAME}.conf_TEMP
        echo "#AddNodes" >> ${NAME}.conf_TEMP
        echo "addnode=174.138.9.14" >> $CONF_DIR/ragnarok.conf
        echo "addnode=174.138.14.163" >> $CONF_DIR/ragnarok.conf
        echo "addnode=139.180.197.202:8853" >> $CONF_DIR/ragnarok.conf
        echo "addnode=149.28.33.252:8853" >> $CONF_DIR/ragnarok.conf
        echo "addnode=174.138.14.163:8853" >> $CONF_DIR/ragnarok.conf
        echo "addnode=178.239.225.246:8853" >> $CONF_DIR/ragnarok.conf
        echo "addnode=198.23.139.109:8853" >> $CONF_DIR/ragnarok.conf
        echo "addnode=207.148.103.115:8853" >> $CONF_DIR/ragnarok.conf
        echo "addnode=209.250.229.110:8853" >> $CONF_DIR/ragnarok.conf
        echo "addnode=3.211.80.4:8853" >> $CONF_DIR/ragnarok.conf
        echo "addnode=45.32.44.238:8853" >> $CONF_DIR/ragnarok.conf
        echo "addnode=45.63.60.61:8853" >> $CONF_DIR/ragnarok.conf
        echo "addnode=45.77.111.228:8853" >> $CONF_DIR/ragnarok.conf
        echo "addnode=51.15.233.35:8853" >> $CONF_DIR/ragnarok.conf
        echo "addnode=51.15.246.53:8853" >> $CONF_DIR/ragnarok.conf
        echo "addnode=51.158.72.104:8853" >> $CONF_DIR/ragnarok.conf
        echo "addnode=54.36.172.186:8853" >> $CONF_DIR/ragnarok.conf
        echo "addnode=60.227.24.188:8853" >> $CONF_DIR/ragnarok.conf
        echo "addnode=79.68.158.105:8853" >> $CONF_DIR/ragnarok.conf
        echo "addnode=80.211.24.110:8853" >> $CONF_DIR/ragnarok.conf
        echo "addnode=85.217.170.186:8853" >> $CONF_DIR/ragnarok.conf
          break
        fi
     done
   fi

   sleep 2
   PID=`ps -ef | grep -i ${NAME} | grep -i ${ALIAS}/ | grep -v grep | awk '{print $2}'`
   echo "PID="$PID
  
   if [ -z "$PID" ]; then
      echo ""
   else
      ~/bin/ragnarok-cli_$ALIAS.sh stop
     sleep 2 # wait 2 seconds 
   fi 
  
   if [ -z "$PID" ]; then
      cd $CONF_DIR
      echo "* Bootstraping Blockchain without conf files"
     rm -R ./database &>/dev/null &
     rm -R ./blocks &>/dev/null &
     rm -R ./sporks &>/dev/null &
     rm -R ./chainstate &>/dev/null &
      cp $CONF_DIR_TMP/bootstrap.zip .
      unzip  bootstrap.zip  >/dev/null 2>&1
      rm ./bootstrap.zip
      sh ~/bin/${NAME}d_$ALIAS.sh   
      sleep 2 # wait 2 seconds 
   fi

   MNCONFIG=$(echo $ALIAS $NODEIP:$PORT $PRIVKEY "txhash" "outputidx")
   echo $MNCONFIG >> ~/bin/masternode_config.txt
  
   if [[ ${REBOOTRESTART,,} =~ "y" ]] ; then
      (crontab -l 2>/dev/null; echo "@reboot sh ~/bin/${NAME}d_$ALIAS.sh") | crontab -
     (crontab -l 2>/dev/null; echo "@reboot sh /root/bin/${NAME}d_$ALIAS.sh") | crontab -
     sudo service cron reload
   fi
  
   COUNTER=$[COUNTER + 1]
done

if [ -d "$CONF_DIR_TMP" ]; then
   rm -rfd $CONF_DIR_TMP
fi

}



function create_key() {
if [[ $OLDKEY ]]; then
  echo -e "${GREEN}* We have a previous key... Using that.. {NC}"
fi

    COINKEY=$OLDKEY
  if [[ ! $OLDKEY ]]; then 
    echo -e "${YELLOW}* Enter your ${RED}$COIN_NAME masternode gen key ${NC}. Or Press enter generate New gen key"
    read -e COINKEY
    if [[ -z "$COINKEY" ]]; then
    $COIN_PATH$COIN_DAEMON -daemon
    sleep 30
    if [ -z "$(ps axo cmd:100 | grep $COIN_DAEMON)" ]; then
    echo -e "${RED}* $COIN_NAME server couldn not start. Check /var/log/syslog for errors.{$NC}"
    exit 1
    fi
    COINKEY=$($COIN_PATH$COIN_CLI masternode genkey)
    if [ "$?" -gt "0" ];
      then
      echo -e "${RED}* Wallet not fully loaded. Let us wait and try again to generate the GEN Key${NC}"
      sleep 30
      COINKEY=$($COIN_PATH$COIN_CLI masternode genkey)
      fi
      $COIN_PATH$COIN_CLI stop
  fi
  clear
  fi

#clear
}

function enable_firewall() {
  echo -e "* Installing and setting up firewall to allow ingress on port ${GREEN}$COIN_PORT${NC}"
  ufw allow $COIN_PORT/tcp comment "$COIN_NAME MN port" >/dev/null
  ufw allow ssh comment "SSH" >/dev/null 2>&1
  ufw limit ssh/tcp >/dev/null 2>&1
  ufw default allow outgoing >/dev/null 2>&1
  echo "y" | ufw enable >/dev/null 2>&1
}


function get_ip() {
  declare -a NODE_IPS
  for ips in $(netstat -i | awk '!/Kernel|Iface|lo/ {print $1," "}')
  do
    NODE_IPS+=($(curl --interface $ips --connect-timeout 2 -s4 icanhazip.com))
  done

  if [ ${#NODE_IPS[@]} -gt 1 ]
    then
      echo -e "${GREEN}* More than one IP. Please type 0 to use the first IP, 1 for the second and so on...${NC}"
      INDEX=0
      for ip in "${NODE_IPS[@]}"
      do
        echo ${INDEX} $ip
        let INDEX=${INDEX}+1
      done
      read -e choose_ip
      NODEIP=${NODE_IPS[$choose_ip]}
  else
    NODEIP=${NODE_IPS[0]}
  fi
}


function compile_error() {
if [ "$?" -gt "0" ];
 then
  echo -e "${RED}* Failed to compile $COIN_NAME. Please investigate.${NC}"
  exit 1
fi
}


function checks() {
if [[ $(lsb_release -d) != *16.04* ]]; then
  echo -e "${RED}* You are not running Ubuntu 16.04. Installation is cancelled.${NC}"
  exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}* $0 must be run as root.${NC}"
   exit 1
fi

}

function prepare_system() {
echo -e "******** Preparing the VPS to setup. ${CYAN}$NAME${NC} ${RED}masternode${NC} ********"
apt-get update >/dev/null 2>&1
DEBIAN_FRONTEND=noninteractive apt-get update > /dev/null 2>&1
DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y -qq upgrade >/dev/null 2>&1
if [[ ! -e /etc/apt/sources.list.d/bitcoin-ubuntu-bitcoin-xenial.list ]]; then 
apt install -y software-properties-common >/dev/null 2>&1
echo -e "${PURPLE}* Adding bitcoin PPA repository"
apt-add-repository -y ppa:bitcoin/bitcoin >/dev/null 2>&1
fi
echo -e "${GREEN}* Installing required packages, it may take some time to finish.${NC}"
apt-get update >/dev/null 2>&1
apt-get install libzmq3-dev -y >/dev/null 2>&1
apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" make software-properties-common \
build-essential libtool autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev libboost-program-options-dev \
libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git wget curl libdb4.8-dev bsdmainutils libdb4.8++-dev \
libminiupnpc-dev libgmp3-dev ufw pkg-config libevent-dev  libdb5.3++ unzip libzmq5 dos2unix jq>/dev/null 2>&1
if [ "$?" -gt "0" ];
  then
    echo -e "${RED}* Not all required packages were installed properly. Try to install them manually by running the following commands:${NC}\n"
    echo "apt-get update"
    echo "apt -y install software-properties-common"
    echo "apt-add-repository -y ppa:bitcoin/bitcoin"
    echo "apt-get update"

echo "apt install -y make build-essential libtool software-properties-common autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev \
libboost-program-options-dev libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git curl libdb4.8-dev \
bsdmainutils libdb4.8++-dev libminiupnpc-dev libgmp3-dev ufw pkg-config libevent-dev libdb5.3++ unzip libzmq5"
 exit 1
fi
#clear
}

function important_information_multi() {
 echo ""
 echo -e "${WHITE}********************************************************************************${NC}"
 echo ""
 echo -e "${YELLOW}********************************************************************************${NC}"
 echo -e "**Copy/Paste lines below in Hot wallet masternode.conf file**"
 echo -e "**and replace txhash and outputidx with data from masternode outputs command**"
 echo -e "**in hot wallet console**"
 echo ""
 echo -e "${RED}"
 cat ~/bin/masternode_config.txt
 echo -e "${NC}"
 echo -e "${YELLOW}********************************************************************************${NC}"
 echo ""
}


function check_resync_all() {
if [ -z "$PARAM1" ]; then
  PARAM1="*"      
else
  PARAM1=${PARAM1,,} 
fi

for FILE in ~/bin/${NAME}d_$PARAM1.sh; do
  echo "${YELLOW}****************************************************************************${NC}"
  COUNTER=1
  DATE=$(date '+%d.%m.%Y %H:%M:%S');
  echo "DATE="$DATE
  echo FILE: " $FILE"
  #cat $FILE
  STARTPOS=$(echo $FILE | grep -b -o _)
  LENGTH=$(echo $FILE | grep -b -o .sh)
  # echo ${STARTPOS:0:2}
  STARTPOS_1=$(echo ${STARTPOS:0:2})
  STARTPOS_1=$[STARTPOS_1 + 1]
  ALIAS=$(echo ${FILE:STARTPOS_1:${LENGTH:0:2}-STARTPOS_1})
  CONFPATH=$(echo "$HOME/.${NAME}_$ALIAS")
  # echo $STARTPOS_1
  # echo ${LENGTH:0:2}
  echo CONF FOLDER: $CONFPATH
  
  for (( ; ; ))
  do
    sleep 2
  
  PID=`ps -ef | grep -i _$ALIAS | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
  echo "PID="$PID
  
  if [ -z "$PID" ]; then
    echo "Monk $ALIAS is STOPPED can't check if synced!"
    break
  fi
  
  LASTBLOCK=$(~/bin/${NAME}-cli_$ALIAS.sh getblockcount)
  GETBLOCKHASH=$(~/bin/${NAME}-cli_$ALIAS.sh getblockhash $LASTBLOCK)

  echo "LASTBLOCK="$LASTBLOCK
  echo "GETBLOCKHASH="$GETBLOCKHASH

  echo "LASTBLOCK="$LASTBLOCK
  echo "GETBLOCKHASH="$GETBLOCKHASH
  echo "BLOCKHASH="$BLOCKHASH


  echo "GETBLOCKHASH="$GETBLOCKHASH
  echo "BLOCKHASH="$BLOCKHASH
  if [ "$GETBLOCKHASH" == "$BLOCKHASH" ]; then
    echo $DATE" Wallet $ALIAS is SYNCED!"
    break
  else  
      if [ "$BLOCKHASH" == "Too" ]; then
       echo "COINEXPLORER Too many requests"
       break  
    fi
    
    # Wallet is not synced
    echo $DATE" Wallet $ALIAS is NOT SYNCED!"
    #
    # echo $LASTBLOCKCOINEXPLORER
    #break
    #STOP 
    ~/bin/${NAME}-cli_$ALIAS.sh stop

    if [[ "$COUNTER" -gt 1 ]]; then
      kill -9 $PID
    fi
    
    sleep 3 # wait 3 seconds 
    PID=`ps -ef | grep -i _$ALIAS | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
    echo "PID="$PID
    
    if [ -z "$PID" ]; then
      echo "${NAME}* $ALIAS is STOPPED"
      
      cd $CONFPATH
      echo CURRENT CONF FOLDER: $PWD
      echo "* Bootstraping Blockchain without conf files"
      wget ${BOOTSTRAP_URL} -O bootstrap.zip >/dev/null 2>&1
      # rm -R peers.dat 
      rm -R ./database
      rm -R ./blocks  
      rm -R ./sporks
      rm -R ./chainstate      
      unzip  bootstrap.zip >/dev/null 2>&1
      $FILE
      sleep 5 # wait 5 seconds 
      
      PID=`ps -ef | grep -i _$ALIAS | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
      echo "PID="$PID
      
      if [ -z "$PID" ]; then
      echo "${NAME}* $ALIAS still not running!"
      fi
      
      break
    else
      echo "${NAME}* $ALIAS still running!"
    fi
  fi
  
  COUNTER=$[COUNTER + 1]
  echo COUNTER: $COUNTER
  if [[ "$COUNTER" -gt 9 ]]; then
    break
  fi    
  done    
done

}

function check_nodes_sync() {
if [ -z "$PARAM1" ]; then
  PARAM1="*"      
else
  PARAM1=${PARAM1,,} 
fi

sudo apt-get install -y jq > /dev/null 2>&1

for FILE in ~/bin/${NAME}d_$PARAM1.sh; do
  sleep 2
  echo "${YELLOW}****************************************************************************${NC}"
  echo FILE: " $FILE"

  STARTPOS=$(echo $FILE | grep -b -o _)
  LENGTH=$(echo $FILE | grep -b -o .sh)
  STARTPOS_1=$(echo ${STARTPOS:0:2})
  STARTPOS_1=$[STARTPOS_1 + 1]
  ALIAS=$(echo ${FILE:STARTPOS_1:${LENGTH:0:2}-STARTPOS_1})  
  
  PID=`ps -ef | grep -i $ALIAS | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
  echo "PID="$PID

  if [ -z "$PID" ]; then
    echo "${NAME} $ALIAS is STOPPED can't check if synced!"
  else
  
    LASTBLOCK=$(~/bin/${NAME}-cli_$ALIAS.sh getblockcount)
    GETBLOCKHASH=$(~/bin/${NAME}-cli_$ALIAS.sh getblockhash $LASTBLOCK)  
      
    WALLETVERSION=$(~/bin/${NAME}-cli_$ALIAS.sh getinfo | grep -i \"version\")
    WALLETVERSION=$(echo $WALLETVERSION | tr , " ")
    WALLETVERSION=$(echo $WALLETVERSION | tr '"' " ")
    WALLETVERSION=$(echo $WALLETVERSION | tr 'version : ' " ")
    WALLETVERSION=$(echo $WALLETVERSION | tr -d ' ' )
    
    if ! [ "$WALLETVERSION" == "$LATESTWALLETVERSION" ]; then
       echo "!!!Your wallet $ALIAS is OUTDATED!!!"
    fi

    echo "LASTBLOCK="$LASTBLOCK
    echo "GETBLOCKHASH="$GETBLOCKHASH
    echo "BLOCKHASH="$BLOCKHASH
    echo "WALLETVERSION="$WALLETVERSION
    
    if [ "$GETBLOCKHASH" == "$BLOCKHASH" ]; then
    echo "Wallet $FILE is SYNCED!"
    else
    if [ "$BLOCKHASH" == "Too" ]; then
       echo "COINEXPLORER Too many requests"
    else 
       echo "Wallet $FILE is NOT SYNCED!"
    fi
    fi
  fi
done
}

function restart_nodes (){

if [ -z "$PARAM1" ]; then
  PARAM1="*"      
else
  PARAM1=${PARAM1,,} 
fi

for FILE in ~/bin/${NAME}d_$PARAM1.sh; do
  echo "${YELLOW}*******************************************************${NC}"
  echo "FILE "$FILE
  $FILE
done

}

function stop_nodes(){
if [ -z "$PARAM1" ]; then
  PARAM1="*"      
else
  PARAM1=${PARAM1,,} 
fi

for FILE in ~/bin/${NAME}-cli_$PARAM1.sh; do
  echo "${YELLOW}*******************************************************${NC}"
  echo "FILE "$FILE
  $FILE stop
done
}

function check_nodes_status (){
if [ -z "$PARAM1" ]; then
  PARAM1="*"      
else
  PARAM1=${PARAM1,,} 
fi

for FILE in ~/bin/${NAME}-cli_$PARAM1.sh; do
  echo "${YELLOW}*******************************************************${NC}"
  echo "FILE "$FILE
  $FILE masternode status
done
}

function resync_specific (){
##
## Script sync wallet using current bootstrap
##

PARAM1=$*
PARAM1=${PARAM1,,} 

sudo apt-get install -y jq > /dev/null 2>&1

if [ -z "$PARAM1" ]; then
  echo "Need to specify node alias!"
  exit -1
fi

if [ ! -f ~/bin/${NAME}d_$PARAM1.sh ]; then
    echo "Wallet $PARAM1 not found!"
  exit -1
fi

for FILE in ~/bin/${NAME}d_$PARAM1.sh; do
  echo "${YELLOW}****************************************************************************${NC}"
  COUNTER=1
  DATE=$(date '+%d.%m.%Y %H:%M:%S');
  echo "DATE="$DATE
  echo FILE: " $FILE"
  STARTPOS=$(echo $FILE | grep -b -o _)
  LENGTH=$(echo $FILE | grep -b -o .sh)./mon
  # echo ${STARTPOS:0:2}
  STARTPOS_1=$(echo ${STARTPOS:0:2})
  STARTPOS_1=$[STARTPOS_1 + 1]
  ALIAS=$(echo ${FILE:STARTPOS_1:${LENGTH:0:2}-STARTPOS_1})
  CONFPATH=$(echo "$HOME/.${NAME}_$ALIAS")
  # echo $STARTPOS_1
  # echo ${LENGTH:0:2}
  echo CONF DIR: $CONFPATH
  
  if [ ! -d $CONFPATH ]; then
  echo "Directory $CONFPATH not found!"
  exit -1
  fi     
  
  for (( ; ; ))
  do
    sleep 2
  
  PID=`ps -ef | grep -i $ALIAS | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
  echo "PID="$PID
  
  if [ -z "$PID" ]; then
    echo "${NAME} $ALIAS is STOPPED can't check if synced!"
  fi
  
  LASTBLOCK=$(~/bin/${NAME}-cli_$ALIAS.sh getblockcount)
  GETBLOCKHASH=$(~/bin/${NAME}-cli_$ALIAS.sh getblockhash $LASTBLOCK)

  echo "LASTBLOCK="$LASTBLOCK
  echo "GETBLOCKHASH="$GETBLOCKHASH

  echo "LASTBLOCK="$LASTBLOCK
  echo "GETBLOCKHASH="$GETBLOCKHASH
  echo "BLOCKHASH="$BLOCKHASH


  echo "GETBLOCKHASH="$GETBLOCKHASH
  echo "BLOCKHASH="$BLOCKHASH

  if [ "$BLOCKHASH" == "Too" ]; then
     echo "COINEXPLORER Too many requests"
     break  
  fi
  
  # Wallet is not synced
  echo $DATE" Wallet $ALIAS is NOT SYNCED!"
  #
  # echo $LASTBLOCKCOINEXPLORER
  #break
  
  if [ -z "$PID" ]; then
     echo ""
  else
    #STOP 
    ~/bin/${NAME}-cli_$ALIAS.sh stop

    if [[ "$COUNTER" -gt 1 ]]; then
      kill -9 $PID
    fi
  fi
  
  sleep 3 # wait 3 seconds 
  PID=`ps -ef | grep -i $ALIAS | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
  echo "PID="$PID
  
  if [ -z "$PID" ]; then
    echo "Monk $ALIAS is STOPPED"
    
    cd $CONFPATH
    echo CURRENT CONF FOLDER: $PWD
    echo "* Bootstraping Blockchain without conf files"
    wget ${BOOTSTRAP_URL} -O bootstrap.zip >/dev/null 2>&1
    # rm -R peers.dat 
    rm -R ./database
    rm -R ./blocks  
    rm -R ./sporks
    rm -R ./chainstate      
    unzip  bootstrap.zip >/dev/null 2>&1
    $FILE
    sleep 5 # wait 5 seconds 
    
    PID=`ps -ef | grep -i $ALIAS | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
    echo "PID="$PID
    
    if [ -z "$PID" ]; then
    echo "${NAME}* $ALIAS still not running!"
    fi
    
    break
  else
    echo "${NAME}* $ALIAS still running!"
  fi
  
  COUNTER=$[COUNTER + 1]
  echo COUNTER: $COUNTER
  if [[ "$COUNTER" -gt 9 ]]; then
    break
  fi    
  done    
done
}

function memory_cpu_sysinfo() {
# dependencies
sudo apt-get install -y bc  >/dev/null 2>&1

TOTALMEM=0
TOTALCPU=0
COUNTER=0
COIN=$1
NUMBOFCPUCORES=$(cat /proc/cpuinfo | awk '/^processor/{print $3}' | wc -l)

if [ -z "$COIN" ]; then
   COIN="daemon"
fi

# echo "COIN=${COIN}"
echo -e "${BLUE}*********************** Calculating **********************${NC}"
echo -e "${WHITE}    ___ _                       __    __      _ _   "
echo -e "${WHITE}   / _ \ | ___  __   ___  ___  / / /\ \ \__  (_) |_ "
echo -e "${WHITE}  / /_)/ |/ _ \/ _\ / __|/ _ \ \ \/  \/ / _\ | | __|"
echo -e "${WHITE} / ___/| |  __/ (_|_\__ \  __/  \  /\  / (_|_| | |_ "
echo -e "${WHITE} \/    |_|\___|\__,_|___/\___|   \/  \/ \__,_|_|\__|"
echo ""
echo -e "                  ${GREEN}This should only takes a few minutes..."
echo ""

for PID in `ps -ef | grep -i ${COIN} | grep daemon | grep conf | grep -v grep | awk '{printf "%d\n", $2}'`; do
   # echo "PID=${PID}"
   PIDMEM=$(cat /proc/${PID}/status |grep VmRSS | awk '{printf "%d\n", $2}')
   # echo "PIDMEM=${PIDMEM}"
   TOTALMEM=$(expr ${TOTALMEM} + ${PIDMEM})

   PIDCPU=$(echo `ps -p ${PID} -o %cpu | grep -v CPU |awk '{printf "%0.2f\n", $1}'`)
   # echo "PIDCPU=${PIDCPU}"
   TOTALCPU=$(echo "${TOTALCPU} + ${PIDCPU}" | bc)

   COUNTER=$[COUNTER + 1]
done

echo -e "${GREEN}* Currently running nodes: ${COUNTER} ${NC}"

if [ $COUNTER == 0 ]
then
   echo -e "${RED}* No installed nodes found! Default stats will be used! ${NC}"
   COUNTER=1
fi

#echo "Total memory used ${TOTALMEM} Kb"

if [ -z "$NUMBOFCPUCORES" ]; then
   NUMBOFCPUCORES=1
elif  [ $COUNTER == 0 ]; then
   NUMBOFCPUCORES=1
fi

# echo "NUMBOFCPUCORES=${NUMBOFCPUCORES}"

if [ -z "$TOTALCPU" ]; then
   TOTALCPU=0
fi

TOTALCPU=$(echo "${TOTALCPU} / ${NUMBOFCPUCORES}" |bc)
echo -e "${GREEN}* Total CPU% used ${TOTALCPU}%${NC}"

TOTALMEMMB=$(expr ${TOTALMEM} / 1024)
# echo "Total memory used ${TOTALMEMMB} Mb"

AVERAGEMEMMB=$(expr ${TOTALMEMMB} / ${COUNTER})

if [ -z "$AVERAGEMEMMB" ]; then
   AVERAGEMEMMB=500
elif  [ $AVERAGEMEMMB == 0 ]; then
   AVERAGEMEMMB=500
fi

AVERAGECPU=$(echo "${TOTALCPU} / ${COUNTER}" |bc -l)
echo -e "${GREEN}* Average CPU used ${AVERAGECPU}% per node${NC}"

TOTALMEMGB=$(expr ${TOTALMEMMB} / 1024)
echo -e "${GREEN}* Total memory used ${TOTALMEMGB} Gb${NC}"

echo -e "${GREEN}* Average memory used ${AVERAGEMEMMB} Mb per node${NC}"

FREEMEMMB=$(free -m | grep Mem | awk '{printf "%d\n", $4}')
echo -e "${GREEN}* Free memory ${FREEMEMMB} Mb${NC}"
NUMOFFREENODESMEM=$(expr ${FREEMEMMB} / ${AVERAGEMEMMB})

if [ -z "$AVERAGECPU" ]; then
   AVERAGECPU=0.5
elif  [ $AVERAGECPU == 0 ]; then
   AVERAGECPU=0.5
fi

NUMOFFREENODESCPU=$(echo "100 / ${AVERAGECPU}" | bc)

### RESULT ###
echo ""
echo -e "${YELLOW}* Based on free memory, this server can host approx. ${RED}${NUMOFFREENODESMEM}${NC} ${YELLOW}additional nodes${NC}"
echo -e "${YELLOW}* Based on free CPU, this server can host approx. ${RED}${NUMOFFREENODESCPU}${NC} ${YELLOW}additional nodes${NC}"

}

function mainmenu() {
clear
printf '\e[8;42;100t'

cat << "EOF"
    
     ██████╗ ██████╗  ██████╗ ██╗    ██╗      ██╗███████╗██╗  ██╗
    ██╔════╝ ██╔══██╗██╔═══██╗██║    ██║      ██║██╔════╝██║  ██║
    ██║  ███╗██████╔╝██║   ██║██║ █╗ ██║█████╗██║███████╗███████║
    ██║   ██║██╔══██╗██║   ██║██║███╗██║╚════╝██║╚════██║██╔══██║
    ╚██████╔╝██║  ██║╚██████╔╝╚███╔███╔╝      ██║███████║██║  ██║
     ╚═════╝ ╚═╝  ╚═╝ ╚═════╝  ╚══╝╚══╝       ╚═╝╚══════╝╚═╝  ╚═╝ 
                                        ╚╗ @mrgrow2k 2019-2020 ╔╝

EOF
 echo -e "${BLUE}****************************************************************${NC}"
 echo -e "${WHITE}${NC}Multi Bash Script Creaated by ${GREEN}MrGrow2k${GREEN} ${WHITE}Main Menu  "
 echo -e "${BLUE}****************************************************************${NC}"
 echo ""
 echo -e "${GREEN}=> 1:${NC}${FgLtYellow} Install 1 or more masternode(s)${NC}"
 echo -e "${GREEN}=> 2:${NC}${FgLtYellow} Resync Nodes that are out of sync${NC}"
 echo -e "${GREEN}=> 3:${NC}${FgLtYellow} Check if node is synced${NC}"
 echo -e "${GREEN}=> 4:${NC}${FgLtYellow} Restart node if no param restart all${NC}"
 echo -e "${GREEN}=> 5:${NC}${FgLtYellow} Stop node if no param stop all${NC}"
 echo -e "${GREEN}=> 6:${NC}${FgLtYellow} Check node status if no param check all${NC}"
 echo -e "${GREEN}=> 7:${NC}${FgLtYellow} Resync specific node (useful if node is stopped)${NC}"
 echo -e "${GREEN}=> 8:${NC}${FgLtYellow} Calculate free memory and cpu for new nodes${NC}"
 echo -e "${GREEN}=> 9:${NC}${NC}${FgLtYellow} Quit and get me out of here${NC}"
 echo -e "${BLUE}****************************************************************${NC}"
}

function mainmenu2 {
#PS3='Please enter your choice: '
shouldloop=true;
while $shouldloop; do
clear
mainmenu
read -rp "* Please select your choice: " opt

    case $opt in
         "1")
            echo "* Lets do a masternode!";
  domasternodes
            read -rp "* Press any key to return to main menu" pause
      ;;
        "2")
            echo "* Resync Nodes that are out of sync!";
  check_resync_all
            read -rp "* Press any key to return to main menu" pause
      ;;
        "3")
            echo "* Check if node is synced";
  check_nodes_sync
            read -rp "* Press any key to return to main menu" pause
      ;;
        "4")
            echo "* Restart node if no param restart all";
  restart_nodes
            read -rp "* Press any key to return to main menu" pause
            ;;
        "5")
            echo "* Stop node if no param stop all";
  stop_nodes
            read -rp "* Press any key to return to main menu" pause
            ;;
        "6")
            echo "* Check node status if no param check all";
  check_nodes_status
            read -rp "* Press any key to return to main menu" pause
            ;;
        "7")
            echo "* Resync specific node (useful if node is stopped)";
  resync_specific
            read -rp "* Press any key to return to main menu" pause
            ;;
        "8")
            echo "* Calculate free memory and cpu for new nodes";
  memory_cpu_sysinfo
            read -rp "* Press any key to return to main menu" pause
            ;;

        "9")
      clear    
      echo "* Returning you to the shell";
  shouldloop=false;
  break
  exit 0
            ;;
   "jump")
  echo -e ""
        read -rp "* Jump to what function?: " jump;
        $jump
  read -rp "* press any key to continue" pause;
            ;;
        *) echo "* invalid option $REPLY";;
    esac
done
}

function domasternodes() {
clear
checks
prepare_system
install_binaries

setup_node
}

function setup_node() {
  get_ip
  configure_nodes
  enable_firewall
  important_information_multi
read -rp "${GREEN}* Press any key to continue${NC}" pause
}


#Main Screen
mainmenu2




