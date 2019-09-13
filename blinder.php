<?php

function test_input($data) {
  $data = trim($data);
  $data = str_replace(' ', '_', $data);
  $data = preg_replace('/[^A-Za-z0-9\_.\']/', '', $data);
  $data = stripslashes($data);
  $data = htmlspecialchars($data);
  return $data;
}

$uploadFail = "";
$file_result = "";
$mail_result = "";
$filename = "";
$file = "";
$email = "";
$emailErr = "";
$name = "";
$ext = "";
$mime = "";
$type = "";
$output = "";
$report_path = "";

$filename = $_FILES["file"]["name"];
$type =$_FILES["file"]["type"];
$email = $_POST["email"];

if ($_FILES["file"]["error"] > 0) {
	echo "No file uploaded or invalid file <br>";
	echo "Error code: " . $_FILES["file"]["error"] . "<br>";
} else {

 // Check file size
if ($_FILES["file"]["size"] > 50000000) {
    echo "Sorry, your file is too large. The upper limit is 50MB. <br>";
    $uploadFail = 1;
}

// Allow certain file formats
$allowed = array('zip','ZIP');
$name = $_FILES["file"]["name"];
$ext = end((explode(".", $name)));
if( ! in_array($ext,$allowed) ) {
    echo "Sorry, only zip files are allowed. <br>";
    $uploadFail = 1;
}

if ($uploadFail == 1) {
    echo "Sorry, your file was not uploaded. <br>";
// if everything is ok, try to upload file
} else {

	$file_result .=
	"Upload: " . $_FILES["file"]["name"] . "<br>" .
	"Type: " . $_FILES["file"]["type"] . "<br>" .
	"Size: " . ($_FILES["file"]["size"] / 1024) . " Kb<br>" .
	"Temp file: " . $_FILES["file"]["tmp_name"] . "<br>" ;

        $name = str_replace(' ', '_', $name);
	$name = test_input($name);

	move_uploaded_file($_FILES["file"]["tmp_name"],
	"/var/www/upload/" . $name  ) ;

	$file_result .= "File upload successful!";

	$file_path = "";
	$file_path .=  "/var/www/upload/" . $name ;

	if ( $email !== "" ) {
	$mail_result .= $_POST["email"];

	if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
	$emailErr = "Invalid email format";
	echo "$emailErr";
	} else {

        $old_path = getcwd();
        chdir('/var/www/code');
        $output = shell_exec("./blinder.sh $file_path $mail_result");
        $report_path .= $file_path . "rep" ;
#        print_r($report_path);
	chdir($old_path);

	}} else {

        $mail_result .= "No email address provided";
        $old_path = getcwd();
        chdir('/var/www/code');
        $output = shell_exec("./blinder.sh $file_path");
        $report_path .= $file_path . "rep" ;
#        print_r($report_path);
        chdir($old_path);
	}

}
}


echo $output;

?>



<html>
<head>
<style>
body { margin:0; padding:0; background:#CCC; font-family:Arial; }

.fileuploadholder {
	width:400px;
	height:auto;
	margin: 20px auto 0px auto;
	background-color:#FFF;
	border:1px solid #CCC;
	padding:6px;
}
  div.section_header {
    padding: 3px 6px 3px 6px;

    background-color: #8E9CB2;

    color: #FFFFFF;
    font-weight: bold;
    font-size: 200%;
    text-align: center;
  }

</style>

