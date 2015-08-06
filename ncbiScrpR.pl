#!/usr/bin/perl

use warnings; use strict; use diagnostics; use feature qw(say);
use Getopt::Long; use Pod::Usage;

use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib (dirname abs_path $0). "/lib";

use Eutil; use Parser;


# =============================================
#
#	Created by: Andres Breton
#	File: ncbiScrpR.pl
#	License:
#
# =============================================


#-------------------------------------------------------------------------
# COMMAND LINE
my $ID = "";
my $DATABASE = "";
my $TYPE = "";
my $FORCE = "";
my $usage= "\n\n $0 [options]\n
Options:
    -id    IDs
    -db     Database (Nucleotide, protein, etc..)
    -type   FASTA, GenBank, etc...
    -force  Force download? [optional]
    -help   Shows this message
\n";

# OPTIONS
GetOptions(
    'id=i'      =>\$ID,
    'db=s'      =>\$DATABASE,
    'type=s'    =>\$TYPE,
    'force:0'   =>\$FORCE,
    help        =>sub{pod2usage($usage);}
)or pod2usage(2);
#-------------------------------------------------------------------------
# CHECKS
unless($ID) {
    die "Did not provide an ID, -id 34577062 $!", $usage;
}
unless($DATABASE) {
    die "Did not provide a database, -db nucleotide", $usage;
}
unless($TYPE) {
    die "Did not provide a type format, -type fasta", $usage;
}
#-------------------------------------------------------------------------
# VARIABLES
my $outDir = createDownloadDir();
my $email = 'breton.a@husky.neu.edu';
#-------------------------------------------------------------------------
# CALLS
my $NCBIfile = getNCBIfile($ID, $outDir, $FORCE, $DATABASE, $TYPE, $email);
if($NCBIfile == 1) {
    parseFile($NCBIfile);
}else {
    die "Something happened. Could not get file from NCBI $!";
}
#-------------------------------------------------------------------------
# SUBS
sub createDownloadDir{
    my $user = `whoami`; chomp $user;
    my $outDir = "Output";
    if (! -e $outDir){
        `mkdir $outDir`;
    }
    return $outDir;
}
