#####################
# barcodecapture.sh #
#      README       #
#####################


# The 'barcodecapture.sh' script will extract fastq sequence reads for a set of barcodes. This script should work on any mac or linux machine, but you will need a bash shell on a windows machine to use this script, as it is written in bash.  
 
# Typically, raw sequences will be gzipped and contain a .gz file extension, and this script assumes that they are.  If not they will need to be gzipped first using the gzip command in bash.  

# If the sequence file contains more than 100 million lines, the script defaults to split the file into multiple files of 100 million lines each and operate on them sequentially before recombining and compressing them at the end to save on memory usage.  This often requires up to ~8GB of memory and may take several hours per sequence file, depending upon size.  If memory is insuffienct or an error occurs, use a smaller split size.  Additionally you will need plenty of free harddrive space, probably at least 20GB, but it could require more large sequence files.


###############
#    Usage    #
###############

sh barcodecapture.sh inputseqfile.gz barcodefile outputseqfile.gz splitsize

# - the inputsequence.gz is the compressed (i.e. gzipped) raw sequence reads in fastq format
# - the barcodefile is a text file where each line contains one barcode to be extracted. Its a good idea to add the enzyme recognition sequnce to each barcode to limit the number of mid-sequence matches.
# - the outputseq.gz file is the desired name of the gzipped ouput of subset sequences  
# - the splitsize argument defines how many lines of sequence should be in each file split. The default is 100000000 if no argument is supplied. If there is sufficent memory, you can provide a larger integer for fewer splits. Alternatively supplying the argument 'FAST' instead of an integer will force the file to be processed all at once. NOTE: the FAST method requires A LOT of memory, (e.g.  or sometimes even greater), for a typical sequnce file.  While this method is slightly faster, it can require a lot of memory and result in failure if the required memory is exceeded, so usually splitting large files is best.


###############
#   Example   #
###############

# Navigate to the example folder and type:

barcodecapture.sh example.fastq.gz examplebarcode.txt exampleoutput.fastq.gz


# To split the file into smaller pieces provide an integer to the split size, such as 200000 

barcodecapture.sh example.fastq.gz examplebarcode.txt exampleoutput.fastq.gz 200000


# Note: this is just for the example, and 200000 would normally be far too small for a sequence file by 2 to 3 orders of magnitude.
# run the following code to check to make sure the output matches the output file provided:

if cmp -s <(gzip -cd exampleoutput.gz) <(gzip -cd outputcheck.gz)
then
   echo "Good! The files match."
else
   echo "Oh No! The files are different."
fi


###################################
# Parsing multiple sequence files #
###################################

# The easiest way to run this for multiple files is to write a small bash script that calls the command several times in sequence. DO NOT try to run several calls in parallel as multiple reading and writing to the disc can result in an error. See example bash script to run mutliple calls below:


###############################
# Example run multiple script #
###############################
# Dont actually run this, its just to show what a short bash script to parse multple files would look like.  It will need to be saved with a .sh extension, and executed with sh.

#!/bin/sh
barcodecapture.sh in1.gz barcode1.txt out1.fastq.gz
barcodecapture.sh in2.gz barcode2.txt out2.fastq.gz



