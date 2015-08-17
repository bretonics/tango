package Database;

use Exporter qw(import);
our @ISA = qw(Exporter);
our @EXPORT = qw(startMongoDB insertData updateData readData removeData); #functions exported by default

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
    my $pid;
    my $dbDir = $outDir."/db";
    `mkdir $dbDir` unless (-e $dbDir);
    my $mongoLog = $dbDir."/mongo.log";

    my $command = "mongod --dbpath $dbDir --logpath $mongoLog --fork";
    say "\nStarting MongoDB server...";
    my @result = `$command`; #get shell results
    if ($? == 0) { #Check return value
        $pid = $result[1] =~ /.+:\s(\d+)$/; $pid = $1; #get child PID
        say "MongoDB successfully started.";
        return $pid;
    } elsif ($? == 25600) { #Possible mongd already running
        say "*********FAILED";
        say "Could not fork. This was most likely caused by an instance of [mongod] already running.";
        # Check for Currently Running MongoDB Server
        my @mongdPS = `ps -e -o pid,args | grep \"mongod\"`;
        if ($mongdPS[0] =~ /^\s?(\d+)\s+mongod.*/) {
            $pid = $1;
            say "YES! Found running process: $mongdPS[0]";
            print "Would you like to continue (y/n)? ";
            my $response = lc <>; chomp $response;
            if ($response eq "yes" || $response eq "y") {
                return $pid;
            } else {
                exit;
            }
        }
    } else {
        croak "ERROR: Failed to execute $command\n Something happened that did not allow MongoDB server to start!", $!;
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
}

sub readData {
    my ($id, $PID, $MONGODB, $COLLECTION, $TASK, $QUERY) = @_;
    say "READING ID:$id from database...";
    my $collectionObj = databaseConnection($MONGODB, $COLLECTION);
    $collectionObj->find({});
}

sub removeData {
    my ($id, $PID, $MONGODB, $COLLECTION, $TASK, $QUERY) = @_;
    say "REMOVING ID:$id from database...";
    my $collectionObj = databaseConnection($MONGODB, $COLLECTION);
    # $collectionObj->remove({});
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
1;
