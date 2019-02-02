#!/usr/bin/env bash
# -*- coding: utf-8 -*-

#ZERO ROUND OF CORRECTION - Long reads -- fix indel
#run finisherSC

#Format your data
echo "Renaming the reads"
#perl -pe 's/>[^\$]*$/">Seg" . ++$n ."\n"/ge' ONT_choppedNcorrected.fa > ONT_renamed.fasta; cp ONT_renamed.fasta raw_reads.fasta; rm -rf ONT_renamed.fasta
echo "Renaming the contigs"
#perl -pe 's/>[^\$]*$/">Seg" . ++$n ."\n"/ge' contigs.fasta > newContigs.fasta; cp newContigs.fasta contigs.fasta; rm -rf newContigs.fasta

#A_set
echo "Finishing A_set contigs"
#python2 ~/tools/finishingTool/finisherSC.py -par 40 /mnt/sdc1/Jit/adineta_genomes_polished/3C_genome/A_finishing/ /home/lege/.conda/envs/align-env/bin/

#B_set
echo "Finishing B_set contigs"
#python2 ~/tools/finishingTool/finisherSC.py -par 40 /mnt/sdc1/Jit/adineta_genomes_polished/3C_genome/B_finishing/ /home/lege/.conda/envs/align-env/bin/

#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


#FIRST ROUND OF CORRECTION #wtpoa correction

echo "Indexing the reference file"
#bwa index both_improved3.fa
echo "Mapping the short reads / PE reads"
#bwa mem -t 4 both_improved3.fa /media/lege/MyPassport/AvagaReads_Trimmed/R1_paired_trm.fq.gz /media/lege/MyPassport/AvagaReads_Trimmed/R2_paired_trm.fq.gz | samtools view -Sb - >sr.bam
echo "Sorting the BAM file"
#samtools sort -T /tmp/sr.srt -o sr.srt.bam sr.bam

echo "Polishing with short reads"
#samtools view sr.srt.bam | /home/lege/tools/wtdbg2/wtpoa-cns -t 40 -x sam-sr -d both_improved3.fa -i - -fo prefix.ctg.3rd.fa

#Evaluate the polishing
#MUMmer3.23/dnadiff --prefix finisherSC.POA.polished.dnadiff both_improved3.fa prefix.ctg.3rd.fa

#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#SECOND ROUND OF CORRECTION #Pilon correction

echo "Indexing the reference file"
#bwa index prefix.ctg.3rd.fa

echo "Mapping the short reads / PE reads"
#bwa mem -t 40 prefix.ctg.3rd.fa /media/lege/MyPassport/AvagaReads_Trimmed/R1_paired_trm.fq.gz /media/lege/MyPassport/AvagaReads_Trimmed/R2_paired_trm.fq.gz | samtools view -Sb - >pilon.sr.bam

echo "Sorting the BAM file"
#samtools sort -T /tmp/pilon.sr.srt -o pilon.sr.srt.bam pilon.sr.bam

echo "Index the bam file"
#samtools index pilon.sr.srt.bam

echo "Correcting with pilon"
#set the memoery size - used -Xmx160G
#java -Xmx160G -jar pilon-1.23.jar --genome prefix.ctg.3rd.fa --frags pilon.sr.srt.bam --threads 40 --changes --outdir pilonCorrection --output pilonCor --tracks --fix all


#Evaluate the polishing
#MUMmer3.23/dnadiff --prefix POA.Pilon.polished.dnadiff prefix.ctg.3rd.fa pilon.fa 
