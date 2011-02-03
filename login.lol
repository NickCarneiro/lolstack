<?php
include_once("header.lol");


if (isLoggedIn()){
	header("Location: /");
}
renderHeader("Login to lolstack");

if (isset($_POST['submit'])){
	$username = $_POST['username'];
	$password = $_POST['password'];
	$curpage = isset($_POST['currentpage']) ? strip_tags($_POST['currentpage']) : '/';
	//validate lengths and emptiness for username and password
	try {
		//validate username
		if (strlen(trim($username)) == 0){
			throw new Exception('Username may not be left blank.');
			
		}
		if (!preg_match("/^[\w]+$/", $username)){
			throw new Exception('Usernames can only contain letters, numbers, and the underscore _.');
		}
		if (strlen($username) > 20 || strlen($username) < 3){
			throw new Exception('Usernames must contain between 3 and 20 characters, inclusive.');
		}
		//validate password
		
		if (strlen(trim($password)) == 0){
			throw new Exception('Password may not be left blank.');
		}
		
		if (strlen($password) > 20 || strlen($password) < 6){
			throw new Exception('Passwords must contain between 6 and 20 characters, inclusive');
		}
		
		//all basic string validations passed, query db
		//sets admin privs if privilege=1
		$userid = validUser($username,$password);
		if ($userid){
			//login successful
			User::loginUser($userid);
			header("Location: ".$curpage);
		} else {
			throw new Exception('Login failed for '.$username);
		}
		
		
	}
	catch(Exception $e) {
		//print error
		echo('<div class="grid_12 entry_glow"><span class="pic_instructions">'.$e->getMessage().'<span></div>');
	}
}

?>
<div class="entry grid_12">
<h1 class='registertitle'>Login to the lolstack community</h1>
<div class="alignright centerform logintext">
<form action="login.lol" method="POST">
Username: <input class="registertext" name="username" type="text" /> <br />
Password: <input class="registertext" name="password" type="password" /> <br />
<input class="registerbutton" name="submit" type="submit" value="Login" /><br />
</form>
<br />

</div>
<h1 class='registertitle'>Don't have an account? <a class="registertitlelink" href="register.lol">Sign up now!</a></h1>

</div>
<?php
include_once("htmlfooter.lol");
?>