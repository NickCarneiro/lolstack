<?php
include_once("header.lol");
if(!Auth::isAdmin()){
	header("Location: login.lol");
	die();
}
renderHeader("Admin panel");
echo ("<div class=\"entries\">");
if (isset($_POST['delete'])){
	if(!is_numeric($_POST['delete'])){
		die("pic id was not numeric");
	}
	$deleteid = $_POST['delete'];
	error_log('deleting pic id: '.$deleteid);
	
	//get pic metadata
	$query = "SELECT pics.id,pics.title,pics.description,pics.filetype,pics.phash,
	pics.category,pics.upvotes,pics.downvotes,pics.user_id,users.username, pics.date_added 
	FROM pics,users WHERE pics.id=$deleteid AND pics.user_id=users.id";
	$result = mysql_query($query);
	$rowcount = mysql_num_rows($result);
	if (!$result){
		echo("SQL error: ".mysql_error()."\nOriginal query: $query\n");
		die();
	}
	if ($rowcount == 0) {
		echo "pic not found for id $deleteid <br>";
		die();
	}
	
	$row = mysql_fetch_assoc($result);
	$dateadded = $row['date_added'];
	$directory = substr($dateadded,0,10); //get date from mysql datetime
	if($row['phash'] == ""){
		die('phash of pic '.$deleteid.' was empty');
	}
	$phash = $row['phash'];
	$filetype = $row['filetype'];
	//delete pic file
	unlink("/srv/uploads/$directory/$phash.$filetype");
	echo("deleted pic from filesystem <br>");
	
	//delete pic from database
	$query = "DELETE FROM pics WHERE id=$deleteid";
	$result = mysql_query($query);
	
	if (!$result){
		echo("SQL error: ".mysql_error()."\nOriginal query: $query\n <br>");
		die();
	}
	echo("deleted entry in pics table <br>");
	
	//delete mirrors from database
	$query = "DELETE FROM mirrors WHERE picid=$deleteid";
	$result = mysql_query($query);
	
	if (!$result){
		echo("SQL error: ".mysql_error()."\nOriginal query: $query\n <br>");
		die();
	}
	echo("deleted entry in mirrors table <br>
	");
}
echo ("<br>
	<a href=\"javascript:history.back()\">back</a></div>");
include_once("htmlfooter.lol");
?>