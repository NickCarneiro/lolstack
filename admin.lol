<?php
include_once("header.lol");
if(!Auth::isAdmin()){
	header("Location: login.lol");
	die();
}

renderHeader("Admin panel");
echo ("<div class=\"entries\">");

$query = "SELECT COUNT(*) FROM pics";		
$result = mysql_query($query);
if (!$result){
	error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
}
$row = mysql_fetch_row($result);
$piccount = $row[0];

$query = "SELECT COUNT(*) FROM users WHERE privilege < 2";		
$result = mysql_query($query);
if (!$result){
	error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
}
$row = mysql_fetch_row($result);
$usercount = $row[0];

$query = "SELECT COUNT(*) FROM comments";		
$result = mysql_query($query);
if (!$result){
	error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
}
$row = mysql_fetch_row($result);
$commentcount = $row[0];

echo ('
<h1>Admin Panel</h1>
<form action="processAdmin.lol" method="post">
Delete pic: <input name="delete" type="text" /><br />
<input type="submit" name="submit" value="submit" />
</form>
<br />
<h1>Stats</h1>
Total users: '.$usercount.'<br />
Total pics: '.$piccount.'<br />
Total comments: '.$commentcount);
echo ("</div>");
include_once("htmlfooter.lol");
?>