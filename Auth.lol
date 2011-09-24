<?php
function isLoggedIn(){
	if(isset($_SESSION['userid']))
	{
		return true;
	}
	else {
		return false;
	}
}



function validUser($username, $password){
	$query = sprintf("SELECT id, privilege FROM users WHERE username='%s' AND password='%s'",
	mysql_real_escape_string($username),
	mysql_real_escape_string(md5($password)));
	$result = mysql_query($query);
	if(!$result){ 
		error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
		return false;
	}
	$num_rows = mysql_num_rows($result);
	if ($num_rows < 1){
		return false;
	}
	else {
		$row = mysql_fetch_assoc($result);
		if ($row['privilege'] == 1){
			$_SESSION['admin'] = 1;
		}
		return $row['id'];
	}
}

class Auth{

public static function curPageURL() {
 $pageURL = 'http';
 //if ($_SERVER["HTTPS"] == "on") {$pageURL .= "s";}
 $pageURL .= "://";
 if ($_SERVER["SERVER_PORT"] != "80") {
  $pageURL .= $_SERVER["SERVER_NAME"].":".$_SERVER["SERVER_PORT"].$_SERVER["REQUEST_URI"];
 } else {
  $pageURL .= $_SERVER["SERVER_NAME"].$_SERVER["REQUEST_URI"];
 }
 return $pageURL;
}


}
?>