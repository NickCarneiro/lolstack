<?php
include_once("header.lol");
if (!isLoggedIn()){
	
	header("Location: login.lol");
	die();
}

				  
renderHeader("Account details");
//include form javascript
echo('<script type="text/javascript" src="js/picform.js"></script>');

$vitals = User::getVitals($_SESSION['userid']);

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
	
	<label class="passwordlabel" for="submit"></label><input class="pmsubmit" type="submit" name="submit" value="Save Password">
	
</form>
</div>

<div class="entry grid_6">
<span class="pic_instructions">Change Email</span>
	<form action="javascript:doNothing()" class="changeemail">
	<label class="passwordlabel" for="email">Email address:</label><input class="profile_password" type="text" name="email" value="<?php echo(htmlentities($vitals['email']))?>" /> <br/>
	
	<label class="passwordlabel" for="submit"></label><input class="pmsubmit" type="submit" name="submit" value="Save Email">
	<span class="statustext">You must specify your email address if you need to reset your password later. We will not use it to contact you or share it with anyone.</span>

	</form>
</div>

<div class="entry grid_4 relative omega">
<span class="pic_instructions">Your lolbucks</span><br />
	<span class="lolbucks">$<?php echo(Lolbucks::getLolbucks($_SESSION['userid']));?></span>
</div>

<?php
include_once("htmlfooter.lol");
?>