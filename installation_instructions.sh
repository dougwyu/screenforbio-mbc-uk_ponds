#!/bin/bash

set -e
set -u
set -o pipefail

# installation instructions for screenforbio

## Homebrew for macOS
# go to http://brew.sh and follow the instructions for installing Homebrew on macOS

## after Homebrew or Linuxbrew  is installed, run these brew installations
brew tap brewsci/bio # a "tap" is a source of "installation formulae" of specialist software, here, bioinformatics
brew tap tseemann/bio
brew install seqtk # https://github.com/lh3/seqtk
brew install coreutils # cut, join, 
brew install gnu-sed

# awk, cut, grep, join, sed, sort, tr seqbuddy seqkit  tabtk



#### https://github.com/alexcrampton-platt/screenforbio-mbc
# screenforbio
# to run this, i need to change my macOS setup to use GNU versions of unix utilities and *also* to prioritise GNU grep, sed, and awk over the macOS versions. To do this, i need to install GNU grep, GNU sed, and GNU awk. These are installed with homebrew, but they are given different names (e.g. gsed, gawk). I need 'sed' to invoke 'gsed'. To do this, i do something that's probably over the top, but it seems to work.
# 1. install and run linuxify # https://github.com/fabiomaia/linuxify
     cd ~/src
     git clone https://github.com/fabiomaia/linuxify.git
     cd linuxify/
     ./linuxify install # to install all the GNU versions
          # ./linuxify uninstall # to remove all the GNU versions and the pathname changes
          # manually remove '. ~/.linuxify' from my ~/.bashrc file
# 2. to linuxify a session:  run the following at the beginning of a script or a session.
     . ~/.linuxify; which sed; awk; which grep
          which sed # should show /usr/local/opt/gnu-sed/libexec/gnubin/sed
          awk # should return help page for gawk
          which grep # should return: '/usr/local/opt/grep/libexec/gnubin/grep'
# 3. OPTIONAL if i want to run linuxify automatically with each new shell
     # add this to my ~/.bashrc
          . ~/.linuxify'
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

# In order to complete the configuration process, please execute the following:

# echo "source ~/.bash_profile" >> $HOME/.bashrc # prob not needed, since =.bash_profile is sourced with every new window
# mv ~/edirect ~/src/edirect
echo "export PATH=\${PATH}:/Users/Negorashi2011/src/edirect" >> $HOME/.bash_profile

# test commands
esearch -h
elink -h
efilter -h
efetch -h
