<?php

include_once("header.lol");

if (isset($_POST['email'])){
	//user is updating email address
	try{
		// is user logged in?
		if (!isset($_SESSION['userid'])){
			throw new Exception('Must be logged in to change password.');	
		}
		
		$query = sprintf("UPDATE users SET email='%s' WHERE id=%d",
		mysql_real_escape_string($_POST['email']),
		mysql_real_escape_String($_SESSION['userid']));
		$result = mysql_query($query);
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
			throw new Exception('database trouble');
		}
		
		echo(json_encode(Array("message"=>"success")));
	}catch(Exception $e){
		
		echo(json_encode(Array("error"=>$e->getMessage())));
	}
}
else if (isset($_POST['current_password'])){
	
	try{
		
		// is user logged in?
		if (!isset($_SESSION['userid'])){
			throw new Exception('Must be logged in to change password.');	
		}
		if (!isset($_POST['new_password'])){
			throw new Exception('New password cannot be blank.');	
		}
		if (!isset($_POST['new_password_confirm'])){
			throw new Exception('New password confirmation cannot be left blank.');	
		}
		if (strlen($_POST['new_password']) > 20 || strlen($_POST['new_password']) < 6){
			throw new Exception('New password must be between 20 and 6 characters.');	
		}
		
		//check current password
		if(!User::verifyPassword($_SESSION['userid'],$_POST['current_password'])){
			throw new Exception('Current password was incorrect.');
		}
		
		$query = sprintf("UPDATE users SET password='%s' WHERE id=%d",
		mysql_real_escape_string(md5($_POST['new_password'])),
		mysql_real_escape_String($_SESSION['userid']));
		$result = mysql_query($query);
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
			throw new Exception('database trouble');
		}
		echo(json_encode(Array("message"=>"success")));	
	}
	catch(Exception $e){
		error_log($e->getMessage());
		echo(json_encode(Array("error"=>$e->getMessage())));
	}
} else if(isset($_POST['reset_email'])){
	//reset password form submitted from password.lol
	try{
		if(!isset($_POST['username']) || strlen(trim($_POST['username'])) == 0){
			throw new Exception('Username cannot be left blank');
		}
		if(strlen(trim($_POST['reset_email'])) == 0){
			throw new Exception('Email cannot be left blank.');
		}
		if(strlen($_POST['username']) > 20){
			throw new Exception('Invalid username');
		}
		if(strlen($_POST['reset_email']) > 255){
			throw new Exception('Invalid username');
		}
		$user_id = User::verifyEmailUsername($_POST['reset_email'],$_POST['username']);
		if($user_id == false){
			throw new Exception('Unknown username/email combination.');
		}
		User::sendResetEmail($user_id);
		
	}catch(Exception $e){
		
		echo("<error>".$e->getMessage()."</error>");
	}
}
?>