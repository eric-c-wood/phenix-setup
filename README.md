# phenix-setup
This set of instructions is a modified version from https://gist.github.com/zach-r-long/5935e0daa4cbb4ea4df182a353904812

To setup phenix, follow the steps below:

1) Setup a machine with Ubuntu 18.04 LTS
2) Enable virtualization in the BIOS
3) If using a VM, make sure VT-x/AMD-v and nested virtualization is enabled
4) Have 3 GB RAM free
5) Navigate to the home directory on the Ubuntu 18.04 LTS (e.g. `cd ~`)
6) `sudo apt -y install git`
7) Clone this repository `git clone https://github.com/eric-c-wood/phenix-setup.git`
8) `cd phenix-setup`
9) `source setup.sh`
10) Navigate to the opened firefox browser which should be pointing to localhost:3000
11) Type `admin@foo.com` for the username and `foobar` for the password
  

