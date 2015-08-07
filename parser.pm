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


sub parseHeader {
    my ($NCBIfile) = @_;
    unless(open(INFILE, "<", $NCBIfile)) {
        croak "Can't open $NCBIfile for reading " , $!;
    }

    ## Get entire file in variable
    $/ = ''; #line separator
    my $FILE = <INFILE>;
    $/ = "\n";  #set back line separator
    close INFILE;

    # Get Locus Name and Sequence Length
    my ($locus, $seqLen) = getLocus($FILE);
    # Get Accession
    my $accession = getAccession($FILE);
    # Get Version
    my $version = getVersion($FILE);
    # Get Organism
    my $organism = getOrganism($FILE);

    return $locus, $seqLen, $accession, $version, $organism;
}

sub getLocus {
    my ($file) = @_;
    if($file =~ /^LOCUS\s+(\w+)\s+(\d+)\s+/) {
        my ($locus, $seqLen) = ($1, $2);
        return $locus, $seqLen;
    }
}

sub getAccession {
    my ($file) = @_;
    if($file =~ /^ACCESSION\s+(\w+)/m) {
        my $accession = $1; return $accession;
    }
}

sub getVersion {
    my ($file) = @_;
    if($file =~ /^VERSION\s+(\w+)\s+/m) {
            my $version = $1; return $version;
        }
}

sub getOrganism {
    my ($file) = @_;
    if($file =~ /organism="(.*?)"/) {
        my $organism = $1; return $organism;
    }
}
