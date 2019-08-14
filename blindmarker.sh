#!/bin/bash

ZIP="$1"

# create temporary directory
WD=$RANDOM$RANDOM$RANDOM
mkdir "$WD"
cp "$ZIP" $WD
cd $WD
unzip "$ZIP"

# fix the filenames
detox *pdf *doc *docx

# now deal with the word documents
ls | egrep '(doc$|docx)' > doclist

# now to conert the doc/docx files and to pdfs
for DOC in *doc *docx ; do
  echo $DOC
  unoconv "$DOC" "$DOC.pdf"
done


# classify front pages based on number of words
for PDF in *pdf ; do
  pdftotext -f 1 -l 1 $PDF - | wc -w \
  | sed "s/$/\t${PDF}/"
done | sort -n | awk '$1>100 {print $2}' > nocovpg.txt

#
#while read line ; do pdftotext -f 1 -l 1  $line - ; done < nocovpg.txt 

# now remove the front page
mkdir blind
for PDF in *pdf ; do
  pdftk $PDF cat 2-end output blind/$PDF
done


# save checksums
cd blind
for PDF in *pdf ; do
  ORIG_MD5=$(md5sum ../$PDF| cut -d ' ' -f1 )
  TRIM_MD5=$(md5sum $PDF| cut -d ' ' -f1)
  echo $PDF $ORIG_MD5 $TRIM_MD5
done > checksums.md5


# find shortest prefix length
N=2
while [ $(cut -d ' ' -f2- checksums.md5 | tr ' ' '\n' | cut -c-${N} | sort | uniq -d | wc -l) -gt 0 ] ; do
  echo $N
  let N=N+1
done ; echo $N

PFXLEN=$N

for PDF in *pdf ; do
  PFX=$(md5sum ../$PDF | cut -d ' ' -f1 | cut -c-${PFXLEN})
  mv $PDF $PFX.pdf
done

echo OriginalFileName OrigCheckSum BlindedCheckSum BlindFilename Grade > marking_table.tsv
paste <(sort -k 2b,2 checksums.md5) <(ls *pdf) | tr ' ' '\t' >> marking_table.tsv


cd ..

zip -r blinded.zip blind/

