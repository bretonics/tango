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
    my ($DBNAME, $collectionName, $outDir) = @_;
    my $dbDir = $outDir."/db";
    `mkdir $dbDir` unless (-e $dbDir);
    my $mongoLog = $dbDir."/mongo.log";
    my $command = "mongod --dbpath $dbDir --logpath $mongoLog";
    system($command);
    if ($? == -1) {
        croak "Failed to execute $command", $1;
    }else {
        say "Starting MongoDB...";
    }

    my $client = MongoDB::MongoClient->new; #connect to local db server
    my $db = $client->get_database($DBNAME); #get MongoDB databse
    my $collection = $db->get_collection($collectionName); #get collection
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# HELPERS
sub insertData {
    my ($collection) = @_;
    $collection->insert({})
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
