package Database;

use Exporter qw(import);
our @ISA = qw(Exporter);
our @EXPORT = qw(startMongoDB insertData updateData readData removeData); #functions exported by default

use warnings; use strict; use diagnostics; use feature qw(say);
use Carp;

use Eutil; use MongoDB; use MongoDB::OID;


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
        confess "Failed to execute $command\nThis could be that an instance of [mongod] is already running. Please check processes for mongod. $?", $!;

        # # Check mongod instance
        # my $pid = $result[1] =~ /.+:\s(\d+)$/; $pid = $1; #get child PID
    }else {
        my $pid = $result[1] =~ /.+:\s(\d+)$/; $pid = $1; #get child PID
        say "\nMongoDB started...";
        return $pid;
    }
}

sub insertData {
    my ($MONGODB, $TASK, $COLLECTION, $id, $gi, $accession, $version, $locus, $organism, $sequence, $seqLen, $gene, $proteinID, $translation) = @_;

    my $collectionObj = databaseConnection($MONGODB, $COLLECTION);
    say "Storing data for ID ($id) into database $MONGODB";
    $collectionObj->insert({_id => $gi, #GI stored as Mongo UID
                        "Accession" => $accession,
                        "Sequence" => $sequence,
                        "Version" => $version,
                        "Locus" => $locus,
                        "Organism" => $organism,
                        "Sequence Length" => $seqLen,
                        "Sequence" => $sequence,
                        "Gene" => $gene,
                        "Protein ID" => $proteinID,
                        "Translation" => $translation
                        })
}

sub updateData {
    my ($id, $PID, $MONGODB, $COLLECTION, $TASK, $QUERY) = @_;
    say "UPDATING ID:$id in database...";
    # my $collectionObj = databaseConnection($MONGODB, $COLLECTION);
    # $collectionObj->update({"" => }, {'' => {'' => }});
    shutdownMDB($PID);
}

sub readData {
    my ($id, $PID, $MONGODB, $COLLECTION, $TASK, $QUERY) = @_;
    say "READING ID:$id from database...";
    my $collectionObj = databaseConnection($MONGODB, $COLLECTION);
    $collectionObj->find({});
    shutdownMDB($PID);
}

sub removeData {
    my ($id, $PID, $MONGODB, $COLLECTION, $TASK, $QUERY) = @_;
    say "REMOVING ID:$id from database...";
    my $collectionObj = databaseConnection($MONGODB, $COLLECTION);
    # $collectionObj->remove({});
    shutdownMDB($PID);
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# HELPERS
sub databaseConnection {
    my ($MONGODB, $COLLECTION) = @_;
    my $client = MongoDB::MongoClient->new; #connect to local db server
    my $db = $client->get_database($MONGODB); #get MongoDB databse
    my $collectionObj = $db->get_collection($COLLECTION); #get collection
    return $collectionObj;
}

sub shutdownMDB {
    my ($PID) = @_;
    say "\nClosing MongoDB.\n"; exec("kill $PID"); #shutdown MongoDB server
}
1;
