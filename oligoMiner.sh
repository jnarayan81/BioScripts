#!/usr/bin/env bash

#Bash script to run oligoMiner tools by Jitendra
#These tools should in path
#bowtie2-build
#jellyfish
#python2.7
#conda create --name probeMining numpy scipy biopython scikit-learn

oligoScript=/home/urbe/Tools/OligoMiner 
genome=$1; #Genome file here
chrName=$2; #chromosome name here

if [ "$#" -lt 2 ];then
	echo "Try with genome.fa and chromosome name, for Example: ./probeMiner genome.fa chr1"
	else
		echo ">>Here we go now for oligo mining<< "

		echo '>>Creating bowtie index of the genome<<'
		#bowtie2-build $genome GenomeIndex

		echo '>>Working on JellyFish step of the genome<<'
		#jellyfish count -s 3300M -m 18 -o genomeJF.jf --out-counter-len 1 -L 2 $genome

		echo ">>Extract the chromosome of interest<<"
		#samtools faidx $genome $chrName > $chrName.fa

		echo '>>Parsing the oligos<<'
		python $oligoScript/blockParse.py -f $chrName.fa

		echo '>>Create the SAM<<'
		bowtie2 -x GenomeIndex -U $chrName.fastq --no-hd -t -k 100 --very-sensitive-local -S $chrName.sam

		echo '>>Cleaning the SAM<<'
		python $oligoScript/outputClean.py -u -f $chrName.sam

		echo '>>Kmer filtering of the oligos<<'
		python $oligoScript/kmerFilter.py -f Segkk175_probes.bed -m 18 -j 18 -j genomeJF.jf -k 4

		echo '>>Reverse complement of the oligos<<'
		python $oligoScript/probeRC.py -f Segkk175_probes.bed

		echo '>>Checking structure of the oligos<<'
		python $oligoScript/structureCheck.py -f Segkk175_probes_18_4.bed -t 0.4

		echo '>>Checking for temparature<<'
		awk 'BEGIN{ FS=OFS="\t" }{ print $1":"$2"-"$3"\t"$4 }' Segkk175_probes_18_4_sC.bed > allSeq.txt
		python $oligoScript/probeTm.py -f allSeq.txt
exit;
	fi

exit 0
