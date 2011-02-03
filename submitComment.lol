<?php
include_once("header.lol");

if (!isLoggedIn()){
	header("Location: login.lol");
	error_log("tried to submit comment but not logged in.");
	die();
}
renderHeader("Submit a comment.");
echo("<div class='entries'>");


/*
if (isset($_GET['picid']) && isset($_GET['parentid'])){

	$picid = strip_tags($_GET['picid']);
	$parentid = strip_tags($_GET['parentid']);
	echo "
		<form action='submitComment.lol' method='POST'>
			<input type='hidden' name='picid' value='$picid' />
			<input type='hidden' name='parentid' value='$parentid' />
			<textarea name='comment'></textarea> <br />
			<input type='submit' name='submit' value='submit' />
		</form>
	</div>";
}
*/
echo("</div>");

include_once("htmlfooter.lol");
?>