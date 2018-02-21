#/bin/bash

cd ~
echo "****************************************************************************"
echo "* Ubuntu 16.04 is the recommended opearting system for this install.       *"
echo "*                                                                          *"
echo "* This script will install and configure your Chaincoin  masternodes.  *"
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
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y install libwww-perl build-essential libtool automake autotools-dev autoconf pkg-config libssl-dev libgmp3-dev libevent-dev bsdmainutils libdb++-dev libminiupnpc-dev libboost-all-dev libqrencode-dev nano htop git bc unzip

#setup swap
fallocate -l 4G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo "vm.swappiness=10" >> /etc/sysctl.conf && echo "/swapfile none swap sw 0 0"

#install GCFORK
rm -r -R GCFORK &> output.log
rm -r -R /root/.MRJA/ &> output.log
git clone https://github.com/legends420/GCFORK.git
cd /root/GCFORK/src
make -f makefile.unix
/root/GCFORK/src/Ganjad &> output.log



# sudo mv  chaincoin/bin/* /usr/bin
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
  echo "Enter port for node $ALIAS(i.E. 11994)"
  read PORT

  echo ""
  echo "Enter masternode private key for node $ALIAS"
  read PRIVKEY

  echo ""
  echo "Enter RPC Port (Any valid free port: i.E. 11995)"
  read RPCPORT

  ALIAS=${ALIAS,,}
  CONF_DIR=~/.chaincoin_$ALIAS

  # Create scripts
  echo '#!/bin/bash' > ~/bin/chaincoind_$ALIAS.sh
  echo "chaincoind -daemon -conf=$CONF_DIR/chaincoin.conf -datadir=$CONF_DIR "'$*' >> ~/bin/chaincoind_$ALIAS.sh
  echo '#!/bin/bash' > ~/bin/chaincoin-cli_$ALIAS.sh
  echo "chaincoin-cli -conf=$CONF_DIR/chaincoin.conf -datadir=$CONF_DIR "'$*' >> ~/bin/chaincoin-cli_$ALIAS.sh
  echo '#!/bin/bash' > ~/bin/chaincoin-tx_$ALIAS.sh
  echo "chaincoin-tx -conf=$CONF_DIR/chaincoin.conf -datadir=$CONF_DIR "'$*' >> ~/bin/chaincoin-tx_$ALIAS.sh
  chmod 755 ~/bin/chaincoin*.sh

  mkdir -p $CONF_DIR
  echo "rpcuser=user"`shuf -i 100000-10000000 -n 1` >> chaincoin.conf_TEMP
  echo "rpcpassword=pass"`shuf -i 100000-10000000 -n 1` >> chaincoin.conf_TEMP
  echo "rpcallowip=127.0.0.1" >> chaincoin.conf_TEMP
  echo "rpcport=$RPCPORT" >> chaincoin.conf_TEMP
  echo "listen=1" >> chaincoin.conf_TEMP
  echo "server=1" >> chaincoin.conf_TEMP
  echo "daemon=1" >> chaincoin.conf_TEMP
  echo "logtimestamps=1" >> chaincoin.conf_TEMP
  echo "maxconnections=256" >> chaincoin.conf_TEMP
  echo "masternode=1" >> chaincoin.conf_TEMP
  echo "" >> chaincoin.conf_TEMP

  #echo "addnode=addnode=51.15.198.252" >> chaincoin.conf_TEMP
  #echo "addnode=addnode=51.15.206.123" >> chaincoin.conf_TEMP
  #echo "addnode=addnode=51.15.66.234" >> chaincoin.conf_TEMP
  #echo "addnode=addnode=51.15.86.224" >> chaincoin.conf_TEMP
  #echo "addnode=addnode=51.15.89.27" >> chaincoin.conf_TEMP
  #echo "addnode=addnode=51.15.57.193" >> chaincoin.conf_TEMP
  #echo "addnode=addnode=134.255.232.212" >> chaincoin.conf_TEMP
  #echo "addnode=addnode=185.239.238.237" >> chaincoin.conf_TEMP
  #echo "addnode=addnode=185.239.238.240" >> chaincoin.conf_TEMP
  #echo "addnode=addnode=134.255.232.212" >> chaincoin.conf_TEMP
  #echo "addnode=addnode=207.148.26.77" >> chaincoin.conf_TEMP
  #echo "addnode=addnode=207.148.19.239" >> chaincoin.conf_TEMP
  #echo "addnode=addnode=108.61.103.123" >> chaincoin.conf_TEMP
  #echo "addnode=addnode=185.239.238.89" >> chaincoin.conf_TEMP
  #echo "addnode=addnode=185.239.238.92" >> chaincoin.conf_TEMP

  echo "" >> chaincoin.conf_TEMP
  echo "port=$PORT" >> chaincoin.conf_TEMP
  echo "masternodeaddress=$IP:$PORT" >> chaincoin.conf_TEMP
  echo "masternodeprivkey=$PRIVKEY" >> chaincoin.conf_TEMP
  sudo ufw allow $PORT/tcp

  mv chaincoin.conf_TEMP $CONF_DIR/chaincoin.conf

  sh ~/bin/chaincoind_$ALIAS.sh
done
