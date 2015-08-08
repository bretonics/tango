#!/usr/bin/perl

use warnings; use strict; use diagnostics; use feature qw(say);
use Getopt::Long; use Pod::Usage;

use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib (dirname abs_path $0). "/lib";

use Eutil; use Parser; use Database;


# =============================================
#
#	MASTERED BY: Andres Breton
#	FILE: ncbiScrpR.pl
#   USAGE:
#	LICENSE:
#
# =============================================


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# VARIABLES
my $outDir = createDownloadDir();
my $email = 'breton.a@husky.neu.edu';
my ($NCBIfile, $NCBIstatus);
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# COMMAND LINE
my @IDS;
my $FILE = "";
my $DATABASE = "";
my $TYPE = "gb";
my $FORCE = "0"; #default- Not force
my $SQLDB = "";
my $usage= "\n\n $0 [options]\n
Options:
    -ids    IDs
    -file   File with IDS [optional]
    -db     Database (Nucleotide, protein, etc..) [optional]
    -type   gb, fasta etc... [optional]
    -force  Force download? [optional]
    -sql    SQL database name
    -help   Shows this message
\n";

# OPTIONS
GetOptions(
    'id=i{1,}'  =>\@IDS,
    'file:s'    =>\$FILE,
    'db=s'      =>\$DATABASE,
    'type:s'    =>\$TYPE,
    'force:1'   =>\$FORCE,
    'sql:s'     =>\$SQLDB,
    help        =>sub{pod2usage($usage);}
)or pod2usage(2);
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# CHECKS
unless(@IDS) {
    die "Did not provide an ID, -id 34577062", $!, $usage;
}
unless($DATABASE) {
    die "Did not provide a database, -db nucleotide", $!, $usage;
}
# unless($TYPE) {
#     die "Did not provide a type format, -type gb", $!, $usage;
# }
$SQLDB = "NCBIdatabase" unless $SQLDB ne ""; #default SQL database name
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# CALLSs
foreach my $id (@IDS) {
    ($NCBIfile, $NCBIstatus) = getNCBIfile($id, $outDir, $FORCE, $DATABASE, $TYPE, $email);
    if($NCBIstatus != 1) {
        die "Something happened. Could not get file from NCBI", $!;
    }else {
        say "Getting NCBI file header content...";
        parseFile($NCBIfile, $TYPE);
    }
}

# Store in SQL database
# system("dbDeamon.r", $SQLDB, $ID, $accession, $seqLen, $locus, $organism, $version); #call R script
# if($? == -1) {
#   print "Command failed: $!\n";
# }else {
#   printf "Command exited with value %d", $? >> 8;
# }
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# SUBS
sub parseFile {
    my ($NCBIfile, $TYPE) = @_;
    if ($TYPE eq "gb") {
        my ($locus, $seqLen, $accession, $version, $organism, $sequence, $gene, $proteinID) = parseHeader($NCBIfile);
    }
}

sub createDownloadDir{
    my $outDir = "Output";
    if (! -e $outDir){
        `mkdir $outDir`;
    }
    return $outDir;
}
