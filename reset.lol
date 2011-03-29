<?php



include_once("header.lol");
				  
renderHeader("Reset password");
//include form javascript
echo('<script type="text/javascript" src="js/picform.js"></script>');



if (isset($_GET['key']) && isset($_GET['username'])){
	$password = User::resetPassword($_GET['username'],$_GET['key']);
	try {
	
	if(!is_string($password)){
		throw new Exception("Invalid username/key combination");
	}
		$message = "Your password has been successfully reset. Please change it on the Account Settings page: <br>
		<br>
		username: $_GET[username]<br>
		password: $password";
	
	} catch(Exception $e) {
		$message = "There was an error resetting your password. <br> <br>".$e->getMessage();
	}
} else {
	$message = "Click the link in the password reset email to reset your password.";
}
?>
<script type="text/javascript" src="js/account.js"></script>


<div class="entry grid_6 push_5 omega">

	<span class="errortext"><?php echo($message)?></span>
</div>



<?php
include_once("htmlfooter.lol");
?>
