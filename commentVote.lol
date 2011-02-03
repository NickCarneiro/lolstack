<?php
include_once("header.lol");


if (isset($_POST['commentid'])){
	$commentid = $_POST['commentid'];
	$action = $_POST['action'];
	$userid = $_SESSION['userid'];
	
	try{
		if (!isLoggedIn()){
			throw new Exception("<a href=\"login.lol\">Login</a>");
		}
		//check if user has already voted
		$query = sprintf("SELECT id FROM commentvotes where userid=%d AND commentid=%d",
		mysql_real_escape_string($userid),
		mysql_real_escape_string($commentid));
		$result = mysql_query($query);
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
			throw new Exception("Error: could not check vote status");
		}
		$num_rows = mysql_num_rows($result);
		if ($num_rows > 0){
			$query = sprintf("SELECT upvotes,downvotes FROM comments where commentid=%d",
			mysql_real_escape_string($commentid));
			$result = mysql_query($query);
			if (!$result){
				error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
				throw new Exception("Error: could not fetch votes");
			}
			$row = mysql_fetch_assoc($result);
			//return effective votes
			//comment already voted on
			throw new Exception($row['upvotes'] - $row['downvotes']);
		}	
		if ($action == "upvote"){
			$query = sprintf("UPDATE comments set upvotes=upvotes+1 WHERE commentid=%d",
			mysql_real_escape_string($commentid));
			$result = mysql_query($query);
			if (!$result){
				error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
				throw new Exception("Error: could not commit upvote");
			}
			//1=upvote, 0=downvote
			$query = sprintf("INSERT into commentvotes (commentid, userid,type, time) 
			VALUES(%d, $userid, 1,FROM_UNIXTIME(%d))",
			mysql_real_escape_string($commentid),
			time());
			$result = mysql_query($query);
			if (!$result){
				error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
				throw new Exception("Error: could not commit upvote");
			}
		}
		else if ($action == "downvote"){
			$query = sprintf("UPDATE comments set downvotes=downvotes+1 WHERE commentid=%d",
			mysql_real_escape_string($commentid));
			$result = mysql_query($query);
			if (!$result){
				error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
				throw new Exception("Error: could not commit downvote");
			}
			$query = sprintf("INSERT into commentvotes (commentid, userid, type, time) 
			VALUES(%d, $userid, 0,FROM_UNIXTIME(%d))",
			mysql_real_escape_string($commentid),
			time());
			$result = mysql_query($query);
			if (!$result){
				error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
				throw new Exception("Error: could not commit downvote");
			}
		}
		else {
			throw new Exception("Error: invalid action");
		}
		$query = sprintf("SELECT upvotes,downvotes FROM comments where commentid=%d",
		mysql_real_escape_string($commentid));
		$result = mysql_query($query);
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
			throw new Exception("Error: could not fetch votes");
		}
		$row = mysql_fetch_assoc($result);
		//return effective votes
		echo ($row['upvotes'] - $row['downvotes']);
	} catch (Exception $e){
		echo ($e->getMessage());
	}
	
}
?>