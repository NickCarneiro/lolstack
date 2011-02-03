<?php 
class Notifications {
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