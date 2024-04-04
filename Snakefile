sample = ["sample_1", "sample_2"]

sjdb = 149

wildcard_constraints:
	sample = '|'.join([re.escape(x) for x in sample])

rule the_end:
	input:
		expand("3_star_mapped/{sample}/{sample}.ReadsPerGene.out.tab", sample=sample),
		expand("3_star_mapped/{sample}/{sample}.Aligned.sortedByCoord.out.bam", sample=sample),
		expand('3_salmon_quant/{sample}/quant.sf', sample=sample),
		"5_GATK/snps_filtered.vcf.gz",
		"5_GATK/indels_filtered.vcf.gz"

	threads: 1
	params:
		runtime="0:01:00",
		job_name="the_end"

rule trim:
	input:
		"0_raw/comb/{sample}.fastq.gz"
	output:
		fq=temp("2_trimmomatic/{sample}.trimmed.fastq.gz"),
		log="2_trimmomatic/log/{sample}.stats"
	threads: 8
	params:
		runtime="0:30:00",
		job_name="trim.{sample}"
	benchmark:
		"benchmarks/trim.{sample}.txt"
	shell:
	    "trimmomatic SE -phred33 {input} {output.fq} "
		"ILLUMINACLIP:adapters/TruSeq3-SE.fa:2:30:10 "
		"LEADING:5 TRAILING:5 SLIDINGWINDOW:5:20 "
		"MINLEN:30 -threads {threads} "
		"-summary {output.log}"

rule salmon_index:
	input:
		decoys='genome/ARS-UCD2.0/GCF_002263795.3/decoys.txt',
		gentrome='genome/ARS-UCD2.0/GCF_002263795.3/gentrome.fna'
	output:
		directory('genome/ARS-UCD2.0/GCF_002263795.3/salmon_index')
	threads: 12
	params:
		runtime='00:30:00',
		job_name="salmon_index"
	benchmark:
		"benchmarks/salmon_index.txt"
	shell:
		"./code/salmon index --threads {threads} --decoys {input.decoys} -i {output} -t {input.gentrome}"

rule salmon_quant:
	input:
		salmon_index="genome/ARS-UCD2.0/GCF_002263795.3/salmon_index",
		fq="2_trimmomatic/{sample}.trimmed.fastq.gz"
	output:
		"3_salmon_quant/{sample}/quant.sf",
		temp('3_salmon_quant/{sample}/cmd_info.json'),
		temp('3_salmon_quant/{sample}/lib_format_counts.json'),
		temp(directory('3_salmon_quant/{sample}/libParams')),
		temp(directory('3_salmon_quant/{sample}/aux_info')),
		temp(directory('3_salmon_quant/{sample}/logs'))
	threads: 8
	params:
		runtime="00:30:00",
		job_name="salmon_quant_{sample}",
		out_prefix="3_salmon_quant/{sample}"
	benchmark:
		"benchmarks/salmon_quant_{sample}.txt"
	shell:
		"./code/salmon quant --threads {threads} -i {input.salmon_index} -l A "
		"-r {input.fq} --validateMappings -o {params.out_prefix}"

rule star_idx:
	input:
		fna="genome/ARS-UCD2.0/GCF_002263795.3/GCF_002263795.3_ARS-UCD2.0_genomic.fna",
		gtf="genome/ARS-UCD2.0/GCF_002263795.3/genomic.gtf"
	output:
		directory("genome/ARS-UCD2.0/GCF_002263795.3/starIndex/")
	threads: 32
	params:
		runtime="0:30:00",
		job_name="star_idx_genome"
	benchmark:
		"benchmarks/star_idx_genome.txt"
	shell:
	    "mkdir -p {output}; "
		"STAR --runThreadN {threads} "
		"--runMode genomeGenerate "
		"--genomeDir {output} "
		"--genomeFastaFiles {input.fna} "
		"--sjdbGTFfile {input.gtf} "
		"--sjdbOverhang {sjdb} "
		"--outTmpDir /lustre/isaac/scratch/rmohame2/STARtmp"


rule star_mapping:
	input:
		fq="2_trimmomatic/{sample}.trimmed.fastq.gz",
		genome_idx="genome/ARS-UCD2.0/GCF_002263795.3/starIndex/",
		gtf="genome/ARS-UCD2.0/GCF_002263795.3/genomic.gtf"
	output:
		"3_star_mapped/{sample}/{sample}.ReadsPerGene.out.tab",
		"3_star_mapped/{sample}/{sample}.Log.final.out",
		temp("3_star_mapped/{sample}/{sample}.SJ.out.tab"),
		temp("3_star_mapped/{sample}/{sample}.Log.out"),
		temp("3_star_mapped/{sample}/{sample}.Aligned.sortedByCoord.out.bam"),
		temp("3_star_mapped/{sample}/{sample}.Log.progress.out"),
		temp(directory("3_star_mapped/{sample}/{sample}._STARgenome"))
	threads: 16
	params:
		runtime="0:20:00",
		job_name="star_mapping.{sample}",
		out_prefix="3_star_mapped/{sample}/{sample}."
	benchmark:
		"benchmarks/star_mapping.{sample}.txt"
	shell:
		"STAR --genomeDir {input.genome_idx} "
	        "--runThreadN {threads} "
		"--readFilesIn {input.fq} "
		"--readFilesCommand zcat "
		"--sjdbGTFfile {input.gtf} "
		"--outFileNamePrefix {params.out_prefix} "
		"--outSAMtype BAM SortedByCoordinate "
		"--outSAMunmapped Within "
		"--outSAMattributes Standard "
		"--quantMode GeneCounts "
		"--sjdbOverhang {sjdb}"


rule star_map_2pass:
	input:
		fq="2_trimmomatic/{sample}.trimmed.fastq.gz",
		genome_idx="genome/ARS-UCD2.0/GCF_002263795.3/starIndex/",
		gtf="genome/ARS-UCD2.0/GCF_002263795.3/genomic.gtf",
		sjdbFiles=expand("3_star_mapped/{sample}/{sample}.SJ.out.tab", sample=sample)
	output:
		"3_star_mapped_2pass/{sample}/{sample}.Log.final.out",
		temp("3_star_mapped_2pass/{sample}/{sample}.Aligned.sortedByCoord.out.bam"),
		temp("3_star_mapped_2pass/{sample}/{sample}.Log.out"),
		temp("3_star_mapped_2pass/{sample}/{sample}.SJ.out.tab"),
		temp("3_star_mapped_2pass/{sample}/{sample}.Log.progress.out"),
		temp(directory("3_star_mapped_2pass/{sample}/{sample}._STARgenome"))
	threads: 16
	params:
		runtime="0:45:00",
		job_name="star_map_2pass.{sample}",
		out_prefix="3_star_mapped_2pass/{sample}/{sample}."
	benchmark:
		"benchmarks/star_map_2pass.{sample}.benchmark.txt"
	shell:
		"STAR --genomeDir {input.genome_idx} "
		"--runThreadN {threads} "
		"--readFilesIn {input.fq} "
		"--readFilesCommand zcat "
		"--sjdbGTFfile {input.gtf} "
		"--sjdbFileChrStartEnd {input.sjdbFiles} "
		"--outFileNamePrefix {params.out_prefix} "
		"--outSAMtype BAM SortedByCoordinate "
		"--outSAMunmapped Within "
		"--outSAMattributes Standard "
		"--sjdbOverhang {sjdb}"


rule bam_index:
	input:
		"3_star_mapped_2pass/{sample}/{sample}.Aligned.sortedByCoord.out.bam"
	output:
		bam=temp("4_preGATK/{sample}/{sample}.Aligned.sortedByCoord.out.bam"),
		bai=temp("4_preGATK/{sample}/{sample}.Aligned.sortedByCoord.out.bai")
	threads: 1
	params:
		runtime="0:05:00",
		job_name="bam_index.{sample}"
	benchmark:
		"benchmarks/bam_index.{sample}.benchmark.txt"
	shell:
		"mkdir -p $PWD/$(dirname {output.bam}); "
		"ln -s $PWD/{input} $PWD/$(dirname {output.bam}) ; "
		"samtools index -@ {threads} -b {output.bam} {output.bai}"


rule AddOrReplaceReadGroups:
	input:
		bam="4_preGATK/{sample}/{sample}.Aligned.sortedByCoord.out.bam",
		bai="4_preGATK/{sample}/{sample}.Aligned.sortedByCoord.out.bai",
		lnbam="3_star_mapped_2pass/{sample}/{sample}.Aligned.sortedByCoord.out.bam"
	output:
		bam=temp("4_preGATK/{sample}/{sample}.Aligned.sortedByCoord.RG.bam"),
		bai=temp("4_preGATK/{sample}/{sample}.Aligned.sortedByCoord.RG.bai")
	threads: 1
	params:
		runtime="0:05:00",
		job_name="RG.{sample}",
		id="{sample}"
	benchmark:
		"benchmarks/RG.{sample}.benchmark.txt"
	shell:
	    "java -XX:ConcGCThreads={threads} "
		"-jar ./code/picard.jar  AddOrReplaceReadGroups "
		"I={input.bam} "
		"O={output.bam} "
		"SORT_ORDER=coordinate "
		"RGSM={params.id} "
		"RGID={params.id} "
		"RGLB=Takara "
		"RGPL=illumina " 
		"RGPU={params.id} "
		"CREATE_INDEX=True"


rule MarkDuplicates:
	input:
		bam="4_preGATK/{sample}/{sample}.Aligned.sortedByCoord.RG.bam",
		bai="4_preGATK/{sample}/{sample}.Aligned.sortedByCoord.RG.bai"
	output:
		bam=temp("4_preGATK/{sample}/{sample}.Aligned.sortedByCoord.RG.dedup.bam"),
		bai=temp("4_preGATK/{sample}/{sample}.Aligned.sortedByCoord.RG.dedup.bai"),
		metrics="4_preGATK/{sample}/{sample}.dedup.metrics"
	threads: 1
	params:
		runtime="0:10:00",
		job_name="dedup.{sample}"
	benchmark:
		"benchmarks/dedup.{sample}.benchmark.txt"
	shell:
	    "java -XX:ConcGCThreads={threads} "
		"-jar ./code/picard.jar MarkDuplicates "
		"I={input.bam} "
		"O={output.bam} "
		"CREATE_INDEX=true "
		"VALIDATION_STRINGENCY=SILENT "
		"M={output.metrics}"


rule SplitNTrim:
	input:
		genome="genome/GCF_002263795.2_ARS-UCD1.3_genomic.fna",
		bam="4_preGATK/{sample}/{sample}.Aligned.sortedByCoord.RG.dedup.bam",
		bai="4_preGATK/{sample}/{sample}.Aligned.sortedByCoord.RG.dedup.bai"
	output:
		bam=temp("4_preGATK/{sample}/{sample}.Aligned.sortedByCoord.RG.dedup.SplitNTrim.bam"),
		bai=temp("4_preGATK/{sample}/{sample}.Aligned.sortedByCoord.RG.dedup.SplitNTrim.bai")
	threads: 8
	params:
		runtime="0:45:00",
		job_name="SplitNTrim.{sample}"
	benchmark:
		"benchmarks/SplitNTrim.{sample}.benchmark.txt"
	shell:
		"./code/gatk --java-options '-XX:ConcGCThreads={threads}' SplitNCigarReads "
		"-R {input.genome} "
		"-I {input.bam} "
		"-O {output.bam} "


rule HaplotypeCaller:
	input:
		genome="genome/GCF_002263795.2_ARS-UCD1.3_genomic.fna",
		bam="4_preGATK/{sample}/{sample}.Aligned.sortedByCoord.RG.dedup.SplitNTrim.bam",
		bai="4_preGATK/{sample}/{sample}.Aligned.sortedByCoord.RG.dedup.SplitNTrim.bai"
	output:
		vcf=temp("5_GATK/per_sample/{sample}.vcf.gz"),
		tbi=temp("5_GATK/per_sample/{sample}.vcf.gz.tbi")
	threads: 8
	params:
		runtime="01:30:00",
		job_name="HaplotypeCaller.{sample}"
	benchmark:
		"benchmarks/HaplotypeCaller.{sample}.benchmark.txt"
	shell:
		"./code/gatk --java-options '-XX:ConcGCThreads=8 -Xmx8g' HaplotypeCaller "
		"-R {input.genome} "
		"-I {input.bam} "
		"-O {output.vcf} "
		"-stand-call-conf 20 "
		"-ERC GVCF "
		"--pcr-indel-model NONE"


rule GenomicsDBImport:
	input:
		expand("5_GATK/per_sample/{sample}.vcf.gz.tbi", sample=sample),
		Rius113="5_GATK/per_sample/Rius113_Taka_230310_S29.vcf.gz",
		Rius114="5_GATK/per_sample/Rius114_Taka_230310_S30.vcf.gz",
		Rius115="5_GATK/per_sample/Rius115_Taka_230310_S31.vcf.gz",
		Rius116="5_GATK/per_sample/Rius116_Taka_230310_S32.vcf.gz",
		Rius118="5_GATK/per_sample/Rius118_Taka_230310_S33.vcf.gz",
		Rius119="5_GATK/per_sample/Rius119_Taka_230310_S34.vcf.gz",
		Rius120="5_GATK/per_sample/Rius120_Taka_230310_S35.vcf.gz",
		Rius281="5_GATK/per_sample/Rius281_Taka_230310_S36.vcf.gz",
		Rius282="5_GATK/per_sample/Rius282_Taka_230310_S37.vcf.gz",
		Rius283="5_GATK/per_sample/Rius283_Taka_230310_S38.vcf.gz",
		Rius284="5_GATK/per_sample/Rius284_Taka_230310_S39.vcf.gz",
		Rius287="5_GATK/per_sample/Rius287_Taka_230310_S40.vcf.gz",
		Rius288="5_GATK/per_sample/Rius288_Taka_230310_S41.vcf.gz",
		Rius313="5_GATK/per_sample/Rius313_Taka_230310_S42.vcf.gz",
		Rius314="5_GATK/per_sample/Rius314_Taka_230310_S43.vcf.gz",
		Rius315="5_GATK/per_sample/Rius315_Taka_230310_S44.vcf.gz",
		Rius316="5_GATK/per_sample/Rius316_Taka_230310_S45.vcf.gz",
		Rius318="5_GATK/per_sample/Rius318_Taka_230310_S46.vcf.gz",
		Rius319="5_GATK/per_sample/Rius319_Taka_230310_S20.vcf.gz",
		Rius320="5_GATK/per_sample/Rius320_Taka_230310_S21.vcf.gz",
		Rius89="5_GATK/per_sample/Rius89_Taka_230310_S22.vcf.gz",
		Rius90="5_GATK/per_sample/Rius90_Taka_230310_S23.vcf.gz",
		Rius91="5_GATK/per_sample/Rius91_Taka_230310_S24.vcf.gz",
		Rius92="5_GATK/per_sample/Rius92_Taka_230310_S25.vcf.gz",
		Rius93="5_GATK/per_sample/Rius93_Taka_230310_S26.vcf.gz",
		Rius95="5_GATK/per_sample/Rius95_Taka_230310_S27.vcf.gz",
		Rius96="5_GATK/per_sample/Rius96_Taka_230310_S28.vcf.gz"
	output:
		temp(directory("5_GATK/GenomicsDBImport_database"))
	threads: 8
	params:
		runtime="03:00:00",
		job_name="GenomicsDBImport"
	benchmark:
		"benchmarks/GenomicsDBImport.benchmark.txt"
	shell:
		"./code/gatk --java-options '-XX:ConcGCThreads=8 -Xmx16g' GenomicsDBImport "
		"-V {input.Rius113} "
		"-V {input.Rius114} "
		"-V {input.Rius115} "
		"-V {input.Rius116} "
		"-V {input.Rius118} "
		"-V {input.Rius119} "
		"-V {input.Rius120} "
		"-V {input.Rius281} "
		"-V {input.Rius282} "
		"-V {input.Rius283} "
		"-V {input.Rius284} "
		"-V {input.Rius287} "
		"-V {input.Rius288} "
		"-V {input.Rius313} "
		"-V {input.Rius314} "
		"-V {input.Rius315} "
		"-V {input.Rius316} "
		"-V {input.Rius318} "
		"-V {input.Rius319} "
		"-V {input.Rius320} "
		"-V {input.Rius89} "
		"-V {input.Rius90} "
		"-V {input.Rius91} "
		"-V {input.Rius92} "
		"-V {input.Rius93} "
		"-V {input.Rius95} "
		"-V {input.Rius96} "
		"--genomicsdb-workspace-path {output} "
		"--tmp-dir /lustre/isaac/scratch/rmohame2/tmp "
		"-L genome/whole_genome_ids.list"


rule joint_call:
	input:
		genome="genome/GCF_002263795.2_ARS-UCD1.3_genomic.fna",
		db="5_GATK/GenomicsDBImport_database"
	output:
		vcf="5_GATK/jointGVCFs.vcf.gz",
		tbi="5_GATK/jointGVCFs.vcf.gz.tbi"
	threads: 8
	params:
		runtime="03:00:00",
		job_name="joint_call"
	benchmark:
		"benchmarks/joint_call.benchmark.txt"
	shell:
	    "./code/gatk --java-options '-XX:ConcGCThreads={threads} -Xmx16g' GenotypeGVCFs "
		"-R {input.genome} "
		"-V gendb://{input.db} "
		"-O {output.vcf} "
		"--tmp-dir /lustre/isaac/scratch/rmohame2/tmp "


rule bcftools_stats:
	input:
		genome="genome/GCF_002263795.2_ARS-UCD1.3_genomic.fna",
		vcf="5_GATK/jointGVCFs.vcf.gz",
                tbi="5_GATK/jointGVCFs.vcf.gz.tbi"
	output:
		bcfstats="5_GATK/bcfstats.txt"
	threads: 1
	params:
		runtime="00:05:00",
		job_name="bcftools"
	benchmark:
		"benchmarks/bcftools_stats.benchmark.txt"
	shell:
		"./code/bcftools stats --threads {threads} -F {input.genome} {input.vcf} > {output.bcfstats}"

rule split_variants:
	input:
		vcf="5_GATK/jointGVCFs.vcf.gz",
		tbi="5_GATK/jointGVCFs.vcf.gz.tbi"
	output:
		snps="5_GATK/snps.vcf.gz",
		indels="5_GATK/indels.vcf.gz"
	threads: 1
	params:
		runtime="00:10:00",
		job_name="split_variants"
	benchmark:
		"benchmarks/split_variants.benchmark.txt"
	shell:
		"./code/gatk --java-options '-XX:ConcGCThreads={threads} -Xmx16g' SelectVariants "
		"-V {input.vcf} -select-type SNP -O {output.snps}; "
		"./code/gatk --java-options '-XX:ConcGCThreads={threads} -Xmx16g' SelectVariants "
		"-V {input.vcf} -select-type INDEL -O {output.indels} "

rule VariantFiltration_SNPs:
	input:
		genome="genome/GCF_002263795.2_ARS-UCD1.3_genomic.fna",
                vcf="5_GATK/snps.vcf.gz"
	output:
		vcf="5_GATK/snps_filtered.vcf.gz"
	threads: 2
        params:
                runtime="00:20:00",
                job_name="VariantFiltration_SNPs"
	benchmark:
                "benchmarks/VariantFiltration_SNPs.benchmark.txt"
	shell:
		"/code/gatk --java-options '-XX:ConcGCThreads={threads} -Xmx16g' VariantFiltration "
		"-R {input.genome} "
		"-V {input.vcf} "
		"-O {output.vcf} "
		"--filter-name QD2 --filter-expression QD < 2.0 "
                "--filter-name FS60 --filter-expression FS > 60.0 "
                "--filter-name MQ40 --filter-expression MQ < 40.0 "
                "--filter-name MQRandSum_n12.5 --filter-expression MQRandSum < -12.5 "
                "--filter-name ReadPosRankSum_n8.0 --filter-expression ReadPosRankSum < -8.0 "
                "--filter-name SOR3 --filter-expression SOR > 3.0 "



rule VariantFiltration_indels:
	input:
		genome="genome/GCF_002263795.2_ARS-UCD1.3_genomic.fna",
                vcf="5_GATK/indels.vcf.gz"
	output:
		vcf="5_GATK/indels_filtered.vcf.gz"
	threads: 2
	params:
		runtime="00:20:00",
		job_name="VariantFiltration_indels"
	benchmark:
		"benchmarks/VariantFiltration_indels.benchmark.txt"
	shell:
                "/code/gatk --java-options '-XX:ConcGCThreads={threads} -Xmx16g' VariantFiltration "
		"-R {input.genome} "
                "-V {input.vcf} "
                "-O {output.vcf} "
                "--filter-name QD2 --filter-expression QD < 2.0 "
                "--filter-name FS60 --filter-expression FS > 60.0 "
                "--filter-name MQ40 --filter-expression MQ < 40.0 "
		"--filter-name MQRandSum_n12.5 --filter-expression MQRandSum < -12.5 "
                "--filter-name ReadPosRankSum_n8.0 --filter-expression ReadPosRankSum < -8.0 "
                "--filter-name SOR3 --filter-expression SOR > 3.0 "

rule bcftools_stats_2:
	input:
		genome="genome/GCF_002263795.2_ARS-UCD1.3_genomic.fna",
		snps="5_GATK/snps_filtered.vcf.gz",
		indels="5_GATK/indels_filtered.vcf.gz"
	output:
		snps="5_GATK/snps_filtered.bcfstats.txt",
		indels="5_GATK/indels_filtered.bcfstats.txt"
	threads: 1
	params:
		runtime="00:05:00",
		job_name="bcftools"
	benchmark:
		"benchmarks/bcftools_stats.benchmark.txt"
	shell:
		"./code/bcftools stats --threads {threads} -F {input.genome} {input.snps} > {output.snps}; "
                "./code/bcftools stats --threads {threads} -F {input.genome} {input.indels} > {output.indels} "
