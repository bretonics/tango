#Tango
&nbsp;

##Usage
Collect, store, and retrieve records from NCBI with just the GI number. Uses [NCBI's E-Utilities](http://www.ncbi.nlm.nih.gov/books/NBK25497/) interface and [MongoDB](https://www.mongodb.org/) as a database for storing locally the most relevant information. 

The program will connect and download the file from NCBI corresponding to the GI number(s) provided and the following are extracted and stored in a MongoDB database: 
>GI, accession, sequence, version, locus, organism, sequence length, gene, protein ID, translation

This creates a local database that can be accessed downstream for many applications. Documents can be inserted, updated, read, and removed in order to help create the database you wish.


###Options
    -ids            ID(s)
    -file           File with ID(s) [CSV or TXT]
    -db             Database (Nucleotide, protein, etc..) [optional]
    -type           gb, fasta, etc... [optional]
    -force          Force download? [optional]
    -mongo          MongoDB database name
    -collection     Collection name in MongoDB database
    -insert         Insert into database [optional/default]
    -update         Update database
    -read           Read from database
    -remove         Remove from database
    -help           Shows help message

**Please check dependencies** are locally installed before running. 

&nbsp;
###Database Operations
####Insert
To insert new data (documents) in the database, provide the GI number(s) with the optional `-insert` flag. 

The following have the same function:

	./tango.pl -file gis.csv	
	./tango.pl -file gis.csv -insert 
	./tango.pl -id 74960989 4165050 -insert

![](http://andresbreton.com/downloads/insertExample.png)


####Update
To update data (documents) stored in the database, provide the `-update` flag followed by the document you want to access in format `field:value` you want to update. You will be asked the field you wish to update in that document.

The following looks for the document with `_id field` matching `34577062`:

	./tango.pl -update _id:34577062
	
It will then tell you which document you are about to update and ask which field you wish to change.

	UPDATING _id record [34577062] in database...
	Available fields are:	_id accession sequence version locus organism seqLength gene proteinID translation

	What field do you want? sequence
	What is the NEW value for sequence field? NEWSEQUENCE
	Document 34577062 updated, sequence field changed to NEWSEQUENCE.


####Read
To read data (documents) stored in the database, provide the `-read` flag followed by your query in format `field:value`. You will be asked what field from the document you want to report back.

The following reads documents with `_id fields` matching `34577062` and `74960989`:

	./tango.pl -read _id:34577062 _id:74960989

![](http://andresbreton.com/downloads/readExample.png)

####Remove
To remove data (documents) stored in the database, provide the `-remove` flag followed by your query in format `field:value` you want removed.

The following removes documents with `_id fields` matching `34577062` and `74960989`:

	./tango.pl -remove _id:34577062 _id:74960989


&nbsp;
##Dependencies
<a name="dependencies"></a> 
You need to have the following installed:

1. [BioPerl](http://www.bioperl.org/wiki/Main_Page)

	**Modules:**
	* Eutilities
	* GenBank	
	* SeqFeatureI

2. [MongoDB](https://www.mongodb.org/downloads) with [MongoDB Perl Driver] (http://search.cpan.org/dist/MongoDB/)