#!/usr/bin/env perl6

#First Raku code :)
#Jitendra @jnarayan81
#USAGE Perl6 dekhoG.pl --afile seq1.txt --sfile seq2.fa
#seq.txt should contain sequences - each per line / seq2.fa should contain multifasta

use String::FuzzyIndex;
use Getopt::Long;

my $data   = "file.dat";
my $adapt = 24;
my $verbose;
get-options("afile=s" => $adapt,    # string / for numeric n
            "sfile=s"   => $data,    # string
            "verbose"  => $verbose);  # flag

#Store file in hash
my $hfh; my $lineNum; my %ngsAdapt;
$hfh = open $adapt, :r;   # read mode
for $hfh.lines -> $hline {
	next unless $hline;
	$lineNum++;
        %ngsAdapt.push: ($lineNum => $hline); 
}

#for %ngsAdapt -> $vowel { say $vowel; say %ngsAdapt{$vowel}; } #Did is print one empty line !

# Lets check for the occurance
my $fh;
$fh = open $data, :r;   # read mode
for $fh.lines -> $line {
	next unless $line;
	#say $line.^name; # check if line is string 
	next if $line.starts-with('>');

    	for %ngsAdapt.kv -> $lineKey, $lineVal {
    		#say $lineVal; say $lineKey;      # accessing an element ;
		my @r = fzindex($line, $lineVal);

		say "{@r.elems} match(es) found.";
		for @r -> ($score, $hsp, $hep, $nsp, $nep, $htb, $ntb, $stb) {
        		say "Match score               : ", $score;
        		say "Matching haystack portion : ", $line.substr: $hsp, ($hep-$hsp+1);
        		say "Matching needle portion   : ", $lineVal.substr:   $nsp, ($nep-$nsp+1);
        		say "Scoring traceback buffer  : ", $stb;
        		say "Haystack traceback buffer : ", $htb;
        		say "Needle traceback buffer   : ", $ntb;
    		}
	}
}



