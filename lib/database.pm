package Database;

use Exporter qw(import);
our @ISA = qw(Exporter);
our @EXPORT = qw(startMongoDB databaseConnection insertData updateData readData removeData); #functions exported by default

use warnings; use strict; use diagnostics; use feature qw(say);
use Carp;
use MongoDB; use MongoDB::OID;


# =============================================
#
# 	MASTERED BY: Andres Breton
#	FILE: database.pm
#
# =============================================

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# MAIN
sub startMongoDB {
    my ($MONGODB, $outDir) = @_;
    my $dbDir = $outDir."/db";
    `mkdir $dbDir` unless (-e $dbDir);
    my $mongoLog = $dbDir."/mongo.log";

    my $command = "mongod --dbpath $dbDir --logpath $mongoLog --fork";
    my @result = `$command`; #get shell results
    if ($? != 0) {
        confess "Failed to execute $command\nThis could be that an instance of [mongod] is already running. Please check processes for mongod.", $!;

        # # Check mongod instance
        # my $pid = $result[1] =~ /.+:\s(\d+)$/; $pid = $1; #get child PID
    }else {
        my $pid = $result[1] =~ /.+:\s(\d+)$/; $pid = $1; #get child PID
        say "\nMongoDB started...";
        return $pid;
    }
}

sub databaseConnection {
    my ($MONGODB, $TASK, $COLLECTION, $id, $gi, $accession, $version, $locus, $organism, $sequence, $seqLen, $gene, $proteinID, $translation) = @_;

    my $client = MongoDB::MongoClient->new; #connect to local db server
    my $db = $client->get_database($MONGODB); #get MongoDB databse
    my $collection = $db->get_collection($COLLECTION); #get collection

    # Operation on Database
    say "Storing data for ID ($id) into database $MONGODB";
    if ($TASK eq "insert") {
        insertData($collection, $gi, $accession, $version, $locus, $organism, $sequence, $seqLen, $gene, $proteinID, $translation);
    } elsif ($TASK eq "update") {
        updateData($collection);
    } elsif ($TASK eq "read") {
        readData($collection);
    } elsif ($TASK eq "remove") {
        removeData($collection);
    } else {
        croak "No write operation provided for Mongo database. Default is \"insert\", value passed is ($TASK).", $!;
    }
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# HELPERS
sub insertData {
    my ($collection, $gi, $accession, $version, $locus, $organism, $sequence, $seqLen, $gene, $proteinID, $translation) = @_;
    $collection->insert({"GI" => $gi,
                        "Accession" => $accession,
                        "Sequence" => $sequence,
                        "Version" => $version,
                        "Locus" => $locus,
                        "Organism" => $organism,
                        "Sequence" => $sequence,
                        "Sequence Length" => $seqLen,
                        "Gene" => $gene,
                        "Protein ID" => $proteinID,
                        "Translation" => $translation
                        })
}

sub updateData {
    my ($collection) = @_;
    $collection->update({"" => }, {'' => {'' => }});
}

sub readData {
    my ($collection) = @_;
    $collection->find({})
}

sub removeData {
    my ($collection) = @_;
    $collection->remove({})
}


1;
