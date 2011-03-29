
<!--<br /><a href="/?date=today&category=funny&page=2">Older -></a>-->

<div class="grid_1 bumper"></div>

</div>
<!--close wrapper-->
</div>

<div id="footer">
<a href="/" class="footer">Home</a> | <a href="about.lol" class="footer">About</a> 
| <a href="contact.lol" class="footer">Contact</a> | 
<a href="terms.lol" class="footer">Terms of Service</a> | <a href="http://trillworks.com" class="footer">© <?php echo(date("Y")." ");?>
Trillworks LLC</a>

</div>
<!-- HTML for site-wide dialogs -->
<div class='hidden modal_login' id='logindialog'>
<div class="center_form">
	<form action='login.lol' method='POST'>
	<label for="username_modal">Username:</label> <input class='registertext' id="username_modal" name='username' type='text' /> <br />
	<label for="password_modal">Password:</label>  <input class='registertext' id="password_modal" name='password' type='password' /> <br />
	<input type='hidden' name='currentpage' value='<?php echo Auth::curPageURL();?>' />

		<input name="submit" class="registerbutton" type="submit" value="Log in" /> <br /> 
		<span class="details"><a href="password.lol">Forget your password?</a></span>
	</form><br />
	
	<span>Don't have an account yet? </span><br />
	
	<form action="register.lol" method="POST">
	<label for="username">Username:</label> <input class="registertext" name="username" type="text" /> <br /> 
	<label for="password1">Password:</label> <input class="registertext" name="password1" type="password" /> <br /> 
	<label for="password2">Confirm:</label> <input class="registertext" name="password2" type="password" /> <br /> 
	<input name="submit" class="registerbutton" type="submit" value="Join!" /> <br /> 
	</form>
	
	</div>
</div>

<div class='hidden' id='formattingdialog'>
	
	<table>
	<tr><td>Type this:</td><td>Get this:</td></tr>
	<tr><td>[b]bold[/b]</td><td><strong>bold</strong></td></tr>
	<tr><td>[i]italic[/i]</td><td><em>italic</em> </td></tr>
	<tr><td>[u]underline[/u]</td><td><span style="text-decoration:underline;">underline</span> </td></tr>
	<tr><td>[s]strike[/s]</td><td><del>strike</del></td></tr>
	<tr><td>[sub]subscript[/sub]</td><td><sub>subscript</sub></td></tr>
	<tr><td>[sup]superscript[/sup]</td><td><sup>superscript</sup> </td></tr>
	<tr><td>[url]http://www.example.com[/url]</td><td><a href=\'http://www.example.com/\'>http://www.example.com</a> </td></tr>
	<tr><td>[url=http://www.example.com]example[/url]</td><td><a href=\'http://www.example.com/\'>example</a></td></tr>

	</table>
	
</div>



</body>
</html>