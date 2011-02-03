<?php
include_once("header.lol");
if (isset($_POST['getcomment'])){
	//retrieve comment for editing
	try{
		
		// is user logged in?
		if (!isset($_SESSION['userid'])){
			throw new Exception('<error>Must be logged in to edit comment.</error>');	
		}
		if (!isset($_POST['commentid'])){
			throw new Exception('<error>No comment id given for retrieval.</error>');	
		}
		$query = sprintf("SELECT comment FROM comments 
		WHERE commentid=%d AND userid=%d",
		mysql_real_escape_string($_POST['commentid']),
		mysql_real_escape_String($_SESSION['userid']));
		$result = mysql_query($query);
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
			throw new Exception('<error>database trouble</error>');
		}
		$row = mysql_fetch_row($result);
		
		echo("<comment_orig>".$row[0]."</comment_orig>");
		
		
	}
	catch(Exception $e){
		error_log($e->getMessage());
		echo($e->getMessage());
	}
}
else if (isset($_POST['editcommentid'])){
	//error_log("got edit submit for ".$_POST['editcommentid']);
	try{
		if (!isset($_SESSION['userid'])){
				throw new Exception('<error>Must be logged in to edit comment.</error>');	
			}
		
		if (!isset($_POST['comment'])){
			throw new Exception('<error>No comment text given for update.</error>');	
		}
		
		$unparsedcomment = $_POST['comment'];
		
		
		//UPDATE parsed and unparsed comment
		$query = sprintf("UPDATE comments SET comment='%s', edited=1
		WHERE commentid=%d AND userid=%d",
		mysql_real_escape_string($unparsedcomment),
		mysql_real_escape_string($_POST['editcommentid']),
		mysql_real_escape_String($_SESSION['userid']));
		$result = mysql_query($query);
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
			throw new Exception('<error>database trouble</error>');
		}
		
		//comment saved successfully. return parsed text to place in page.
		echo('<comment>'.Threaded_Comments::bbParse(htmlentities($unparsedcomment,ENT_QUOTES,'UTF-8')).'</comment><commentid>'.$_POST['editcommentid'].'</commentid>');
	}
		catch(Exception $e){
		error_log($e->getMessage());
		echo($e->getMessage());
	}
}
else if (isset($_POST['picid'])){
	//submitting new comment
	//validate comment, picid, and parentid
	$comment = $_POST['comment'];
	//error_log('comment '.$comment);
	$picid = strip_tags($_POST['picid']);
	$parentid = mysql_real_escape_string(strip_tags($_POST['parentid']));
	try{
		// is user logged in?
		
		if (!isset($_SESSION['userid'])){
			throw new Exception('<error>Must be logged in to comment.</error>');	
		}
		
		$commentlength = strlen(trim($comment));
		if ($commentlength == 0){
			throw new Exception('<error>Comment may not be empty</error>');	
		}
		$picidlength = strlen(trim($picid));
		if ($picidlength == 0){
			throw new Exception('<error>picid may not be empty</error>');	
		}
		$parentidlength = strlen(trim($parentid));
		
		if ($parentidlength == 0){
				throw new Exception('<error>parentid may not be empty</error>');	
			}
		if(!is_numeric($picid)){
			throw new Exception('<error>invalid picid</error>');
		}
	
	$query = sprintf("INSERT INTO comments (picid,parentid,comment,timesubmitted,userid)
	VALUES(%d,%s,'%s',FROM_UNIXTIME(%d),%d)",
	mysql_real_escape_string($picid),
	$parentid,
	mysql_real_escape_string($comment),
	time(),
	mysql_real_escape_string($_SESSION['userid']));
	
	$result = mysql_query($query);
	if (!$result){
		error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
		throw new Exception('database trouble');
		
	}
	//add notification for parent
	if (is_numeric($parentid)){
		//get userid that posted parentid comment
		$query = "SELECT userid FROM comments WHERE commentid=$parentid";
		$result = mysql_query($query);
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
			throw new Exception('<error>database trouble</error>');
		}
		$row = mysql_fetch_row($result);
		$parentuserid = $row[0];
		if(!Notifications::addNotification($parentuserid, "commentreply")){
			throw new Exception("<error>Error adding notification for commentreply</error>");
		}
	}
	else {
		//parent must be null. add notification for pic reply
		//get userid that posted parentid comment
		$query = sprintf("SELECT user_id FROM pics WHERE id=%d",
		mysql_real_escape_string($picid));
		$result = mysql_query($query);
		if (!$result){
			throw new Exception('database trouble');
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
		}
		$row = mysql_fetch_row($result);
		$picuserid = $row[0];
		if(!Notifications::addNotification($picuserid, "picreply")){
			throw new Exception("<error>Error adding notification for picreply</error>");
		}
	}
	//get new commentid for highlighting on page
	$query = sprintf("SELECT commentid FROM comments WHERE userid=%d ORDER BY
	timesubmitted DESC LIMIT 1",
	mysql_real_escape_string($_SESSION['userid']));
	$result = mysql_query($query);
	if (!$result){
			throw new Exception('database trouble');
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
		}
	$row = mysql_fetch_row($result);
	$commentid = $row[0];	
	echo "<message>Comment added successfully.</message><picid>$picid</picid><commentid>$commentid</commentid>";
	} catch(Exception $e){
		error_log($e->getMessage());
		echo($e->getMessage());
	}
}
?>