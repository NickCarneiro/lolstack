<?php 
class Notifications {

//handle all notifications for a comment
//returns false if something goes wrong
public static function pushCommentNotifications($parentid, $picid){
//add notification for parent
	if (is_numeric($parentid)){
		//get userid that posted parentid comment
		$query = "SELECT userid FROM comments WHERE commentid=$parentid";
		$result = mysql_query($query);
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
			throw new Exception('<error>database trouble</error>');
		}
		$row = mysql_fetch_row($result);
		$parentuserid = $row[0];
		if(!Notifications::addNotification($parentuserid, "commentreply")){
			error_log("Error adding notification for commentreply");
			return false;
		}
	}
	else {
		//parent must be null. add notification for pic reply
		//get userid that posted parentid comment
		$query = sprintf("SELECT user_id FROM pics WHERE id=%d",
		mysql_real_escape_string($picid));
		$result = mysql_query($query);
		if (!$result){
			throw new Exception('database trouble');
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
		}
		$row = mysql_fetch_row($result);
		$picuserid = $row[0];
		if(!Notifications::addNotification($picuserid, "picreply")){
			error_log("Error adding notification for picreply");
			return false;
		}
	}
}
	public static function addNotification($user_id, $type){
		if($type == "message"){
			$query = "UPDATE notifications SET messagecount=messagecount+1 
			WHERE userid=$user_id";
			if (!mysql_query($query)){
				error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
				return false;
			}
		}
		else if($type == "commentreply"){
			$query = "UPDATE notifications SET commentreplycount=commentreplycount+1 
			WHERE userid=$user_id";
			if (!mysql_query($query)){
				error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
				return false;
			}
		}
		else {
			//pic reply
			$query = "UPDATE notifications SET picreplycount=picreplycount+1 
			WHERE userid=$user_id";
			if (!mysql_query($query)){
				error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
				return false;		
			}
		}	
		return true;
	}
	public static function resetNotifications($userid){
		$query = sprintf("UPDATE notifications 
		SET messagecount=0, commentreplycount=0,picreplycount=0
		WHERE userid=%d",
		mysql_real_escape_string($userid));
		$result = mysql_query($query);
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
		}
	}	
	
	public static function getNotifications($userid){
		$query = sprintf("SELECT messagecount, commentreplycount, picreplycount
		FROM notifications WHERE userid=%d",
		mysql_real_escape_string($userid));
		$result = mysql_query($query);
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
		}
		$row = mysql_fetch_row($result);
		$notifications['pms'] = $row[0];
		$notifications['coms'] = $row[1];
		$notifications['pics'] = $row[2];
		return $notifications;
	}
	
	
}
?>