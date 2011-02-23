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
	}catch(Exception $e){
		echo("<error>".$e->getMessage()."</error>");
	}
}
if (isset($_POST['current_password'])){
	//retrieve comment for editing
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
		
	}
	catch(Exception $e){
		error_log($e->getMessage());
		echo("<error>".$e->getMessage()."</error>");
	}
}
?>