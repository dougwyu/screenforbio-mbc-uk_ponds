#!/bin/bash

set -e
set -u
set -o pipefail

# installation instructions for screenforbio

# I install all github repositories (repos) in ~/src
mkdir ~/src

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


#### https://github.com/alexcrampton-platt/screenforbio-mbc
# screenforbio
# install linuxify to use GNU versions of sed, awk, and grep over the macOS versions. GNU grep, GNU sed, and GNU awk are installed with homebrew, but they are given different names (e.g. gsed, gawk, ggrep). However, the scripts use 'sed', 'grep', and 'awk'. To prioritise GNU versions, i use 'Linuxify'
# 1. install and run linuxify # https://github.com/fabiomaia/linuxify
     cd ~/src
     git clone https://github.com/fabiomaia/linuxify.git
     cd linuxify/
     ./linuxify install # to install all the GNU versions
          # ./linuxify uninstall # to remove all the GNU versions and the pathname changes
          # manually remove '. ~/.linuxify' from my ~/.bashrc file
     ls -al ~/src/linuxify # should see .linuxify but not executable
     chmod 755 ~/src/.linuxify # make executable
     cp ~/src/.linuxify ~/ # cp to root
# 2. to 'linuxify' a terminal session:  run the following at the beginning of a script or a session.
     . ~/.linuxify; awk; which sed; which grep
          awk # should return help page for gawk
          which sed # should show /usr/local/opt/gnu-sed/libexec/gnubin/sed
          which grep # should return: '/usr/local/opt/grep/libexec/gnubin/grep'
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

# In order to complete the configuration process, please execute the following:

# echo "source ~/.bash_profile" >> $HOME/.bashrc # prob not needed, since =.bash_profile is sourced with every new window
# mv ~/edirect ~/src/edirect
echo "export PATH=\${PATH}:/Users/Negorashi2011/src/edirect" >> $HOME/.bash_profile

# test commands
esearch -h
elink -h
efilter -h
efetch -h
