Blinder is a web-based document blinding assistant. It is designed to perform blinding of student assignment documents. Upload a zip-compressed folder of files in doc/docx/pdf formats and blinder will remove the coverpage and rename the files in a code that anonymises the submissions.

For this to work, students need to have a coverpage, and begin the assignment responses on page 2. They should also refrain from adding any identifying information to pages 2 onwards.

Visit [blinder.cc](http://www.blinder.cc) to use to tool.

After uploading your zip file, you will get a download link to a zip file of blinded assignments. After extracting it, you will find:
- some pdf files
- checksums.tsv
- marking_table.tsv

The pdf files are the assigment documents after having the 1st page removed and
file name changed to a short code. Any doc or docx files have been converted to pdf.
If students haven't included a coverpage, then you might find the first page of the
document is missing. This tool does not 
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
