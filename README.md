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

```

```

## 2. Metagenomic genome assembly pipeline

Using **nf-core/mag** pipeline to assemble MAGs


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

Output generated all desired and exprected outputs (2020-10-01) so will continue with creating snakemake file to execute across all metagenomes.


