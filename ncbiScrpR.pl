#!/usr/bin/perl

use warnings; use strict; use diagnostics; use feature qw(say);
use Getopt::Long; use Pod::Usage;

use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib (dirname abs_path $0). "/lib";

use Eutil; use Parser;


# =============================================
#
#	MASTERED BY: Andres Breton
#	FILE: ncbiScrpR.pl
#   USAGE:
#	LICENSE:
#
# =============================================


#-------------------------------------------------------------------------
# COMMAND LINE
my $ID = "";
my $DATABASE = "";
my $TYPE = "";
my $FORCE = "";
my $SQLDB = "";
my $usage= "\n\n $0 [options]\n
Options:
    -id    IDs
    -db     Database (Nucleotide, protein, etc..)
    -type   fasta, gb, etc...
    -force  Force download? [optional]
    -sql    SQL database name
    -help   Shows this message
\n";

# OPTIONS
GetOptions(
    'id=i'      =>\$ID,
    'db=s'      =>\$DATABASE,
    'type=s'    =>\$TYPE,
    'force:0'   =>\$FORCE, #defaults to NO
    'sql:s'     =>\$SQLDB,
    help        =>sub{pod2usage($usage);}
)or pod2usage(2);
#-------------------------------------------------------------------------
# CHECKS
unless($ID) {
    die "Did not provide an ID, -id 34577062", $!, $usage;
}
unless($DATABASE) {
    die "Did not provide a database, -db nucleotide", $!, $usage;
}
unless($TYPE) {
    die "Did not provide a type format, -type fasta", $!, $usage;
}
$SQLDB = "NCBIdatabase" unless $SQLDB ne ""; #default SQL database name
$FORCE = 0 unless $FORCE != 0; #default force download
#-------------------------------------------------------------------------
# VARIABLES
my $outDir = createDownloadDir();
my $email = 'breton.a@husky.neu.edu';
my ($NCBIfile, $NCBIstatus);
#-------------------------------------------------------------------------
# CALLS
# my $temp = join(",", @IDS);
($NCBIfile, $NCBIstatus) = getNCBIfile($ID, $outDir, $FORCE, $DATABASE, $TYPE, $email);
if($NCBIstatus == 1) {
    parseFile($NCBIfile, $TYPE);
}else {
    die "Something happened. Could not get file from NCBI", $!;
}

# Store in SQL database
# system("dbDeamon.r", $SQLDB, $ID, $accession, $seqLen, $locus, $organism, $version); #call R script
# if($? == -1) {
#   print "Command failed: $!\n";
# }else {
#   printf "Command exited with value %d", $? >> 8;
# }
#-------------------------------------------------------------------------
# SUBS
sub parseFile {
    my ($NCBIfile, $TYPE) = @_;
    if ($TYPE eq "gb") {
        my ($locus, $seqLen, $accession, $version, $organism, $sequence) = parseHeader($NCBIfile); say $sequence;
    }
}

sub createDownloadDir{
    my $outDir = "Output";
    if (! -e $outDir){
        `mkdir $outDir`;
    }
    return $outDir;
}
