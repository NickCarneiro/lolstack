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
		} else if($action == "clearvote"){
			error_log("clearing vote");
			$query = sprintf("SELECT type FROM commentvotes WHERE commentid=%d AND userid=%d",
			mysql_real_escape_string($commentid),
			mysql_real_escape_string($userid));
			$result = mysql_query($query);
			if (!$result){
				error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
				throw new Exception("Error: could not clear vote");
			}
			if(mysql_num_rows($result) < 1){
				throw new Exception("Error: No vote found");
			}
			$row = mysql_fetch_row($result);
			$type = $row[0];
			//decrement votes column in pic table
			if($type == 1){
				//remove upvote
				$query = sprintf("UPDATE comments SET upvotes = upvotes-1 WHERE commentid=%d",
				mysql_real_escape_string($commentid));
				
			} else {
				//remove downvote
				$query = sprintf("UPDATE comments SET downvotes = downvotes-1 WHERE commentid=%d",
				mysql_real_escape_string($commentid));
			}
				$result = mysql_query($query);
				if (!$result){
					error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
					throw new Exception("Error: could not clear vote");
				}
				//delete original vote
				$query = sprintf("DELETE FROM commentvotes WHERE commentid=%d and userid=%d",
				mysql_real_escape_string($commentid),
				mysql_real_escape_string($userid));
				//error_log("picid: ".$id." userid: ".$userid);
				$result = mysql_query($query);
				if (!$result){
					error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
					throw new Exception("Error: could not delete vote from votes table");
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