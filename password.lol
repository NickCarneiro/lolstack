<?php
include_once("header.lol");
				  
renderHeader("Reset password");
//include form javascript
echo('<script type="text/javascript" src="js/picform.js"></script>');

$vitals = User::getVitals($_SESSION['userid']);

?>
<script type="text/javascript" src="js/account.js"></script>

<div class="entry grid_16 alpha" id="picerrorscontainer">
	
		<span class="pic_instructions" id="accounterrors">Reset your password using the form below</span>
		<span id="debug"></span>
	
</div>
<div class="entry grid_6 push_5 omega">
<span class="pic_instructions">Reset password</span>
	<form action="javascript:doNothing()" class="resetpassword">
	<label class="passwordlabel" for="username">Username:</label><input class="profile_password" type="text" name="username" /> <br/>
	<label class="passwordlabel" for="reset_email">Email Address: </label><input class="profile_password" type="text" name="reset_email" /><br />
	<br />
	
	<label class="passwordlabel" for="submit"></label><input class="pmsubmit" type="submit" name="submit" value="Reset Password">
	
</form>
</div>



<?php
include_once("htmlfooter.lol");
?>