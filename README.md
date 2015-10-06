#[Tango](https://github.com/bretonics/tango/zipball/master)
[![GitHub license](https://img.shields.io/badge/License-GPL2-blue.svg)](http://www.gnu.org/licenses/gpl-2.0.html)
[![Github Issues](http://githubbadges.herokuapp.com/bretonics/scripter/issues.svg)](https://github.com/bretonics/scripter/issues)
[![Pending Pull-Requests](http://githubbadges.herokuapp.com/bretonics/scripter/pulls.svg)](https://github.com/bretonics/scripter/pulls)
![](https://reposs.herokuapp.com/?path=bretonics/scripter&color=orange)

>Download source code by clicking **Tango** title above or [here](https://github.com/bretonics/tango/zipball/master). 

>**Please check that the list of [dependencies](#dependencies)** below are locally installed before running.



##Usage
Collect, store, and retrieve Genbank records from NCBI with just the GI number. Using [NCBI's E-Utilities](http://www.ncbi.nlm.nih.gov/books/NBK25497/) interface to fetch records and [MongoDB](https://www.mongodb.org/) as a local database for storage, the program essentially curates a **local** database that only contains the records you need with the most significant information. This facilitates maintaining a very specific dataset that can be accessed in downstream analysis. No more looking up NCBI files again!

When provided with GI ID(s), the program will connect and download the corresponding file(s) from NCBI, extract the most important data, and store the following in a MongoDB database: 
>GI, accession, sequence, version, locus, organism, sequence length, gene, protein ID, translation

Applying specific flags, documents can be created, updated, read, and removed in the MongoDB database. There are also options to name a database and the collection. For more information on how MongoDB stores it's data, visit [MongoDB's documentation](http://docs.mongodb.org/manual/core/crud-introduction/).

###Options
    -ids            ID(s)
    -file           File with ID(s) [csv or txt]
    -db             Database (Nucleotide, protein, etc..)
    -type           gb, fasta, etc...
    -force          Force download?
    -mongo          MongoDB database name
    -collection     Collection name in MongoDB database
    -insert         Insert into database [optional/default]
    -update         Update database
    -read           Read from database
    -remove         Remove from database
    -help           Shows help message 

Ex.) You may choose to create different databases by supplying the `-mongo` flag followed by the desired database name: `-mongo Axolotl`. 

Or choose a different collection by passing the `-collection` flag followed by the desired collection name: `-collection Protein`.

These are optional as defaults have been assigned to them already.


##Database Operations


###Insert
To insert new data (documents) in the database, provide the GI number(s) with the optional `-insert` flag. 

The following have the same function:

	./tango.pl -file Examples/gis.csv	
	./tango.pl -file Examples/gis.txt -insert 
	./tango.pl -id 74960989 4165050 -insert

![](http://andresbreton.com/downloads/insertExample.png)

&nbsp;
###Update
To update data (documents) stored in the database, provide the `-update` flag followed by the document you want to access in format `field:value` you want to update. You will be asked the field you wish to update in that document.

The following looks for the document with `_id field` matching `34577062`:

	./tango.pl -update _id:34577062
	
It will then tell you which document you are about to update and ask which field you wish to change:

	UPDATING _id record [34577062] in database...
	Available fields are:	_id accession sequence version locus organism seqLength gene proteinID translation

	What field do you want? sequence
	What is the NEW value for sequence field? NEWSEQUENCE
	Document 34577062 updated, sequence field changed to NEWSEQUENCE.


###Read
To read data (documents) stored in the database, provide the `-read` flag followed by your query in format `field:value`. You will be asked what field from the document you want to report back.

The following reads documents with `_id fields` matching `34577062` and `74960989`:

	./tango.pl -read _id:34577062 _id:74960989

![](http://andresbreton.com/downloads/readExample.png)


###Remove
To remove data (documents) stored in the database, provide the `-remove` flag followed by your query in format `field:value` you want removed.

The following removes documents with `_id fields` matching `34577062` and `74960989`:

	./tango.pl -remove _id:34577062 _id:74960989



##Dependencies
<a name="dependencies"></a> 
You need to have the following installed:

1. [BioPerl](http://www.bioperl.org/wiki/Main_Page)

2. BioPerl Modules ([CPAN](http://www.cpan.org))
	* [Eutilities](http://www.bioperl.org/wiki/Module:Bio::DB::EUtilities)
	* [GenBank](http://www.bioperl.org/wiki/Module:Bio::DB::GenBank)
	* [SeqFeatureI](http://www.bioperl.org/wiki/Module:Bio::SeqFeatureI)

3. [MongoDB](https://www.mongodb.org/downloads) 
	* [MongoDB Perl Driver] (http://search.cpan.org/dist/MongoDB/)