#!/usr/bin/env bash
#Prereq  
#ubuntu 16-18
# Ensure virtulization is enabled in bios
#if using a VM ensure VT-x/AMD-V is enabled for VM
# At least 3 GB of free RAM, so approx 4 GB with 1 GB for OS and 4 cores

#Packages:
echo "Getting base set of packages"
sudo apt update
sudo apt -y install libpcap-dev libreadline-dev qemu qemu-kvm openvswitch-switch build-essential unzip genisoimage debootstrap syslinux extlinux bird ntpdate curl git tmux net-tools bison

#Git some helper tools ((not required but makes dealing with multiple go versions easier) 
echo "Installing GVM"
bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
source ~/.gvm/scripts/gvm
gvm install go1.4 -B
gvm use go1.4
export GOROOT_BOOTSTRAP=$GOROOT

#go 1.12 to build minimega
echo "Installing go 1.12"
gvm install go1.12

#go 1.17 to build phenix 
echo "Installing go 1.17"
gvm install go1.17

#Phenix web server dependencies

# NVM Manager ( not required but makes dealing with npm easier)
echo "Installing NVM"
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Install node js and npm
echo "Installing node js and npm"
nvm install node
nvm install --lts

# Install yarn
echo "Installing yarn"
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -;
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list;
sudo apt update;
sudo apt install -y --no-install-recommends yarn

# Install google proto buffers
echo "Installing Google proto buffers"
PROTOC_ZIP=protoc-3.7.1-linux-x86_64.zip
curl -OL https://github.com/protocolbuffers/protobuf/releases/download/v3.7.1/$PROTOC_ZIP
sudo unzip -o $PROTOC_ZIP -d /usr/local bin/protoc
sudo unzip -o $PROTOC_ZIP -d /usr/local 'include/*'
rm -f $PROTOC_ZIP

#setup image directory
sudo mkdir -p /phenix/images

# get the images (copy paste into a terminal window) 
echo "Downloading experiment images"
cd /tmp
fileId=1s9YC8pzdISDbmD1Zs5TwPVa5NLfrWjsu
fileName=images.tar.gz
curl -sc /tmp/cookie "https://drive.google.com/uc?export=download&id=${fileId}" > /dev/null
code="$(awk '/_warning_/ {print $NF}' /tmp/cookie)"  
curl -Lb /tmp/cookie "https://drive.google.com/uc?export=download&confirm=${code}&id=${fileId}" -o ${fileName} 

echo "Unpacking images to /phenix/images"
sudo tar -xzf images.tar.gz -C /phenix/images/

#setup minimega
echo "Setting up minimega"
cd /opt
sudo git clone https://github.com/sandia-minimega/minimega.git
cd minimega;
gvm use go1.12;
./build.bash

#setup phenix
echo "Setting up phenix"
cd /opt
sudo git clone https://github.com/sandia-minimega/phenix.git
cd phenix;
gvm use go1.17;
yarn add sass
make bin/phenix

#setup ovs bridge
sudo ovs-vsctl add-br mega_bridge
sudo ovs-vsctl add-br phenix

#load the topology file,this defines the network and nodes including node configuration   
phenix cfg create ~/phenix-setup/examples/topology.yml --skip-validation --log.error-stderr  
#load the scenario file, this defines a topology and any apps / host meta data  
phenix cfg create ~/phenix-setup/examples/scenario.yml --skip-validation --log.error-stderr  

#used to show file injection see topology  
echo "hello world" > /tmp/blah  

#setup services
cd ~/miniEnv
sudo systemctl enable phenix-web.service
sudo systemctl enable miniweb.service
sudo systemctl enable minimega.service

#start all the services
sudo systemctl start phenix-web

#navigate to host port 3000  
firefox http://localhost:3000 &  


