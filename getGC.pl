#!/usr/bin/perl -w

#Perl script to print the GC
#usage: perl getGC.pl fastaFile [>outfile]

use strict;
use warnings;

local $/ = '>';

while (<>) {
	chomp;
	/\S/ or next;
	my ( $id, $seq ) = /(.+?)\n(.+)/s;
	$seq =~ s/\n//g;

	my $GCcount = $seq =~ tr/GC//;
	my $len = length $seq;
	my $GCPer = ( $GCcount / length $seq ) * 100;
	print "$id\t$len\t$GCPer\n";
}

__END__
