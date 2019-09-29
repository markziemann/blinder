#!/bin/bash

set -x

################################################################################
#
# unblinder.sh is a document unblinding assistant.
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
MYCODE=$RANDOM$RANDOM$RANDOM
WD=/var/www/html/unblinder_$MYCODE
WD2=unblinder_$MYCODE

mkdir "$WD"
cp "$ZIP" $WD
cd $WD
unzip "$ZIP" >/dev/null 2>&1

# bring all documents to pwd
mv $(find . | egrep -i '(doc$|docx$|pdf$|tsv$)') .
MYCNT=$(find . | egrep -ic '(pdf$)')
echo "Found $MYCNT pdf files. <br><br> "

mkdir unblinded
sed 1d marking_table.tsv | while read line ; do
    FILE=$(echo $line | cut -d ' ' -f3)
    CHECKSUM=$(grep -w $FILE marking_table.tsv | cut -f1 )
    NAME=$(grep -w $CHECKSUM checksums.tsv | cut -f1)
    mv $FILE unblinded/$NAME
done

join -1 2 -2 1 \
 <(sort -k 2,2 checksums.tsv) \
 <(sort -k 1b,1 marking_table.tsv) \
| tr ' ' '\t' \
| awk '{OFS="\t"}{print $2,$1,$3,$5,$6}' \
| sort -k2g > results.tsv

mv marking_table.tsv checksums.tsv results.tsv unblinded

zip -r unblinded.zip unblinded >/dev/null 2>&1

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
find /var/www/html -name '*blinder_*' -maxdepth 1 -mmin +10 -exec rm -rfv {} >/dev/null  2>&1 \;


cat <<EOT
<form action="$WD2/unblinded.zip">
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


