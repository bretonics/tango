#!/usr/bin/perl

use warnings; use strict; use diagnostics; use feature qw(say);
use Getopt::Long; use Pod::Usage; use Data::Dumper;

use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib (dirname abs_path $0). "/lib";

use Eutil; use Parser; use Database;


# =============================================================================
#
#   CAPITAN:  Andres Breton
#   FILE: tango.pl
#   LICENSE:  GPL2
#   USAGE:  Collect, store, and retrieve records from NCBI with just the GI number.
#           Uses NCBI's E-Utilities interface and MongoDB as a database for
#           storing locally the most relevant information.
#   DEPENDENCIES:   BioPerl modules
#
# =============================================================================


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# VARIABLES
my $outDir = createOutputDir("Data");
my $email = 'breton.a@husky.neu.edu'; #use your own email
my ($NCBIfile, $NCBIstatus);
my ($locus, $seqLen, $accession, $version, $gi, $organism, $sequence, $gene, $proteinID, $translation);
my ($PID, %fieldValues);
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# COMMAND LINE
my @IDS;
my $FILE = "";
my $DATABASE = "nuccore"; #defaults to nucleotide
my $TYPE = "gb";
my $FORCE = "0"; #default- Not force
my $MONGODB = "NCBI_database"; #defaults to
my $COLLECTION = "nuccore";
my ($INSERT, @UPDATE, @READ, @REMOVE);
my $usage = "\n\n $0 [options]\n
Options:
    -id             ID(s)
    -file           File with ID(s) [CSV or TXT]
    -db             Database (Nucleotide, protein, etc..) [optional]
    -type           gb, fasta, etc... [optional]
    -force          Force download? [optional]
    -mongo          MongoDB database name
    -collection     Collection name in MongoDB database
    -insert         Insert into database [optional/default]
    -update         Update database
    -read           Read from database
    -remove         Remove from database
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
    'insert+'       =>\$INSERT,
    'update:s{1,}'  =>\@UPDATE,
    'read:s{1,}'    =>\@READ,
    'remove:s{1,}'  =>\@REMOVE,
    help            =>sub{pod2usage($usage);}
)or pod2usage(2);
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# CALLS
argChecks();
$PID = startMongoDB($MONGODB, $outDir);
if ($INSERT) {
    callEutil(\@IDS, $PID, $MONGODB, $COLLECTION);
} else {
    sendToMongo($PID, $MONGODB, $COLLECTION, \@UPDATE, \@READ, \@REMOVE);
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# SUBS
sub argChecks { #Check Arguments/Parameters
    # Pase Query Field => Value Pairs
    if (@UPDATE) {
        parseQuery(@UPDATE);
    } elsif (@READ) {
        parseQuery(@READ);
    } elsif (@REMOVE) {
        parseQuery(@REMOVE);
    } else {
        say "Inserting into database..\n";
        $INSERT = 1;
    }
    # Skip ID Check if accessing DB Only
    unless (!defined $INSERT) {
        # File vs ID List
        if ($FILE ne "") {
            checkFile($FILE);
        } else {
            unless (@IDS) {
                warn "Did not provide ID(s), -id 34577062 or -file <file>", $!, $usage; exit;
            }
        }
    }
    # Defaults Warning
    unless($DATABASE ne "nuccore") {
        say "Did not provide an NCBI database, -db nucleotide. Default \"$DATABASE\" used.";
    }
    unless ($COLLECTION ne "nuccore") {
        say "No database collection name entered. Defaulting to \"$COLLECTION\" as collection name.";
    }
    unless ($MONGODB ne "NCBI_database") {
        say "Did not provide a MongoDB database name. Defaulting to \"$MONGODB\".";
    }

}

sub checkFile { #Check File Format
    my ($FILE) = @_;
    unless (open(INFILE, "<", $FILE)) {
        warn "Could not open $FILE", $!;
    }
    # Check CSV or TXT File
    if ($FILE =~ /.+.csv/) {
        @IDS = split(/,/, <INFILE>);
    }elsif($FILE =~ /.+.txt/) {
        while(<INFILE>) {
            chomp;
            push @IDS, $_;
        }
    }else{
        die "Could not determine file delimiter. Try \",\" or \"\\n\"";
    }
    close INFILE;
}

sub callEutil { #Get NCBI File(s), Distribute DB Tasks
    my ($IDS, $PID, $MONGODB, $COLLECTION) = @_;
    my @IDS = @$IDS; # Dereference IDS

    # Iterate through each ID passed
    foreach my $id (@IDS) {
        ($NCBIfile, $NCBIstatus) = getNCBIfile($id, $outDir, $FORCE, $DATABASE, $TYPE, $email); # Get NCBI File

        if ($NCBIstatus != 1) { #Check Download
            while ($NCBIstatus != 1) {
                ($NCBIfile, $NCBIstatus) = failedDownload($NCBIstatus, $id, $outDir, $FORCE, $DATABASE, $TYPE, $email);
            }
            # Parse File
            ($locus, $seqLen, $accession, $version, $gi, $organism, $sequence, $gene, $proteinID, $translation) = parseFile($NCBIfile, $id, $TYPE);
        } else {
            # Parse File
            ($locus, $seqLen, $accession, $version, $gi, $organism, $sequence, $gene, $proteinID, $translation) = parseFile($NCBIfile, $id, $TYPE);
        }
        insertData($MONGODB, $COLLECTION, $id, $gi, $accession, $version, $locus, $organism, $sequence, $seqLen, $gene, $proteinID, $translation);
    }
    shutdownMDB($PID);
}

sub sendToMongo {
    my ($PID, $MONGODB, $COLLECTION, $UPDATE, $READ, $REMOVE) = @_;
    # Dereference
    my @UPDATE = @$UPDATE;
    my @READ = @$READ;
    my @REMOVE = @$REMOVE;

    # Iterate Through Each Query Field<->Value Pair
    foreach my $field (keys %fieldValues) {
        foreach my $value (keys $fieldValues{$field}) {
            # Delegate DB Task
            if (@UPDATE) {
                updateData($field, $value, $MONGODB, $COLLECTION);
            } elsif (@READ) {
                readData($field, $value, $MONGODB, $COLLECTION);
            } elsif (@REMOVE) {
                removeData($field, $value, $MONGODB, $COLLECTION);
            } else {
                die "ERROR: No database operation found!", $!;
            }
        }
    }
    shutdownMDB($PID);
}

sub parseQuery {
    my (@QUERY) = @_;
    foreach(@QUERY) {
        chomp;
        $_ =~ /(.+):(.+)/;
        my ($field, $value) = ($1, $2); #get field<->value pair
        if (!defined $fieldValues{$field}{$value}) {
            $fieldValues{$field}{$value} = 1;
        }
    }
}

sub parseFile { #Parse NCBI File
    my ($NCBIfile, $id, $TYPE) = @_;
    my ($locus, $seqLen, $accession, $version, $gi, $organism, $sequence, $proteinID, $translation, $gene);
    say "Parsing file $NCBIfile:";
    if ($TYPE eq "gb") {
        ($locus, $seqLen, $accession, $version, $gi, $organism, $sequence, $gene) = parseHeader($NCBIfile);
        ($sequence, $proteinID, $translation, $gene) = parseFeatures($id);
    }
    return $locus, $seqLen, $accession, $version, $gi, $organism, $sequence, $gene, $proteinID, $translation;
}

sub createOutputDir {
    my ($outDir) =  @_;
    if (! -e $outDir){
        `mkdir $outDir`;
    }
    return $outDir;
}

sub failedDownload { #NCBI File Fetch Failure
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

sub shutdownMDB {
    my ($PID) = @_;
    say "\nClosing MongoDB.\n"; exec("kill $PID"); #shutdown MongoDB server
}
