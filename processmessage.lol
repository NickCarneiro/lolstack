<?php
include_once("header.lol");
if (!isLoggedIn()){
	header("Location: login.lol");
	die();
} 

if(isset($_POST['subject'])){
	$to = trim(mysql_real_escape_string(strip_tags($_POST['to'])));
	$from = $_SESSION['userid'];
	//HTML entities are NOT converted before database insertion.
	//must apply htmlentities() before rendering to visitors
	$subject = trim(mysql_real_escape_string($_POST['subject']));
	$body = trim($_POST['body']);
	try{
		if (strlen($to) == 0){
			throw new Exception("To field must not be left blank.");
		}
		if (strlen($subject) == 0){
			//throw new Exception("Subject must not be left blank.");
			$subject = "[no subject]";
		}
		if (strlen($body) == 0){
			throw new Exception("Body must not be left blank.");
		}
		$body = mysql_real_escape_string(Threaded_comments::bbParse($body));
		$query = "SELECT id from users WHERE username='$to'";
		$result = mysql_query($query);
		$rowcount = mysql_num_rows($result);
		if ($rowcount == 0) {
			throw new Exception("User ".$to." does not exist.");
		}
		$to_id = mysql_fetch_row($result);
		$to_id = $to_id[0];
		$msgResult = Message::sendMessage($to_id, $_SESSION['userid'], $subject, $body);
		if($msgResult){
			//create notification for recipient
			Notifications::addNotification($to_id, "message");
			echo("<message>Message sent.</message><fromid>$to_id</fromid>");
		} else {
			throw new Exception("Message delivery error. Try again.");
		}
		
	} catch(Exception $e){
		echo '<error>'.$e->getMessage().'</error>';
		error_log($e->getMessage());
	}
}

class Message{
	public static function sendMessage($to_id, $from_id, $subject, $body){
	//Assumes sanitzed inputs
		$query = "INSERT INTO messages (to_id, from_id, subject, body, date) 
		VALUES($to_id, $from_id, '$subject','$body',FROM_UNIXTIME(".time()."))";
		$result = mysql_query($query);
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
			return false;
		}
		return true;
	}
}
?>