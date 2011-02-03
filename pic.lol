<?php
include_once("header.lol");

if (isset($_GET['id'])){
	//error_log('get id '.$_GET['id']);
	if (is_numeric($_GET['id'])){
		$userid = (isLoggedIn() ? $_SESSION['userid'] : -1);
		$id = mysql_real_escape_string($_GET['id']);
		$query = sprintf("SELECT pics.title,pics.description,pics.phash,pics.filetype,
		pics.category,pics.upvotes,pics.downvotes,pics.date_added,pics.user_id,
		users.username, votes.type
		FROM pics LEFT JOIN (votes)
		ON (pics.id=votes.picid AND votes.userid=%d)
		INNER JOIN (users)
		ON (pics.user_id=users.id)
		WHERE pics.id=%d",
		$userid,
		$id);
		
		$result = mysql_query($query);
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
			header("Location: error.lol?type=1");
			echo "Image not found.";
		}
		if (mysql_num_rows($result) == 0){
			header("Location: error.lol?type=1");
			//echo "Image not found.";
		}
		else {
			//show picture
			$row = mysql_fetch_assoc($result);
			renderHeader(strip_tags($row['title']));
			echo('<script type="text/javascript" src="js/jquery.ae.image.resize.min.js"></script>
			<script type="text/javascript" src="js/pic.js"></script>
			 ');
			echo('<script type="text/javascript" src="js/commentform.js"></script>');
			
			echo("<div class='piccontainer grid_16 alpha'>");
			echo(renderVoteButtons($id,$row['type'],$row['upvotes'],$row['downvotes']));
			echo("<div class='titlecontainer'>
			<h1 class='pictitle'>".renderTitle($id)."</h1><br />
				");		
			echo('<a class="showhide" href="javascript:showHideDiv(\'pic\')">Show/Hide pic</a> &nbsp;&nbsp;&nbsp;&nbsp;<span class="clicktozoom" id="clicktozoom">Click image to zoom</span></div> 
					
			<div id="pic" class="unhidden">
			');

			echo(renderPic($id,$row['phash'],$row['filetype'],$row['date_added'],$row['username'],$row['user_id'],$row['category']));
			echo('</div>');
			
			echo ('<div id="picdescription">'.
			Threaded_Comments::bbParse(htmlentities($row['description'],ENT_QUOTES,'UTF-8')).
			'</div>');
			
			//edit link if pic belongs to current user
			if(isLoggedIn() && $_SESSION['userid'] == $row['user_id']){
				echo('<span class="details"><a id="editdesc_'.$id.'" class="editdesc" href="javascript:doNothing()">edit</a><br /><br />');
			}
			//show comments
			//echo("<a href='submitComment.lol?picid=$id&parentid=null'>Leave a comment</a>");
			echo('<span class="details picdetails"><a class="leavecomment details" id="commentform" href="javascript:doNothing()">
			Leave a comment</a>
			</span></div>
			
			');
			
			echo("<br /><br />");
			
			echo('<div id="newcomment" class="hidden top_comment_container">
					<span class="details picdetails">Enter your comment:</span>
					<form class="submitcomment" id="toplevelcomment" action="javascript:doNothing()">
						<input type="hidden" name="picid" value="'.$id.'" />
						<input type="hidden" name="parentid" value="null" />
						<textarea class="top_comment_area" name="comment"></textarea> <br />
						<input class="commentbutton" id="submitbutton" type="submit" name="submit" value="Add comment" /> <input class="commentbutton" type="button" name="cancel" value="Cancel" onclick="javascript:showHideBlock(\'newcomment\')" /><br />
						<a class="link_top details formattinghelp" href="javascript:doNothing()">formatting help</a>
					</form>
					<div id="formatting_top" class="hidden" class="formattinglink"></div>
				</div>
				
				<div id="descformdiv" class="hidden">
					<form class="editdescform" id="editdescform" action="javascript:doNothing()">
						<input type="hidden" name="picid" value="'.$id.'" />
						
						<textarea id="descformarea" name="descformarea"></textarea> <br />
						<input id="editdescbutton" type="submit" name="editdescbutton" value="submit" /> <button type="button" id="canceldescedit">cancel</button>
						<span class="details"><a class="link_top"  href="javascript:doNothing()">formatting help</a></span>
					</form>
					<div id="formattingdescdiv" class="hidden"></div>
				</div>
		<div id="dialog" title="Comment deleted">
			<p>Your comment has been deleted.</p>
			<div class="hidden" id="dialogid" value="-1"></div>
			<div class="hidden" id="picid" value="'.$_GET['id'].'"></div>
		</div>
		
<div id="successdialog" title="Comment submitted">
			<span id="commenterrors"></span><br />
			<span id="successerror"></span>
			
</div>

<div id="processingdialog" title="Processing comment" class="hidden">
			<p>Your comment is being processed. Stay still and don\'t touch anything.</p><br />
			<img src="images/loading.gif" />
</div>
<div id="errordialog" title="Comment Error">
			<span id="errormessage"></span>
</div>
<div id="formattinghelp" class="hidden textleft">
benbenben
</div>
<div id="editform" class="hidden">
<form class="submitedit"  action="javascript:doNothing()">
						<input type="hidden" name="picid"  />
						<input type="hidden" id="editcommentid" name="editcommentid" value="" />
						<textarea class="editarea" id="editarea" name="comment"></textarea> <br />
						<input class="submitedit"  type="submit" name="submitedit" value="submit" /> <button type="button" class="cancelbutton" id="">cancel</button>
						<a class="formattinghelp link_top" href="javascript:doNothing()">formatting help</a>
					</form>
					<div id="formatting_none" class="formatting_none hidden"></div>
</div>

				');
			//render comments
	
			$threaded_comments = new Threaded_comments($id);
			$threaded_comments->print_comments();
			echo('<div class="grid_16 overlapbug omega">
				
			
			</div>');
			
		}
	}
	else {
		header("Location: error.lol?type=1");
		echo("image not found");
	}
	
} else {
	header("Location: error.lol?type=1");
}

include_once("htmlfooter.lol");
function renderTitle($id){
	$query = "SELECT title FROM pics WHERE id='$id'";
	$result = mysql_query($query);
	if (!$result){
		error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
	}
	$row = mysql_fetch_row($result);
	return htmlentities($row[0],ENT_QUOTES,'UTF-8');
}

function renderVoteButtons($id,$type,$upvotes,$downvotes){
	
	//determine if buttons should be gray,
	// and if so which direction to point.
	if(is_numeric($type)){
		if($type == 1){
			$class="upvote_gray";
		} else {
			$class="downvote_gray";
		}
	} else {
		$class = false;
	}
	$effectivevotes = $upvotes - $downvotes;

	echo("
	<div class='votepack'>
		
		<span class='vote_buttons' id='vote_buttons$id'>
			<a href='javascript:;' class='votebutton ".($class != false ? $class : 'upvote')."' id='upvote_button$id'></a><br />
			<span class='votes_count' id='votes_count$id'>$effectivevotes
			</span><br />
			<a href='javascript:;' class='votebutton ".($class != false ? $class : 'downvote')."' id='downvote_button$id'></a>
			
		</span>
	</div>
	");
}
function renderPic($picid, $phash,$filetype,$dateadded,$username,$userid,$category){

	//first try to get mirrored version of pic. If not found, serve local copy.
	$query = "SELECT directurl,landingurl FROM mirrors WHERE picid='$picid'";
	$result = mysql_query($query);
	if (!$result){
		error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
	}
	$rowcount = mysql_num_rows($result);
	//$output = '<div class="picdetails">';
	if ($rowcount > 0) {
		$row = mysql_fetch_row($result);
		$output = "<img id=\"theActualPic\" src=\"$row[0]\" /><br />";
		$hosted = true;
		$output .= "";
	}
	else {
		$hosted = false;
		$directory = substr($dateadded,0,10); //get date from mysql datetime
		$output = "<img id=\"theActualPic\" src=\"http://uploads.lolstack.com/$directory/$phash.$filetype\" /><br />";

	}
	$output .='<span class="details">Submitted by 
	<a href="userInfo.lol?id='.$userid.'">'.$username.'
	</a> to <a href="/?date=today&category='.$category.'">
	'.$category.'</a> '.
	User::time_since(convert_datetime($dateadded))
	.' ago</span>';
	if ($hosted){
		$output .= "<span class=\"details picdetails\">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Image hosted by <a href=\"$row[1]\">imgur</a></span>";

	}
	return $output;
}

function datetime_to_timestamp($str) { 

    list($date, $time) = explode(' ', $str); 
    list($year, $month, $day) = explode('-', $date); 
    list($hour, $minute, $second) = explode(':', $time); 
     
    $timestamp = mktime($hour, $minute, $second, $month, $day, $year); 
     
    return $timestamp; 
} 

?>