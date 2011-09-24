<?php
include_once("header.lol");
if(!Auth::isAdmin()){
	header("Location: login.lol");
	die();
}

renderHeader("Admin panel");


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
<div class="grid_16">
<div class="grid_4 entry alpha">
<span class="pic_instructions">Delete an image</span><br />
<form action="processAdmin.lol" method="post">
pic id: <input name="delete" type="text" /><br />
<input type="submit" name="submit" value="submit" />
</form>
</div>
<div class="entry grid_4">
<span class="pic_instructions">Stats</span><br />
Total users: '.$usercount.'<br />
Total pics: '.$piccount.'<br />
Total comments: '.$commentcount);
echo("</div>");
?>
<div class="entry omega grid_4">
<span class="pic_instructions">Ban a user</span><br />
<form action="processAdmin.lol" method="post">
user id: <input name="ban_user_id" type="text" /><br />
<input type="submit" name="submit" value="submit" />
</form>
</div>

<div class="entry omega grid_4">
<span class="pic_instructions">Mark NSFW</span><br />
<form action="processAdmin.lol" method="post">
pic id: <input name="nsfw_id" type="text" /><br />
<input type="submit" name="submit" value="submit" />
</form>
</div>
<?php
echo("</div>");
include_once("htmlfooter.lol");
?>