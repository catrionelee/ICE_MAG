import pandas as pd

configfile: 'abricate_config.yaml'

FECAL_SAMPLES = pd.read_csv(config["fecal"], sep="\t").set_index("mag", drop=False)



#ABRICATE_REPORTS = expand('/abricate_results/{env}_ARGs/{assembly}/{sample}/{mag}_ARGs.txt', env = ENVIRONMENT.index, sample = SAMPLE.index, assembly = ASSEMBLY.index, contig = CONTIG.index)

rule all:
	input:
		'contigs_w_chrom_assoc_args.txt'
#		ABRICATE_REPORTS,
		env = lambda wildards: SAMPLE.loc[wildcards.mag, 'Environment'],
		sample = lambda wildcards: SAMPLE.loc[wildcards.mag, 'Sample'],
		assembly = lambda wildcards: SAMPLE.loc[wildcards.mag, 'Assembly'],
		bin = lambda wildcards: SAMPLE.loc[wildcards.mag, 'BIN']


rulte test:
	input:
                SAMPLE.loc[wildcards.sample, 'location']
	output:
		'test/{sample}_{contig}_location.txt'
	shell:
		'echo {input} > {output}'


rule abricate_arg:
	input:
		lambda wildcards: SAMPLE.loc[wildcards.sample, 'location']
	output:
		'abricate_arg/{assembly}/{assembly}_{bin}_args.txt'
	conda:
		'~/miniconda3/envs/abricate.yaml'
	shell:
		'abricte --db megares --fofn {input} > {output}' 


rule abricate_plasmid:
	input:
                lambda wildcards: SAMPLE.loc[wildcards.sample, 'location']
	output:
		'abricate_plasmid/{assembly}/{sample}_plasmids.txt'
	conda:
                '~/miniconda3/envs/abricate.yaml'
	shell:
                'abricte --db plasmidfinder --fofn {input} > {output}'


rule blast_ice:
	input:
		db='~/iceberg.fasta',
		mag='SAMPLE.loc[wildcards.sample, "location"]'
	output:
		'blast_ice/{assembly}/{sample}_ices.txt'
	shell:
		'blastn -db {db} -query {mag} -outfmt 7 -out {output}'


rule get_arg_contigs:
	input:
                'abricate_arg/{assembly}/{sample}_args.txt'
	output:
		'contigs_w_args.txt'
	shell:
		'm=$(awk "{print $1}" {input})',
		'c=$(awk "{print $2}" {input})',
		'echo -e "$m\t$c" >> {output}'


rule get_plasmid_contigs:
	input:
		'abricate_plasmid/{assembly}/{sample}_plasmids.txt'
	output:
		'contigs_w_plasmids.txt'
	shell:
                'm=$(awk "{print $1}" {input})'
                'c=$(awk "{print $2}" {input})'
                'echo -e "$m\t$c" >> {output}'



rule arg-plasmid_compare:
	input:
		arg='contigs_w_args.txt'
		plasmid='contigs_w_plasmids.txt'
	output:
		'contigs_w_plasmid_assoc_args.txt'
	shell:
		'awk "FNR==NR{a[$1,$2];next} (($1,$2) in a)" {arg} {plasmid} > {output}'
		

rule arg-ice_compare:
	input:
                arg='contigs_w_args.txt'
		ice='
	output:
		'contigs_w_ice_assoc_args.txt'
	shell:
                'awk "FNR==NR{a[$1,$2];next} (($1,$2) in a)" {arg} {ice} > {output}'

		

rule lonely_arg:
	input:
		arg='contigs_w_args.txt'
		plasmid_arg='contigs_w_plasmid_assoc_args.txt'
		ice_arg='contigs_w_ice_assoc_args.txt'
	output:
		'contigs_w_chrom_assoc_args.txt'
	shell:
		'x=$(comm -13 <(sort {arg}) <(sort {plasmid_arg}))'
		'y=$(comm -13 <(sort $x) <(sort {ice_arg})'
		'echo $y > {output}'

