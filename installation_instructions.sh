#!/bin/bash

set -e
set -u
set -o pipefail

# installation instructions for screenforbio

# I install all github repositories (repos) in ~/src
mkdir ~/src

# go to https://drive5.com/usearch/
# register and download the 32-bit usearch11 binary for your OS
# install usearch binary downloaded from https://drive5.com/usearch/download.html
cd ~/Downloads
mv ~/Downloads/usearch11.0.667_i86osx32 /usr/local/bin
cd /usr/local/bin
ln -s usearch11.0.667_i86osx32 usearch11  # make symbolic link (symlink)
chmod 755 usearch11
usearch11 # should return something like the following
# usearch v11.0.667_i86osx32, 4.0Gb RAM (17.2Gb total), 8 cores
# (C) Copyright 2013-18 Robert C. Edgar, all rights reserved.
# https://drive5.com/usearch
#
# License: dougwyu@mac.com

# download and install usearch 8.1, also from https://drive5.com/usearch/download.html
mv ~/Downloads/v8.1.1861_i86osx32 /usr/local/bin
cd /usr/local/bin
ln -s v8.1.1861_i86osx32 usearch  # make symbolic link (symlink)
chmod 755 usearch
usearch # should return something like the following
# usearch v8.1.1861_i86osx32, 4.0Gb RAM (17.2Gb total), 8 cores
# (C) Copyright 2013-15 Robert C. Edgar, all rights reserved.
# http://drive5.com/usearch
#
# License: dougwyu@mac.com

## Homebrew for macOS
# go to http://brew.sh and follow the instructions for installing Homebrew on macOS

## after Homebrew or Linuxbrew  is installed, run these brew installations
brew tap brewsci/bio # a "tap" is a source of "installation formulae" of specialist software, here, bioinformatics
brew tap tseemann/bio
brew install seqtk # https://github.com/lh3/seqtk
brew install coreutils # cut, join, sort, tr
brew install gnu-sed
brew install grep # gnu-grep
brew install gawk
brew install brewsci/bio/seqkit
brew install perl
brew install python@3
brew install python@2

#### install buddysuite, which requires python3
# https://github.com/biologyguy/BuddySuite
pip3 install buddysuite # installs a bunch of software
buddysuite -setup
seqbuddy -h

# tabtk
cd ~/src/
git clone https://github.com/lh3/tabtk
cd tabtk/
make
mv ./tabtk /usr/local/bin

# sativa



#### https://github.com/alexcrampton-platt/screenforbio-mbc
# screenforbio
# install linuxify to use GNU versions of sed, awk, and grep over the macOS versions. GNU grep, GNU sed, and GNU awk are installed with homebrew, but they are given different names (e.g. gsed, gawk, ggrep). However, the scripts use 'sed', 'grep', and 'awk'. To prioritise GNU versions, i use 'Linuxify'
# 1. install and run linuxify # https://github.com/fabiomaia/linuxify
     cd ~/src
     git clone https://github.com/fabiomaia/linuxify.git
     cd linuxify/
     ./linuxify install # to install all the GNU versions
          # cd ~/src/linuxify/;  ./linuxify uninstall # to remove all the GNU versions and the pathname changes
          # manually remove '. ~/.linuxify' from my ~/.bashrc file
     ls -al ~/src/linuxify/ # should see the file .linuxify
     cp ~/src/linuxify/.linuxify ~/ # cp to root directory
# 2. to 'linuxify' a terminal session:  run the following at the beginning of a script or a session.
     . ~/.linuxify; awk; which sed; which grep
          # awk # should return help page for gawk
          # which sed # should show /usr/local/opt/gnu-sed/libexec/gnubin/sed
          # which grep # should return: '/usr/local/opt/grep/libexec/gnubin/grep'
# 3. OPTIONAL if i want to run linuxify automatically with each new shell
     # add this to my ~/.bashrc
          . ~/.linuxify
     # then add this to my .bash_profile
          if [ -f ~/.bashrc ]; then
              source ~/.bashrc
          fi
# https://apple.stackexchange.com/questions/51036/what-is-the-difference-between-bash-profile-and-bashrc

# Then i forked https://github.com/alexcrampton-platt/screenforbio-mbc to https://github.com/dougwyu/screenforbio-mbc-dougwyu
# this is what i will use to run PROTAX

# Entrez Direct
# https://www.ncbi.nlm.nih.gov/books/NBK179288/
# This downloads several scripts into an "edirect" folder in the user's home directory. The setup.sh script then downloads any missing Perl modules, and may print an additional command for updating the PATH environment variable in the user's configuration file. Copy that command, if present, and paste it into the terminal window to complete the installation process.
cd ~
/bin/bash
perl -MNet::FTP -e \
  '$ftp = new Net::FTP("ftp.ncbi.nlm.nih.gov", Passive => 1);
   $ftp->login; $ftp->binary;
   $ftp->get("/entrez/entrezdirect/edirect.tar.gz");'
gunzip -c edirect.tar.gz | tar xf -
rm edirect.tar.gz
builtin exit
export PATH=${PATH}:$HOME/edirect >& /dev/null || setenv PATH "${PATH}:$HOME/edirect"
./edirect/setup.sh # takes a long time

cd ~
/bin/bash
perl -MNet::FTP -e \
  '$ftp = new Net::FTP("ftp.ncbi.nlm.nih.gov", Passive => 1);
   $ftp->login; $ftp->binary;
   $ftp->get("/entrez/entrezdirect/edirect.tar.gz");'
gunzip -c edirect.tar.gz | tar xf -
rm edirect.tar.gz
builtin exit
export PATH=${PATH}:$HOME/edirect >& /dev/null || setenv PATH "${PATH}:$HOME/edirect"
./edirect/setup.sh # takes a long time

# In order to complete the configuration process, please execute the following:

echo "source ~/.bash_profile" >> $HOME/.bashrc # prob not needed, since =.bash_profile is sourced with every new window
mv ~/edirect ~/src/edirect
echo "export PATH=\${PATH}:/Users/Negorashi2011/src/edirect" >> $HOME/.bash_profile

# test commands
esearch -h
elink -h
efilter -h
efetch -h
