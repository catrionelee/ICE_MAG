---
title: 'Honour''s Thesis: Characterizing Metagenomic Resistomes Documentation'
author: "Catrione Lee"
date: "September 30, 2020"
output: html_document
---

# Thesis: Characterizing Metegenomic Resistomes *in silico* for Agricultural and Environmental Microbiomes


# Objectives

1. To detect antimicrobial resistance gene (ARG)-containing mobile genetic elements (MGE) - in particular integrative conjugative elements (ICE) - in important environmental microbiomes downstream of the agricultural sector: the structure, prevalence, and diversity of ICEs will be evaluated. 

2. Acomparision of the resistomes between microbiomes will be conducted to determine if certain resistomes can move through the environment.

3. This work will also compare and contrast methods to achieve the objectives above.



# 1. Distribution of taxa in metegenomes

Using **Kraken2** tool against the nucleotide data base to determine the taxonomic diversity:

<https://github.com/catrionelee/ICE_MAG/blob/master/miniKraken2>

# 2. Metagenomic genome assembly pipeline

Using **nf-core/mag** pipeline to assemble MAGs

<https://github.com/catrionelee/ICE_MAG/blob/master/nf-core-mag>

## Choosing an Assembly 

Selecting all assemblies for SRR6512893 (fecal metagenome), the `quast_and_busco_summary.tsv` file was manipulated to show averages of each metric unless otherwise stated. All averages are rounded to nearest integar for simplicity.

| Metric | Megahit | metaSPAdes |
| --- | --- | --- |
| %Complete | 44 | 36 |
| %Missing | 9 | 55 |
| # contigs (>= 0 bp) | 340 | 307 |
| # contigs (>= 1000 bp) | 340 | 307 |
| # contigs (>= 5000 bp) SUM | 12521 | 14488 |
| # contigs (>= 10000 bp) SUM | 4490 | 5026 |
| # contigs (>= 25000 bp) SUM | 789 | 741 |
| # contigs (>= 50000 bp) SUM | 140 | 113 |
| Total length (>= 5000 bp) | 787877 | 696432 |
| Total length (>= 10000 bp) | 480925 | 406878 |
| Total length (>= 25000 bp) | 175414 | 125573 |
| Total length (>= 50000 bp) | 57029 | 34216 |
| # contigs | 340 | 307 |
| Largest contig | 31719 | 28152 |
| Total length | 1473125 | 1317251 |
| N50 | 7405 | 7455 |
| N75 | 4244 | 4073 |
| L50 | 95 | 86 |
| L75 | 187 | 170 |
| # N's per 100 kbp | 0 | 206 |

Based on the table's results and consulting the literature, **Megahit** will be the preffered assembler for our uses. van der Walt et al. 2017 and Vollmers et al. 2017 both agreed that metaSPAdes was better suited for community profiling, but that Megahit was better for determining micro diversity.



# 3. Identifying ICEs and ARGs in MAGs

Using the **CONJscan** module of MacSyFinder to locate ICEs in the MAGs. Could use built in database or ICEberg 2.0.


# 4. Identifying ICEs in reads

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

Output generated all desired and expected outputs (2020-10-01) so will continue with creating snakemake file to execute across all metagenomes. There are 303 putative ICEs. Average number of sequences per putative ICE was 141.627.

Each metagenomic environment will be run separately so to easily compare. Soil was ran with 500 Gb of memory (2020-10-03). <https://https://github.com/catrionelee/ICE_MAG/blob/master/metaCherchant/subset-soil>

2020-10-04: 500 Gb not enough for the script, 1000 Gb not enough, cannot cluster allocate >2000 Gb of memory. Script is loading all files and then going to analysis. could try making a snakemake file such that each read file is loaded, read, and then searched which will be stored in the output, then the script can move on to the next file, freeing up memory. <https://github.com/catrionelee/ICE_MAG/blob/master/metaCherchant/workflow_snakemake>


## A. SRR6512893 putative ICEs
*Each output folder is the entry no. in the ICEberg2.0 db* **Therefore No. 2 is CTn341**
SRR6512893 is a fecal metagenome. There are **303 ICEs** found with hits to the ICEberg 2.0 database.

### Coverage
Coverage was initially set to 5, but increasing to 10 and 20 resulted in:

* Coverage=10: **271** putative ICEs. Lost 32 putative ICEs.
* Coverage=20: **225** putative ICEs.

## B. Checking the output ICE identity
Initially thought that each output folder from initial run was indicating the ICEberge db ref number. However, this left 89 putative ICEs unaccounted for within the database. Then thought that the output folders were referencing the entry within the database (ignoring the header compoetely). Generated blast database from the iceberg fasta database `makeblastdb -in iceberg.fasta -dbtype nucl -parse_seqidsmakeblastdb -in iceberg.fasta -dbtype nucl -parse_seqids`, then blasted the sequences from each of the output folders against this: `blastn -db iceberg.fasta -query ./catrione_metagenomics/metacherchant/subset_SRR6512893/output/2/seqs.fasta -out blastn_2_vs_iceberg.txt`

The output 2 looks like it could match the 2nd entry, CTn341; or ref no. 58. I'm confident that the metacherchant algorithm would have been able to distiguish between the 2 and assigned it correctly. 

Looking at the 3rd output, it should be ICE|12|ICEVchBan5. Indeed this result pops up in the blast results but so do many other results so this one is less conclusive.


# 5. Identifying ARGs from context

### SRR6512893
There are a total of 4 ARG hits to 3 different putative ICEs from the NCBI db using ABRicate. There was *aadE* (x2), *mef(A)* (x1), and *tet(Q)*, where *mef(A)* and *tet(Q)* were found in the same putative ICE.

**When do we stop calling them putative?**

## Repeating metaCherchant and ABRicate with SRR9037497
Since there were only three total ICE's that contained an ARG in SRR6512893, we will try repeating the results with another fecal sample SRR9037497. Used the parameters in <> with a coverage = 10.

# 6. Determining taxonomy from context around ICEs

### SRR6512893
Used following command to submit to biocluster the snakefile <https://github.com/catrionelee/ICE_MAG/blob/master/metaCherchant/SRR6512893/kraken.smk>: 
`snakemake --cluster "qsub -V -cwd -pe smp {threads}" --jobs 50 -s kraken.smk --use-conda`
