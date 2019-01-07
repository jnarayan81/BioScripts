#!/bin/bash
# Submission script for Vega 
#SBATCH --job-name=CANUAssembly
#SBATCH --time=14-00:00:00 # days-hh:mm:ss
#
#SBATCH --ntasks=200 
#SBATCH --mem-per-cpu=40960 # 40GB
#SBATCH --partition=defq 
# 
# Uncomment the following line if your work 
# is floating point intensive and CPU-bound.
### SBATCH --threads-per-core=1
#
#SBATCH --mail-user=jitendra.narayan@unamur.be
#SBATCH --mail-type=ALL
#
#SBATCH --comment=AVAGA 
mkdir -p $GLOBALSCRATCH/$SLURM_JOB_ID

module load Java/1.8.0_45

module load gnuplot/4.6.6-intel-2014b

export PATH=$PATH:/home/unamur/URBE/jnarayan/CANUAssembly/canu/Linux-amd64/bin

canu -p AvagaHaploid -d AvagaHap -genomeSize=120m -pacbio-raw allPacBio_clean.fa -nanopore-raw ONT_choppedNcorrected.fa corOutCoverage=200 correctedErrorRate=0.20 -minReadLength=5000 -minOverlapLength=2500
~                             
