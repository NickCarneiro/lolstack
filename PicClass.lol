<?php
class PicClass{
	/**
	returns array of information or false if pic doesn't exist.
	**/
	public static function picVitals($pic_id, $user_id){
		$query = sprintf("SELECT pics.title,pics.description,pics.phash, pics.filetype,
		pics.category,pics.upvotes,pics.downvotes,pics.date_added,pics.user_id,
		users.username, votes.type, mirrors.directurl
		FROM pics 
		LEFT JOIN (votes)
		ON (pics.id=votes.picid AND votes.userid=%d)
		LEFT JOIN (mirrors)
		ON (pics.id=mirrors.picid)
		INNER JOIN (users)
		ON (pics.user_id=users.id)
		WHERE pics.id=%d",
		$user_id,
		$pic_id);
		$result = mysql_query($query);
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
			return false;
		}
		$vitals = mysql_fetch_assoc($result);
		
		//if no mirror found, replace with local url
		if($vitals['directurl'] == null){
			$directory = substr($vitals['date_added'],0,10); //get date from mysql datetime
			$vitals['image_url'] = "http://uploads.lolstack.com/$directory/$vitals[phash].$vitals[filetype]";
		} else {
			$vitals['image_url'] = $vitals['directurl'];
		}
		unset($vitals['directurl']);
		unset($vitals['phash']);
		unset($vitals['filetype']);
		return $vitals;
	}
	
	public static function picList($page,$category,$timeframe,$user_id){
		
		switch($timeframe){
		  case "today":
				$date = strtotime("-24 hours");
				break;
			case "week":
				$date = strtotime("-1 week");
				break;
			case "month":
				$date = strtotime("-1 month");
				
				break;
			case "alltime":
				$date = strtotime("January 1st, 2010");
				break;
			case "recent":
				$date = "recent";
				
				break;
			default:
				$date = strtotime("today");
		}
		$perpage = 15;
		$offset = ($page - 1) * $perpage;
		
		$query = sprintf("SELECT pics.title,pics.description,pics.phash, pics.filetype,
		pics.category,pics.upvotes,pics.downvotes,pics.date_added,pics.user_id,
		users.username, votes.type, mirrors.directurl
		FROM pics 
		LEFT JOIN (votes)
		ON (pics.id=votes.picid AND votes.userid=%d)
		LEFT JOIN (mirrors)
		ON (pics.id=mirrors.picid)
		INNER JOIN (users)
		ON (pics.user_id=users.id)
		WHERE pics.date_added > FROM_UNIXTIME(%s)
		AND category LIKE '%s'
		ORDER BY upvotes - downvotes DESC, pics.date_added DESC LIMIT %d,%d",
		$user_id,
		$date,
		$category,
		mysql_real_escape_string($offset),
		mysql_real_escape_string($perpage));
	
		$result = mysql_query($query);
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
			return false;
		}
		
		if(mysql_num_rows($result) == 0){
			error_log("no rows returned: ".mysql_error()."\nOriginal query: $query\n");
			return false;
		}
		
		$listing = Array();
		$i = 0;
		//transfer mysql result to proper php array
		// check url and remove unwanted fields in the process
		while($pic = mysql_fetch_assoc($result)){
			
			if($pic['directurl'] == null){
				$directory = substr($pic['date_added'],0,10); //get date from mysql datetime
				$pic['image_url'] = "http://uploads.lolstack.com/$directory/$pic[phash].$pic[filetype]";
				} else {
					$pic['image_url'] = $pic['directurl'];
				}
				unset($pic['directurl']);
				unset($pic['phash']);
				unset($pic['filetype']);
				$listing[$i] = $pic;
			$i++;		
			
		}
		
		return $listing;
	}
}
?>