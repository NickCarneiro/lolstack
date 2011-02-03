<?php
include_once("header.lol");

if (isset($_POST['submit'])){
	$registerresponse = Register::registerRequest();
	//take user to welcome page if registration was successful
	if(is_numeric($registerresponse)){
		
		User::loginUser($registerresponse);
		header("Location: welcome.lol");
		die();
	}
	$error = '<div class="grid_16 entry_glow"><span class="pic_instructions">'.$registerresponse.'</span></div>';
} else {
	$error = '';
}
renderHeader("Register for lolstack");
echo("<div class=\"entries\">");
echo($error);
?>
<div class="entry grid_10">
<h1 class='registertitle'>Join the lolstack community</h1>
	<div class="alignright centerform logintext">
	<form action="register.lol" method="POST">
	Username: <input class="registertext" name="username" type="text" /> <br /> 
	Password: <input class="registertext" name="password1" type="password" /> <br /> 
	Confirm password: <input class="registertext" name="password2" type="password" /> <br /> 
	 <input name="submit" class="registerbutton" type="submit" value="Join!" /> <br /> 
	</form>
	</div>
</div>
<div class="grid_6 entryguy">
<div class="cerealguytext">We're thrilled to have you here.</div>
</div>
</div>
<?php
include_once("htmlfooter.lol");

class Register{
		/**
		* returns new user id if user is successfully added, error string on failure.
		*/
		public static function registerRequest(){
		$username = $_POST['username'];
		$password = $_POST['password1'];
		$password2 = $_POST['password2'];
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
			if (strcmp($password, $password2) != 0){
				throw new Exception('Passwords did not match');
			}
			if (strlen(trim($password)) == 0){
				throw new Exception('Password may not be left blank.');
			}
			
			if (strlen($password) > 20 || strlen($password) < 6){
				throw new Exception('Passwords must contain between 6 and 20 characters, inclusive');
			}
			
			//check for uniqueness
			if (Register::userExists($username)){
				throw new Exception('Sorry, the username "'.$username.'" is already taken.  :(');
			}
			
			//all validations passed
			$newuser = new User();
			$newuserid = $newuser->add($username,md5($password));
			if(is_numeric($newuserid)){
				return $newuserid;
			} else {
				throw new Exception('Sorry, there was some database trouble. Try again in a bit.  :(');

			}
		}
		catch(Exception $e) {
			//print error
			return $e->getMessage();
		}
	}
	
	public static function userExists($username){
		$query = sprintf("SELECT username FROM users WHERE username='%s'",
		mysql_real_escape_string($username));
		$result = mysql_query($query) or 
		error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
		$num_rows = mysql_num_rows($result);
		if ($num_rows > 0){
			return true;
		}
		else {
		return false;
		}
	}
}
?>