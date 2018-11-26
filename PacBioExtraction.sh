#!/usr/bin/env bash
#PacBio reads extraction scritps by Jitendra
#You need to install bax2bam #conda install -c bioconda bax2bam
# install bamtools package conda install -c bioconda bamtools 

echo "Extraction begins"

outFolder=$1;
mkdir $outFolder

for i in *zip; do unzip $i; tar -xvzf *.tar.gz; bax2bam *_1/Analysis_Results/*.1.bax.h5 *_1/Analysis_Results/*.2.bax.h5 *_1/Analysis_Results/*.3.bax.h5; 
cp *_1/Analysis_Results/*.subreads.fastq subreads_fq/; rm *.tar.gz; rm -r *_1 ;done

#Then
#mkdir allBam
#mv *.bam allBam
#cd allBam
#for i in *.bam; do bamtools convert -format fasta -in $i -out $i.fasta; done
