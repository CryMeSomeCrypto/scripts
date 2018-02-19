#/bin/bash

cd ~
echo "****************************************************************************"
echo "* Ubuntu 16.04 is the recommended opearting system for this install.       *"
echo "*                                                                          *"
echo "* This script will install and configure your SocialSend  masternodes.  *"
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
  sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade
  sudo apt-get install -y pkg-config
  sudo apt-get install automake libdb++-dev build-essential libtool autotools-dev autoconf pkg-config libssl-dev libboost-all-dev libminiupnpc-dev git software-properties-common python-software-properties g++ bsdmainutils libevent-dev -y
  sudo add-apt-repository ppa:bitcoin/bitcoin -y
  sudo apt-get update
  sudo apt-get install libdb4.8-dev libdb4.8++-dev -y

  sudo dd if=/dev/zero of=/swapfile bs=1M count=2000
	sudo mkswap /swapfile
	sudo chown root:root /swapfile
	sudo chmod 0600 /swapfile
	sudo swapon /swapfile

	#make swap permanent
	sudo echo "/swapfile none swap sw 0 0 \n" >> /etc/fstab


  cd ~/
  sudo git clone https://github.com/SocialSend/SocialSend.git

  cd SocialSend #TODO: squash relative path
  sudo chmod +x share/genbuild.sh
  sudo chmod +x autogen.sh
  sudo chmod 755 src/leveldb/build_detect_platform
  ./autogen.sh
  ./configure $1 --disable-tests
  sudo make
  sudo make install

  # sudo mv  send/bin/* /usr/bin
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
  echo "Enter port for node $ALIAS(i.E. 50050)"
  read PORT

  echo ""
  echo "Enter masternode private key for node $ALIAS"
  read PRIVKEY

  echo ""
  echo "Enter RPC Port (Any valid free port: i.E. 50050)"
  read RPCPORT

  ALIAS=${ALIAS,,}
  CONF_DIR=~/.send_$ALIAS

  # Create scripts
  echo '#!/bin/bash' > ~/bin/sendd_$ALIAS.sh
  echo "sendd -daemon -conf=$CONF_DIR/send.conf -datadir=$CONF_DIR "'$*' >> ~/bin/sendd_$ALIAS.sh
  echo '#!/bin/bash' > ~/bin/send-cli_$ALIAS.sh
  echo "send-cli -conf=$CONF_DIR/send.conf -datadir=$CONF_DIR "'$*' >> ~/bin/send-cli_$ALIAS.sh
  echo '#!/bin/bash' > ~/bin/send-tx_$ALIAS.sh
  echo "send-tx -conf=$CONF_DIR/send.conf -datadir=$CONF_DIR "'$*' >> ~/bin/send-tx_$ALIAS.sh
  chmod 755 ~/bin/send*.sh

  mkdir -p $CONF_DIR
  echo "rpcuser=user"`shuf -i 100000-10000000 -n 1` >> send.conf_TEMP
  echo "rpcpassword=pass"`shuf -i 100000-10000000 -n 1` >> send.conf_TEMP
  echo "rpcallowip=127.0.0.1" >> send.conf_TEMP
  echo "rpcport=$RPCPORT" >> send.conf_TEMP
  echo "listen=1" >> send.conf_TEMP
  echo "server=1" >> send.conf_TEMP
  echo "daemon=1" >> send.conf_TEMP
  echo "logtimestamps=1" >> send.conf_TEMP
  echo "maxconnections=256" >> send.conf_TEMP
  echo "masternode=1" >> send.conf_TEMP
  echo "" >> send.conf_TEMP

  #echo "addnode=addnode=51.15.198.252" >> send.conf_TEMP
  #echo "addnode=addnode=51.15.206.123" >> send.conf_TEMP
  #echo "addnode=addnode=51.15.66.234" >> send.conf_TEMP
  #echo "addnode=addnode=51.15.86.224" >> send.conf_TEMP
  #echo "addnode=addnode=51.15.89.27" >> send.conf_TEMP
  #echo "addnode=addnode=51.15.57.193" >> send.conf_TEMP
  #echo "addnode=addnode=134.255.232.212" >> send.conf_TEMP
  #echo "addnode=addnode=185.239.238.237" >> send.conf_TEMP
  #echo "addnode=addnode=185.239.238.240" >> send.conf_TEMP
  #echo "addnode=addnode=134.255.232.212" >> send.conf_TEMP
  #echo "addnode=addnode=207.148.26.77" >> send.conf_TEMP
  #echo "addnode=addnode=207.148.19.239" >> send.conf_TEMP
  #echo "addnode=addnode=108.61.103.123" >> send.conf_TEMP
  #echo "addnode=addnode=185.239.238.89" >> send.conf_TEMP
  #echo "addnode=addnode=185.239.238.92" >> send.conf_TEMP

  echo "" >> send.conf_TEMP
  echo "port=$PORT" >> send.conf_TEMP
  echo "masternodeaddress=$IP:$PORT" >> send.conf_TEMP
  echo "masternodeprivkey=$PRIVKEY" >> send.conf_TEMP
  sudo ufw allow $PORT/tcp

  mv send.conf_TEMP $CONF_DIR/send.conf

  sh ~/bin/sendd_$ALIAS.sh
done
