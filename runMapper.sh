#!/bin/bash

#only for LONG READS mapping 
#USAGE: runMapper.sh minimap2 ref.fa reads.fa/fq 48 ont
echo -e "This is a bash scrip to map your long reads and make it visualization ready !" 

#Location of the tools
samtools=/home/urbe/anaconda3/bin/samtools
graphMapLoc=/home/urbe/Tools/graphmap/bin/Linux-x64/graphmap
minimap2Loc=/home/urbe/Tools/minimap2-2.3_x64-linux/minimap2
bwaMemLoc=/home/urbe/anaconda3/bin/bwa
ngmlrLoc=/home/urbe/Tools/ngmlr/bin/ngmlr-0.2.3/ngmlr
lamsaLoc=/home/urbe/Tools/LAMSA/lamsa

#Parameters accepted
toolName=$1
refFasta=$2
longReads=$3
thread=$4
readsType=$5

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
   $bwaMemLoc mem $refFasta $longReads -t $thread > $fileName.out.sam
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
   		$minimap2Loc -ax map-ont $refFasta $longReads -t $thread > $fileName.out.sam
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
elif [ $toolName == "graphmap" ]; then
   echo "Mapping with $toolName"
   $graphMapLoc align -r $refFasta -d $longReads -t $thread -o $fileName.out.sam
else
   echo "Unknown mapper name and parameter !"
fi


echo "Getting files ready for visualization !"
$samtools view -Sb $fileName.out.sam | $samtools sort -m 4G -@$thread -o $fileName.sorted.bam - && $samtools index -@$thread $fileName.sorted.bam

echo "All Done :)"
