#!/bin/sh
# $1 = fastq
# $2 = barcodes
# $3 = output file
# $4 = splitSize

echo "input.fastq.gz file......... $1"
echo "barcode file................ $2"
echo "output.fastq.gz file........ $3"

echo "`date` ... Process started"

if [ -z "$1" ] || [ -z "$2" ]
	then
		echo "Provide the input gzipped fastq file, barcode file, and an output file name"
		echo "Optionally you may provie the number of split size for large files, default is 100 million lines and may require about 8GB of memory"
		echo "For a faster but memory inefficient method, type 'FAST' instead of the split size argument"
fi

if [ -z "$3" ] 
then
	OUTPUT="output.fastq.gz"
else 
	OUTPUT=$3
fi

if [ "$4" == "FAST" ]
then
	gzip -cd "$1" | grep  -B1 -A2 -f "$2" | grep -v -- "^--$" | gzip -c > "$3"
else 
	if [ -z "$4" ]
	then
	SPLITSIZE=100000000
	else
	SPLITSIZE=$4 
	fi

	ISDIVISIBLE=`expr $SPLITSIZE % 4`
	if [ "$ISDIVISIBLE" -ne 0 ]
	then
		echo "Split size must be an integer divisible by 4, or type 'FAST' for a fast but memory inefficient method"
		exit 1	
	fi

   	TEMPDIR=$(mktemp -d splittmpXXXXXX)

	echo "`date` ... UNZIP commencing..."
	gzip -cd "$1" > $TEMPDIR/fastqtemp

	NLINES=$(wc -l < $TEMPDIR/fastqtemp)
	NSEQ=$(($NLINES / 4))
   	echo "File to parse has "$NSEQ" sequence reads."

	if [ "$NLINES" -ge "$SPLITSIZE" ]
	then
		echo "`date` ... SPLIT commencing..."
		split -"$SPLITSIZE" $TEMPDIR/fastqtemp $TEMPDIR/Split_
		rm $TEMPDIR/fastqtemp

		NOSPLIT=$(ls $TEMPDIR/Split_* | wc -w)
	    echo "split size is $SPLITSIZE, with $NOSPLIT splits"
	    
	    for i in $TEMPDIR/Split_*
	    do
		    echo "`date` ... PARSE SEQUENCE $i commencing..."
			grep  -B1 -A2 -f "$2" "$i" > "${i}_sub"
			# rm "$i"

			echo "`date` ... WRITE $i commencing..."
			grep -v -- "^--$" "${i}_sub" > "${i}_subnd"
	    	# rm "${i}_sub"
	    done
		
		# rm "$TEMPDIR/Split_"*
	    echo "`date` ... CAT commencing..."
	    cat $TEMPDIR/*_subnd > $TEMPDIR/fastqtozip
	    # rm $TEMPDIR/*_sub*
	else
		echo "File will NOT be split, provide a fourth argument as an integer less than 100000000 (100 million) to split the file" 
		echo "Alternatively, provide the argument 'FAST' to expedite the process a little."
		echo "`date` ... PARSE SEQUENCE commencing..."
		grep  -B1 -A2 -f "$2" $TEMPDIR/fastqtemp > $TEMPDIR/fastqtemp2

		echo "`date` ... WRITE commencing..."
		grep -v -- "^--$" $TEMPDIR/fastqtemp2 > $TEMPDIR/fastqtozip
		rm $TEMPDIR/fastqtemp2
	fi

	echo "`date` ... COMPRESS commencing..."
	gzip -c $TEMPDIR/fastqtozip > "$3"

	echo "`date` ... CLEANUP commencing..."
	rm -rf $TEMPDIR
fi

echo "`date` ... Process finished."

