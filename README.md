# ScreenForBio metabarcoding pipeline for Ailaoshan

A fork of the ScreenForBio metabarcoding pipeline originally published in:

Axtner, J., Crampton-Platt, A., Hoerig, L.A., Xu, C.C.Y., Yu, D.W., Wilting, A. (2019), An efficient and robust laboratory workflow and tetrapod database for larger scale environmental DNA studies. Giga Sci. 8, 646–17. doi:10.1093/gigascience/giz029

Preprint available from [bioRxiv](https://www.biorxiv.org/content/early/2018/06/12/345082).  
Paper available from [GigaScience](https://academic.oup.com/gigascience/article/doi/10.1093/gigascience/giz029/5450733).  

This fork is customised to the Ailaoshan leech iDNA dataset, and updated to take advantage of the MIDORI_UNIQUE_20180221 datasets that are now available. There are some bug fixes and additional R utilities. However, if you have some knowledge of bash and R scripting, then you can easily adapt this pipeline for your paired-end Illumina metabarcoding, from processing of twin-tagged raw reads through to taxonomic classification with *PROTAX*.

The pipeline steps that will be of most use to other projects are those related to *PROTAX*: generating curated reference databases and associated taxonomic classification; training *PROTAX* models (weighted or unweighted); and classification of OTUs with *PROTAX*.

Steps and associated scripts:
1. Process twin-tagged metabarcoding data (not run in this fork, but the script is available)
  - *read_preprocessing.sh*
2. Obtain initial taxonomic classification for target taxon
  - *get_taxonomy.sh*
3. Generate non-redundant curated reference sequence database for target amplicon(s) and fix taxonomic classification
  - *get_sequences.sh*
4. Train PROTAX models for target amplicon(s)
  - *train_protax.sh* (unweighted) or *train_weighted_protax.sh* (weighted)
  - *check_protax_training.sh* (makes bias-accuracy plots)
5. Classify query sequences (reads or OTUs) with PROTAX
  - *protax_classify.sh* or *protax_classify_otus.sh* (unweighted models)
  - *weighted_protax_classify.sh* or *weighted_protax_classify_otus.sh* (weighted models)

**Note:** in some steps the ***screenforbio-mbc*** release associated with the manuscript is specific to the amplicons used in the study - primer sets and relevant settings are hard-coded in *read_preprocessing.sh* and *get_sequences.sh*. This will be generalised in a future release.

### Required software (tested versions)
Pipeline tested on macOS 10.14.4

- macOS should have GNU grep, awk and sed prioritised over macOS's BSD versions. These can be installed independently with Homebrew, or you can activate their pathnames with [linuxify](https://github.com/fabiomaia/linuxify) for every new session.  
````
cd ~/src # or wherever you install your github repos
git clone https://github.com/fabiomaia/linuxify.git
cd linuxify/
./linuxify install # places `./linuxify` file at root directory

# to linuxify a session:  run the following at the beginning of a script or a session.
. ~/.linuxify; awk; which grep; which sed
     awk # should return help page for `gawk`
     which grep # should return: `/usr/local/opt/grep/libexec/gnubin/grep`
     which sed # should return: `/usr/local/opt/gnu-sed/libexec/gnubin/sed`
````

- Processing of raw reads only  
  - bcl2fastq (v2.18)  
     * downloaded from Illumina.com (only for RedHat or CentOS Linux). If you have a local sequencer, it should already be running somewhere. If you send out for sequencing, the provider will have it running.  
  - AdapterRemoval (v2.1.7)  
     * first install [miniconda](https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.pkg)  
````
brew update; brew upgrade; brew cleanup  
brew install python # installs python3  
conda update -n base conda  
conda install -c bioconda adapterremoval  
````
  - cutadapt (v2.3)  
  `brew install cutadapt`  
  - usearch (v8.1.1861_i86osx32, v11.0.667_i86osx32)  
     * macOS binaries downloaded from [drive5](drive5.com) and moved to /usr/local/bin
````
     cd /usr/local/bin/
     # symlink to usearch and usearch11 aliases
     ln -s usearch8.1.1861_i86osx32 usearch
     ln -s usearch11.0.667_i86osx32 usearch11
     # public (free) usearch binaries are 32-bit only and thus will only run on macOS up to v 10.14.
````

- Building databases and PROTAX  
  - R (v3.6.0)  
     * installed from binary downloaded from [CRAN](https://cran.rstudio.com)
  - taxize (v0.9.8)
     * if not available, install development version ≥0.9.7.9313: `remotes::install_github("ropensci/taxize")`  
  - tabtk (r19)  
````
     cd ~/src/  
     git clone https://github.com/lh3/tabtk.git  
     cd tabtk  
     make  
     mv tabtk /usr/local/bin/tabtk  
````
  - seqtk (v1.3-r106)  
     `brew install seqtk`  
  - seqkit (v0.10.1)  
     `brew install seqkit`  
  - Entrez Direct (v6.00 and v8.30)  
     * see installation instructions on [NIH](https://www.ncbi.nlm.nih.gov/books/NBK179288/)
````
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
````
  - usearch (v8.1.1861_i86osx32, v11.0.667_i86osx32)  
     * see installation instructions above
  - blast (v2.9.0+)  
     `brew install blast`  
  - mafft (v7.407)  
     `brew install mafft`  
  - sativa (v0.9-57-g8a99328)  
````
     cd ~/src; git clone https://github.com/amkozlov/sativa  
     cd sativa
     ./install.sh --no-avx  
     ln -s sativa.py sativa  
     echo 'export PATH="$HOME/src/sativa:${PATH}"' >> ~/.bash_profile  
     # source ~/.bash_profile # if you want to run immediately  
````
  - seqbuddy (v1.3.0)  
````
     pip3 install buddysuite # installs a bunch of software  
     buddysuite -setup  
     seqbuddy -h  
````
  - last (926)  
     `brew install brewsci/bio/last`
  - perl (v5.28)  
     `brew install perl # perl 5.30 installed`

*get_sequences.sh* also requires MIDORI databases for mitochondrial target genes [Machida *et al.*, 2017](https://www.nature.com/articles/sdata201727). Download relevant MIDORI_UNIQUE FASTAs in RDP format from the [website](http://www.reference-midori.info/download.php). The manuscript used MIDORI_UNIQUE_1.1 versions of COI, Cytb, lrRNA and srRNA. The unzipped FASTAs should be *copied* to the working directory (because the script moves the working MIDORI fasta files to the intermediate_files/ folder after it finishes module one).  There are downloaded versions in the archived_files/ folder

The 20180221 versions of MIDORI have more complex headers, which interfere with the `get_sequences.sh` code.  
* *V 1.1*:  `>AF382008	root;Eukaryota;Chordata;Mammalia;Primates;Hominidae;Homo;Homo sapiens`  
* *V 20180221*:  `>AF382008.3.649.1602	root;Eukaryota;Chordata;Mammalia;Primates;Hominidae;Homo;Homo sapiens`  

The filenames will be changed to this format: `MIDORI_UNIQUE_1.2_srRNA_RDP.fasta`, and the extra stuff on the headers will be removed before running get_sequences.h

*collapsetypes_v4.6.pl* should already be in your ***screenforbio-mbc*** directory. If not, install as follows:
*get_sequences.sh* requires *collapsetypes_v4.6.pl* to be in the ***screenforbio-mbc*** directory. Download from Douglas Chesters' [sourceforge page](https://sourceforge.net/projects/collapsetypes/).  
````
     chmod 755 ~/Downloads/collapsetypes_v4.6.pl  
     mv ~/Downloads/collapsetypes_v4.6.pl ~/src/screenforbio-mbc-ailaoshan/  
````

*PROTAX* scripts are reposted here with the kind permission of Panu Somervuo. These are in the *protaxscripts* subdirectory of ***screenforbio-mbc***. This version of *PROTAX* is from [Rodgers *et al.* 2017](https://doi.org/10.1111/1755-0998.12701), scripts were originally posted on [Dryad](https://datadryad.org/resource/doi:10.5061/dryad.bj5k0).  

### Usage
All steps in the pipeline are implemented via bash scripts with similar parameter requirements. Each script includes commented usage instructions at the start and displays the same instructions if run without any or an incorrect number of parameters.

For the Ailaoshan fork, the full command history is in `screenforbio_ailaoshan.sh`. Although formatted as a shell script, it should be run command by command, instead of as a single bash script file, because there are multiple choices to be made during the pipeline.

Some of the bash scripts used within are primarily wrappers for R scripts, all of which are assumed to be in the ***screenforbio-mbc*** directory.  

*get_taxonomy.sh* example:

    mkdir ~/Documents/mbc_analysis
    cd ~/Documents/mbc_analysis
    bash ~/Documents/screenforbio-mbc/get_taxonomy.sh

You will see the following message:

    You are trying to use get_taxonomy.sh but have not provided enough information.
    Please check the following:

    Usage: bash get_taxonomy.sh taxonName taxonRank screenforbio
    Where:
    taxonName is the scientific name of the target taxon e.g. Tetrapoda
    taxonRank is the classification rank of the target taxon e.g. superclass
    screenforbio is the path to the screenforbio-mbc directory

To get the ITIS classification for Mammalia:

    bash ~/Documents/screenforbio-mbc/get_taxonomy.sh Mammalia class ~/Documents/screenforbio-mbc

When the script is running various messages will be printed to both the terminal and a log file. On completion of the script the final messages will indicate the next script that should be run and any actions the user should take beforehand.

Enjoy :-)
