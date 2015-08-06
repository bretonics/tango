package Eutil;

use Exporter qw(import);
our @ISA = qw(Exporter);
our @EXPORT = qw(getNCBIfile); #functions exported by default

use warnings; use strict; use diagnostics; use feature qw(say);
use Carp;
use Bio::DB::EUtilities;

# =============================================
#
# 	Created by: Andres Breton
#	File: eutil.pm
#
# =============================================


sub getNCBIfile {
    my ($ID, $outDir, $FORCE, $DATABASE, $TYPE, $email) = @_;

    my $eutil = Bio::DB::EUtilities->new(
            -eutil => "efetch",
            -db => $DATABASE,
            -id => $ID,
            -email => $email,
            -rettype => $TYPE,
    );

    my $outFile = $outDir."/$ID.".$TYPE;

    #Fetch
    $eutil->get_Response( -file => $outFile);
    say "Fetching data from NCBI for ID $ID";
    sleep(3); #Don't overload NCBI requests
    return 1;
}
1;
