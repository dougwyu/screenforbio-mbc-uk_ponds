#!/bin/bash

set -e
set -u
set -o pipefail

# Send STDOUT and STDERR to log file
exec > >(tee -a get_taxonomy.`date +%Y-%m-%d`.log)
exec 2> >(tee -a get_taxonomy.`date +%Y-%m-%d`.log >&2)

# run '. ~/.linuxify' # activates GNU versions of grep, sed, awk
source ~/.bashrc

# Run

# Steps and associated scripts:
# 1. Process twin-tagged metabarcoding data
#   - *read_preprocessing.sh*


# Steps and associated scripts:

# 1. Process twin-tagged metabarcoding data
# did not run because we have an alternative bioinformatic pipeline

# 2. Obtain initial taxonomic classification for target taxon
#   - *get_taxonomy.sh*
# The working folder is the folder with the scripts in it.
# usage: bash get_taxonomy.sh <taxonName> <taxonRank> <screenforbio>
# where:
# <taxonName> is the scientific name of the target taxon e.g. Tetrapoda
# <taxonRank> is the classification rank of the target taxon e.g. superclass
# <screenforbio> is the path to the screenforbio-mbc directory
cd ~/src/screenforbio-mbc-dougwyu/
. ~/.linuxify; which sed # should show /usr/local/opt/gnu-sed/libexec/gnubin/sed
bash ~/src/screenforbio-mbc-dougwyu/get_taxonomy.sh Tetrapoda superclass ~/src/screenforbio-mbc-dougwyu/
# this takes a long time.
# output is Tetrapoda_ITIS_taxonomy.txt, which is also in screenforbio-mbc-dougwyu/archived_files/

# 3. Generate non-redundant curated reference sequence database for target amplicon(s) and fix taxonomic classification
#   - *get_sequences.sh*
# usage: bash get_sequences.sh <extras> <gap-fill> <module> <taxon> <screenforbio>
# where:
# <extras> is 'yes' or 'no', indicating whether to add local FASTA format sequences. if 'yes', files must be in present directory labelled "extra_12S.fa", "extra_16S.fa", "extra_Cytb.fa", "extra_COI.fa", with headers in format Genus_species_uniqueID.
# <gap-fill> is 'no' or a tab-delimited text file of species names to be targeted for gap-filling from NCBI, in format Genus_species.
# <module> is 'one', 'two', 'three' or 'four' indicating whether the script is starting from scratch ('one'), restarting after checking the output of the mafft alignment ('two'), restarting after manual correction of failed taxonomy lookups ('three'), or restarting after manual checks of SATIVA output ('four'). see end of module messages for any requirements for the next module."
# <taxon> is the taxon for which the taxonomy was downloaded with get_taxonomy.sh, e.g. Mammalia or Tetrapoda (all outputs should be in present directory).
# <screenforbio> is the path to the screenforbio-mbc directory
cd ~/src/screenforbio-mbc-dougwyu/
. ~/.linuxify; which sed # should show /usr/local/opt/gnu-sed/libexec/gnubin/sed
# copy MIDORI files that i want to process to the working directory: screenforbio-mbc-dougwyu/
cp archived_files/MIDORI_UNIQUE_1.1_lrRNA_RDP.fasta.gz ./; gunzip MIDORI_UNIQUE_1.1_lrRNA_RDP.fasta.gz
cp archived_files/MIDORI_UNIQUE_1.1_srRNA_RDP.fasta.gz ./; gunzip MIDORI_UNIQUE_1.1_srRNA_RDP.fasta.gz
# cp archived_files/MIDORI_UNIQUE_1.2_lrRNA_RDP.fasta.gz ./; gunzip MIDORI_UNIQUE_1.2_lrRNA_RDP.fasta.gz
# cp archived_files/MIDORI_UNIQUE_1.2_srRNA_RDP.fasta.gz ./; gunzip MIDORI_UNIQUE_1.2_srRNA_RDP.fasta.gz

bash ~/src/screenforbio-mbc-dougwyu/get_sequences.sh no no one Tetrapoda ~/src/screenforbio-mbc-dougwyu/

# Module 1 took 0.81 hours

# Module 1 complete. Stopping now for manual inspection of alignments *.mafft.fa inside ./intermediate_files.
# Restart script when happy with alignments (save as *.mafft_edit.fa in present directory even if no edits are made).
# Input files have been moved to ./intermediate_files

mv ./intermediate_files/MIDORI_lrRNA.amp_blast.noN.mafft.fa ./MIDORI_lrRNA.amp_blast.noN.mafft_edit.fa
mv ./intermediate_files/MIDORI_srRNA.amp_blast.noN.mafft.fa ./MIDORI_srRNA.amp_blast.noN.mafft_edit.fa
bash ~/src/screenforbio-mbc-dougwyu/get_sequences.sh no no two Tetrapoda ~/src/screenforbio-mbc-dougwyu/

bash ~/src/screenforbio-mbc-dougwyu/get_sequences.sh no no three Tetrapoda ~/src/screenforbio-mbc-dougwyu/


# 4. Train PROTAX models for target amplicon(s)
#   - *train_protax.sh* (unweighted) or *train_weighted_protax.sh* (weighted)
#   - *check_protax_training.sh* (makes bias-accuracy plots)
# 5. Classify query sequences (reads or OTUs) with PROTAX
#   - *protax_classify.sh* or *protax_classify_otus.sh* (unweighted models)
#   - *weighted_protax_classify.sh* or *weighted_protax_classify_otus.sh* (weighted models)
#
