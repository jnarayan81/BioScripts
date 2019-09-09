#!/usr/bin/env perl

use strict;
use warnings;
use Bio::SeqIO;
my $in = Bio::SeqIO->new(-format => 'fasta',
                         -fh   => $ARGV[0]);
while( my $s = $in->next_seq ) {
    my ($id) = ($s->id =~ /^(?:\w+)\|(\S+)\|/);
    Bio::SeqIO->new(-format => 'fasta',
                    -file   => ">".$id.".fasta")->write_seq($s);
}
