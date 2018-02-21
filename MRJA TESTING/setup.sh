#/bin/bash

cd ~
echo "****************************************************************************"
echo "* Ubuntu 16.04 is the recommended opearting system for this install.       *"
echo "*                                                                          *"
echo "* This script will install and configure your GanjaProject  masternodes.  *"
echo "****************************************************************************"
echo && echo && echo
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!                                                 !"
echo "! Make sure you double check before hitting enter !"
echo "!                                                 !"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo && echo && echo

echo "Do you want to install all needed dependencies (no if you did it before)? [y/n]"
read DOSETUP

if [[ $DOSETUP =~ "y" ]] ; then
apt-get update
apt-get -y upgrade
apt-get -y install libwww-perl build-essential libtool automake autotools-dev autoconf pkg-config libssl-dev libgmp3-dev libevent-dev bsdmainutils libdb++-dev libminiupnpc-dev libboost-all-dev libqrencode-dev unzip
fallocate -l 4G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo "vm.swappiness=10" >> /etc/sysctl.conf
echo "/swapfile none swap sw 0 0" >> /etc/fstab



mkdir -p /root/dev
cd /root/dev

git clone https://github.com/legends420/GCFORK.git
cd /root/dev/GCFORK/src
make -f makefile.unix

  sudo apt-get install -y ufw
  sudo ufw allow ssh/tcp
  sudo ufw limit ssh/tcp
  sudo ufw logging on
  echo "y" | sudo ufw enable
  sudo ufw status

  mkdir -p ~/bin
  echo 'export PATH=~/bin:$PATH' > ~/.bash_aliases
  source ~/.bashrc
fi

## Setup conf
mkdir -p ~/bin
echo ""
echo "Configure your masternodes now!"
echo "Type the IP of this server, followed by [ENTER]:"
read IP

MNCOUNT=""
re='^[0-9]+$'
while ! [[ $MNCOUNT =~ $re ]] ; do
   echo ""
   echo "How many nodes do you want to create on this server?, followed by [ENTER]:"
   read MNCOUNT
done

for i in `seq 1 1 $MNCOUNT`; do
  echo ""
  echo "Enter alias for new node"
  read ALIAS

  echo ""
  echo "Enter port for node $ALIAS(i.e. 10559)"
  read PORT

  echo ""
  echo "Enter masternode private key for node $ALIAS"
  read PRIVKEY

  echo ""
  echo "Enter RPC Port (Any valid free port: i.E. 10560)"
  read RPCPORT

  echo ""
  echo "Enter TX Index"
  read TX

  ALIAS=${ALIAS,,}
  CONF_DIR=~/.MRJA_$ALIAS

  # Create scripts
  echo '#!/bin/bash' > ~/bin/Ganjad_$ALIAS.sh
  echo "Ganjad -daemon -conf=$CONF_DIR/GanjaProject.conf -datadir=$CONF_DIR "'$*' >> ~/bin/Ganjad_$ALIAS.sh
  echo '#!/bin/bash' > ~/bin/Ganja-cli_$ALIAS.sh
  echo "Ganja-cli -conf=$CONF_DIR/GanjaProject.conf -datadir=$CONF_DIR "'$*' >> ~/bin/Ganja-cli_$ALIAS.sh
  echo '#!/bin/bash' > ~/bin/Ganja-tx_$ALIAS.sh
  echo "Ganja-tx -conf=$CONF_DIR/GanjaProject.conf -datadir=$CONF_DIR "'$*' >> ~/bin/Ganja-tx_$ALIAS.sh
  chmod 755 ~/bin/GanjaProject*.sh

  mkdir -p $CONF_DIR
  echo "rpcuser=user"`shuf -i 100000-10000000 -n 1` >> GanjaProject.conf_TEMP
  echo "rpcpassword=pass"`shuf -i 100000-10000000 -n 1` >> GanjaProject.conf_TEMP
  echo "rpcallowip=127.0.0.1" >> GanjaProject.conf_TEMP
  echo "rpcport=$RPCPORT" >> GanjaProject.conf_TEMP
  echo "port=10559" >> GanjaProject.conf_TEMP
  echo "externalip=$IP" >> GanjaProject.conf_TEMP
  echo "listen=1" >> GanjaProject.conf_TEMP
  echo "server=1" >> GanjaProject.conf_TEMP
  echo "daemon=1" >> GanjaProject.conf_TEMP
  echo "txindex=$tx" >>GanjaProject.conf_TEMP
  echo "logtimestamps=1" >> GanjaProject.conf_TEMP
  echo "maxconnections=500" >> GanjaProject.conf_TEMP
  echo "masternode=1" >> GanjaProject.conf_TEMP
  echo "mnconflock=1" >> GanjaProject.conf_TEMP
  echo "" >> GanjaProject.conf_TEMP

  #echo "addnode=addnode=51.15.198.252" >> GanjaProject.conf_TEMP
  #echo "addnode=addnode=51.15.206.123" >> GanjaProject.conf_TEMP
  #echo "addnode=addnode=51.15.66.234" >> GanjaProject.conf_TEMP
  #echo "addnode=addnode=51.15.86.224" >> GanjaProject.conf_TEMP
  #echo "addnode=addnode=51.15.89.27" >> GanjaProject.conf_TEMP
  #echo "addnode=addnode=51.15.57.193" >> GanjaProject.conf_TEMP
  #echo "addnode=addnode=134.255.232.212" >> GanjaProject.conf_TEMP
  #echo "addnode=addnode=185.239.238.237" >> GanjaProject.conf_TEMP
  #cho "addnode=addnode=185.239.238.240" >> GanjaProject.conf_TEMP
  #echo "addnode=addnode=134.255.232.212" >> GanjaProject.conf_TEMP
  #echo "addnode=addnode=207.148.26.77" >> GanjaProject.conf_TEMP
  #echo "addnode=addnode=207.148.19.239" >> GanjaProject.conf_TEMP
  #echo "addnode=addnode=108.61.103.123" >> GanjaProject.conf_TEMP
  #echo "addnode=addnode=185.239.238.89" >> GanjaProject.conf_TEMP
  #echo "addnode=addnode=185.239.238.92" >> GanjaProject.conf_TEMP

  echo "" >> GanjaProject.conf_TEMP
  echo "port=$PORT" >> GanjaProject.conf_TEMP
  echo "masternodeaddr=$IP:$PORT" >> GanjaProject.conf_TEMP
  echo "masternodeprivkey=$PRIVKEY" >> GanjaProject.conf_TEMP
  echo "stake=0" >> GanjaProject.conf_TEMP
  echo "staking=0" >> GanjaProject.conf_TEMP
  echo "seednode=138.197.44.71" >> GanjaProject.conf_TEMP
  sudo ufw allow $PORT/tcp

  mv GanjaProject.conf_TEMP $CONF_DIR/GanjaProject.conf

  sh ~/bin/Ganjad_$ALIAS.sh
done
