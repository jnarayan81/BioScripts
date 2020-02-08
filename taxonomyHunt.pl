#!/usr/local/bin/perl
		
########################################
#
#  It required NCBI taxonomy database ( taxdump)
#  The location of taxdump folder ftp://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz

#  Author: Jitendra Narayan < jnarayan81@gmail.com>
#  Copyright (c) 2020 by Jitendra. All rights reserved.
#  You may distribute this script under the same terms as perl itself
#

use strict;
use warnings;

$|++; ## flush perl’s print buffer

my (%names, %nodes, @array2d, %finalHash);
my $taxonomy_directory='taxdump'; #Where is your taxdump
print "Loading the taxonomy $taxonomy_directory -- gonna fill up your RAM :) sorry for that\n";
my ($files,$dirs)=getDirectoryFiles($taxonomy_directory);
process_file($_) for @$files;    # This subrutine create a hash of names and nodes file.
print "\nProcessing done, yahh ! I guess you have high quality RAM, rich hmmm\n";

#Now ready to check 
&yesORno();



# --- all subs here----
## returns 1 for y 
sub yesORno() { 
    my $input = ''; 
    while ( $input !~ /y|n/i ) { 
	print "\nEnter your species id [ if you want to exit type q ]: \n";
        my $input = <STDIN>; 
        chomp $input;
	exit if $input eq "q"; 
	my $speciesId=$input;
	my $abc = $names{$speciesId};
	print "\nYour reference species Id and Name is : $speciesId  --> $abc\n";
	} 
}


sub process_file{ # This is your custom subroutine to perform on each file    
    my $f = shift;     
    my ($val, $nam) = check_file($f);   
	if ($val == 1 and ($nam eq "names")) {  # print "processing file $f\n";
		%names=file2hash ($f, $nam);
		#return @array;
		}
         elsif ($val == 1 and $nam eq "nodes") { # print "processing file $f\n";
		%nodes=file2hash ($f, $nam);
		}
	}

#-----------------------------------------------------------------------
sub check_file {
    use File::Basename;
    my $filepath = shift; # print $file;
    my $file = basename($filepath);
    my @ff= split /\./, $file;
    if ($ff[0] eq "names" || "nodes" ) 
	{ return 1, $ff[0]; }
}

#-------------------------------------------------------------------------
sub file2hash {
	my ($infile, $n) = @_;
	my %hash;
	open FILE, $infile or die $!;
	while (<FILE>) {
   		chomp;  # s/^\s*(.*)\s*$/$1/;
	        next if (index($_, "scientific") == -1); #{ print "'$string' contains '$substring'\n";}
		my @tmp_array= split /\t/ , $_;
		s{^\s+|\s+$}{}g foreach @tmp_array; # Removing leading and trailing whitespace from array strings.
   		my ($key, $val) = split /\t\|\t/;
   		#Lets add only scientific name -- rest ignore
		if (($infile eq "names.dmp") and  ($tmp_array[6] ne "scientific name")) {next;}  #print "$tmp_array[6]\n";      ## if we want to enter only specific lines.
   		#I edited this line, do not remember why i did add line nu;ber in it
		if($n eq "names") { $key="$key";}    # I make it unique by adding the line number and split later...
		$val =~ s/\s+/_/g;  ## replace the space with underscore ...
		$hash{$key} = $val;  
		# print "$n\t$key\t$val\n";
        } 
	close FILE;
return %hash;      
}

#-------------------------------------------------------------------------
sub printhash {
  	my %hash=%{$_[0]};
	foreach my $key (sort keys %hash) {
     	print "$key : $hash{$key}\n";
	}
}

#-------------------------------------------------------------------------
sub findkey {
        my ($species, $hash) =@_;
	my  %hash=%$hash;  my @all_keys;
	foreach my $key (keys %hash) {
     	if ($hash{$key} =~ m/^$species$/i) { push @all_keys, $key};
	}
s{^\s+|\s+$}{}g foreach @all_keys; # Removing leading and trailing whitespace from array strings.
return @all_keys;
undef @all_keys;
} 

#-------------------------------------------------------------------------
sub findId {
        my ($id, $hash) =@_;
	my  %hash=%$hash;  my @all_values;
	foreach my $key (keys %hash) {
	my @newValue= split(/:/, $hash{$key});       ## What if we have more than two hits for a key !!!!!
     	if ($newValue[0]==$id) { push @all_values, $key};
	}
s{^\s+|\s+$}{}g foreach @all_values; # Removing leading and trailing whitespace from array strings.
my $all_values=join(",",uniq(@all_values));
return $all_values;
undef @all_values;
} 


#----------------------------------------------------------------------
sub getDirectoryFiles {          # It get the directory files and return it
     my $taxdir = shift;

     opendir(my $dh, $taxdir) || die "can't opendir $taxdir : $!";
     my @entries = grep {!( /^\.$/ || /^\.\.$/)} readdir($dh);
     @entries =  map { "$taxdir/$_" } @entries; #change to absolute paths
     closedir $dh;

     my @files =  grep( -f $_ , @entries);
     my @dirs = grep(-d $_, @entries);
     return (\@files,\@dirs);     ## return as a reference 

}
