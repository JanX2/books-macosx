#!/bin/bash

/usr/bin/xsltproc --stringparam date "`date`" "$1" "$2" > /tmp/books-export/output.fo

CLASSPATH="."

for i in `ls ./fop-jars`; do 
	CLASSPATH=$CLASSPATH:./fop-jars/$i
done

rm "$3"

/usr/bin/java -cp $CLASSPATH org.apache.fop.cli.Main /tmp/books-export/output.fo "$3"

rm /tmp/books-export/output.fo