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

# fix the crazy filenames
detox -r *

# bring all documents to pwd
mv $(find . | egrep -i '(doc$|docx$|pdf$)') .
MYCNT=$(find . | egrep -ic '(doc$|docx$|pdf$)')
echo "Found $MYCNT documents including pdf and doc/docx files. <br>"

# all lower case for simplicity
rename -f 'y/A-Z/a-z/' *

# now deal with the word documents
find . | egrep '(doc$|docx$)' > doclist

# now to conert the doc/docx files and to pdfs
DOCCNT=$(wc -l < doclist)
if [ $DOCCNT -ge 1 ] ; then
  echo "Converting $DOCCNT word docs to PDFs. <br>"
  ls *doc *docx | parallel unoconv {} {}.pdf
fi

#DOCCNT=$(find . | egrep -c '(doc$|docx$)' )
#echo "$DOCCNT doc/docx files didn't convert properly"<br>

# classify front pages based on number of words
CVRPG(){
pdftotext -f 1 -l 1 $1 - | wc -w  | sed "s/$/\t${PDF}/"
}
export -f CVRPG
ls *pdf | parallel CVRPG | sort -n | awk '$1>100 {print $2}' > nocovpg.txt


# now remove the front page
MYCNT=$(find . | egrep -ic '(pdf$)')
echo "Removing coverpage from $MYCNT pdf documents. <br>"
mkdir blind
ls *pdf | parallel pdftk {} cat 2-end output blind/{}


# save checksums
cd blind
echo "OrigFileName OrigCheckSum BlindedCheckSum" | tr ' ' '\t' > checksums.tsv
CHCKSUMS(){
PDF=$1
ORIG_MD5=$(md5sum ../$PDF| cut -d ' ' -f1 )
TRIM_MD5=$(md5sum $PDF| cut -d ' ' -f1)
echo $PDF $ORIG_MD5 $TRIM_MD5
}
export -f CHCKSUMS
ls *pdf | parallel CHCKSUMS {} | tr ' ' '\t' >> checksums.tsv



# find shortest prefix length
N=2
while [ $(cut -f2 checksums.tsv | sed 1d | tr ' ' '\n' | cut -c-${N} | sort | uniq -d | wc -l) -gt 0 ] ; do
  let N=N+1
done

PFXLEN=$N

echo "Renaming PDFs. <br><br>"

#for PDF in *pdf ; do
#  PFX=$(md5sum ../$PDF | cut -d ' ' -f1 | cut -c-${PFXLEN})
#  mv $PDF $PFX.pdf
#done

RENAME(){
PDF=$1
PFXLEN=$2
PFX=$(md5sum ../$PDF | cut -d ' ' -f1 | cut -c-${PFXLEN})
mv $PDF $PFX.pdf
}
export -f RENAME
parallel RENAME ::: *pdf ::: $PFXLEN


echo OrigCheckSum BlindedCheckSum BlindFilename Grade | tr ' ' '\t' > marking_table.tsv
paste <(sed 1d checksums.tsv | sort -k 2b,2 ) <(ls *pdf) | tr ' ' '\t' | cut -f2- >> marking_table.tsv

wget "https://raw.githubusercontent.com/markziemann/blinder/master/doc/readme.txt"

cd ..

zip -r blinded.zip blind/ >/dev/null 2>&1

################################################
# Generate a report
################################################
# add some more information to the reort
REPORT=$WD.rep


cat <<EOT | fold -s -w120 | sed 's/$/<br>/' >> $REPORT
Thanks for using Blinder. We provide this free tool to the academic community \
to help assessment fairness. Please understand that this tool is a work in \
progress and that bugs may be present. \
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
find /tmp/ -name '*blind*' -maxdepth 1 -mmin +10 -exec rm -rfv {} >/dev/null  2>&1 \;


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

blinder "$1"

