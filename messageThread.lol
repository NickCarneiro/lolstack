<?php 
include_once("header.lol");
if (!isLoggedIn()){
	header("Location: login.lol");
	die();
}
if (isset($_GET['from_id']) && is_numeric($_GET['from_id'])){
	
	$from_id = strip_tags($_GET['from_id']);
	$to_id = $_SESSION['userid'];


	renderHeader("Private Messages");
	echo('<script type="text/javascript" src="js/messagethread.js"></script>');

	$vitals = User::getVitals($from_id);
	echo('<div class="entry grid_16">
	<span class="welcomeheadline">
	Private messages between you and '.$vitals['username'].'</span>
	</div>
	');
	
	
	echo('<div id="reply" class="entry grid_16"><a id="pmreplybutton" class="loginlink" href="javascript:doNothing()">Send a reply</a></div> <div class="grid_13"></div>');
	//get subject line if message is a reply
	$query = sprintf("SELECT subject FROM messages WHERE ((messages.to_id=%d AND messages.from_id=%d) 
	OR (messages.to_id=%d AND messages.from_id=%d))
	ORDER BY date DESC
	LIMIT 1",
	mysql_real_escape_string($to_id),
	mysql_real_escape_string($from_id),
	mysql_real_escape_string($from_id),
	mysql_real_escape_string($to_id));
	$result = mysql_query($query);
	if (!$result){
		error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
	} 
	
	if(mysql_num_rows($result) == 0){
		$re = '';
	} else {
		
		$row = mysql_fetch_row($result);
		
		//print_r($row);
		//$re = str_replace("'","\'",$row[0]);
		$re = $row[0];
	}
	
	echo("<div id='pmbox' class='hidden'>
	
	<form action='javascript:doNothing()' class='submitpm'>
	<input type='hidden' name='to' value='$vitals[username]'/> <br/>
	<label for='subject'>Subject: </label><input class='pmtext_subject' type='text' name='subject' /><br />
	<label for='body'>Body: </label><textarea class='pmtext_body' name='body'></textarea><br />
	<input id='from_id' type='hidden' value='$from_id'>
	<label for='submit'></label><input class='pmsubmit' type='submit' name='submit' value='Send message'> <a class='formattinghelp' href='javascript:doNothing()'>formatting help</a>
	
	</form>
	
	</div>");
	$perpage = 10;
	$offset = $perpage * (isset($_GET['page']) && is_numeric($_GET['page']) && $_GET['page'] > 0 ? strip_tags($_GET['page']) - 1 : 0);
	$query = sprintf("SELECT messages.subject, messages.body, messages.date, users.username
	FROM messages,users 
	WHERE ((messages.to_id=%d AND messages.from_id=%d) 
	OR (messages.to_id=%d AND messages.from_id=%d)) 
	AND messages.from_id=users.id 
	ORDER BY messages.date DESC 
	LIMIT %d,%d",
	mysql_real_escape_string($_SESSION['userid']),
	mysql_real_escape_string($from_id),
	mysql_real_escape_string($from_id),
	mysql_real_escape_string($_SESSION['userid']),
	mysql_real_escape_string($offset),
	$perpage);
	$result = mysql_query($query);
	if (!$result){
		error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
	} 
	while($row = mysql_fetch_assoc($result)){
		echo('<div class="pmcontainer grid_16"><div class="pad8">');
		echo('<a class="username" href="userInfo.lol?id='.$from_id.'">
		'.$row['username'].'</a>
		');
		echo("<span class='commentlink'>".htmlentities($row['subject'])."</span>");
		echo('
		<span class="commentlink">'
		.date("F j, Y, g:i a",convert_datetime($row['date'])).
		"</span> <br />");
		
		echo('<span class="commenttext">'.$row['body']."</span></div></div><br /><br />");
	}
	
} else {
	echo("Invalid from_id.");
}

renderMessagePagination($from_id,$to_id,$perpage);
echo("<div class='grid_16 bumper2'>");
echo('</div>');

include_once("htmlfooter.lol");

function renderMessagePagination($from_id,$to_id,$perpage){
	$push = '14';
	if(isset($_GET['page']) && is_numeric($_GET['page'])){
		$nextpage = strip_tags(mysql_real_escape_string($_GET['page']) + 1);	
	} else {
		$nextpage = 2;
	}
	if ($nextpage > 2) {
		//show newer button
		$push = 12;
		echo ("<div class='entry grid_2 link'><a href='messageThread.lol?from_id=$from_id&page=".($nextpage - 2)."'><- Newer</a> </div>");
	}
	
	$messagecount = User::messageCount($from_id, $to_id);
	//echo("nextpage: $nextpage, perpage: $perpage, messagecount: $messagecount");
	if (($nextpage - 1) * $perpage <= $messagecount){
		echo ("<div class='entry grid_2 push_$push link'><a href='messageThread.lol?from_id=$from_id&page=".($nextpage)."'>Older -></a></div>");
	}
}
?>