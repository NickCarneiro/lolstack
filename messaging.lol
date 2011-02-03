<?php
include_once("header.lol");
if (!isLoggedIn()){
	header("Location: login.lol");
	die();
}
renderHeader("lolstack: Inbox");


echo ("<script type=\"text/javascript\" src=\"js/messaging.js\"></script>");
//send final page numbers so we know when to hide the "older" pagination buttons

$lastComPage = getLastComPage();
$lastPicPage = getLastPicPage();
$lastPmPage = getLastPmPage();
echo("
<form class='hidden'>
<input id='lastComPage' value='$lastComPage' />
<input id='lastPicPage' value='$lastPicPage' />
<input id='lastPmPage' value='$lastPmPage' />
</form>
");
$notifications = Notifications::getNotifications($_SESSION['userid']);
//3 column layout
echo('<div class="grid_5 alpha entry">');
renderCommentReplies($notifications);
echo('</div><div class="grid_5 entry">');
renderPicReplies($notifications);

echo('</div><div class="grid_6 omega entry">');
renderPMs($notifications);
echo("

	
	<span class='pic_instructions'>
	<a href='privatemessage.lol'>
	Send a private message</a></span>
	
	");
echo('</div>
<div class="grid_16"><br /><br /> <br /></div>
');


	
Notifications::resetNotifications($_SESSION['userid']);
include_once("htmlfooter.lol");

function getLastComPage(){
	//query for comment replies
	$query = sprintf("SELECT COUNT(*) FROM comments,users WHERE comments.parentid IN 
	(SELECT commentid FROM comments WHERE comments.userid=%d)
	AND comments.userid = users.id",
	mysql_real_escape_string($_SESSION['userid']));

	$result = mysql_query($query);
		
	if (!$result){
		error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");	
	}
	$row = mysql_fetch_row($result);
	$totalComReplies = $row[0];
	$perpage = 10;
	return ceil($totalComReplies / $perpage);
	
}


function getLastPicPage(){
	//query for pic replies
	$query = sprintf("SELECT COUNT(*) FROM comments,users WHERE comments.parentid is NULL 
	AND comments.picid 
	IN(SELECT id FROM pics WHERE user_id=%d )
	AND comments.userid = users.id",
	mysql_real_escape_string($_SESSION['userid']));

	$result = mysql_query($query);
		
	if (!$result){
		error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");	
	}
	$row = mysql_fetch_row($result);
	$totalPicReplies = $row[0];
	$perpage = 10;
	return ceil($totalPicReplies / $perpage);
	
}

function getLastPmPage(){
	//query for pic replies
	$query = sprintf("SELECT COUNT(*) FROM messages,users WHERE messages.to_id=%d 
	AND messages.from_id=users.id 
	",
	mysql_real_escape_string($_SESSION['userid']));

	$result = mysql_query($query);
		
	if (!$result){
		error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");	
	}
	$row = mysql_fetch_row($result);
	$totalPicReplies = $row[0];
	$perpage = 15;
	return ceil($totalPicReplies / $perpage);
	
}

function renderCommentReplies($notifications){
		//query for comment replies
	$query = sprintf("SELECT comments.commentid, comments.picid, comments.timesubmitted, 
	comments.comment, comments.upvotes, comments.downvotes, users.username
	FROM comments,users WHERE comments.parentid IN 
	(SELECT commentid FROM comments WHERE comments.userid=%d)
	AND comments.userid = users.id ORDER BY comments.timesubmitted DESC LIMIT 10",
	mysql_real_escape_string($_SESSION['userid']));

	$result = mysql_query($query);
		
	if (!$result){
		error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
		
	}

	echo("<span class='welcomeheadline'>Comment replies ($notifications[coms])</span>");
	$rowcount = mysql_num_rows($result);
	if ($rowcount == 0) {
		echo "No comments replies found";
	}
	echo("<ul class='replylist' id='comReplyList'>");


	while($row = mysql_fetch_assoc($result)){
		echo("<li><a href=\"pic.lol?id=$row[picid]#container_$row[commentid]\">$row[username]: 
		".htmlentities(substr($row['comment'],0,20))."...</a></li>");
	}
	echo("</ul> <br />");
	//comment reply pagination
	echo('<a id="commentsNewer" class="pic_instructions" href="javascript:loadComments(\'newer\')"><- Newer</a> ');

	echo('<a class="pic_instructions" id="commentsOlder" href="javascript:loadComments(\'older\')">Older -></a> <img id="comSpinner" class="hidden" src="images/spinner.gif" />');

}

function renderPicReplies($notifications){
	//query for pic replies	
	$query = sprintf("SELECT comments.commentid, comments.picid, comments.timesubmitted, 
	comments.comment, comments.upvotes, comments.downvotes, users.username
	FROM comments,users WHERE comments.parentid is NULL AND comments.picid 
	IN(SELECT id FROM pics WHERE user_id=%d )
	AND comments.userid = users.id ORDER BY comments.timesubmitted DESC LIMIT 10",
	mysql_real_escape_string($_SESSION['userid']));

	$result = mysql_query($query);
		
	if (!$result){
		error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
	}


	echo("<span class='welcomeheadline'>Pic replies ($notifications[pics])</span>");
	$rowcount = mysql_num_rows($result);
	if ($rowcount == 0) {
		echo "No pic replies found";
	}	
	echo("<ul class='replylist' id=\"picReplyList\">");
	while($row = mysql_fetch_assoc($result)){
		echo("<li><a href=\"pic.lol?id=$row[picid]#container_$row[commentid]\">$row[username] : 
		".htmlentities(substr($row['comment'],0,20))."...</a></li>");
	}
	echo("</ul><br />");
		//comment reply pagination
	echo('<a class="pic_instructions" id="picCommentsNewer" href="javascript:loadPicComments(\'newer\')"><- Newer</a> ');

	echo('<a class="pic_instructions" id="picCommentsOlder" href="javascript:loadPicComments(\'older\')">Older -></a> <img id="picSpinner" class="hidden" src="images/spinner.gif" />');	
}

function renderPMs($notifications){
	//query for PMs
	
	$query = sprintf("SELECT messages.from_id, messages.subject, messages.body, messages.date, users.username
	FROM messages,users WHERE messages.to_id=%d AND messages.from_id=users.id ORDER BY messages.date DESC LIMIT 10",
	mysql_real_escape_string($_SESSION['userid']));

	$result = mysql_query($query);
		
	if (!$result){
		error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
	}

	//show privates messages
	echo("<span class='welcomeheadline'>Private messages ($notifications[pms])</span>");
	echo("<ul class='replylist' id=\"privateMessages\">");
	while($row = mysql_fetch_assoc($result)){
		echo("<li><a href=\"messageThread.lol?from_id=".$row['from_id']."\"> ".$row['username'].": ".htmlentities($row['subject'])."</a></li>");
	}
	echo("</ul><br />");
	//private message pagination
	echo('<a id="privateMessagesNewer" class="pic_instructions" href="javascript:loadPrivateMessages(\'newer\')"><- Newer</a> ');

	echo('<a class="pic_instructions" id="privateMessagesOlder" href="javascript:loadPrivateMessages(\'older\')">Older -></a> <img id="pmSpinner" class="hidden" src="images/spinner.gif" />');

	
}

?>

