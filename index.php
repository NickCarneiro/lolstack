<?php
include_once("header.lol");
renderHeader("lolstack home: Funny original pictures");
renderRightCol();
echo('<div class="leftcol grid_10 omega">');
$perpage = 15;
try {
	if (isset($_GET['date'])){
		switch($_GET['date']){
		  case "today":
				$date = strtotime("-24 hours");
				break;
			case "week":
				$date = strtotime("-1 week");
				break;
			case "month":
				$date = strtotime("-1 month");
				//error_log("this month chosen");
				break;
			case "alltime":
				$date = strtotime("January 1st, 2010");
				break;
			case "recent":
				$date = "recent";
				
				break;
			default:
				$date = strtotime("-24 hours");
		}
	}
	else {
		$date = strtotime("-24 hours");
	}
	
	if (isset($_GET['category'])){
		$category = strtolower(mysql_real_escape_string($_GET['category']));
		if (!in_array($category, $categories)){
			//error_log("invalid category '".$category."' from ip ".$_SERVER['REMOTE_ADDR']);
			$category = "funny";
		}
		if (strcmp($category,'all') == 0){
			//set wildcard
			$category = "%";
		}
	}
	else {
		$category = "funny";
	}
	
	if (isset($_GET['page'])){
		if(is_numeric($_GET['page'])){
			$page = $_GET['page'];
			
		}
	} else {
		$page = 1;
	}
	//get total rows to determine if page is the last
	
	if($date != "recent"){
		
		$query = sprintf("SELECT COUNT(*) FROM pics,users WHERE pics.date_added > FROM_UNIXTIME(%s) AND pics.user_id=users.id
		AND category LIKE '%s'",
		$date,
		$category);
		$result = mysql_query($query);
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
		}
		
		$row = mysql_fetch_row($result);
		//echo("resultcount ".$row[0]);
		$lastpage = ceil($row[0] / $perpage);
	} else {
		
		$lastpage = 10;
	}
	
	
	$offset = ($page - 1) * $perpage;
	$userid = (isLoggedIn() ? $_SESSION['userid'] : -1);
	if($date != "recent"){
		$query = sprintf("		
		SELECT pics.id,pics.title,pics.description,pics.filetype,
		pics.category,pics.upvotes,pics.downvotes,pics.user_id, 
		pics.date_added, pics.nsfw, pics.thumb,pics.phash,users.username,votes.type
		FROM pics LEFT JOIN (votes)
		ON (pics.id=votes.picid AND votes.userid=%d)
		INNER JOIN (users)
		ON (pics.user_id=users.id)
		WHERE pics.date_added > FROM_UNIXTIME(%s)
		AND category LIKE '%s'
		ORDER BY upvotes - downvotes DESC, pics.date_added DESC LIMIT %d,%d",
		$userid,
		$date,
		$category,
		mysql_real_escape_string($offset),
		$perpage);
	} else {
		
		$query = sprintf("		
		SELECT pics.id,pics.title,pics.description,pics.filetype,
		pics.category,pics.upvotes,pics.downvotes,pics.user_id, 
		pics.date_added, pics.nsfw, pics.phash,pics.thumb,users.username,votes.type
		FROM pics LEFT JOIN (votes)
		ON (pics.id=votes.picid AND votes.userid=%d)
		INNER JOIN (users)
		ON (pics.user_id=users.id)
		WHERE category LIKE '%s'
		ORDER BY date_added DESC LIMIT %d,%d",
		$userid,
		$category,
		mysql_real_escape_string($offset),
		$perpage);
	}
	$result = mysql_query($query);
	$rowcount = mysql_num_rows($result);
	if ($rowcount == 0) {
		echo ("<div class='entry grid_10 pull_6'>
		<span class='errortext'>No images found for category \"$headercat\" in time range \"$headerdate\".<br /><br />
		Tip: Try selecting a longer time range using the second button on the top navigation bar.
		</span>
		</div>");
	}
	if (!$result){
		error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
		
	}
	$i = 0;
	while ($row = mysql_fetch_assoc($result)){
		$alpha = '';
		if($i == 0){
			$alpha = 'alpha';
		} else if($i == $rowcount - 1){
			$alpha = 'omega';
		}
		$voted = $row['type'] == null ? false : $row['type'];
		
		echo (renderPic($row['id'], $row['title'], $row['description'],
		$row['category'],$row['upvotes'],$row['downvotes'],$row['username'],
		$row['date_added'],$row['category'],$row['user_id'],$row['nsfw'],$alpha,$voted,$row['phash'],$row['thumb']));
		$i++;
	}
} catch (Exception $e){
	echo($e->getMessage());
}

renderPagination($lastpage);
echo('</div><!-- close leftcol-->');
include_once("htmlfooter.lol");


function renderPagination($lastpage){
	
	if (isset($_GET['date'])){
		$headerdate = $_GET['date'];
	}
	else {
		$headerdate ='today';
	}
	if (isset($_GET['page']) && is_numeric($_GET['page'])){
		$page = $_GET['page'] + 1;
	} else {
		$page = 2;
	}
	if(isset($_GET['category'])){
		$category = strip_tags($_GET['category']);
	} else {
		$category = "funny";
	}
	echo("<br />");
	if ($page > 2){
		//print back button
		echo("<div class='entry grid_2 pull_6 link'><a href=\"/?date=$headerdate&category=$category&page=".($page - 2)."\"><- Back</a> </div>");
		$prefix = '';
	} else {
		$prefix = 'push_2';
	}
	if ($page - 1 < $lastpage){
		echo("<div class='entry grid_2 link $prefix'><a href=\"/?date=$headerdate&category=$category&page=$page\">More -></a></div>");
	}
}
function renderPic($id,$title,$description,$category,
$upvotes,$downvotes,$username,$timesubmitted,$category,
$user_id,$nsfw,$alpha,$voted,$phash,$thumb){
	$effectivevotes = $upvotes - $downvotes;
	$numcomments = Comments::commentCount($id);
	//great way to handle pluralization
	if ($numcomments >= 5){
		$commentstring = ($numcomments == 1 ? $numcomments." comment" : $numcomments." comments");
	} else {
		$commentstring = "";
	}
	if(is_numeric($voted)){
		if($voted == 1){
			$class = "upvote_gray";
		} else {
			$class = "downvote_gray";
		}
	} else {
		$class = false;
	}
	
	
	$urltitle = sanitize_url($title);
	$nsfwstring = $nsfw == 1 ? "<span style=\"color:red\">nsfw</span>" : "";
	$output = "
	<div class='entry grid_10 pull_6 $alpha'>
	<div class='votepack'>
		
		<span class='vote_buttons' id='vote_buttons$id'>
			<a href='javascript:;' class='votebutton ".($class != false ? $class : 'upvote')."' id='upvote_button$id'></a><br />
			<span class='votes_count' id='votes_count$id'>$effectivevotes
			</span><br />
			<a href='javascript:;' class='votebutton ".($class != false ? $class : 'downvote')."' id='downvote_button$id'></a>
			
		</span>
	</div>";
	$directory = substr($timesubmitted,0,10); //get date from mysql datetime
	if(file_exists("/srv/uploads/$directory/".$phash."_112x70.jpeg") && $nsfw != 1 && $thumb == 1){
		$imgsrc = "http://uploads.lolstack.com/$directory/".$phash."_112x70.jpeg";
	} else {
		$imgsrc = "images/nothumb.jpg";
	}
	$output .= "
	<a href='pic.lol?id=$id&title=$urltitle'>
	<img class='thumb' src='$imgsrc' />
	</a>
	<div class='linkcontainer'>
		<span class='link'>
			<a href='pic.lol?id=$id&title=$urltitle'> $title </a> 
		</span>
	</div>
	<div class='detailscontainer'>
	<span class='details'>
		Submitted by <a href='userInfo.lol?id=$user_id'>$username</a> to <a href='/?category=$category'>$category</a>, ".User::time_since(convert_datetime($timesubmitted))."  ago
		<a href='pic.lol?id=$id&title=$urltitle'>$commentstring</a> $nsfwstring
	</span>
	</div>
	
	
	
	
	
</div>


";
	return $output;
}

function renderRightCol(){
	echo('<div class="grid_6 push_10 rightcol alpha">
	<div class="grid_6 alpha entry">
	<form action="search.lol" method="get">
	<input type="text" class="searchtext" name="searchterms" value="Search image database" />

	<input type="submit" class="searchsubmit" name="search" value="Search" />
	</form>
	</div>
	');
	if(!isLoggedIn()){
		echo('
			<div class="grid_6 entry logindiv">
			<form action="login.lol" method="post">
			<input name="username" type="text" class="usernametext" value="Username" />
			<input name="password" type="password" class="passwordtext" value="password" />
			<input type="hidden" name="currentpage" value="/">
			<span class="loginformtext">New to lolstack? <a href="register.lol">Join</a>. It\'s fun.</span>
			<input type="submit" name="submit" value="Login" class="loginsubmit">
			</form>
			</div>
		');
	}
	echo('
	<div class="grid_6 entry centertext entryhover" onClick="javascript:window.location=\'submitpic.lol\'">
	<a class="uploadlink" href="submitpic.lol">Upload an image</span></a> 
	</div>
	
	<div class="grid_6 omega entryguy">
		<div class="cerealguytext">It\'s an image sharing site with <a href="about.lol" class="gloworange">original content</a>!</div>
	</div>
	
</div>');
}
?>

