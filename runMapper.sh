#!/bin/bash

#only for LONG READS mapping 
#USAGE: runMapper.sh minimap2 ref.fa reads.fa/fq 48 ont default/strict
echo -e "This is a bash scrip to map your long reads and make it visualization ready !" 

#Location of the tools
samtools=/home/urbe/anaconda3/bin/samtools
graphMapLoc=/home/urbe/Tools/graphmap/bin/Linux-x64/graphmap
minimap2Loc=/home/urbe/Tools/minimap2-2.3_x64-linux/minimap2
bwaMemLoc=/home/urbe/anaconda3/bin/bwa
ngmlrLoc=/home/urbe/Tools/ngmlr/bin/ngmlr-0.2.3/ngmlr
lamsaLoc=/home/urbe/Tools/LAMSA/lamsa
lordfastLoc=/home/urbe/Tools/lordfast
cosineLoc=/home/urbe/Tools/cosine

#Parameters accepted
toolName=$1
refFasta=$2
longReads=$3
thread=$4
readsType=$5
accuracy=$6

if [ $# -lt 5 ]; then
    echo "No or less arguments provided"
    echo "#USAGE: runMapper.sh minimap2 ref.fa reads.fa/fq 48 ont"
    exit 1
fi

fileName=$(basename "$refFasta"); #fileName=$(basename "$refFasta" .fq);
echo "Name of the file used for mapping $fileName, present at $refFasta"

if [ $toolName == "bwa" ]; then
   echo "Mapping with $toolName"
   $bwaMemLoc index $refFasta
   	if [ $readsType == "ont" ]; then
   		if [ $accuracy == "default" ]; then
   		$bwaMemLoc mem -x ont2d $refFasta $longReads -t $thread > $fileName.out.sam
		else [ $accuracy == "strict" ]; then
		$bwaMemLoc mem -k 16 -W 60 $refFasta $longReads -t $thread > $fileName.out.sam
		fi
    	elif [ $readsType == "pacbio" ]; then
   		if [ $accuracy == "default" ]; then
   		$bwaMemLoc mem -x pacbio $refFasta $longReads -t $thread > $fileName.out.sam
		else [ $accuracy == "strict" ]; then
		$bwaMemLoc mem -k 16 -W 60 $refFasta $longReads -t $thread > $fileName.out.sam
	else
		echo "BWA mem:Please specify reads type: ont, pacbio"
	fi
elif [ $toolName == "lamsa" ]; then
   echo "Mapping with $toolName"
   $lamsaLoc index $refFasta
	if [ $readsType == "ont" ]; then
   		$lamsaLoc aln -t $thread -T ont2d $refFasta $longReads > $fileName.out.sam
	elif [ $readsType == "pacbio" ]; then
   		$lamsaLoc aln -t $thread -T pacbio $refFasta $longReads > $fileName.out.sam
	else
		echo "LAMSA:Please specify reads type: ont, pacbio"
	fi
elif [ $toolName == "minimap2" ]; then
   echo "Mapping with $toolName"
	if [ $readsType == "ont" ]; then
		if [ $accuracy == "default" ]; then
   		$minimap2Loc -ax map-ont $refFasta $longReads -t $thread > $fileName.out.sam
		else [ $accuracy == "strict" ]; then
		$minimap2Loc -ax map-ont -k 14 -W 45 $refFasta $longReads -t $thread > $fileName.out.sam
		fi
	elif [ $readsType == "pacbio" ]; then
   		$minimap2Loc -ax map-pb $refFasta $longReads -t $thread > $fileName.out.sam
	else
		echo "MINIMAP2:Please specify reads type: ont, pacbio"
	fi
elif [ $toolName == "ngmlr" ]; then
   echo "Mapping with $toolName"
	if [ $readsType == "ont" ]; then
   		$ngmlrLoc -t $thread -r $refFasta -q $longReads -o $fileName.out.sam -x $readsType
	elif [ $readsType == "pacbio" ]; then
   		$ngmlrLoc -t $thread -r $refFasta -q $longReads -o $fileName.out.sam -x $readsType
	else
		echo "NGMLR:Please specify reads type: ont, pacbio"
	fi
elif [ $toolName == "cosine" ]; then
   echo "Mapping with $toolName"
   $cosineLoc --ref_filename $refFasta --output_ref_prefix $fileName.out --fft_block_size 32768 --kmer_size 3 --max_read_size 5000 --window_size 500 --window_shift 100 --seed 0 --save_ref_fft 1
	if [ $readsType == "ont" ]; then
   		$cosineLoc --ref_filename $refFasta --read_filename $longReads --output_ref_prefix $fileName.out.sam --output_read_prefix $fileName.out.sam --fft_block_size 32768  --max_num_fft_blocks 15 --num_threads $thread --kmer_size 3 --max_read_size 5000 --window_size 100 --window_shift 10 --min_dp_score 100 --seed 1
	elif [ $readsType == "pacbio" ]; then
   		$cosineLoc --ref_filename $refFasta --read_filename $longReads --output_ref_prefix $fileName.out.sam --output_read_prefix $fileName.out.sam --fft_block_size 32768  --max_num_fft_blocks 15 --num_threads $thread --kmer_size 3 --max_read_size 5000 --window_size 250 --window_shift 50 --min_dp_score 100 --seed 1
	else
		echo "COSINE:Please specify reads type: ont, pacbio"
	fi
elif [ $toolName == "graphmap" ]; then
   echo "Mapping with $toolName"
   $graphMapLoc align -r $refFasta -d $longReads -t $thread -o $fileName.out.sam
elif [ $toolName == "lordfast" ]; then
   echo "Mapping with $toolName"
   $lordfastLoc --index $refFasta
   $lordfastLoc --search $refFasta --seq $longReads --threads $thread > $fileName.out.sam
else
   echo "Unknown mapper name and parameter !"
fi
	       
echo "Getting files ready for visualization !"
$samtools view -Sb $fileName.out.sam | $samtools sort -m 4G -@ $thread -o $fileName.sorted.bam - && $samtools index -@ $thread $fileName.sorted.bam

echo "All Done :)"
