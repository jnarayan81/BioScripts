#!/usr/bin/perl -w
use strict;
use warnings;

#USAGE=$0 genome.fa.fai coordinates
my $genomeSize = "$ARGV[0]";
my $genomeFasta = "$ARGV[1]";
open(my $fh, '<:encoding(UTF-8)', $genomeSize) or die "Could not open file '$genomeSize' $!";

#Store in hash
my %GenomeSizeHash;
while (my $row = <$fh>) {
  chomp $row;
  my @tmpLine= split '\t', $row;
  $GenomeSizeHash{$tmpLine[0]}=$tmpLine[1];
  #print "$row\n";
}

#my $chrSize=$GenomeSizeHash{'ONT1'};
#print $chrSize;

#Coordinates Format
#ONT1	0	2	68	
#ONT2	23292	23294	23	

open(my $fh2, '<:encoding(UTF-8)', $genomeFasta) or die "Could not open file '$genomeFasta' $!";
#Create bed -should be sorted by frst,scond,third column
my $startVal=0;

{
  $_ = <$fh2>;
  my $next_line;

  while( $next_line = <$fh2> )
  {
    my @tmpLine2= split '\t', $_;
    my $chrSize=$GenomeSizeHash{$tmpLine2[0]};
    
    my @nextTmp = split '\t', $next_line;
	print "$tmpLine2[0]\t$startVal\t$tmpLine2[1]\n" if ($tmpLine2[1]-$startVal) > 0;
	if ($tmpLine2[0] ne $nextTmp[0]) { 
	$startVal=0; print "$tmpLine2[0]\t$tmpLine2[2]\t$chrSize\n" if ($chrSize-$tmpLine2[2]) > 0; }  #To print the end of the chromosome
	else { $startVal=$tmpLine2[2];}
    #print "current line: $_ -- next line: $next_line$/";
  }
  continue
  {
    $_ = $next_line;
  }
}

__END__
