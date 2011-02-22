<?php
include_once("header.lol");
if (!isLoggedIn()){
	
	header("Location: login.lol");
	die();
}

				  
renderHeader("Account details");
//include form javascript
echo('<script type="text/javascript" src="js/picform.js"></script>');



?>
<script type="text/javascript" src="js/account.js"></script>

<div class="entry grid_16 alpha" id="picerrorscontainer">
	
		<span class="pic_instructions" id="accounterrors">Account info</span>
		<span id="debug"></span>
	
</div>
<div class="entry grid_6 omega">
<span class="pic_instructions">Change password</span>
	<form action="javascript:doNothing()" class="changepassword">
	<label class="passwordlabel" for="current_password">Current password:</label><input class="profile_password" type="password" name="current_password" /> <br/>
	<label class="passwordlabel" for="new_password">New Password: </label><input class="profile_password" type="password" name="new_password" /><br />
	<label class="passwordlabel" for="new_password_confirm">Confirm: </label><input class="profile_password" type="password" name="new_password_confirm" /><br />
	
	<label class="passwordlabel" for="submit"></label><input class="pmsubmit" type="submit" name="submit" value="Save Changes">
</form>
</div>


<?php
include_once("htmlfooter.lol");
?>