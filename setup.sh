#!/usr/bin/env bash
#Prereq  
#ubuntu 20.04
# Ensure virtulization is enabled in bios
#if using a VM ensure VT-x/AMD-V is enabled for VM
# At least 3 GB of free RAM, so approx 4 GB with 1 GB for OS and 4 cores

#Packages:
echo "Getting base set of packages"
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt -y install git libpcap-dev libreadline-dev qemu qemu-kvm openvswitch-switch build-essential unzip genisoimage debootstrap syslinux extlinux bird ntpdate curl tmux net-tools bison

#Git some helper tools ((not required but makes dealing with multiple go versions easier) 
echo "Installing GVM"
bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
source ~/.gvm/scripts/gvm
gvm install go1.4 -B
gvm use go1.4
export GOROOT_BOOTSTRAP=$GOROOT

#go 1.17.13 to build/compile go 1.21.5
echo "Installing go 1.17.13"
gvm install go1.17.13
gvm use go1.17.13
export GOROOT_BOOTSTRAP=$GOROOT

#go 1.21.5 to build phenix/minimega 
echo "Installing go 1.21.5"
gvm install go1.21.5

#Phenix web server dependencies

# NVM Manager ( not required but makes dealing with npm easier)
echo "Installing NVM"
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Install node js and npm
echo "Installing node js and npm"
nvm install 14.21.3

# Install yarn
echo "Installing yarn"
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -;
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list;
sudo apt update;
sudo apt install -y --no-install-recommends yarn

# Install google proto buffers
echo "Installing Google proto buffers"
PROTOC_ZIP=protoc-3.14.0-linux-x86_64.zip
curl -OL https://github.com/protocolbuffers/protobuf/releases/download/v3.14.0/$PROTOC_ZIP
sudo unzip -o $PROTOC_ZIP -d /usr/local bin/protoc
sudo unzip -o $PROTOC_ZIP -d /usr/local 'include/*'
sudo chmod 755 /usr/local/bin/protoc
sudo chmod -R 755 /usr/local/include/google
rm -f $PROTOC_ZIP

#setup image directory
sudo mkdir -p /phenix/images
sudo chown -R $USER:$USER /phenix/images

#setup minimega
echo "Setting up minimega"
cd ~
git clone https://github.com/sandia-minimega/minimega.git
sudo mv ~/minimega /opt/minimega
sudo chown -R $USER:$USER /opt/minimega
cp ~/phenix-setup/mini*.service /opt/minimega
sed -i s/MM_CONTEXT=minimega/MM_CONTEXT=$(hostname -s)/ /opt/minimega/minimega.service
cd /opt/minimega/scripts;
gvm use go1.21.5;
./build.bash

#setup phenix
echo "Setting up phenix"
cd ~
git clone https://github.com/sandialabs/sceptre-phenix.git
sudo mv ~/sceptre-phenix /opt/phenix
sudo chown -R $USER:$USER /opt/phenix
cp ~/phenix-setup/phenix*.service /opt/phenix
echo "VUE_APP_AUTH=enabled" > /opt/phenix/src/js/.env.local
cd /opt/phenix;
gvm use go1.21.5;
make bin/phenix

#setup ovs bridge
sudo ovs-vsctl add-br mega_bridge
sudo ovs-vsctl add-br phenix

#setup services
sudo systemctl enable /opt/phenix/phenix-web.service
sudo systemctl enable /opt/minimega/miniweb.service
sudo systemctl enable /opt/minimega/minimega.service

#start all the services
sudo systemctl start phenix-web

#navigate to host port 3000  
firefox http://localhost:3000 &  


