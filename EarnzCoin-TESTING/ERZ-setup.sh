#/bin/bash

cd ~
echo "****************************************************************************"
echo "* Ubuntu 14.04 is the recommended opearting system for this install.       *"
echo "*                                                                          *"
echo "* This script will install and configure your EarnzCoin  masternodes.  *"
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
  sudo apt-get update -y
  sudo apt-get upgrade -y
  sudo apt-get dist-upgrade -y
  sudo apt-get install nano htop git -y

  sudo apt-get install build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils software-properties-common -y

  apt-get install -y libminiupnpc-dev libdb++-dev libdb-dev libcrypto++-dev libqrencode-dev libboost-all-dev build-essential libboost-system-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libssl-dev libdb++-dev libssl-dev ufw git software-properties-common

  sudo apt-get install libzmq3-dev libminiupnpc-dev libssl-dev libevent-dev -y

  sudo add-apt-repository ppa:bitcoin/bitcoin

  sudo apt-get install libdb4.8-dev libdb4.8++-dev -y

  sudo apt-get install libdb5.3-dev libdb5.3++-dev build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils git libboost-all-dev libminiupnpc-dev libqt5gui5 libqt5core5a libqt5webkit5-dev libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler libqrencode-dev libgmp3-dev git -y


  git clone https://github.com/Frenzel1337/EarnzCoin

  cd EarnzCoin/src/leveldb/
  chmod +x build_detect_platform
  make libleveldb.a libmemenv.a

  cd ..
  make -f makefile.unix

  # dd if=/dev/zero of=/var/swap.img bs=1024k count=1000
  # mkswap /var/swap.img
  # swapon /var/swap.img

  # sudo mv  EarnzCoin/bin/* /usr/bitcoin

  cd

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
  echo "Enter port for node $ALIAS(i.E. 7748)"
  read PORT

  echo ""
  echo "Enter masternode private key for node $ALIAS"
  read PRIVKEY

  echo ""
  echo "Enter RPC Port (Any valid free port: i.E. 27261)"
  read RPCPORT

  ALIAS=${ALIAS,,}
  CONF_DIR=~/.EarnzCoin_$ALIAS

  # Create scripts
  echo '#!/bin/bash' > ~/bin/EarnzCoind_$ALIAS.sh
  echo "EarnzCoind -daemon -conf=$CONF_DIR/EarnzCoin.conf -datadir=$CONF_DIR "'$*' >> ~/bin/EarnzCoind_$ALIAS.sh
  echo '#!/bin/bash' > ~/bin/EarnzCoin-cli_$ALIAS.sh
  echo "EarnzCoin-cli -conf=$CONF_DIR/EarnzCoin.conf -datadir=$CONF_DIR "'$*' >> ~/bin/EarnzCoin-cli_$ALIAS.sh
  echo '#!/bin/bash' > ~/bin/EarnzCoin-tx_$ALIAS.sh
  echo "EarnzCoin-tx -conf=$CONF_DIR/EarnzCoin.conf -datadir=$CONF_DIR "'$*' >> ~/bin/EarnzCoin-tx_$ALIAS.sh
  chmod 755 ~/bin/EarnzCoin*.sh

  mkdir -p $CONF_DIR
  echo "rpcuser=user"`shuf -i 100000-10000000 -n 1` >> EarnzCoin.conf_TEMP
  echo "rpcpassword=pass"`shuf -i 100000-10000000 -n 1` >> EarnzCoin.conf_TEMP
  echo "rpcallowip=127.0.0.1" >> EarnzCoin.conf_TEMP
  echo "rpcport=$RPCPORT" >> EarnzCoin.conf_TEMP
  echo "listen=1" >> EarnzCoin.conf_TEMP
  echo "server=1" >> EarnzCoin.conf_TEMP
  echo "daemon=1" >> EarnzCoin.conf_TEMP
  echo "logtimestamps=1" >> EarnzCoin.conf_TEMP
  echo "maxconnections=256" >> EarnzCoin.conf_TEMP
  echo "masternode=1" >> EarnzCoin.conf_TEMP
  echo "" >> EarnzCoin.conf_TEMP

  #echo "addnode=addnode=51.15.198.252" >> EarnzCoin.conf_TEMP
  #echo "addnode=addnode=51.15.206.123" >> EarnzCoin.conf_TEMP
  #echo "addnode=addnode=51.15.66.234" >> EarnzCoin.conf_TEMP
  #echo "addnode=addnode=51.15.86.224" >> EarnzCoin.conf_TEMP
  #echo "addnode=addnode=51.15.89.27" >> EarnzCoin.conf_TEMP
  #echo "addnode=addnode=51.15.57.193" >> EarnzCoin.conf_TEMP
  #echo "addnode=addnode=134.255.232.212" >> EarnzCoin.conf_TEMP
  #echo "addnode=addnode=185.239.238.237" >> EarnzCoin.conf_TEMP
  #echo "addnode=addnode=185.239.238.240" >> EarnzCoin.conf_TEMP
  #echo "addnode=addnode=134.255.232.212" >> EarnzCoin.conf_TEMP
  #echo "addnode=addnode=207.148.26.77" >> EarnzCoin.conf_TEMP
  #echo "addnode=addnode=207.148.19.239" >> EarnzCoin.conf_TEMP
  #echo "addnode=addnode=108.61.103.123" >> EarnzCoin.conf_TEMP
  #echo "addnode=addnode=185.239.238.89" >> EarnzCoin.conf_TEMP
  #echo "addnode=addnode=185.239.238.92" >> EarnzCoin.conf_TEMP

  echo "" >> EarnzCoin.conf_TEMP
  echo "port=$PORT" >> EarnzCoin.conf_TEMP
  echo "masternodeaddress=$IP:$PORT" >> EarnzCoin.conf_TEMP
  echo "masternodeprivkey=$PRIVKEY" >> EarnzCoin.conf_TEMP
  sudo ufw allow $PORT/tcp

  mv EarnzCoin.conf_TEMP $CONF_DIR/EarnzCoin.conf

  sh ~/bin/EarnzCoind_$ALIAS.sh
done
