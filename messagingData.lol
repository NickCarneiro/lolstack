<?php
//this file returns data for pagination AJAX requests sent by messaging.lol/messaging.js
include_once("header.lol");
if (isset($_POST['comPage'])){
	try{
		if(!isset($_SESSION['userid'])){
			throw new Exception('You must be logged in to view comment replies.');
		}
		if(!isset($_POST['comPage']) || !is_numeric($_POST['comPage'])){
			throw new Exception('Bad request. Need valid comPage parameter.');
		}
		
		//query database for comments in range
		$page = $_POST['comPage'];
		$page = ($page < 1) ? 1 : $page;
		
		$perpage = 10;
		$comOffset = $perpage * ($page - 1);
		$query = sprintf("SELECT comments.commentid, comments.picid, comments.timesubmitted, 
comments.comment, comments.upvotes, comments.downvotes, users.username
FROM comments,users WHERE comments.parentid IN 
(SELECT commentid FROM comments WHERE comments.userid=%d)
AND comments.userid = users.id ORDER BY comments.timesubmitted DESC LIMIT %d, %d",
		mysql_real_escape_string($_SESSION['userid']),
		mysql_real_escape_string($comOffset),
		mysql_real_escape_string($perpage));
		$result = mysql_query($query);
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
			throw new Exception("Database trouble.");
		}
		while($row = mysql_fetch_assoc($result)){
			echo("<li><a href=\"pic.lol?id=$row[picid]#votes_count$row[commentid]\">$row[username]: 
			".htmlentities(substr($row['comment'],0,20))."...</a></li>");
		}
		//echo "<rows>got post request from user $_SESSION[userid], current page: $_POST[comPage]</rows>";
	}
	catch(Exception $e){
		echo "<error>".$e->getMessage()."</error>";
	}
	
}
else if (isset($_POST['picPage'])){
	try{
	
		if(!isset($_SESSION['userid'])){
			throw new Exception('You must be logged in to view comment replies.');
		}
		if(!isset($_POST['picPage']) || !is_numeric($_POST['picPage'])){
			throw new Exception('Bad request. Need valid comPage parameter.');
		}
		
		//query database for comments in range
		$page = $_POST['picPage'];
		$page = ($page < 1) ? 1 : $page;
		
		$perpage = 10;
		$comOffset = $perpage * ($page - 1);
		$query = sprintf("SELECT comments.commentid, comments.picid, comments.timesubmitted, 
		comments.comment, comments.upvotes, comments.downvotes, users.username
		FROM comments,users WHERE comments.parentid is NULL AND comments.picid 
		IN(SELECT id FROM pics WHERE user_id=%d )
		AND comments.userid = users.id 
		ORDER BY comments.timesubmitted DESC LIMIT %d,%d",
		mysql_real_escape_string($_SESSION['userid']),
		mysql_real_escape_string($comOffset),
		mysql_real_escape_string($perpage));
		$result = mysql_query($query);
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
			throw new Exception("Database trouble.");
		}
		while($row = mysql_fetch_assoc($result)){
			echo("<li><a href=\"pic.lol?id=$row[picid]#container_$row[commentid]\">$row[username]: 
			".htmlentities(substr($row['comment'],0,20))."</a> </li>");
		}
		//echo "<rows>got post request from user $_SESSION[userid], current page: $_POST[comPage]</rows>";
	}
	catch(Exception $e){
		echo "<error>".$e->getMessage()."</error>";
	}
	
}
else if (isset($_POST['pmPage'])){
	try{
		
		if(!isset($_SESSION['userid'])){
			throw new Exception('You must be logged in to view comment replies.');
		}
		if(!isset($_POST['pmPage']) || !is_numeric($_POST['pmPage'])){
			throw new Exception('Bad request. Need valid comPage parameter.');
		}
		
		//query database for comments in range
		$page = $_POST['pmPage'];
		$page = ($page < 1) ? 1 : $page;
		
		$perpage = 10;
		$comOffset = $perpage * ($page - 1);
		$query = sprintf("SELECT messages.from_id, messages.subject, messages.body, 
		messages.date, users.username
		FROM messages,users WHERE messages.to_id=%d 
		AND messages.from_id=users.id 
		ORDER BY messages.date DESC LIMIT %d,%d",
		mysql_real_escape_string($_SESSION['userid']),
		mysql_real_escape_string($comOffset),
		mysql_real_escape_string($perpage));
		$result = mysql_query($query);
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
			throw new Exception("Database trouble.");
		}
		while($row = mysql_fetch_assoc($result)){
			echo("<li><a href=\"messageThread.lol?from_id=".$row['from_id']."\"> ".$row['username'].": ".htmlentities($row['subject'])." </a></li>");
		}
		//echo "<rows>got post request from user $_SESSION[userid], current page: $_POST[comPage]</rows>";
	}
	catch(Exception $e){
		echo "<error>".$e->getMessage()."</error>";
	}
	
}
?>