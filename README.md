---
title: 'Honour''s Thesis: Characterizing Metagenomic Resistomes Documentation'
author: "Catrione Lee"
date: "September 30, 2020"
output: html_document
---

# Thesis: Characterizing Metegenomic Resistomes *in silico* for Agricultural and Environmental Microbiomes


## Objectives

1. To detect antimicrobial resistance gene (ARG)-containing mobile genetic elements (MGE) - in particular integrative conjugative elements (ICE) - in important environmental microbiomes downstream of the agricultural sector: the structure, prevalence, and diversity of ICEs will be evaluated. 

2. Acomparision of the resistomes between microbiomes will be conducted to determine if certain resistomes can move through the environment.

3. This work will also compare and contrast methods to achieve the objectives above.



## 1. Distribution of taxa in metegenomes

Using **Kraken2** tool against the nucleotide data base to determine the taxonomic diversity:

<https://github.com/catrionelee/ICE_MAG/blob/master/miniKraken2>

## 2. Metagenomic genome assembly pipeline

Using **nf-core/mag** pipeline to assemble MAGs

<https://github.com/catrionelee/ICE_MAG/blob/master/nf-core-mag>


## 3. Identifying ICEs and ARGs in MAGs

Using the **CONJscan** module of MacSyFinder to locate ICEs in the MAGs. Could use built in database or ICEberg 2.0.


## 4. Identifying ICEs in reads

Using **metaCherchant** <https://github.com/ctlab/metacherchant> on single fecal metagenome SRR6512893 parameters againt ICEberg 2.0 database:

```{echo=FALSE}
#!/usr/bin/env bash

./metacherchant.sh --tool environment-finder \
        --k 31 \
        --coverage=5 \
        --reads /home/AAFC-AAC/leecat/catrione_metagenomics/SRR6512893_*{1,2}.fastq.gz \
        --seq /home/AAFC-AAC/leecat/iceberg.fasta \
        --output output \
        --work-dir workDir \
        --maxkmers=100000 \
        --bothdirs=TRUE \
        --chunklength=100 \
        -pf 5\
        -m 100G \
        -c
```

Output generated all desired and expected outputs (2020-10-01) so will continue with creating snakemake file to execute across all metagenomes.
# There are 303 putative ICEs. Average number of sequences per putative ICE was 141.627.

Each metagenomic environment will be run separately so to easily compare. Soil was ran with 500 Gb of memory (2020-10-03). <https://https://github.com/catrionelee/ICE_MAG/blob/master/metaCherchant/subset-soil>

2020-10-04: 500 Gb not enough for the script, 1000 Gb not enough, cannot cluster allocate >2000 Gb of memory. Script is loading all files and then going to analysis. could try making a snakemake file such that each read file is loaded, read, and then searched which will be stored in the output, then the script can move on to the next file, freeing up memory. <https://github.com/catrionelee/ICE_MAG/blob/master/metaCherchant/workflow_snakemake>
