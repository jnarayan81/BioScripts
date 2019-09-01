use Bio::Taxon;

#Taxonomy parser by Jitendra 
#Update the directory, nodesfile and namesfile location before running
#wget ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump.tar.gz
#tar xzfp taxdump.tar.gz;

#USAGE: perl parseTaxDB.pl homo_sapiens metazoa

my $sps = $ARGV[0];
my $groupName = $ARGV[1];

# Get one from a database
my $dbh = Bio::DB::Taxonomy->new(-source   => 'flatfile',
                                 -directory=> '/home/jitendra/myTools/myScipts',
                                 -nodesfile=> '/home/jitendra/myTools/myScipts/nodes.dmp',
                                 -namesfile=> '/home/jitendra/myTools/myScipts/names.dmp');
my $nam = $dbh->get_taxon(-name => $sps);
#$human = $dbh->get_taxon(-taxonid => '9606');
if(!$nam) { print "Try again with correct scientific name\n"; exit;}
print "Eureka we found $sps, id is ", $nam->id, "\n"; # 9606

# We can also take advantage of Bio::Tree::Tree* methods:
use Bio::Tree::Tree;
my $tree_functions = Bio::Tree::Tree->new();
#my @lineage = $tree_functions->get_lineage_nodes($human);
my $lineage = lc ($tree_functions->get_lineage_string($nam));
#print $lineage;

if (index(lc($lineage), lc($groupName)) != -1) {
    print "$sps belong to $groupName\n";
} else { print "It does not belong to $groupName\n It fall here : $lineage \n";}

