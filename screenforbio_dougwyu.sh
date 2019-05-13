#!/bin/bash

set -e
set -u
set -o pipefail

# Send STDOUT and STDERR to log file
exec > >(tee -a get_taxonomy.`date +%Y-%m-%d`.log)
exec 2> >(tee -a get_taxonomy.`date +%Y-%m-%d`.log >&2)

# run '. ~/.linuxify' # activates GNU versions of grep, sed, awk

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
# there are two 12S_primers files:  12S_primers_kocher.fa and 12S_primers_riaz.fa. Duplicate the one that you want to use and change its filename to 12S_primers.fa, and this will be the pair used to pull out 12S amplicons from the Midori reference database
# to use the Kocher primers (12S_primers_kocher.fa), in get_sequences.sh:
     # change the usearch -search_pcr line 178 to
     # usearch -search_pcr ${label}.raw.fa -db ${SCRIPTS}/12S_primers.fa -strand both -maxdiffs 4 -minamp 420 -maxamp 470 -ampout ${label}.amp.fa
     # change the usearch -fastx_truncate line 183 to
     # usearch -fastx_truncate ${label}.amp.fa -stripleft 30 -stripright 28 -fastaout ${label}.amp_only.fa # for Kocher 12S primers
     # change the awk line 188 to
     # cat ${label}.amp.blastn | awk 'BEGIN{FS=OFS}($4>=360){print $1 OFS $7 OFS $8}' > ${label}.amp.blastn.coords # for 12S Kocher primers
# to use the Riaz primers (12S_primers_riaz.fa), in get_sequences.sh:
     # change the usearch -search_pcr line 179 to
     # usearch11 -search_pcr2 ${label}.raw.fa -fwdprimer ACTGGGATTAGATACCCC -revprimer YRGAACAGGCTCCTCTAG -minamp 84 -maxamp 120 -strand both -maxdiffs 4 -fastaout ${label}.amp.fa # for 12S Riaz primers
     # change the usearch -fastx_truncate line 184 to
     # usearch -fastx_truncate ${label}.amp.fa -stripleft 0 -stripright 0 -fastaout ${label}.amp_only.fa # for Riaz 12S primers
     # change the awk line 189 to
     # cat ${label}.amp.blastn | awk 'BEGIN{FS=OFS}($4>=84){print $1 OFS $7 OFS $8}' > ${label}.amp.blastn.coords # for 12S Riaz primers

bash ~/src/screenforbio-mbc-dougwyu/get_sequences.sh no no one Tetrapoda ~/src/screenforbio-mbc-dougwyu/
# Successful
# Module 1 took 0.58 hours (16Smam and 12SRiaz primers, Midori 1.1)

# Actions after Module 1 complete
# Module 1 complete. Stopping now for manual inspection of alignments *.mafft.fa inside ./intermediate_files.
# Restart script when happy with alignments (save as *.mafft_edit.fa in present directory even if no edits are made).
# Input files have been moved to ./intermediate_files
mv ./intermediate_files/MIDORI_lrRNA.amp_blast.noN.mafft.fa ./MIDORI_lrRNA.amp_blast.noN.mafft_edit.fa
mv ./intermediate_files/MIDORI_srRNA.amp_blast.noN.mafft.fa ./MIDORI_srRNA.amp_blast.noN.mafft_edit.fa

# Module 2 - Compare sequence species labels with ITIS taxonomy. Non-matching labels queried against Catalogue of Life to check for known synonyms. Remaining mismatches kept if genus already exists in taxonomy, otherwise flagged for removal. End of module: optional check of flagged species labels.
# requires a taxon_ITIS_taxonomy.txt file (e.g. Tetrapoda_ITIS_taxonomy.txt file)
cd ~/src/screenforbio-mbc-dougwyu/
. ~/.linuxify; which sed # should show /usr/local/opt/gnu-sed/libexec/gnubin/sed
bash ~/src/screenforbio-mbc-dougwyu/get_sequences.sh no no two Tetrapoda ~/src/screenforbio-mbc-dougwyu/

# some species cause the taxize::classification() function to fail, throwing up the following error:
     # Retrieving data for taxon 'Natrix natrix'

     # Error in doc_parse_raw(x, encoding = encoding, base_url = base_url, as_html = as_html,  :
     #   CData section not finished
     # Kindler, C., Böhme, W., Corti, C., Gvozdik, V., J [63]
# These are 'misbehavers,' and we remove them manually by adding a sed command at line 532, before running get_taxonomy_mismatches.R
     # remove misbehavers by deleting these species, like this:
     # sed -i '/Hemidactylus adensis/d' MIDORI_${TAXON}.ITIS_mismatch_sp.txt
     #
     # and then add back the removed species at line 564, like this:
     # sed -i '$a\Hemidactylus_adensis\' MIDORI_${TAXON}.missing_sp.txt

# Success
# Module 2 took 0.96 hours
# There are two output files:
# Tetrapoda.missing_sp_to_delete.txt
# Tetrapoda.combined_taxonomy.txt

# Actions after Module 2 complete
# Module 2 complete. Stopping now for manual inspection of failed species lookups (in Tetrapoda.missing_sp_to_delete.txt).
# If a failed lookup can be resolved, remove from Tetrapoda.missing_sp_to_delete.txt and add taxonomy to a tab-delimited file named Tetrapoda.missing_sp_taxonomy.txt with columns for kingdom,phylum,class,order,family,genus,species,status,query - 'status' should be something short and descriptive (_ instead of spaces; eg. mispelling or manual_synonym) and 'query' should be the entry in Tetrapoda.missing_sp_to_delete.txt. Tetrapoda.missing_sp_taxonomy.txt must not have a header line when the script is restarted.
# If all failed lookups are resolved, delete Tetrapoda.missing_sp_to_delete.txt. If some/all failed lookups cannot be resolved, keep the relevant species names in Tetrapoda.missing_sp_to_delete.txt. When restarting the script it will check for the presence of this file and act accordingly (sequences for these species will be discarded).
# If no failed lookups can be resolved, do not create Tetrapoda.missing_sp_taxonomy.txt, leave Tetrapoda.missing_sp_to_delete.txt as it is.
# Restart script when happy.

# I looked through Tetrapoda.missing_sp_to_delete.txt, and all the species are not ones found in Ailaoshan or Yunnan so rather than look up and add their full taxonomic pathways, i will go to module_three.


# Module 3 - Discard flagged sequences. Update taxonomy key file for sequences found to be incorrectly labelled in Module 2. Run SATIVA. End of module: optional check of putatively mislabelled sequences
# requires file Tetrapoda.combined_taxonomy.txt from Module 2, or there is a copy in archived_files/
cd ~/src/screenforbio-mbc-dougwyu/
. ~/.linuxify; which sed # should show /usr/local/opt/gnu-sed/libexec/gnubin/sed
bash ~/src/screenforbio-mbc-dougwyu/get_sequences.sh no no three Tetrapoda ~/src/screenforbio-mbc-dougwyu/
# Success
# Module 3 took ~ 5.7 hours for srRNA and lrRNA, using 4 threads

# Actions after Module 3 complete
# Module 3 complete. Stopping now for manual inspection of mislabelled sequences in ./MIDORI_locus_sativa/MIDORI_locus.mis
# To skip manual editing, do nothing and restart script.
# To make changes, create file ./MIDORI_locus_sativa/MIDORI_locus.mis_to_delete and copy all confirmed mislabelled sequence accessions as a single column, tab-delimited list. These will be deleted at the start of module 4.
# For sequences where species-level or genus-level mislabelling can be resolved, make corrections directly in Tetrapoda.final_taxonomy_sativa.txt (i.e. replace the taxonomic classification for that sequence with the correct one), this will be used to rename sequences.
# Make higher level changes to the taxonomy at your own risk - untested.
# Restart script when happy.
cd ~/src/screenforbio-mbc-dougwyu/
. ~/.linuxify; which sed # should show /usr/local/opt/gnu-sed/libexec/gnubin/sed
# archive an original version before changing it with the sativa suggestions
cp Tetrapoda.final_taxonomy_sativa.txt Tetrapoda.final_taxonomy_sativa_orig.txt
# then use this R code (delete_seqs_suggested_by_sativa.Rmd) to remove sequences that sativa identifies as incorrect
     # I remove all sequences that sativa identifies as having an incorrect taxonomy above genus level, as such large errors are most likely to be database errors.
     # I accept sativa's proposed substitute taxonomies where sativa confidence >- 0.998 (i.e. i accept only the most confident substitutions)
     # Programming notes
          #to open this file in something like Excel, open the file in a text editor, select all, and paste into an empty Excel table. I cannot import successfully with Excel's import function
          # to use R, readr can import if the first set of lines is skipped, and the column names are provided
          # MIDORI_lrRNA <- read_delim("~/src/screenforbio-mbc-dougwyu/MIDORI_lrRNA_sativa/MIDORI_lrRNA.mis", "\t", escape_double = FALSE, trim_ws = TRUE, skip = 5, col_names = c("SeqID", "MislabeledLevel","OriginalLabel","ProposedLabel","Confidence","OriginalTaxonomyPath","ProposedTaxonomyPath","PerRankConfidence"))


# Module 4 - Discard flagged sequences. Finalize consensus taxonomy and relabel sequences with correct species label and accession number. Select 1 representative sequence per haplotype per species.
cd ~/src/screenforbio-mbc-dougwyu/
. ~/.linuxify; which sed # should show /usr/local/opt/gnu-sed/libexec/gnubin/sed
bash ~/src/screenforbio-mbc-dougwyu/get_sequences.sh no no four Tetrapoda ~/src/screenforbio-mbc-dougwyu/

# Success
# Module 4 took 4.96 hours
# Actions after Module 4 complete:  None needed
#
# Module 4 complete. You have reached the end of get_sequences.sh
#
# Final database sequences are in Tetrapoda.final_database.locus.fa, final taxonomy file is in Tetrapoda.final_protax_taxonomy.txt
#
# Next step: train PROTAX models with either:
#   - train_protax.sh for unweighted models
#   - train_weighted_protax.sh for models weighted using a list of expected species



# 4. Train PROTAX models for target amplicon(s)
#   - *train_protax.sh* (unweighted) or *train_weighted_protax.sh* (weighted)
#   - *check_protax_training.sh* (makes bias-accuracy plots)
cd ~/src/screenforbio-mbc-dougwyu/
. ~/.linuxify; which sed # should show /usr/local/opt/gnu-sed/libexec/gnubin/sed
bash ~/src/screenforbio-mbc-dougwyu/train_protax.sh Tetrapoda.final_protax_taxonomy.txt ~/src/screenforbio-mbc-dougwyu/
# usage: bash train_protax.sh taxonomy screenforbio
# where:
# taxonomy is the final protax-formatted taxonomy file from get_sequences.sh (e.g. Tetrapoda.final_protax_taxonomy.txt)
# uses fasta files output from module_four of get_sequences.sh:  taxon.final_database.locus.fa (e.g. Tetrapoda.final_database.12S.fa)
# screenforbio is the path to the screenforbio-mbc directory (must contain subdirectory protaxscripts)

# usage: bash train_weighted_protax.sh splist taxonomy screenforbio
# where:
# splist is a list of expected species to use in weighting in the format Genus,species (e.g. Homo,sapiens)
# taxonomy is the final protax-formatted taxonomy file from get_sequences.sh (e.g. Tetrapoda.final_protax_taxonomy.txt)
# screenforbio is the path to the screenforbio-mbc directory (must contain subdirectory protaxscripts)

# note: will take the taxon from the protax taxonomy file name
# note: assumes curated database FASTA files are in current directory and labelled with format taxon.final_database.locus.fa




# 5. Classify query sequences (reads or OTUs) with PROTAX
#   - *protax_classify.sh* or *protax_classify_otus.sh* (unweighted models)
#   - *weighted_protax_classify.sh* or *weighted_protax_classify_otus.sh* (weighted models)
#
