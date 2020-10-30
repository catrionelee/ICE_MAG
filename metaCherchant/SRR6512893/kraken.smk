import pandas as pd

configfile: 'kraken_config.yaml'

SAMPLE = pd.read_csv(config["samples"], sep="\t").set_index("sample", drop=False)

KRAKEN_CLASSIFICATIONS = expand('kraken_results/{sample}_kraken_classification.txt', sample = SAMPLE.index)

KRAKEN_REPORTS = expand('kraken_results/{sample}_kraken_report.txt', sample=SAMPLE.index)

rule all:
    input:
        KRAKEN_CLASSIFICATIONS, KRAKEN_REPORTS

rule kraken2:
    input:
        input='/home/AAFC-AAC/leecat/catrione_metagenomics/metacherchant/subset_SRR6512893/output/{sample}/seqs.fasta'
    params:
        thread = 8,
        confidence = 0,
        base_qual = 0
    output:
        kraken_class = 'kraken_results/{sample}_kraken_classification.txt',
        kraken_report = 'kraken_results/{sample}_kraken_report.txt'
    conda: 
        'envs/kraken2.yaml'
    shell:
        "kraken2 "
        "--db /isilon/saint-hyacinthe-rdc/users/gauthierm/db/kraken2_nt_buildnewdb "
        "--threads {params.thread} "
        "--output {output.kraken_class} "
        "--confidence {params.confidence} "
        "--minimum-base-quality {params.base_qual} "
        "--report {output.kraken_report} "
        #"--memory-mapping "
        #"--paired "
        "--use-names "
        #"--gzip-compressed "
        "{input.input}"
        
