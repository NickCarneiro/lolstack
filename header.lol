<?php
include_once("Database.lol");
include_once("User.lol");
include_once("Auth.lol");
include_once("Phash.lol");
include_once("Storage.lol");
include_once("Imgur.lol");
include_once("Comments.lol");
include_once("Notifications.lol");
include_once("Categories.lol");
include_once("Sidebar.lol");
session_start();
Database::DatabaseConnect();
date_default_timezone_set('America/Chicago');



if (isset($_GET['date'])){
	$headerdate = $_GET['date'];
}
else {
	$headerdate ='today';
}
if (isset($_GET['category'])){
	$headercat = $_GET['category'];
}
else {
	$headercat ='funny';
}
function renderHeader($title){
	global $categories;
	global $headerdate;
	global $headercat;
	echo ('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">

<head>

<title>'.$title.'</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link href="css/style.css" rel="stylesheet" type="text/css" />
<link type="text/css" href="css/ui-lightness/jquery-ui-1.8.7.custom.css" rel="stylesheet" />
  <link rel="stylesheet" href="css/mainStyle.css" type="text/css" />
<link rel="stylesheet" href="css/tipBoxStyle.css" type="text/css" />
<link rel="stylesheet" href="css/dropdown.css" type="text/css" />
<link rel="stylesheet" href="css/960.css" type="text/css" />



<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.4.4/jquery.min.js"></script>
<script type="text/javascript" src="js/jquery.form.js"></script>
<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.9/jquery-ui.min.js"></script>
<script type="text/javascript" src="js/voting.js"></script>
<script type="text/javascript" src="js/dhtml.js"></script>
<script type="text/javascript" src="js/dropdown.js"></script>
<script type="text/javascript" src="js/jquery.inputTip.js"></script>

');
if(isLoggedIn()){
	//set javascript variable if logged in
	echo('
	<script type="text/javascript">
		var loggedIn = 1;
	</script>
	');
} else {
	echo('
	<script type="text/javascript">
		var loggedIn = 0;
	</script>
	');
}
echo("

	<script type=\"text/javascript\">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-7363929-13']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>
</head>

<body>

");

echo('<div id="wrapper">
<div class="container_16">
	
<div class="entry_top grid_16">
<div class="logocontainer grid_6 alpha">
<a href="/">
<img src="images/logo.png">
</a>
</div>
<div class="grid_2">
         <dl id="category" class="dropdown_cat dropdown">
        <dt><a href="#"><span>'.$headercat.'<img class="menuarrow" src="images/arrow.png" /></span></a></dt>
        <dd>
            <ul>');
//print out li entries for each category	
foreach ($categories as $key => $cat){
		echo '<li><a href="/?date='.$headerdate.'&category='.$cat.'">'.$cat.'</a></li>';		
	}		
                
echo('
            </ul>
        </dd>
    </dl>');
	
echo('</div>
<div class="grid_2">
         <dl id="timeframe" class="dropdown_time dropdown">
        <dt><a href="#"><span>'.$headerdate.'<img class="menuarrow" src="images/arrow.png" /></span></a></dt>
        <dd>
            <ul>
                <li><a href="/?date=today&category='.$headercat.'">Today</a></li>
                <li><a href="/?date=week&category='.$headercat.'">Past week</a></li>
				<li><a href="/?date=month&category='.$headercat.'">Past month</a></li>
				<li><a href="/?date=alltime&category='.$headercat.'">All time</a></li>
				<li><a href="/?date=recent&category='.$headercat.'">Recently uploaded</a></li>

            </ul>
        </dd>
    </dl>
	
</div>

<div class="grid_2 tab_white">
');
if(!isLoggedIn()){
	echo('<a href="about.lol" class="loginlink">About</a>');
} else {
	echo('<a href="messaging.lol" class="loginlink">Inbox</a>');
}
echo('
</div>

<div class="grid_2 tab_orange">');
if(isLoggedIn()){
	echo('<a href="submitpic.lol" class="loginlink_white">Upload</a>');
}
else {
	echo('<a href="register.lol" class="loginlink_white">Join</a>');
}
echo('</div>');


if(isLoggedIn()){
	
	echo('<div class="grid_2 omega">');
	echo(' <dl id="more" class="dropdown_more dropdown">
        <dt><a href="#"><span>More<img class="menuarrow" src="images/arrow.png" /></span></a></dt>
        <dd>
            <ul>
                <li><a href="account.lol">Account Settings</a></li>
				<li><a href="userInfo.lol?id='.$_SESSION['userid'].'">Public Profile</a></li>
				<li><a href="about.lol">About</a></li>
				<li><a href="contact.lol">Contact</a></li>
				<li><a href="logout.lol">Logout</a></li>
            </ul>
        </dd>
    </dl>
	');

} else {
	echo('<div class="grid_2 tab_orange omega">');
	echo('<a href="javascript:doNothing();" id="toploginlink" class="loginlink_white">Log in</a>');

}
//echo('</div>');
if(isLoggedIn()){
		$user = new User();
		$notifications = $user->notificationCount($_SESSION['userid']);
		$plural = ($notifications > 1 || $notifications ==0 ? "notifications" : "notification");
		
		echo('<span class="statustext grid_8 pull_8">
		Welcome, <a href="account.lol">
		'.$_SESSION['username'].'</a>. '); 
		if($notifications > 0){
			echo('You have '.$notifications.' new <a href="messaging.lol">'.$plural.'.</a></span>');
		}
		echo('</span>');
	}
echo('</div>
	
</div>


');


	
}


?>
