<?php
include_once("header.lol");


if (isset($_POST['id'])){
	$id = $_POST['id'];
	$action = $_POST['action'];
	
	try{
		if (!isLoggedIn()){
			throw new Exception("<a href=\"login.lol\">Login</a>");
		}
		$userid = $_SESSION['userid'];
		//check if user has already voted
		$query = sprintf("SELECT id FROM votes where userid=%d AND picid=%d",
		mysql_real_escape_string($userid),
		mysql_real_escape_string($id));
		$result = mysql_query($query);
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
			throw new Exception("Error: could not check vote status");
		}
		$num_rows = mysql_num_rows($result);
		if ($num_rows > 0){
			$query = sprintf("SELECT upvotes,downvotes FROM pics where id=%d",
			mysql_real_escape_string($id));
			$result = mysql_query($query);
			if (!$result){
				error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
				throw new Exception("Error: could not fetch votes");
			}
			$row = mysql_fetch_assoc($result);
			//return effective votes
			throw new Exception($row['upvotes'] - $row['downvotes']);
		}	
		if ($action == "upvote"){
			$query = sprintf("UPDATE pics set upvotes=upvotes+1 WHERE id=%d",
			mysql_real_escape_string($id));
			$result = mysql_query($query);
			if (!$result){
				error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
				throw new Exception("Error: could not commit upvote");
			}
			//1=upvote, 0=downvote
			$query = sprintf("INSERT into votes (picid, userid,type, time) 
			VALUES(%d, $userid, 1,FROM_UNIXTIME(%d))",
			mysql_real_escape_string($id),
			time());
			$result = mysql_query($query);
			if (!$result){
				error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
				throw new Exception("Error: could not commit upvote");
			}
		}
		else if ($action == "downvote"){
			$query = sprintf("UPDATE pics set downvotes=downvotes+1 WHERE id=%d",
			mysql_real_escape_string($id));
			$result = mysql_query($query);
			if (!$result){
				error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
				throw new Exception("Error: could not commit downvote");
			}
			$query = sprintf("INSERT into votes (picid, userid, type, time) 
			VALUES(%d, $userid, 0,FROM_UNIXTIME(%d))",
			mysql_real_escape_string($id),
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
		$query = sprintf("SELECT upvotes,downvotes FROM pics where id=%d",
		mysql_real_escape_string($id));
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
		//error_log($e->getMessage());
	}
	
}
?>