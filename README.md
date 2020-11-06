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


# 4. Identifying ICEs with ARGs in reads

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


## C. Identifying ARGs from context

### SRR6512893
There are a total of 4 ARG hits to 3 different putative ICEs from the NCBI db using ABRicate. There was *aadE* (x2), *mef(A)* (x1), and *tet(Q)*, where *mef(A)* and *tet(Q)* were found in the same putative ICE. The ICEs were "32" CTnBST, "439" ICESag37, and "480" CTnHyB.
```
abricate --db megares catrione_metagenomics/metacherchant/ICE_in_reads/subset_SRR6512893/output/*/seqs.fasta > all
```

**When do we stop calling them putative?**

### SRR9037497
Since there were only three total ICE's that contained an ARG in SRR6512893, we will try repeating the results with another fecal sample SRR9037497. Used the parameters in <> with a coverage = 10.

This resulted in 162 putative ICEs.

`abricate --db megares ./output/*/seqs.fasta > ARGs_in_ICE_megares.txt`
There were no ARGs found within those 162 ICEs from the MEGARes database.


## D. Determining taxonomy from context around ICEs

### SRR6512893
Used following command to submit to biocluster the snakefile <https://github.com/catrionelee/ICE_MAG/blob/master/metaCherchant/SRR6512893/kraken.smk>: 
`snakemake --cluster "qsub -V -cwd -pe smp {threads}" --jobs 50 -s kraken.smk --use-conda`

Of the 303 total jobs, 268 succeeded while 35 failed.
For the three ICEs with ARGs:

#### "32" CTnBST, GenBank AY345595
The original bacterium was *Bacteroides uniformis*. There were hits to the Family Bacteroideae to which this bacterium belongs. The other hits were confidently in the Order Clostridiales, with prominant species being *Clostridium bolteae* and most probably *Clostridioides difficile*.

#### "439" ICESag37, GenBank CP019978
The original bacterial host for the ICE was *Streptococcus agalactiae* and there were numerous hits to the Streptococcus Genus. The Other prominant hits beloing to the ORder Clostridiales, with *Clostridioides difficile* present but most probably *Roseburia intestinalis*.

#### "480" CTnHyB, GenBank KJ816753
The original host bacterium was *Bacteroides fragilis* and the only taxonomic assignment was to this bacterium. This indicates that this particular ICE has not switched hosts and has stayed integrated into the chromosome.


# 5.  Finding ARGs associated with ICEs in reads
Since the ICEs found within reads (metaCherchant w/ ICEberg2.0) were highly fragmented, it was difficult to find complete enough ICEs to detect any ARGs within them. Instead, by first searching for the ARGs in the reads (metaCherchant w/ MEGARes), then using the flanking regions/context to find associated ICEs we should have higher yields.

Used metaCherchant with the MEGARes database against the SRR6512893 reads with following parameters.
<https://github.com/catrionelee/ICE_MAG/tree/master/metaCherchant/ARG%20in%20reads>
Used coverage of 10 for results.

Found 476 ARGs.

Used metaCherchant again but with ICEberg database against the constructed/pulle dsequences from previous run with ARGs. This will determine if there are any ARGs surrounded by ICEs based on their context. Used the pollowing prarameters, excet with coverage of 5 because context will be less complete:
<https://github.com/catrionelee/ICE_MAG/blob/master/metaCherchant/ARG%20in%20reads/params_for_ARG_ICE> 

Found 173 ICEs associated with ARGs in SRR6512893. The directory names are the same entries to the ICEberg database, like before. The three ICEs detected earlier are contained within this list of 173.

Ran ARBicate with the MEGARes database against the "constructed" ICEs but found 0 ARGs. This seems to indicate that ABRicate is unable to detect ARGs from the seqs.fasta files that metaCherchatn generates. 


## A. Match putative ICEs to ARGs associated with
Looking at putative ICE "32", found 2 read ids's: Id48 and Id187. Using `grep -w "Id48" */seqs.fasta` and with Id187, found no matches at all to the ARGs output sequences. This indicates that the Id's are unique to each metaCherchant run and cannot be compared.

Using BLASTn instead:
```
blastn -subject ../ICE/output/*/seqs.fasta -query */seqs.fasta -out ../ICE/blastn_ARGs_v_ICEs.txt -outfmt 7
```
Too many arguments in the `seqs.fasta` files. Need to narrow down to single ICE.

```
blastn -subject */seqs.fasta -query ../ICE/output/32/seqs.fasta -out ../ICE/blastn_32_v_ARGs.txt -outfmt 7
```
Too many arguments. Can only do 1 agaisnt 1 at a time apparently. Need to make a Snakefile.


## B. Confirming ICEs
According to Stafford et al. 2020 there are 5 essential ICE genes. Found primers and created fasta file with them all inside. Made script to print out each putative ICE's # ids and wc -c (i.e. the length of the sequence).
```
#!/usr/bin/env bash

rm largest_ICE_from_read.txt
touch largest_ICE_from_read.txt

readarray -t array < "list_ICE_w_ARGs.txt"

for i in "${array[@]}"
do
      :
        id=`grep -c "^>" ../output/$i/seqs.fasta`
        word=`wc -c ../output/$i/seqs.fasta`
        echo -e "ICE_$i\t$id ids\t$word length" >> largest_ICE_from_read.txt
done
```
Retrieved the ones with 9 or more ids and these happened to coincide with the longest total sequences. These graph.gfa I downloaded, loaded into Bandage and extracted the paths into separate fasta files. Then ran BLASTn: `blastn -subject essential_ICE_primers.fasta -query bandage_paths/* -out paths_v_primers_blast.txt -outfmt 7` but encountered error: `Error: Too many positional arguments (1), the offending value: bandage_paths/140_path_2.fasta`.



