<?php
include_once("header.lol");
//responsible for adding pics to db and filesystem
// for bots, not regular users. This file will be
// deprecated once the bots are disabled.
class PicClass {


				  
	public static function add($title, $url, $landingurl, $username, $userid, $category){
	//echo("$url :: $landingurl \n");
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
		try{
			if(strpos(strtolower($title),"reddit") != false){
				throw new Exception("Contained reddit string");
			}
			
			if(strpos(strtolower($title),"nsfw") != false){
				$nsfw = 1;
			} else {
				$nsfw = 0;
			}
			
			//check if imgur url exists in mirror table
			$query = "SELECT COUNT(*) FROM mirrors WHERE landingurl='".mysql_real_escape_string($landingurl)."'";
			
			$result = mysql_query($query);
			if (!$result){
				error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
				throw new Exception("Database trouble on mirror check.");
			}
			$row = mysql_fetch_row($result);
			if ($row[0] > 0 ){
				throw new Exception("Mirror already exists.");
			}
			
		
			$uuid = gen_uuid();
			$targetfile = '/srv/uploads/'.$uuid;
			file_put_contents($targetfile, file_get_contents($url));
			//echo("targetfile: $targetfile ");
			$imageinfo = getimagesize($targetfile);
			$md5 = md5($targetfile);
			if(!$imageinfo){
				unlink($targetfile);
				throw new Exception("File must be an image.");
			}
			
			$mimetype = $imageinfo['mime'];
			$filetype = $mime[$mimetype];
			//check for jpeg or gif or png
			if(strcmp($filetype, "gif") != 0 && strcmp($filetype,"jpeg") != 0 && strcmp($filetype,"png")){
				error_log("filetype is: ".$filetype);
				unlink($targetfile);
				throw new Exception("Image must be a jpeg, gif, or png file. You submitted a ".strip_tags($filetype).".");

			}
			//if image is a png, convert to jpg
			if($filetype == "png"){
				//png2jpg($originalFile, $outputFile, $quality)
				PicClass::png2jpg($targetfile, $targetfile.".jpeg", 80);
				//error_log("targetfile: $targetfile");
				unlink($targetfile);
				rename($targetfile.".jpeg",$targetfile);
				$md5 = md5($targetfile);
				$filetype = "jpeg";
			}
			
			//check for pHash existence
			$phash = Phash::getPhash($targetfile);
			if ($phash == null){
				
				throw new Exception("Error getting phash.");
			}
			
			$hashexists = Storage::checkHash($phash);
			
			
			if (is_numeric($hashexists)){
				unlink($targetfile);
				throw new Exception("Image already exists with picid ".$hashexists." candidate url: ".$url);
			}
			//check pic resolution before storing permanently
			$minres = 70;
			if(!PicClass::checkRes($imageinfo, $minres, $minres)){
				unlink($targetfile);
				throw new Exception("Image too small. Minimum resolution: $minres pixels.");
			}
			
			//add file to storage system
			$finaldest = Storage::storePic($targetfile,$phash,$filetype);
			if(!$finaldest){
				unlink($targetfile);
				throw new Exception("Error storing pic.");
			}
			
			
			//insert entry in database
			//give pic a random number of votes
			$upvotes = rand(4,16);
			$downvotes = rand(1,4);
			$query = sprintf("INSERT INTO pics (title,md5,phash,user_id,filetype,date_added,category,nsfw,upvotes,downvotes) 
			VALUES('%s','%s',%s,%d,'%s',FROM_UNIXTIME(%d),'%s',%d,$upvotes,$downvotes)",
			mysql_real_escape_string($title),
			$md5,
			$phash,
			$userid,
			$filetype,
			time() - rand(1,7200),
			$category,
			$nsfw);
			
			$result = mysql_query($query);
			if (!$result){
				
				error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
				throw new Exception("Database trouble on pic insert.");
			}
			
			//get pic id
			$query = "SELECT id FROM pics WHERE md5='$md5'";
			$result = mysql_query($query);
			if (!$result){
				error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
				throw new Exception("Database trouble finding id.");
			}
			$row = mysql_fetch_row($result);
			$pic_id = $row[0];
			
			//already have imgur link, insert row in mirror table
			$query = "INSERT INTO mirrors (picid,directurl,landingurl,name) 
			VALUES('$pic_id', '$url', '$landingurl','imgur')";
			$result = mysql_query($query);
			if (!$result){
				error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
				throw new Exception("Database trouble on mirror insert.");
			}
			
			
			
			return true;
		}
		catch(Exception $e){
			error_log($e->getMessage());
			echo $e->getMessage();
			return false;
		}
	}
	
	/**
	Check if image file meets minimum vertical 
	and horizontal size requirements
	$imageinfo: result of getimagesize()
	$minhoriz: minimum horizontal resolution in pixels
	$minvert: vertical
	returns false if image too small
	*/
	public static function checkRes($imageinfo, $minhoriz,$minvert){
		if($imageinfo[0] < $minhoriz){
			return false;
		}
		else if($imageinfo[1] < $minvert){
			return false;
		}
		else {
			return true;
		}
	}
	
	public static function png2jpg($originalFile, $outputFile, $quality) {
		$image = imagecreatefrompng($originalFile);
		imagejpeg($image, $outputFile, $quality);
		imagedestroy($image);
	}
}
?>