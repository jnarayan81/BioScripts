#!/home/wusy/miniconda2/bin/perl
#run sibelia with Multi CPUs
#author: jnarayan81@gmail.com

use File::Spec::Functions qw/rel2abs/;
use File::Basename;
use Getopt::Long;
use threads;
use Bio::Seq;
use Bio::SeqIO;

#get options for interative usage
my %opts;
GetOptions(\%opts,
	"h",
	"q:s","t:s","o:s",
	"w:s","p:s",
	"s:s","c:s"
);

#Check the condition
if ((!$opts{q})||(!$opts{t})||(!$opts{o})||($opts{h})||(!$opts{c})||(!$opts{s})||(!$opts{w}))
{
	print "
usage: $0 -h -s <sibelia_path> -q <query> -t <target> -o output -p cpus -c other Sibelia parameters

Main options:
  -h                     show the help info
  -q   <query>           BLAT query
  -t   <target>          BLAT target
  -o   output            the output dir/files  
  -w   work_path         specify the path where all the intermediate outfile and directory stored
  -p   cpus              how many parts to split(default 2)
  -c                     other Sibelia params could be passed in with xs:loose -- where x is '-' and : is ' ' ... see Sibelia manual for more info
";
	exit(1);
}
#settings


#initialize parameters
($SIBELIA,$QUERY,$TARGET,$OUTPUT,$WORKDIR,$CPUS,$PARAMS)=@opts{'s','q','t','o','w','p','c'};
#wrap BLAT params
$PARAMS =~ s/:/ /g;
$PARAMS =~ s/x/-/g;

if (-d $WORKDIR){ system("rm -rf $WORKDIR");}

#default
$WORKDIR = ($WORKDIR)?$WORKDIR:rel2abs("./");	##current dir as workdir
$CPUS = ($CPUS > 0)? $CPUS : 4;	#use 4 cpus by default


#check script parameters and working environment
$QUERY=rel2abs($QUERY);
$TARGET=rel2abs($TARGET);
unless (-e $QUERY) {die "The QUERY file doesn't exist or unreadable: $QUERY\n";}
unless (-e $TARGET) {die "The TARGET file doesn't exist or unreadable: $TARGET\n";}

unless (-e $WORKDIR) {mkdir $WORKDIR;}
$WORKDIR=rel2abs($WORKDIR);
#Link file to the query
system("ln -sf $QUERY $WORKDIR/query.fa");
system("ln -sf $TARGET $WORKDIR/target.fa");

#split input fasta sequence
splitter("$WORKDIR/query.fa",$CPUS) || die "Split input fasta error\n";

#generate shell command to run on linux
my @cmd;
for $i(1..$CPUS){
        if (-s "$WORKDIR/query.fa.split.$i") { print "empty/n"; next;}
	$cmd="$SIBELIA -o $OUTPUT.$i $PARAMS $WORKDIR/target.fa $WORKDIR/query.fa.split.$i > $WORKDIR/log.$i\n";
	push @cmd,$cmd;
}

#wrap it up
my @threads;
for $i(1..$CPUS){
	$cmd = shift @cmd;
	$thread = threads->create(\&wrapper,$cmd);
	$threads[$i] = $thread;
}

#recycle 
my $failcount;
my $ret;
for $i(1..$CPUS){
	if ($ret=$threads[$i]->join()){
		$failcount++;
		print "Thread $i exited with non-zero $ret, your result may not be complete, suggest retry...\n";
	}
}

#cat output
#die "Some parts of the work end up with error, or empty sequences please check and retry!\n" if ($failcount);
$cmd="mv -f $OUTPUT.* $WORKDIR";
system $cmd;
print "Sibelia finished! Your result could be found at: $WORKDIR\n";

#thread
sub wrapper{
	#in: cmd
	#out: retcode
	my $cmd = shift @_;
	print "start CMD: $cmd\n";
	return system($cmd);
}

sub splitter{
	my $fasta=shift @_;
	my $parts=shift @_;

	for $n(1..$parts){ open $n,">","$fasta.split.$n" || die; }
	
	open FASTA,"<",$fasta || die;
	my $l=0;
	while(<FASTA>){
		if (/^>/){ $l++; $n=$l%$parts;$n=$parts if ($n==0); }
		print $n $_;
	}
	for $n(1..$parts){ close OUT;}
	close FASTA;
}
