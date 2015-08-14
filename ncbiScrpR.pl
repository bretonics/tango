#!/usr/bin/perl

use warnings; use strict; use diagnostics; use feature qw(say);
use Getopt::Long; use Pod::Usage;

use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib (dirname abs_path $0). "/lib";

use Eutil; use Parser; use Database;


# =============================================
#
#	CAPITAN: Andres Breton
#	FILE: ncbiScrpR.pl
#   USAGE:
#	LICENSE:
#
# =============================================


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# VARIABLES
my $outDir = createDownloadDir();
my $email = 'breton.a@husky.neu.edu'; #use your own email
my ($NCBIfile, $NCBIstatus);
my ($locus, $seqLen, $accession, $version, $gi, $organism, $sequence, $gene, $proteinID, $translation);
my $PID;
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# COMMAND LINE
my @IDS;
my $FILE = "";
my $DATABASE = "nuccore"; #defaults to nucleotide
my $TYPE = "gb";
my $FORCE = "0"; #default- Not force
my $MONGODB = "NCBI_database"; #defaults to
my $COLLECTION = "Download";
my $TASK = "insert";
my $usage = "\n\n $0 [options]\n
Options:
    -ids            IDs
    -file           File with IDS [CSV or TXT]
    -db             Database (Nucleotide, protein, etc..) [optional]
    -type           gb, fasta, etc... [optional]
    -force          Force download? [optional]
    -mongo          MongoDB database name
    -collection     Collection name in Mongo database
    -task           Insert, update, remove data from database
    -help           Shows this message
\n";

# OPTIONS
GetOptions(
    'id:i{1,}'      =>\@IDS,
    'file:s'        =>\$FILE,
    'db:s'          =>\$DATABASE,
    'type:s'        =>\$TYPE,
    'force:1'       =>\$FORCE,
    'mongo:s'       =>\$MONGODB,
    'collection:s'  =>\$COLLECTION,
    'insert:s'      =>\$TASK,
    help            =>sub{pod2usage($usage);}
)or pod2usage(2);
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# CALLS
checks($FILE, @IDS, $COLLECTION); # check parameters/arguments
$PID = startMongoDB($MONGODB, $outDir);
callEutil(\@IDS, $PID);
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# SUBS
sub checks {
    # File vs ID List
    if ($FILE ne "") {
        checkFile($FILE);
    }
    unless (@IDS) {
        warn "Did not provide ID(s), -id 34577062 or -file <file>", $!, $usage; exit;
    }
    # unless($DATABASE) {
    #     die "Did not provide a database, -db nucleotide", $!, $usage;
    # }
    unless ($COLLECTION ne "Download") {
        say "\nNo database collection name entered. Defaulting to \"$COLLECTION\" as collection name.\n";
    }
}

sub checkFile {
    my ($FILE) = @_;
    unless (open(INFILE, "<", $FILE)) {
        warn "Could not open $FILE", $!;
    }
    # Check CSV or TXT File
    if ($FILE =~ /.+.csv/) {
        @IDS = split(/,/, <INFILE>);
    }elsif($FILE =~ /.+.txt/) {
        @IDS = <INFILE>;
    }else{
        die "Could not determine file delimiter. Try \",\" or \"\\n\"";
    }
    close INFILE;
}

sub callEutil {
    my ($IDS, $PID) = @_;
    my @IDS = @$IDS; #dereference IDS array passed
    foreach my $id (@IDS) {
        # Get NCBI File
        ($NCBIfile, $NCBIstatus) = getNCBIfile($id, $outDir, $FORCE, $DATABASE, $TYPE, $email);
        # Check NCBI Successful Download
        if($NCBIstatus != 1) {
            while ($NCBIstatus != 1) {
                ($NCBIfile, $NCBIstatus) = failedDownload($NCBIstatus, $id, $outDir, $FORCE, $DATABASE, $TYPE, $email);
            }
            # Parse File
            ($locus, $seqLen, $accession, $version, $gi, $organism, $sequence, $gene, $proteinID, $translation) = parseFile($NCBIfile, $id, $TYPE);
        }else {
            # Parse File
            ($locus, $seqLen, $accession, $version, $gi, $organism, $sequence, $gene, $proteinID, $translation) = parseFile($NCBIfile, $id, $TYPE);
        }
        # Store Data in MongoDB database
        databaseConnection($MONGODB, $TASK, $COLLECTION, $id, $gi, $accession, $version, $locus, $organism, $sequence, $seqLen, $gene, $proteinID, $translation);
    }
    say "Closing MongoDB..."; exec("kill $PID"); #shurdown mongod deamon
}

sub parseFile {
    my ($NCBIfile, $id, $TYPE) = @_;
    my ($locus, $seqLen, $accession, $version, $gi, $organism, $sequence, $proteinID, $translation, $gene);
    say "Parsing file $NCBIfile:";
    if ($TYPE eq "gb") {
        ($locus, $seqLen, $accession, $version, $gi, $organism, $sequence, $gene) = parseHeader($NCBIfile);
        ($sequence, $proteinID, $translation, $gene) = parseFeatures($id);
    }
    return $locus, $seqLen, $accession, $version, $gi, $organism, $sequence, $gene, $proteinID, $translation;
}

sub createDownloadDir {
    my $outDir = "Data";
    if (! -e $outDir){
        `mkdir $outDir`;
    }
    return $outDir;
}

sub failedDownload {
    my ($NCBIstatus, $id, $outDir, $FORCE, $DATABASE, $TYPE, $email) = @_;
    say "Something happened while fetching. Could not get file from NCBI.", $!;
    # Retry on Fail
    print "Would you like to retry? (y/n)";
    my $response = <>; chomp $response;
    if ($response eq "y" || $response eq "yes") {
        ($NCBIfile, $NCBIstatus) = getNCBIfile($id, $outDir, $FORCE, $DATABASE, $TYPE, $email);
        return $NCBIfile, $NCBIstatus;
    }else {
        die "Fetching cancelled by user", $!;
    }
}
