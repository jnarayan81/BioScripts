use strict;

open (MYFILEA, $ARGV[0]);

while (<MYFILEA>) {
	chomp;
	my $line1=$_; 
	my @L1 = split ( /\t/, $line1 ); 
	s{^\s+|\s+$}{}g foreach @L1;
	open (MYFILEB, $ARGV[1]);
	while (<MYFILEB>) {
		chomp;
		my $line2=$_; 
		
		my @L2 = split ( /\t/, $line2 ); 
		s{^\s+|\s+$}{}g foreach @L2;

		$L2[1] =~ s/evolved/icev/g;
		
		next if $L1[4] ne $L2[1];

		my $fromA = $L1[5]; my $toA = $L1[6]; my $fromB = $L2[2]; my $toB = $L2[3];

		my @common_range = get_common_range($fromA, $toA, $fromB, $toB);

		my $common_range = $common_range[0]."-".$common_range[-1];
		#print "$fromA, $toA, $fromB, $toB\n";
		
		print "$line1\t$line2\n";

	}

	close (MYFILEB);
	}
close (MYFILEA); 



sub get_common_range {
  my @A = $_[0]..$_[1];
  my %B = map {$_ => 1} $_[2]..$_[3];
  my @common = ();

  foreach my $i (@A) {
    if (defined $B{$i}) {
      push (@common, $i);
    } 
  }
  return sort {$a <=> $b} @common;
}
