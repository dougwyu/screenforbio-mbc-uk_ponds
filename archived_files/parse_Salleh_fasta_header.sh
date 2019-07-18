#!/bin/bash

set -e
set -u
set -o pipefail

cd ~/src/screenforbio-mbc-ailaoshan/archived_files/
. ~/.linuxify; which sed # should show /usr/local/opt/gnu-sed/libexec/gnubin/sed

# start with: >KY117560_Arctictis_binturong|ABI/1-17067
# change to:  >Arctictis_binturong_KY117560"

# ^([0-9, A-Z, a-z]*)_(\w+) # regex to capture GI number and Genus_species

# keep only header text before the "|"
# seqkit seq -i strips non-header info from header lines (doesn't touch the sequences)
# ^([^\|]+) # capture 1 or more characters starting from the beginning up to but not including "|", which automatically cuts out anything after the "|"
seqkit seq -i --id-regexp "^([^\|]+)" Salleh2017GigaScience_72mitogenomes.fasta | \
     # switch order of name and GI number
     seqkit replace -p "^([0-9, A-Z, a-z]*)_(\w+)" -r '$2 _ $1' | \
     seqkit replace -p " _ " -r '_' -o salleh_reformatted.fa  # remove spaces
seqkit seq -g  salleh_reformatted.fa -o extra_12S.fa # remove gaps
head extra_12S.fa

cp extra_12S.fa extra_16S.fa # these the input files to get_sequences.sh, where <extras> is 'yes'
cp extra_12S.fa ~/src/screenforbio-mbc-ailaoshan/
cp extra_16S.fa ~/src/screenforbio-mbc-ailaoshan/
