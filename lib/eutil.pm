package eutil;

use Exporter qw(import);
our @ISA = qw(Exporter);
our @EXPORT = qw(getNCBIfile); #functions exported by default

use warnings; use strict; use diagnostics; use feature qw(say);
use Carp;
use Bio::DB::EUtilities;


#####################
#
# 	Created by: Andres Breton
#	File: eutil.pl
#
#####################


sub getNCBIfile {
    my ($id, $outDir, $forceDownload, $db, $retType, $email) = @_;
    my $eutil = Bio::DB::EUtilities->new(
                -eutil => "efetch",
                -db => $db,
                -id => $id,
                -email => $email,
                -rettype => $retType,
    );

    my $outFile = $outDir."/$id.".$retType;

    #Fetch
    $eutil->get_Response( -file => $outFile);
    say "Fetching data from NCBI for ID: $id";
    sleep(3);
}
1;
