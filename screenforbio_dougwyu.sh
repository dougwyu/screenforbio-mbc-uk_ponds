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
# Failed
# Probably can succeed with faster internet
# output is Tetrapoda_ITIS_taxonomy.txt, a copy of which is in screenforbio-mbc-dougwyu/archived_files/

# 3. Generate non-redundant curated reference sequence database for target amplicon(s) and fix taxonomic classification
#   - *get_sequences.sh*
# usage: bash get_sequences.sh <extras> <gap-fill> <module> <taxon> <screenforbio>
# where:
# <extras> is 'yes' or 'no', indicating whether to add local FASTA format sequences. if 'yes', files must be in present directory labelled "extra_12S.fa", "extra_16S.fa", "extra_Cytb.fa", "extra_COI.fa", with headers in format Genus_species_uniqueID.
# <gap-fill> is 'no' or a tab-delimited text file of species names to be targeted for gap-filling from NCBI, in format Genus_species.
# <module> is 'one', 'two', 'three' or 'four' indicating whether the script is starting from scratch ('one'), restarting after checking the output of the mafft alignment ('two'), restarting after manual correction of failed taxonomy lookups ('three'), or restarting after manual checks of SATIVA output ('four'). see end of module messages for any requirements for the next module."
# <taxon> is the taxon for which the taxonomy was downloaded with get_taxonomy.sh, e.g. Mammalia or Tetrapoda (all outputs should be in present directory).
# <screenforbio> is the path to the screenforbio-mbc directory


# Module 1 - Extract subset of raw Midori database for query taxon and loci. Remove sequences with non-binomial species names, reduce subspecies to species labels. Add local sequences (optional). Check for relevant new sequences for list of query species on NCBI (GenBank and RefSeq) (optional). Select amplicon region and remove primers. Remove sequences with ambiguous bases. Align. End of module: optional check of alignments
cd ~/src/screenforbio-mbc-dougwyu/
. ~/.linuxify; which sed # should show /usr/local/opt/gnu-sed/libexec/gnubin/sed
# copy MIDORI files that i want to process to the working directory: screenforbio-mbc-dougwyu/
cp archived_files/MIDORI_UNIQUE_1.1_lrRNA_RDP.fasta.gz ./; gunzip MIDORI_UNIQUE_1.1_lrRNA_RDP.fasta.gz
cp archived_files/MIDORI_UNIQUE_1.1_srRNA_RDP.fasta.gz ./; gunzip MIDORI_UNIQUE_1.1_srRNA_RDP.fasta.gz
# cp archived_files/MIDORI_UNIQUE_1.2_lrRNA_RDP.fasta.gz ./; gunzip MIDORI_UNIQUE_1.2_lrRNA_RDP.fasta.gz
# cp archived_files/MIDORI_UNIQUE_1.2_srRNA_RDP.fasta.gz ./; gunzip MIDORI_UNIQUE_1.2_srRNA_RDP.fasta.gz
bash ~/src/screenforbio-mbc-dougwyu/get_sequences.sh no no one Tetrapoda ~/src/screenforbio-mbc-dougwyu/
# Successful
# Module 1 took 0.81 hours

# Actions after Module 1 complete
# Module 1 complete. Stopping now for manual inspection of alignments *.mafft.fa inside ./intermediate_files.
# Restart script when happy with alignments (save as *.mafft_edit.fa in present directory even if no edits are made).
# Input files have been moved to ./intermediate_files
mv ./intermediate_files/MIDORI_lrRNA.amp_blast.noN.mafft.fa ./MIDORI_lrRNA.amp_blast.noN.mafft_edit.fa
mv ./intermediate_files/MIDORI_srRNA.amp_blast.noN.mafft.fa ./MIDORI_srRNA.amp_blast.noN.mafft_edit.fa

# Module 2 - Compare sequence species labels with taxonomy. Non-matching labels queried against Catalogue of Life to check for known synonyms. Remaining mismatches kept if genus already exists in taxonomy, otherwise flagged for removal. End of module: optional check of flagged species labels.
cd ~/src/screenforbio-mbc-dougwyu/
. ~/.linuxify; which sed # should show /usr/local/opt/gnu-sed/libexec/gnubin/sed
bash ~/src/screenforbio-mbc-dougwyu/get_sequences.sh no no two Tetrapoda ~/src/screenforbio-mbc-dougwyu/
# Failed, got the output file Tetrapoda.combined_taxonomy.txt from Alex

# Actions after Module 2 complete
# echo "Module 2 complete. Stopping now for manual inspection of failed species lookups (in ${TAXON}.missing_sp_to_delete.txt)."
# echo "If a failed lookup can be resolved, remove from ${TAXON}.missing_sp_to_delete.txt and add taxonomy to a tab-delimited file named ${TAXON}.missing_sp_taxonomy.txt with columns for kingdom,phylum,class,order,family,genus,species,status,query - 'status' should be something short and descriptive ("_" instead of spaces; eg. "mispelling" or "manual_synonym") and 'query' should be the entry in ${TAXON}.missing_sp_to_delete.txt. ${TAXON}.missing_sp_taxonomy.txt must not have a header line when the script is restarted."
# echo "If all failed lookups are resolved, delete ${TAXON}.missing_sp_to_delete.txt. If some/all failed lookups cannot be resolved, keep the relevant species names in ${TAXON}.missing_sp_to_delete.txt. When restarting the script it will check for the presence of this file and act accordingly (sequences for these species will be discarded)."
# echo "If no failed lookups can be resolved, do not create ${TAXON}.missing_sp_taxonomy.txt, leave ${TAXON}.missing_sp_to_delete.txt as it is."


# Module 3 - Discard flagged sequences. Update taxonomy key file for sequences found to be incorrectly labelled in Module 2. Run SATIVA. End of module: optional check of putatively mislabelled sequences
# requires file Tetrapoda.combined_taxonomy.txt from Module 2, or there is a copy in archived_files/
cd ~/src/screenforbio-mbc-dougwyu/
. ~/.linuxify; which sed # should show /usr/local/opt/gnu-sed/libexec/gnubin/sed
bash ~/src/screenforbio-mbc-dougwyu/get_sequences.sh no no three Tetrapoda ~/src/screenforbio-mbc-dougwyu/
# Successful
# Module 3 took ~ 9 hours for srRNA and lrRNA, using 4 threads

# Actions after Module 3 complete
# echo "Module 3 complete. Stopping now for manual inspection of mislabelled sequences in ./MIDORI_locus_sativa/MIDORI_locus.mis"
# to open this file in something like Excel, open the file in a text editor, select all, and paste into an empty Excel table. I cannot import successfully with Excel's import function
# to use R, readr can import if the first set of lines is skipped, and the column names are provided
# MIDORI_lrRNA <- read_delim("~/src/screenforbio-mbc-dougwyu/MIDORI_lrRNA_sativa/MIDORI_lrRNA.mis", "\t", escape_double = FALSE, trim_ws = TRUE, skip = 5, col_names = c("SeqID", "MislabeledLevel","OriginalLabel","ProposedLabel","Confidence","OriginalTaxonomyPath","ProposedTaxonomyPath","PerRankConfidence"))
# echo "To skip manual editing, do nothing and restart script."
# echo "To make changes, create file ./MIDORI_locus_sativa/MIDORI_locus.mis_to_delete and copy all confirmed mislabelled sequence accessions as a single column, tab-delimited list. These will be deleted at the start of module 4."
# echo "For sequences where species-level or genus-level mislabelling can be resolved, make corrections directly in ${TAXON}.final_taxonomy_sativa.txt (i.e. replace the taxonomic classification for that sequence with the correct one), this will be used to rename sequences."
# echo "Make higher level changes to the taxonomy at your own risk - untested."
# echo "Restart script when happy."
cd ~/src/screenforbio-mbc-dougwyu/
. ~/.linuxify; which sed # should show /usr/local/opt/gnu-sed/libexec/gnubin/sed
# archive an original version before changing it with the sativa suggestions
cp Tetrapoda.final_taxonomy_sativa.txt Tetrapoda.final_taxonomy_sativa_orig.txt
# then use this R code (delete_seqs_suggested_by_sativa.Rmd) to remove sequences that sativa identifies as incorrect
     # I remove all sequences that sativa identifies as having an incorrect taxonomy above genus level, as such large errors are most likely to be database errors.
     # I accept sativa's proposed substitute taxonomies where sativa confidence >- 0.998 (i.e. i accept only the most confident substitutions)

# Module 4 - Discard flagged sequences. Finalize consensus taxonomy and relabel sequences with correct species label and accession number. Select 1 representative sequence per haplotype per species.
cd ~/src/screenforbio-mbc-dougwyu/
. ~/.linuxify; which sed # should show /usr/local/opt/gnu-sed/libexec/gnubin/sed
bash ~/src/screenforbio-mbc-dougwyu/get_sequences.sh no no four Tetrapoda ~/src/screenforbio-mbc-dougwyu/



# 4. Train PROTAX models for target amplicon(s)
#   - *train_protax.sh* (unweighted) or *train_weighted_protax.sh* (weighted)
#   - *check_protax_training.sh* (makes bias-accuracy plots)
# 5. Classify query sequences (reads or OTUs) with PROTAX
#   - *protax_classify.sh* or *protax_classify_otus.sh* (unweighted models)
#   - *weighted_protax_classify.sh* or *weighted_protax_classify_otus.sh* (weighted models)
#
