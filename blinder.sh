#!/bin/bash

set -x

################################################################################
#
# blinder.sh is a document blinding assistant.
#
# It accepts a zip folder containing documents including doc/docx/pdf formats
# and returns a zip folder of pdf files that have had the coverpage removed
# and renames in such a coded way to remove identifying info. It provides a
# table so that after marking, the assignments can be re-identified again.
#
# by Mark Ziemann email:mark.ziemann@gmail.com
#
################################################################################

blinder(){
ZIP="$1"

# create temporary directory
WD=/tmp/blinder_$RANDOM$RANDOM$RANDOM
mkdir "$WD"
cp "$ZIP" $WD
cd $WD
unzip "$ZIP" >/dev/null 2>&1

# fix the filenames
detox *pdf *doc *docx

# now deal with the word documents
ls | egrep '(doc$|docx)' > doclist

# now to conert the doc/docx files and to pdfs
DOCCNT=$(wc -l < doclist)
if [ $DOCLIST -ge 1 ] ; then
  for DOC in *doc *docx ; do
    unoconv "$DOC" "$DOC.pdf"
  done
fi

# classify front pages based on number of words
for PDF in *pdf ; do
  pdftotext -f 1 -l 1 $PDF - | wc -w \
  | sed "s/$/\t${PDF}/"
done | sort -n | awk '$1>100 {print $2}' > nocovpg.txt


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
  let N=N+1
done

PFXLEN=$N

for PDF in *pdf ; do
  PFX=$(md5sum ../$PDF | cut -d ' ' -f1 | cut -c-${PFXLEN})
  mv $PDF $PFX.pdf
done

echo OriginalFileName OrigCheckSum BlindedCheckSum BlindFilename Grade | tr ' ' '\t' > marking_table.tsv
paste <(sort -k 2b,2 checksums.md5) <(ls *pdf) | tr ' ' '\t' >> marking_table.tsv

cd ..

zip -r blinded.zip blind/ >/dev/null 2>&1

################################################
# Generate a report
################################################
# add some more information to the reort
REPORT=$WD.rep


cat <<EOT | fold -s -w120 | sed 's/$/<br>/' >> $REPORT

Thanks for using Blinder. We provide this free tool to the XXX community \
to help XXX. Please understand that this tool is a work in progress and \
that bugs may be present. \
Feedback via twitter: "@mdziemann".
Report bugs via GitHub: "https://github.com/markziemann/blinder/issues"

Disclaimer: Although all reasonable efforts have been taken to ensure the accuracy and reliability of the \
data and underlying software, the author and author's employer do not and cannot warrant the \
performance or results that may be obtained by using this software or data. We disclaim all warranties, \
express or implied, including warranties of performance, merchantability or fitness for any particular \
purpose.

EOT

#dump to screen
cat $REPORT

#sed -i 's/<br>//g' $REPORT
#enscript -B --margins=10:10: -o $REPORT.ps -f Courier@7.3/10 $REPORT
#ps2pdfwr $REPORT.ps $FILE.pdf

# remove old working directories


cat <<EOT
<form action="/code/$WD/blinded.zip">
    <input type="submit" value="Download zip file" />
</form>
<button onclick="goBack()">Go Back</button>

<script>
function goBack() {
    window.history.back();
}
</script>
EOT



}
export -f blinder

blinder $1
