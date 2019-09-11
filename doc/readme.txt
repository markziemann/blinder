Blinder is a document blinding assistant.

It accepts a zip folder containing documents including doc/docx/pdf formats
and returns a zip folder of pdf files that have had the coverpage removed
and renames in such a coded way to remove identifying info. It provides a
table so that after marking, the assignments can be re-identified again.

by Mark Ziemann email:mark.ziemann@gmail.com

In this folder you will find:
- some pdf files
- checksums.tsv
- marking_table.tsv

The pdf files are the assigment documents after having the 1st page removed and
file name changed to a short code. If students haven't included a coverpage, then
you might find the first page of the document is missing. This tool does not 
remove any identifying information elsewhere in the assignment so students will
need to be instructed not to add identifiable information to pages 2 and onwards,
as well as to begin the assignment on page 2.

The marking table is useful to import into a spreadsheet and to populate grades 
while marking is in progress. It doesn't contain any identifiable information.

The checksums.tsv is a table that can be imported into a spreadsheet to match up
the graded files to the originally submitted file. Note that the rows are likely
a different order so matching the blind files to the original needs to be done 
carefully. 

If you are delegating marking to an assistant, delete the checksums.tsv file
before sending to them (keep a copy for you own records). Ask the assistant
to complete the marking table.


