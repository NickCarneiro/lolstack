<?php
class Lolbucks{
	public static function getLolbucks($user_id){
		$query = sprintf("SELECT lolbucks FROM users WHERE id=%d",$user_id);
		$result = mysql_query($query);
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
			return false;
		}
		if(mysql_num_rows($result) < 1){
			return false;
		}
		
		$row = mysql_fetch_row($result);
		return $row[0];
		
	}
}
?>