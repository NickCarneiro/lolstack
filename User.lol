<?php

class User {

	public function __construct(){
		include_once("Database.lol");
		Database::DatabaseConnect();
	}
	/* Works out the time since the entry post, takes a an argument in unix time (seconds) */
	public static function time_since($original) {
		// array of time period chunks
		$chunks = array(
			array(60 * 60 * 24 * 365 , 'year'),
			array(60 * 60 * 24 * 30 , 'month'),
			array(60 * 60 * 24 * 7, 'week'),
			array(60 * 60 * 24 , 'day'),
			array(60 * 60 , 'hour'),
			array(60 , 'minute'),
		);
		
		$today = time(); /* Current unix time  */
		$since = $today - $original;
		
		// $j saves performing the count function each time around the loop
		for ($i = 0, $j = count($chunks); $i < $j; $i++) {
			
			$seconds = $chunks[$i][0];
			$name = $chunks[$i][1];
			
			// finding the biggest chunk (if the chunk fits, break)
			if (($count = floor($since / $seconds)) != 0) {
				// DEBUG print "<!-- It's $name -->\n";
				break;
			}
		}
		
		$print = ($count == 1) ? '1 '.$name : "$count {$name}s";
		if ($name == "minute" && $count == 0){
			$count = $since / $seconds * 60;
			$name = "second";
			$print = ($count == 1) ? '1 '.$name : "$count {$name}s";
		}
		/*
		if ($i + 1 < $j) {
			// now getting the second item
			$seconds2 = $chunks[$i + 1][0];
			$name2 = $chunks[$i + 1][1];
			
			// add second item if it's greater than 0
			
			if (($count2 = floor(($since - ($seconds * $count)) / $seconds2)) != 0) {
				$print .= ($count2 == 1) ? ', 1 '.$name2 : ", $count2 {$name2}s";
			}
			
		}
		*/
		return $print;
	}

	public function notificationCount($userid){
		$query = sprintf("SELECT messagecount, commentreplycount, picreplycount FROM notifications
		WHERE userid=%d",
		mysql_real_escape_string($userid));
		$result = mysql_query($query);
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
		}
		$row = mysql_fetch_row($result);
		$total = $row['0'] + $row['1'] + $row['2'];
		return $total;
	}
	/**
	* returns user_id on success, false on failure
	*/
	public function add($username, $password){
		$query = sprintf("INSERT INTO users (username, password, join_date) 
		VALUES('%s','%s',FROM_UNIXTIME(%d))",
		mysql_real_escape_string($username),
		mysql_real_escape_string($password),
		time());

		// Perform Query
		if(!mysql_query($query)){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
			error_log( "sql error adding user");
			return false;
		}
		//get userid for newly created user
		$query = sprintf("SELECT id FROM users WHERE username='%s'",
		mysql_real_escape_string($username));
		$result = mysql_query($query);
		$row = mysql_fetch_row($result);
		$userid = $row[0];
		return $userid;
	}
	/**
	* returns array of keys username, join_date,last_login
	*/
	public static function getVitals($userid){
		$query = sprintf("SELECT username,join_date,last_login,email FROM users WHERE id=%d",
		mysql_real_escape_string($userid));
	
		$result = mysql_query($query);
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
			
		}
		$row = mysql_fetch_row($result);
		$vitals['username'] = $row[0];
		$vitals['join_date'] = $row[1];
		$vitals['last_login'] = $row[2];
		$vitals['email'] = $row[3];
		return $vitals;
	
	}
	
	public static function getPoints($userid){
		$query = sprintf("SELECT SUM(upvotes), SUM(downvotes) 
		 FROM pics WHERE user_id=%d",
		mysql_real_escape_string($userid));
	
		$result = mysql_query($query);
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
		}
		$row = mysql_fetch_row($result);
		$upvotes = $row[0];
		$downvotes = $row[1];
		$points['pic'] = $upvotes - $downvotes;
		
		$query = sprintf("SELECT SUM(upvotes), SUM(downvotes) 
		 FROM comments WHERE userid=%d",
		mysql_real_escape_string($userid));
	
		$result = mysql_query($query);
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
		}
		$row = mysql_fetch_row($result);
		$upvotes = $row[0];
		$downvotes = $row[1];
		
		$points['comment'] = $upvotes - $downvotes;
		
		return $points;
	}
	
		public static function exists($userid){
		$query = sprintf("SELECT username FROM users WHERE id=%d",
		mysql_real_escape_string($userid));
	
		$result = mysql_query($query);
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
			throw new Exception("Database trouble.");
		}
		$rowcount = mysql_num_rows($result);
		if ($rowcount > 0){
			return true;
		} else {
		return false;
		}
	
	}
	/**
	* returns array of assoc arrays containing pic metadata
	*/
	public static function getPicHistory($userid, $perpage, $offset){
		$query = sprintf("SELECT id,title,category,upvotes,downvotes FROM pics WHERE user_id=%d
		ORDER BY date_added DESC LIMIT %d, %d",
		mysql_real_escape_string($userid),
		mysql_real_escape_string($offset),
		mysql_real_escape_string($perpage));
	
		$result = mysql_query($query);
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
			throw new Exception("Database trouble.");
		}
		$i = 0;
		
		while($row = mysql_fetch_assoc($result)){
			$history[$i] = $row;
			$i++;
		}
		
		if (isset($history)){
			return $history;
		} else {
			return;
		}
		
	}
	
	/**
	* returns array of assoc arrays containing comment data
	*/
	
	public function getCommentHistory($userid, $perpage, $offset){
		$query = sprintf("SELECT commentid,picid,comment,upvotes,downvotes 
		FROM comments WHERE userid=%d
		ORDER BY timesubmitted DESC LIMIT %d,%d",
		mysql_real_escape_string($userid),
		mysql_real_escape_string($offset),
		mysql_real_escape_string($perpage));
	
		$result = mysql_query($query);
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
			throw new Exception("Database trouble.");
		}
		$i = 0;
		$history = Array();
		while($row = mysql_fetch_assoc($result)){
			$history[$i] = $row;
			$i++;
		}
		return $history;
	}
	/**
	* returns number of comments by user $userid
	*/
	public static function commentCount($userid){
		$query = sprintf("SELECT count(*) from comments WHERE userid=%d",
		mysql_real_escape_string($userid));
		
		$result = mysql_query($query);
		
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
			throw new Exception("Database trouble.");
		}
		$row = mysql_fetch_row($result);
		//error_log("comment count: ".$row[0]);
		return $row[0];
	}
	
	/**
	* returns number of pic submissions by user $userid
	*/
	public static function subCount($userid){
		$query = sprintf("SELECT count(*) from pics WHERE user_id=%d",
		mysql_real_escape_string($userid));

		$result = mysql_query($query);
		
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
			throw new Exception("Database trouble.");
		}
		$row = mysql_fetch_row($result);
		//error_log("comment count: ".$row[0]);
		return $row[0];
	}
	
	public static function messageCount($userid1, $userid2){
		$query = sprintf("SELECT count(*) from messages 
		WHERE (to_id=%d AND from_id=%d)
		OR (to_id=%d AND from_id=%d)",
		mysql_real_escape_string($userid1),
		mysql_real_escape_string($userid2),
		mysql_real_escape_string($userid2),
		mysql_real_escape_string($userid1));
		$result = mysql_query($query);
		
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
		}
		$row = mysql_fetch_row($result);
		return $row[0];
	}
	
	
	
	public static function loginUser($userid){
		$_SESSION['userid'] = $userid;
		$query = "SELECT username FROM users WHERE id=$userid";
		$result = mysql_query($query);
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
		}
		$row = mysql_fetch_row($result);
		$username = $row[0];
		$_SESSION['username'] = $username;

		//update ip and login time
		$query = "UPDATE users SET last_login=FROM_UNIXTIME(".time()."), 
		last_ip='".$_SERVER['REMOTE_ADDR']."' WHERE id=$userid";
		$result = mysql_query($query);
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
		}
	}
	
	//returns true if password is correct for userid
	public static function verifyPassword($userid,$password){
		$query = "SELECT password FROM users WHERE id=$userid";
		$result = mysql_query($query);
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
			return false;
		}
		$row = mysql_fetch_row($result);
		$dbpassword = $row[0];
		
		if($dbpassword == md5($password)){
			return true;
		} else {
			return false;
		}
	}
}
?>