<?php
include_once("header.lol");


if (isset($_POST['id'])){
	$id = $_POST['id'];
	$action = $_POST['action'];
	//error_log("action: $action");
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
			//throw new Exception($row['upvotes'] - $row['downvotes']);
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
		} else if($action == "clearvote"){
			error_log("clearing vote");
			$query = sprintf("SELECT type FROM votes WHERE picid=%d AND userid=%d",
			mysql_real_escape_string($id),
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
				$query = sprintf("UPDATE pics SET upvotes = upvotes-1 WHERE id=%d",
				mysql_real_escape_string($id));
				
			} else {
				//remove downvote
				$query = sprintf("UPDATE pics SET downvotes = downvotes-1 WHERE id=%d",
				mysql_real_escape_string($id));
			}
				$result = mysql_query($query);
				if (!$result){
					error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
					throw new Exception("Error: could not clear vote");
				}
				//delete original vote
				$query = sprintf("DELETE FROM votes WHERE picid=%d and userid=%d",
				mysql_real_escape_string($id),
				mysql_real_escape_string($userid));
				error_log("picid: ".$id." userid: ".$userid);
				$result = mysql_query($query);
				if (!$result){
					error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
					throw new Exception("Error: could not delete vote from votes table");
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
		//$effvotes = $row['upvotes'] - $row['downvotes'];
		//error_log("id: ".$id." votes: $effvotes");//
		echo ($row['upvotes'] - $row['downvotes']);
		//echo("asdf");
	} catch (Exception $e){
		error_log ($e->getMessage());
		echo("error");
	}
	
}
?>