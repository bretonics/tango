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
my ($locus, $seqLen, $accession, $version, $gi, $organism, $sequence, $gene, $proteinID, $translation);
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# COMMAND LINE
my @IDS;
my $FILE = "";
my $DATABASE = "";
my $TYPE = "gb";
my $FORCE = "0"; #default- Not force
my $SQLDB = "NCBIdatabase"; #defaults to
my $usage= "\n\n $0 [options]\n
Options:
    -ids    IDs
    -file   File with IDS [CSV or TXT]
    -db     Database (Nucleotide, protein, etc..) [optional]
    -type   gb, fasta, etc... [optional]
    -force  Force download? [optional]
    -sql    SQL database name
    -help   Shows this message
\n";

# OPTIONS
GetOptions(
    'id:i{1,}'  =>\@IDS,
    'file:s'    =>\$FILE,
    'db=s'      =>\$DATABASE,
    'type:s'    =>\$TYPE,
    'force:1'   =>\$FORCE,
    'sql:s'     =>\$SQLDB,
    help        =>sub{pod2usage($usage);}
)or pod2usage(2);
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# CHECKS
# File vs ID List
if($FILE ne "") {
    unless (open(INFILE, "<", $FILE)) {
        die "Could not open $FILE", $!;
    }
    # Check CSV or TXT File
    if ($FILE =~ /.+.csv/) {
        @IDS = split(/,/, <INFILE>);
        say "this IDs = @IDS";
    }elsif($FILE =~ /.+.txt/) {
        @IDS = <INFILE>;
    }else{
        warn "Could not determine file delimiter. Try \",\" or \"\n\"";
    }
    close INFILE;
}
unless(@IDS) {
    die "Did not provide ID(s), -id 34577062 or -file <file>", $!, $usage;
}
unless($DATABASE) {
    die "Did not provide a database, -db nucleotide", $!, $usage;
}
# unless($TYPE) {
#     die "Did not provide a type format, -type gb", $!, $usage;
# }
# $SQLDB = "NCBIdatabase" unless $SQLDB ne ""; #default SQL database name
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# CALLSs
foreach my $id (@IDS) {
    # Get NCBI File
    ($NCBIfile, $NCBIstatus) = getNCBIfile($id, $outDir, $FORCE, $DATABASE, $TYPE, $email);
    # Check NCBI Successful Download
    if($NCBIstatus != 1) {
        say "Something happened while fetching. Could not get file from NCBI.", $!;
        # Retry on Fail
        print "Would you like to retry? (y/n)";
        my $response = <>; chomp $response;
        if ($response eq "y" || $response eq "yes") {
            ($NCBIfile, $NCBIstatus) = getNCBIfile($id, $outDir, $FORCE, $DATABASE, $TYPE, $email);
        }

    }else {
        # Parse File
        ($locus, $seqLen, $accession, $version, $gi, $organism, $sequence, $gene, $proteinID, $translation) = parseFile($NCBIfile, $id, $TYPE);
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
    my ($NCBIfile, $id, $TYPE) = @_;
    my ($locus, $seqLen, $accession, $version, $gi, $organism, $sequence, $gene, $proteinID, $translation);

    if ($TYPE eq "gb") {
        say "Getting NCBI file [header] content...\n";
        ($locus, $seqLen, $accession, $version, $gi, $organism, $sequence, $gene) = parseHeader($NCBIfile);
        say "Getting NCBI file [features] content:...\n";
        ($proteinID, $translation) = parseFeatures($id); say "Features: $proteinID, $translation";
    }
    return $locus, $seqLen, $accession, $version, $gi, $organism, $sequence, $gene, $proteinID, $translation;
}

sub createDownloadDir{
    my $outDir = "Output";
    if (! -e $outDir){
        `mkdir $outDir`;
    }
    return $outDir;
}
