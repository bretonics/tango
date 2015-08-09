package Parser;

use Exporter qw(import);
our @ISA = qw(Exporter);
our @EXPORT = qw(parseHeader parseFeatures); #functions exported by default

use warnings; use strict; use diagnostics; use feature qw(say);
use Carp;
use Bio::DB::GenBank; use Bio::SeqFeatureI;

# =============================================
#
# 	MASTERED BY: Andres Breton
#	FILE: parser.pm
#
# =============================================

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# MAIN
sub parseHeader {
    my ($NCBIfile) = @_;
    unless(open(INFILE, "<", $NCBIfile)) {
        croak "Can't open $NCBIfile for reading " , $!;
    }

    # Slurp File
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
    # Get GI
    my $gi = getGI($FILE);
    # Get Organism
    my $organism = getOrganism($FILE);
    # Get Sequence
    my $sequence = getSequence($FILE);
    # Get Gene
    # my $gene = getGene($FILE);

    return $locus, $seqLen, $accession, $version, $gi, $organism, $sequence;
}

sub parseFeatures {
    my ($id) = @_;
    my ($proteinID, $translation, $gene) = qw(NA NA NA);
    my $dbObject = Bio::DB::GenBank->new;   #set database object
    my $seqObject = $dbObject->get_Seq_by_id($id);  #set seq object
    for my $feature ($seqObject->get_SeqFeatures) {   #gets seqObject features
        # Get Protein ID and Translation
        if($feature->primary_tag eq "CDS") {
            ($proteinID, $translation) = getProteinID($feature);

            # if($feature->has_tag("protein_id")) {
            #     ($proteinID) = $feature->get_tag_values("protein_id");
            #     ($translation) = $feature->get_tag_values("translation");
            # }
        }
        # Get Gene
        if ($feature->primary_tag eq "gene") {
            ($gene) = getGene($feature);
        }
    }
    return $proteinID, $translation, $gene;
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# HELPERS
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

sub getGI {
	my ($file) = @_;
	if($file =~ /^VERSION.*GI:(\w+)/m){
		my $gi = $1; return $gi;
	}
	else{
		croak "ERROR getting GI", $!;
	}
}

sub getOrganism {
    my ($file) = @_;
    if($file =~ /organism="(.*?)"/) {
        my $organism = $1; return $organism;
    }
}

sub getSequence {
    my ($file) = @_;
    my $seq;
	if($file =~ /ORIGIN\s*(.*)\/\//s){
	    $seq = $1;
	}
	else{
		croak "ERROR getting sequence";
	}
	$seq =~ s/[\s\d]//g; #remove spaces/numbers from sequence
	return uc($seq);
}

sub getGene {
	my ($feature) = @_;
    my $gene;
	if($feature->has_tag("gene")) {
        ($gene) = $feature->get_tag_values("gene");
	}else{
		# return "unknown";
	}
    return $gene;
}
# sub getGene {
# 	my ($file) = @_;
# 	if($file=~/gene="(.*?)"/s){
# 		my $gene = $1; return $gene;
# 	}
# 	else{
# 		return 'unknown';
# 	}
# }

sub getProteinID {
	my ($feature) = @_;
    my ($proteinID, $translation);
    if($feature->has_tag("protein_id")) {
        ($proteinID) = $feature->get_tag_values("protein_id");
        ($translation) = $feature->get_tag_values("translation");
    }else{
		# return "unknown";
	}
    return $proteinID, $translation;
}

# sub getProteinID {
# 	my ($file) = @_;
# 	if($file=~/protein_id="(.*?)"/s){
# 		my $proteinID = $1; return $proteinID;
# 	}
# 	else{
# 		return 'unknown';
# 	}
# }
1;
