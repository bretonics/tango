package Parser;

use Exporter qw(import);
our @ISA = qw(Exporter);
our @EXPORT = qw(parseHeader); #functions exported by default

use warnings; use strict; use diagnostics; use feature qw(say);
use Carp;

# =============================================
#
# 	MASTERED BY: Andres Breton
#	FILE: parser.pm
#
# =============================================


parseHeader($NCBIfile);
sub parseHeader {
    my ($NCBIfile) = @_;
    open(FILE, "<", $NCBIfile);

    while(<FILE>) {
        # Get Locus Name and Sequence Length
        if($_ =~ /^LOCUS\s+(\w+)\s+(\d+)\s+/) {
            my ($locus, $seqLen) = ($1, $2);
        }
        # Get Accession
        if($_ =~ /^ACCESSION\s+(\w+)/) {
            my $accession = $1;
        }
        # Get Version
        if($_ =~ /^VERSION\s+(\w+)\s+/) {
            my $version = $1;
        }
        # Get Organism
        if($_ =~ /organism="(.*?)"/) {
            my $organism = $1;
        }
    }
    close(FILE);
}
