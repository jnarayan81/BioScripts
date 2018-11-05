#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use File::Basename;
use Cwd qw(abs_path); 

#Run KAT (Kmer Analysis Toolkit) on assembly to check assembly completeness @ Jitendra
#USAGE: perl runKAT.pl -genome scaffolds.fasta -reads /media/urbe/MyADrive/ARC_MA_sequencing/94_Fastq_files_GC047403/JitReads/R1_paired_trm.fq.gz -tech illumina -d test2 -nCPUs 40 -KAT /home/urbe/anaconda3/bin/kat -r 1

my ($genome, $reads, $outputDir, $nCPUs, $help, $nRounds, $KAT_path, $tech);

GetOptions( 
	"genome=s" => \$genome,
	"reads=s" => \$reads,
	"tech=s" => \$tech,
	"dir=s" => \$outputDir,
	"nCPUs=i" => \$nCPUs,
	"r|rounds=i" => \$nRounds, #used in illumina case
	"KAT=s" => \$KAT_path,
	"h|help" => \$help,	
);

if (!$KAT_path) { &print_help(); exit(); }

# get path for dir where reads are
my $abs_reads = abs_path($reads);
my @path = split("/", $abs_reads);
#my $reads_dir;
#for (my $j=0; $j < @path -1; $j++) { $reads_dir .= $path[$j]."/"; }
#$reads = $path[-1];

$genome = abs_path($genome);
my $outName = $outputDir;
$outputDir = abs_path($outputDir);
$KAT_path = abs_path($KAT_path);
my $cwd = abs_path(); #original path

# split reads into files..
print "\n##########################################################\n";
print "\nStarting pipeline for KAT completeness check\n";
print "\n##########################################################\n";

my($name,$location,$suffix) = fileparse($reads,'.fq.gz');

#Compares jellyfish K-mer count hashes.
if (($tech eq "ont") or ($tech eq "pacbio")) {
#print "$genome, $reads, $outputDir, $nCPUs, $nRounds, $KAT_path, $tech\n";
system ("$KAT_path comp -t $nCPUs -o $outputDir $reads $genome");
}
elsif ($tech eq "illumina") {
	if ($nRounds == 1) {
	#my $name = fileparse($reads,'.fq');
	#my $basename = basename($reads,'.fq');
	#my $dirname  = dirname($reads);
	#print "$name , $location, $suffix";	
	#print "$genome, $reads, $outputDir, $nCPUs, $nRounds, $KAT_path, $tech\n";
	system ("$KAT_path comp -t $nCPUs -o $outputDir $reads $genome");	
	}
	else {
	system ("$KAT_path comp -t $nCPUs -o $outputDir $location.?.$suffix $genome");	
	}
}
else {
print "You might forgot some flags, check -help\n";
}

#Lets plot the graph 
#system (" $KAT_path hist -t $nCPUs -o $outputDir $reads");
#system (" $KAT_path plot spectra-hist $outName-kat.hist   ");

system (" $KAT_path plot spectra-cn $outName-main.mx -x 600");
#system (" $KAT_path plot spectra-mx $outName-main.mx");

#system (" $KAT_path gcp $reads");
#system (" $KAT_path plot density $outName-main.mx");

#print completeness on terminal
system ("more $outName.dist_analysis.json | grep -i 'complete'");
system ("mkdir final.$outName");
system ("mv $outName* final.$outName");
######


sub print_help {
	print "\n#######################################################################\n";
	print "\nThis scripts calls and check the genome completeness using KAT.\n\n";
	print "Usage: perl $0\n";
	print "\t-genome: reference fasta file for checking\n";
	print "\t-reads: fastq/fasta file of reads\n";
	print "\t-tech: reads generation protocol/ illumina / pacbio / ont\n";
	print "\t-dir: path\n";
	print "\t-nCPUs: number of CPUs to use\n";
	print "\t-r|rounds: number of rounds to perform\n";
	print "\t-KAT: path of executable\n";
	print "\t-h|help\n";
	print "\n#######################################################################\n\n";

}
