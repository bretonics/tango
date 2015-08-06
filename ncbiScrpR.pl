#!/usr/bin/perl

use warnings; use strict; use diagnostics; use feature qw(say);
use Getopt::Long; use Pod::Usage;

use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib (dirname abs_path $0). "/lib";

use eutil;


# =============================================
#
#	Created by: Andres Breton
#	File:
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
    -id     ID
    -db     Database (Nucleotide, protein, etc..)
    -type   FASTA, GeneBank, etc...
    -force  Force download?
    -help   Shows this message
\n";

# OPTIONS
GetOptions(
    'id=i'      =>\$ID,
    'db=s'      =>\$DATABASE,
    'type=s'    =>\$TYPE,
    'force:0'   =>\$FORCE,
    help    =>sub{pod2usage($usage);}
)or pod2usage(2);
#-------------------------------------------------------------------------
# CHECKS
unless ($ID){
    die "Did not provide an ID, -id 34577062", $usage;
}
#-------------------------------------------------------------------------
# VARIABLES
my $outDir = createDownloadDir();
my $email = 'breton.a@husky.neu.edu';
#-------------------------------------------------------------------------
# CALLS
my $genBank = getNCBIfile($ID, $outDir, $FORCE, $DATABASE, $TYPE, $email);
#-------------------------------------------------------------------------
# SUBS
sub createDownloadDir{
    my $user = `whoami`; chomp $user;
    my $outDir = "GenBank";
    if (! -e $outDir){
        `mkdir $outDir`;
    }
    return $outDir;
}
