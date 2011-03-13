<?php
include_once("header.lol");
renderHeader("lolstack: search image database");
echo('<div class="grid_10 alpha">');
if(isset($_GET['searchterms'])){
	if(strlen($_GET['searchterms']) < 3){
		renderInfoBox('Query must be at least 3 characters.');
		unset($_GET['searchterms']);
	} else {
		$searchString = strip_tags($_GET['searchterms']);
		$perpage = 15;
		$totalResults = 0;
		$lastpage = initializePagination($searchString,$perpage);
		
		$searchResults = Search::titleSearch($searchString);
	}
	
} else{
	renderInfoBox('Enter some search terms to find images in our database.');
	$searchString = '';
}
?>
<div class="grid_10 entry">
	<form action="search.lol" method="get">
	<input type="text" class="searchtext_searchpage" name="searchterms" value="<?php echo(isset($_GET['searchterms']) ? $searchString : '')?>" />
	
	<input type="submit" class="searchsubmit" name="search" value="Search" />
	</form>
	
</div>

<?php
	if(isset($_GET['searchterms'])){
		renderResults($searchResults,$totalResults);
		renderPagination($lastpage);
	}?>
</div>
<div class="grid_6 omega">
<div class="grid_6 entryguy">
		<div class="cerealguytext">Search is a hard problem. Try google if you have trouble.</div>
	</div>
</div>

<?php
include_once("htmlfooter.lol");

function renderInfoBox($message){
	echo('<div class="entry grid_10">
	<span class="pic_instructions">'.$message.'
	<span>
	</div>');
}

function initializePagination($searchString,$perpage){
	global $page;
	global $totalResults;
	//figure out pagnination stuff
	if (isset($_GET['page'])){
		if(is_numeric($_GET['page'])){
			$page = $_GET['page'];
			
		}
	} else {
		$page = 1;
	}
	//get total rows to determine if page is the last
	
	
		
	$query = sprintf("SELECT COUNT(*) FROM pics
	WHERE title LIKE '%%%s%%' 
	OR title LIKE '%s%%' 
	OR title LIKE '%%%s'
	OR title LIKE '%s'",
	mysql_real_escape_string($searchString),
	mysql_real_escape_string($searchString),
	mysql_real_escape_string($searchString),
	mysql_real_escape_string($searchString));
	$result = mysql_query($query);
	if (!$result){
		error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
	}
	
	$row = mysql_fetch_row($result);
	//echo("resultcount ".$row[0]);
	$totalResults = $row[0];
	$lastpage = ceil($row[0] / $perpage);
	return $lastpage;
	//end pagination stuff
}
function renderPagination($lastpage){
	
	if (isset($_GET['page']) && is_numeric($_GET['page'])){
		$page = $_GET['page'] + 1;
	} else {
		$page = 2;
	}
	
	if ($page > 2){
		//print back button
		error_log('back button');
		echo("<div class='entry grid_2 link'><a href=\"search.lol?searchterms=".strip_tags($_GET['searchterms'])."&page=".($page - 2)."\"><- Back</a> </div>");
		$prefix = 'push_6';
	} else {
		$prefix = 'push_8';
	}
	if ($page - 1 < $lastpage){
		echo("<div class='entry grid_2 link $prefix'><a href=\"search.lol?searchterms=".strip_tags($_GET['searchterms'])."&page=$page\">More -></a></div>");
	}
	echo("<br />");
}
function renderResults($results,$totalResults){
	global $page;
	
	if($results == false){
		echo('<div class="entry grid_10">
		<span class="pic_instructions">No images found.
		</span></div>');
	} else {
		echo('<div class="entry grid_10">
		<span class="pic_instructions">'.$totalResults.' images found.
		</span></div>');
		foreach($results as $pic){
		$voted = $pic['type'] == null ? false : $pic['type'];
		$effectivevotes = $pic['upvotes'] - $pic['downvotes'];
		$numcomments = Comments::commentCount($pic['id']);
		//great way to handle pluralization
		$commentstring = ($numcomments == 1 ? $numcomments." comment" : $numcomments." comments");
		if(is_numeric($voted)){
			if($voted == 1){
				$class = "upvote_gray";
			} else {
				$class = "downvote_gray";
			}
		} else {
			$class = false;
		}
	
	
		$urltitle = sanitize_url($pic['title']);
		$nsfwstring = $pic['nsfw'] == 1 ? "<span style=\"color:red\">nsfw</span>" : "";
		$directory = substr($pic['date_added'],0,10); //get date from mysql datetime
		if(file_exists("/srv/uploads/$directory/".$pic['phash']."_112x70.jpeg")){
			$imgsrc = "http://uploads.lolstack.com/$directory/".$pic['phash']."_112x70.jpeg";
		} else {
			$imgsrc = "images/nothumb.jpg";
		}
		echo("
		<div class='entry grid_10'>
		<div class='votepack'>
		
		<span class='vote_buttons' id='vote_buttons$pic[id]'>
			<a href='javascript:;' class='votebutton ".($class != false ? $class : 'upvote')."' id='upvote_button$pic[id]'></a><br />
			<span class='votes_count' id='votes_count$pic[id]'>$effectivevotes
			</span><br />
			<a href='javascript:;' class='votebutton ".($class != false ? $class : 'downvote')."' id='downvote_button$pic[id]'></a>
			
		</span>
		</div>
		<a href='pic.lol?id=$pic[id]&title=$urltitle'>
		<img class='thumb' src='$imgsrc' />
		</a>
		<div class='linkcontainer'>
		<span class='link'>
			<a href='pic.lol?id=$pic[id]&title=$urltitle'> $pic[title] </a> 
		</span>
		</div>
		<div class='detailscontainer'>
		<span class='details'>
		Submitted by <a href='userInfo.lol?id=$pic[user_id]'>$pic[username]</a> to <a href='/?category=$pic[category]'>$pic[category]</a>, ".User::time_since(convert_datetime($pic['date_added']))."  ago
		<a href='pic.lol?id=$pic[id]&title=$urltitle'>$commentstring</a> $nsfwstring
		</span>
		</div>
		</div>");
		}
	}
}
class Search{
	//returns array of picdata arrays
	//returns false if no results found
	public static function titleSearch($terms){
		global $page;
		global $perpage;
		if(isLoggedIn()){
			$userid = $_SESSION['userid'];
		} else {
			$userid = -1;
		}
		
		$offset = ($page - 1) * $perpage;
		$query = sprintf("SELECT pics.*,users.username,votes.type FROM
		pics LEFT JOIN (votes)
		ON (pics.id=votes.picid AND votes.userid=%d)
		INNER JOIN (users)
		ON (pics.user_id=users.id)		
		WHERE title LIKE '%%%s%%' 
		OR title LIKE '%s%%' 
		OR title LIKE '%%%s'
		OR title LIKE '%s'
		AND pics.user_id=users.id
		ORDER BY upvotes DESC
		LIMIT %d,%d",
		$userid,
		mysql_real_escape_string($terms),
		mysql_real_escape_string($terms),
		mysql_real_escape_string($terms),
		mysql_real_escape_string($terms),
		$offset,
		$perpage);
		$result = mysql_query($query);
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
		}
		$i = 0;
		if(mysql_num_rows($result) == 0){
			return false;
		} else {
			
			while($row = mysql_fetch_assoc($result)){
				$picResults[$i] = $row;
				$i++;
			}
			
			return $picResults;
		}
		
		
	}
}
?>