# Name: Collapsetypes.pl
# Description: Perl script for removing identical or near identical DNA sequences from a fasta file. Creates a file with only unique haplotypes / genotypes
# Copyright (C) 2013  Douglas Chesters
# Modified by Enrique Gonzalez-Tortuero
#
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# contact address dc0357548934@live.co.uk
#
# citation: Chesters, D. (2013) collapsetypes.pl [computer software available at http://sourceforge.net/projects/collapsetypes/]
#
this script was used in:

Gattolliat and Monaghan. (2010) "DNA-based association of adults and larvae in Baetidae (Ephemeroptera) with the description of a new genus Adnoptilum in Madagascar." Journal of the North American Benthological Society 29.3 : 1042-1057.

Pinzon-Navarro, et al. (2010) "DNA-based taxonomy of larval stages reveals huge unknown species diversity in neotropical seed weevils (genus Conotrachelus): relevance to evolutionary ecology." Molecular Phylogenetics and Evolution 56.1 : 281-293.

Chesters, et al. (2012) "The integrative taxonomic approach reveals host specific species in an encyrtid parasitoid species complex." PloS one 7.5 : e37655.

Quicke, et al. (2012) "Utility of the DNA barcoding gene fragment for parasitic wasp phylogeny (Hymenoptera: Ichneumonoidea): data release and new measure of taxonomic congruence." Molecular Ecology Resources 12.4 : 676-685.

# QUICKSTART:
# -----------
#
# Run with the command:
# $ perl collapsetypes_v4.5.pl -infile=input.fas -ambchar=?nN -nrdiffs=3
#
# Command line options are input file name, the characters you wish to depict ambiguous positions and the number of differences to determine haplotypes.
# * Input is fasta format alignment.
# * Ambiguous positions (-ambchar=<characters>) are those in which the type of nucleotide is unknown, here these are ignored when deciding whether 2 sequences are identical. If you dont have ambiguous characters, it doesnt matter what you use in the command line.
# * The number of differences to determine haplotypes (-nrdiffs=<number>) allows sequencing misreads, i.e if 2 sequences differ by just a single base, they are considered the same haplotype. By default, this program consider that a difference between sequences are the same haplotype.
# * Output is a file with only unique sequences in it.
#
# MORE DETAILED:
# --------------
#
# If you have a Mac or Linux:
# 	* Just open a shell (terminal), add execute permission, and change to the directory containing your input file. If you don't want to add execute permission to this script, you must to change to the folder where the script is.
#
# If you have Windows: 
# 	* You will need to install Perl first. Go to the activePerl website once installed put perl in your dos path (google it), or just place your input file into the /perl/bin/ folder. Then, open a command prompt then cd into the folder with your input file
#
# Type: "perl collapsetypes_v4.5.pl -infile=[input_file_name] -ambchar=[additional_ambiguity_characters] -nrdiffs=[number_of_allowed_diffs]"
# (Eg: perl collapsetypes_v4.5.pl -infile=input.fas -ambchar=?nN -nrdiffs=3)
#
# * Input file must be fasta format ALIGNMENT.
#
# * Additional ambiguity characters I have come across: '?', 'x', 'X', 'n', 'N', '-' in particular, decide what you want to do about gap characters. For example if you have indels, represented by hyphen in the sequences, and you wish that the presence of an indel between 2 sequences would still constitute an identical pair of sequences, then you would include hyphen as an additional ambiguity characters in the command. Conversly, if you think an indel means the 2 sequences are different (this is default), then no hyphen in the command 
# * The number of differences to determine haplotypes (-nrdiffs=<number>) allows sequencing misreads, i.e if 2 sequences differ by just a single base, they are considered the same haplotype. By default, this program consider that a difference between sequences are the same haplotype.
# * output files: 	1) fasta format file with the unique sequences
#			2) haplotype_assignations, which sequences have been printed, with list of identical sequences on the same row (see note below)
#			3) haplotype_assignations2, each unique haplotype is given a number, file lists all sequences and what haplotype number they are, and whether printed
#			4) haplotype_assignations3, lists all sequences which are duplicates, and which other sequences they match. Pattern of matches is not always consistent, see explaination for this, in the section 'this script will sometimes give you unintuitive .....'
#
# The script removes redundent sequences from a input file, printing one of each unique haplotype to the output file other programs that do something similar include:
#	* TCS (Clement, 2000, Mol Ecol)
#	* FaBox (Villesen 2007, mol ecol notes), 
#	* DNASP (Rozas et al 2003)
#	* Collapse (Posada 2006) - this program differs in that the full nucleotide code is accounted for (see algorithm below), and does not require installation (most of the above do require this) and generates some useful additional output files and permits 'near'-identical sequence removal also. Useful if you want to account for some sequencing error. In terms of general behaviour, i have had reports that it is more liberal at sequence removal than Collapse. Also, when used prior to GMYC analysis (Pons et al 06, syst biol), I hear it gives significant improvement to likelihoods the script starts to get very slow as you use large numbers of seqs (>~2000)
#
# The algorithm:
#
# loop 1, read each sequence in turn
# loop2, read each sequence in turn, starting from the index of above sequence +1. So all sequence pairs are compared.
# For each pairwise comparison:
# 	for each occurance of   N,       if corresponding position in other sequence has	[atcgmrwsykvhdb],	other seq gets score+1
#              ..           	Y                               ..                      	[ct]         		..
#              ..           	R                               ..  	                        [ag]			..	
#              ..           	M                               .. 	                        [ac]			..
#              ..           	W                               ..  	                        [at]			..
#              ..           	S                               ..		                [cg]			..
#              ..           	K                               ..		                [tg]			..
#              ..           	V                               ..		                [acgmsr]		..
#              ..           	H                               ..		                [actmyw]		..
#              ..           	D                               .. 	                        [agtrkw]		..
#              ..           	B                               ..    	                        [cgtsky]		..
#
# For all positions except those with [NYRMWSKVHBD], if the 2 sequences are identical put black mark against lowest scoring sequence. If they score the same then black mark the pair member in loop 1 (this allows further comparisons with the other member). Then, print all sequence without black mark to file, unique_haplotypes.
#
#
# This script will sometimes give you unintuitive results, heres why:
#
# 	seq1 CCCGATCGTTCCC
# 	seq2 ATCGATCGTTCCC
# 	seq3 NNNNYYYGTTCCC
#
# When deciding whether seq1 and 3 above are the same haplotype, it can only look at the last 6 bases of each sequence, and indeed they are the same here (also the same as seq2). so as far as the program is concerned seq 3 is the same as seq2 and seq3 is the same as seq1. however the lack of N's in seq 1 and 2 mean theres more bases to compare, and they are not the same at some of these. so the result is seq1 == seq3. seq2 == seq3 even though seq1 does not == seq2.
# So in the haplotype assignations output a sequence composed of largly missing data will probably be assigned to lots of different haplotypes. But will not be printed anyway because it will be low scoring
#
# There should be mp duplicate id's in your input file. Assignations3 file lists all duplicated id's as assignations1 / 2 will ommit if one is same as another which is same as another which is removed. Sequence id's need to be reasonable length. not e.g. 1 character
#
# Its IMPORTANT to consider the characters you use for gap and missing for default i have  "N" , "n" , "x" , "X" , "?" for missing, and assume "-" for gap, treated as different character state, that would mean that, in the example below, seq5 and seq6 are the same haplotype, seq6 and seq7 are different haplotypes
#
# 	seq5 CCCCC
# 	seq6 CCCCN
# 	seq7 -CCCC
#
# Note that N is always used as an ambiguity character, irrespective of what you specify in the command line.
#
#
# Main test dataset:
#
#	>SEQ_c.3
#	?aaaaaaaaaaaaaatt
#	>SEQ_d.1
#	aaaaaaaaaaaaaaata
#	>SEQ_c.1
#	aaaaaaaaaaaaaaatt
#	>SEQ_a.1
#	ttttttttttttttttt
#	>SEQ_c.2
#	aaaaaaaaaaaaaaatt
#	>SEQ_a.2
#	ttttttttttttttytt
#	>SEQ_a.3
#	ttttttttttttttttt
#	>SEQ_b.1
#	ttttttttttttttttc
#	>SEQ_c.3
#	?aaaaaaaaaaaaaatn
#
#
# the three SEQ_a's are all the same, but SEQ_a.2 has an ambig char so should not be printed.
# SEQ_c.3 is a duplicated ID. SEQ_c's all the same, but SEQ_c.3 is the worse scoring of the three.
# SEQ_d.1 the same as second SEQ_c.3 when nonAbmig chars are looked at so the lower SEQ_c.3 belongs to 2 haplotype numbers
#
# output:
#
# 	printed:SEQ_d.1	same_as:SEQ_c.3	
# 	printed:SEQ_c.2	same_as:SEQ_c.3	SEQ_c.1	SEQ_c.3	
# 	printed:SEQ_a.3	same_as:SEQ_a.1	SEQ_a.2	
# 	printed:SEQ_b.1
#
# VERSION HISTORY
# ---------------
#
# 	v4: 	Will now work on files produced across platforms. 
#		Eg you can run the script on a pc, using a fasta file generated on mac
#		Does not replace spaces with underscores on fasta ids
#		Can now handle identical id's in the input file (although these shouldnt really be present), by appending numbers to redundent id's. This feature works ONLY WITH FASTA FORMAT, not with nexus (its more difficult with nexus due to possibilty of sequence interleaving)
#		Tabs as seperators instead of spaces in information files, since id's may contain spaces this would disorganise excel's data to columns feature
# 	v4.1: Takes nexus format (tested with sequential version, but interleaved should work). 
#		Accepts x, N and ? as missing data char
#		Note comments (anything between square brackets) are removed from nexus files. 
#		I know sometimes extra sequence is included in these comments. if you are desperate to have comments reinserted into outfile let me know.
# 	v4.2: '-' added as missing data character. writes output in nexus format
# 	v4.3: big re-write. now based on sequences id's rather than file indices. 
# 	            Another output file (.assign3) is given, 
# 	            SOME INFORMATION OMITTED FROM OTHER FILES SHOULD BE FOUND IN THIS.
# 	v4.4: User specified missing data / gap characters
# 	v4.5: Missing characters specified in command line. nexus format support discontinued. streamlined.
#	v4.6: improvement to UI and structure, by Enrique Gonzalez-Tortuero
