<?php
class PicClass{
	//get last pic that a user submitted
	//returns false if no pics submitted
	public static function latestPic($user_id){
		$query = sprintf("SELECT max(id) from pics where user_id=%d",
		$user_id);
		$result = mysql_query($query);
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
			return false;
		}
		$row = mysql_fetch_row($result);
		if(isset($row[0])){
			return $row[0];
		} else {
			return false;
		}
		
	}
	
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
	
	//returns an error string on failure, or a new pic_id on success
	// eg: 	"Error: Image already submitted <picid>2043</picid>"
	// or	"11075"
	public static function addNewPic($title, $description, 
	$category, $nsfw, $tags, $user_id){
	global $categories;
	//note: image data must exist in the files array for index "image"
	
	$mime = array('image/gif' => 'gif',
                  'image/jpeg' => 'jpeg',
                  'image/png' => 'png',
                  'application/x-shockwave-flash' => 'swf',
                  'image/psd' => 'psd',
                  'image/bmp' => 'bmp',
                  'image/tiff' => 'tiff',
                  'image/tiff' => 'tiff',
                  'image/jp2' => 'jp2',
                  'image/iff' => 'iff',
                  'image/vnd.wap.wbmp' => 'bmp',
                  'image/xbm' => 'xbm',
				  'image/x-ms-bmp' => 'bmp',
                  'image/vnd.microsoft.icon' => 'ico');
		
		
			$description_orig = $description;
			$tags = strip_tags($tags);
			//validate title, description and category
			$titlelength = strlen(trim($title));
			if ( $titlelength == 0 || $titlelength > 300){
				throw new Exception('Title must be between 1 and 300 characters.');				
			}
			
			if (!in_array($category,$categories)){
				throw new Exception('Invalid category.');
			}
				
			//direct upload
			$uploaddir = "/srv/uploads/";
			$md5 = md5($_FILES['image']['tmp_name']);
			$ext = pathinfo($_FILES['image']['name'], PATHINFO_EXTENSION);
			$newfile = $md5.'.'.$ext;
			$targetfile = $uploaddir .$newfile;
			
			if (!move_uploaded_file($_FILES['image']['tmp_name'], $targetfile)) {
				throw new Exception( "File upload failed.");
			}
			//error_log("target: ".$targetfile);
			//check that file is an image
			$imageinfo = getimagesize($targetfile);
		
			
			if(!$imageinfo){
				unlink($targetfile);
				throw new Exception( "File must be an image");
			}
			//error_log(json_encode($imageinfo));
			$mimetype = $imageinfo['mime'];
			$filetype = $mime[$mimetype];
			//check for jpeg or gif or png
			if(strcmp($filetype, "gif") != 0 && strcmp($filetype,"jpeg") != 0 
			&& strcmp($filetype,"png")){
				error_log("filetype is: ".$filetype);
				unlink($targetfile);
				throw new Exception("Image must be a jpeg, gif, or png file. You submitted a ".strip_tags($filetype));

			}
			//if image is a png, convert to jpg
			if($filetype == "png"){
				
				Storage::png2jpg($targetfile, $targetfile.".jpeg", 80);
				//error_log("targetfile: $targetfile");
				unlink($targetfile);
				rename($targetfile.".jpeg",$targetfile);
				$md5 = md5($targetfile);
				$filetype = "jpeg";
			}
			
			//check for pHash existence
			$phash = Phash::getPhash($targetfile);
			//error_log("phash: ".$phash);
			$hashexists = Storage::checkHash($phash);
			if ($hashexists !== true){
				unlink($targetfile);
				throw new Exception("Image already exists in database. $hashexists");
			}
			
			//check pic resolution before storing permanently
			$minres = 70;
			if(!Storage::checkRes($imageinfo, $minres, $minres)){
				throw new Exception("Image too small. Minimum resolution: $minres pixels.");
			}
			
			//add file to storage system
			$finaldest = Storage::storePic($targetfile,$phash,$filetype);
			if(!$finaldest){
				throw new Exception("Error storing pic.");
			}
			
			
			//parse bbcode in description
			include_once('Comments.lol');
			$description = Comments::bbParse($description_orig);
			
			//insert entry in database
			$query = sprintf("INSERT INTO pics 
			(title,description,description_orig,md5,phash,user_id,filetype,date_added,category,nsfw) 
			VALUES('%s','%s','%s','%s',%s,%d,'%s',FROM_UNIXTIME(%d),'%s',%d)",
			mysql_real_escape_string($title),
			mysql_real_escape_string($description),
			mysql_real_escape_string($description_orig),
			$md5,
			$phash,
			$user_id,
			$filetype,
			time(),
			$category,
			$nsfw);
			
			$result = mysql_query($query);
			if (!$result){
				error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
				throw new Exception("Database trouble.");
			}
			
			//insert tags into tags table
			
			if (strlen(trim($tags))>0){
				//find id of pic in database
				$query = "SELECT id FROM pics WHERE md5='$md5'";
				$result = mysql_query($query);
				if (!$result){
					error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
					throw new Exception("Database trouble finding id.");
				}
				$row = mysql_fetch_row($result);
				$pic_id = $row[0];
				$tagarray = split(",",$tags);
				foreach($tagarray as $tag){
					if(strlen(trim($tag)) == 0){
						//skip tag if blank
						continue;
					}
					$query = sprintf("INSERT INTO tags (pic_id,tag) VALUES(%d,'%s')",
					mysql_real_escape_string($pic_id),
					mysql_real_escape_string(trim($tag)));
			
					$result = mysql_query($query);
					if (!$result){
						error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
						throw new Exception("Database trouble on tag insertion.");
					}
				}
			}
			
			//upload stored pic to mirror (requires picid)
			$result = mysql_query("SELECT id from pics where phash='$phash'");
			$row = mysql_fetch_row($result);
			$mirror = mirrorPic($row[0], $finaldest);
			if (!$mirror){
				error_log("Image failed to mirror. Pic id: ".$row[0]);
			} 
			
			return PicClass::latestPic($user_id);
			
		
		
	}
}
?>