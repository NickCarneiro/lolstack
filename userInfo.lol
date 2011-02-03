<?php
include_once("header.lol");



if (is_numeric($_GET['id'])){
	$userid = $_GET['id'];
	//check that user exists
	$user = new User();
	$exists = $user->exists($userid);
	if($exists){
		//get vitals
		$vitals = User::getVitals($userid);
		renderHeader("User info for $vitals[username]");
		echo('
		<div class="user_leftcol grid_8 alpha">');
		$vitals = User::getVitals($userid);
		renderVitals($userid,$vitals);
		renderPicHistory($userid, $vitals);
		
		echo('
		<div class="grid_16 overlapbug omega">
		</div>
		</div>
		');
		echo('
		<div class="user_rightcol grid_8 omega">');
		renderPoints($userid,$vitals);
		renderCommentHistory($userid, $vitals);
		
		echo('
		&nbsp;
		</div>
		');
	} else {
		header("Location: error.lol?type=2");
	}
} else {
	header("Location: error.lol?type=2");
}

include_once("htmlfooter.lol");
function renderVitals($userid, $vitals){
	echo('
	<div class="entry grid_8 ">
	<span class="welcomeheadline">'.$vitals['username'].'</span><br />
		
	<table class="pic_instructions">
			<tr><td>Stacker for:</td><td>'.User::time_since(convert_datetime($vitals['join_date'])).'</td></tr>
			<tr><td>Last login:</td><td>'.User::time_since(convert_datetime($vitals['last_login'])).' ago</td></tr>
		</table><br />
		<span class="link margin8"><a href="privatemessage.lol?to='.$vitals['username'].'">Send a private message to '.$vitals['username'].'</a></span>
		</div>
	');
}

function renderPoints($userid, $vitals){
	$points = User::getPoints($userid);
	echo('
	<div class="entry grid_8">
	<span class="welcomeheadline">lolpoints</span><br />
		<span class="pic_instructions">for pics: '.$points['pic'].'</span><br />
		<span class="pic_instructions">for comments: '.$points['comment'].'</span><br />
		<span class="pic_instructions">total: '.($points['pic'] + $points['comment']).'</span>
		</div>
	');
}

function renderPicHistory($userid, $vitals){
		$perpage = 15;
		$subOffset = $perpage * (isset($_GET['subpage']) && is_numeric($_GET['subpage']) && $_GET['subpage'] > 0 ? strip_tags($_GET['subpage']) - 1 : 0);

		//get pic history
		$pichistory = User::getPicHistory($userid, $perpage, $subOffset);
		
		echo '
		<div class="entry grid_8">
		
		
		<span class="welcomeheadline">Recent Uploads</span>
		<table class="pic_instructions recentuploads">
			<tr><td class="title_col"><span class="col_title">Title</span></td><td class="col"><span class="col_title">Category</span></td><td class="col"><span class="col_title">lolpoints</span></td></tr>';
		if(!is_null($pichistory)){	
			foreach ($pichistory as $pic){
				echo '<tr><td class="title_col"><a href="pic.lol?id='.$pic['id'].'">'.$pic['title'].'</a></td><td class="col">'.$pic['category'].'</td>
				<td class="col">'.($pic['upvotes']-$pic['downvotes']).'</td></tr>';
			}
		}
		echo '</table> <br />
		';
		$subcount = User::subCount($userid);
		renderSubPagination($userid, $subcount, $perpage);
		echo('</div>');
}

function renderCommentHistory($userid, $vitals){
	$perpage = 15;
	$comOffset = $perpage * (isset($_GET['compage']) && is_numeric($_GET['compage']) && $_GET['compage'] > 0 ? strip_tags($_GET['compage']) - 1 : 0);
	$commenthistory = User::getCommentHistory($userid, $perpage, $comOffset);
	echo '<div class="entry grid_8">
		<span class="welcomeheadline">Recent Comments</span>
		<table class="pic_instructions recentuploads">
			<tr><td td class="title_col"><span class="col_title">Comment</span></td><td class="col"><span class="col_title">Upvotes</span></td><td class="col"><span class="col_title">Downvotes</span></td></tr>';
		foreach ($commenthistory as $comment){
			echo '<tr><td td class="title_col"><a href="pic.lol?id='.$comment['picid'].
			'#container_'.$comment['commentid'].'">'.
			substr($comment['comment'],0,50).'</a></td>
			<td class="col">'.$comment['upvotes'].'</td><td class="col">'.$comment['downvotes'].'</td></tr>';
		}
		echo '</table> <br />';
		$commentcount = User::commentCount($userid);
		renderComPagination($userid, $commentcount, $perpage);
		echo('</div>');
}
function renderSubPagination($id, $subcount,$perpage){
	if(isset($_GET['subpage']) && is_numeric($_GET['subpage'])){
		$nextpage = strip_tags(mysql_real_escape_string($_GET['subpage']) + 1);	
	} else {
		$nextpage = 2;
	}
	
	$compage = (isset($_GET['compage']) && is_numeric($_GET['compage']) && $_GET['compage'] > 0 ? $_GET['compage'] : 1);
	
	if ($nextpage > 2) {
		//show newer button
		echo ("<a class='pag_newer' href='userInfo.lol?id=$id&subpage=".($nextpage - 2)."&compage=$compage'><- Newer</a> ");
	}
	//echo "nextpage: $nextpage, perpage: $perpage, subcount: $subcount";
	if(($nextpage -1) * $perpage <= $subcount){
		echo ("<a class='pag_older' href='userInfo.lol?id=$id&subpage=".($nextpage)."&compage=$compage'>Older -></a>");
	}
}

function renderComPagination($id, $commentcount, $perpage){
	if(isset($_GET['compage']) && is_numeric($_GET['compage'])){
		$nextpage = strip_tags(mysql_real_escape_string($_GET['compage']) + 1);	
	} else {
		$nextpage = 2;
	}
	
	$subpage = (isset($_GET['subpage']) && is_numeric($_GET['subpage']) && $_GET['subpage'] > 0 ? $_GET['subpage'] : 1);
	
	if ($nextpage > 2) {
		//show newer button
		echo ("<a class='pag_newer' href='userInfo.lol?id=$id&compage=".($nextpage - 2)."&subpage=$subpage'><- Newer</a> ");
	}
	if(($nextpage - 1) * $perpage <= $commentcount){
		echo ("<a class='pag_older' href='userInfo.lol?id=$id&compage=".($nextpage)."&subpage=$subpage'>Older -></a>");
	}
}
?>