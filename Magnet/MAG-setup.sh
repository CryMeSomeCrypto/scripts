#/bin/bash

cd ~
echo "****************************************************************************"
echo "* Ubuntu 17.10 is the recommended opearting system for this install.       *"
echo "*                                                                          *"
echo "* This script will install and configure your Magnet  masternodes.  *"
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
sudo apt-get install build-essential libtool automake autotools-dev autoconf pkg-config libssl-dev libgmp3-dev libevent-dev bsdmainutils -y
sudo apt-get install libboost-all-dev -y
sudo add-apt-repository ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install libdb4.8-dev libdb4.8++-dev -y
sudo apt-get install libminiupnpc-dev -y
sudo apt-get install unrar -y
sudo apt-get upgrade -y

# INSTALLING THE DAEMON:
git clone https://github.com/magnetwork/magnet.git
cd magnet
chmod +x src/leveldb/build_detect_platform
chmod +x src/secp256k1/autogen.sh
cd src/leveldb
make libleveldb.a libmemenv.a
cd ..
make -f makefile.unix && strip magnetd

  # sudo mv  magnet/bin/* /usr/bin
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
  echo "Enter port for node $ALIAS(i.E. 17177)"
  read PORT

  echo ""
  echo "Enter masternode private key for node $ALIAS"
  read PRIVKEY

  echo ""
  echo "Enter RPC Port (Any valid free port: i.E. 17179)"
  read RPCPORT

  ALIAS=${ALIAS,,}
  CONF_DIR=~/.magnet_$ALIAS

  # Create scripts
  echo '#!/bin/bash' > ~/bin/magnetd_$ALIAS.sh
  echo "magnetd -daemon -conf=$CONF_DIR/magnet.conf -datadir=$CONF_DIR "'$*' >> ~/bin/magnetd_$ALIAS.sh
  echo '#!/bin/bash' > ~/bin/magnet-cli_$ALIAS.sh
  echo "magnet-cli -conf=$CONF_DIR/magnet.conf -datadir=$CONF_DIR "'$*' >> ~/bin/magnet-cli_$ALIAS.sh
  echo '#!/bin/bash' > ~/bin/magnet-tx_$ALIAS.sh
  echo "magnet-tx -conf=$CONF_DIR/magnet.conf -datadir=$CONF_DIR "'$*' >> ~/bin/magnet-tx_$ALIAS.sh
  chmod 755 ~/bin/magnet*.sh

  mkdir -p $CONF_DIR
  echo "rpcuser=user"`shuf -i 100000-10000000 -n 1` >> magnet.conf_TEMP
  echo "rpcpassword=pass"`shuf -i 100000-10000000 -n 1` >> magnet.conf_TEMP
  echo "rpcallowip=127.0.0.1" >> magnet.conf_TEMP
  echo "rpcport=$RPCPORT" >> magnet.conf_TEMP
  echo "listen=1" >> magnet.conf_TEMP
  echo "server=1" >> magnet.conf_TEMP
  echo "daemon=1" >> magnet.conf_TEMP
  echo "logtimestamps=1" >> magnet.conf_TEMP
  echo "maxconnections=256" >> magnet.conf_TEMP
  echo "masternode=1" >> magnet.conf_TEMP
  echo "" >> magnet.conf_TEMP

  echo "addnode=addnode=35.195.167.40" >> magnet.conf_TEMP
  echo "addnode=addnode=35.199.188.194" >> magnet.conf_TEMP
  echo "addnode=addnode=104.196.155.39" >> magnet.conf_TEMP
  echo "addnode=addnode=35.197.228.109" >> magnet.conf_TEMP
  echo "addnode=addnode=35.198.35.45" >> magnet.conf_TEMP
  echo "addnode=addnode=35.197.145.93" >> magnet.conf_TEMP

  echo "" >> magnet.conf_TEMP
  echo "port=$PORT" >> magnet.conf_TEMP
  echo "masternodeaddress=$IP:$PORT" >> magnet.conf_TEMP
  echo "masternodeprivkey=$PRIVKEY" >> magnet.conf_TEMP
  sudo ufw allow $PORT/tcp

  mv magnet.conf_TEMP $CONF_DIR/magnet.conf

  sh ~/bin/magnetd_$ALIAS.sh
done
