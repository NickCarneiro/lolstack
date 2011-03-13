<?php
include_once("header.lol");

if (!isLoggedIn()){
	header("Location: login.lol");
	die();
}
if (isset($_POST['comment_id'])){
	if(is_numeric($_POST['comment_id'])){
		$comment_id = mysql_real_escape_string($_POST['comment_id']);
	}
	$deleteresult = Comments::deleteComment($comment_id, $_SESSION['userid']);
	if($deleteresult != true){
		echo($deleteresult);
	} else {
		//comment deleted successfully. reload page.
		echo("successfully deleted comment");
	}
	
}
?>