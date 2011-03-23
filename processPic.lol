<?php
include_once("header.lol");


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
if (isset($_POST['getdesc'])){
	//user is trying to edit a description
	try {
		if(!isset($_SESSION['userid'])){
			throw new Exception('<error>You must be logged in to edit a description.</error>');
		}
		if(!isset($_POST['picid'])){
			throw new Exception('<error>No pic id.</error>');
		}
		if(!is_numeric($_POST['picid'])){
			throw new Exception('<error>Invalid pic id.</error>');
		}
		$query = sprintf("SELECT description from pics WHERE id=%d AND user_id=%d",
		mysql_real_escape_string($_POST['picid']),
		mysql_real_escape_string($_SESSION['userid']));
		$result = mysql_query($query);
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
			throw new Exception("<error>Database trouble.</error>");
		}
		$row = mysql_fetch_row($result);
		
		echo "<desc>".$row[0]."</desc>";
	}
	catch(Exception $e){
		echo $e->getMessage();
	}
}	
else if (isset($_POST['descformarea'])){
	//error_log("edit desc");
	//user is submitting an edited description
	try {
		if(!isset($_POST['picid'])){
			throw new Exception('<error>No pic id.</error>');
		}
		if(!isset($_POST['descformarea'])){
			throw new Exception('<error>No pic id.</error>');
		}
		if(!isset($_SESSION['userid'])){
			throw new Exception('<error>You must be logged in to edit a description.</error>');
		}
		$newdesc = $_POST['descformarea'];
		$newdesc = $_POST['descformarea'];
		$query = sprintf("UPDATE pics SET description='%s'
		WHERE id=%d and user_id=%d",
		mysql_real_escape_string($newdesc),
		mysql_real_escape_string($_POST['picid']),
		mysql_real_escape_string($_SESSION['userid']));
		$result = mysql_query($query);
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
			throw new Exception("<error>Database trouble.</error>");
		}
		
		echo("<desc>".Comments::bbParse(htmlentities($newdesc,ENT_QUOTES,'UTF-8'))."</desc>");
	}catch(Exception $e){
		echo $e->getMessage();
	}
}			  
else if (isset($_POST['category'])){
//post a new pic
	try {
	
		foreach($_POST as $key=>$post){
			//error_log($key." ".$post);
		}
		if(!isset($_SESSION['userid'])){
			throw new Exception('<error>You must be logged in to post a pic.</error>');
		}
		$userid = $_SESSION['userid'];
		$title = $_POST['title'];
		$description_orig = $_POST['description'];
		$category = $_POST['category'];
		$tags = strip_tags($_POST['tags']);
		//validate title, description and category
		$titlelength = strlen(trim($title));
		if ( $titlelength == 0 || $titlelength > 300){
			
			throw new Exception('<error>Title must be between 1 and 300 characters.</error>');
						
		}
		
		if (!in_array($category,$categories)){
			throw new Exception('<error>Invalid category.</error>');
		}
		$nsfw = 0;
		if (isset($_POST['nsfw'])){
			$nsfw = 1;
		}
		$thumb = 1;
		if (isset($_POST['nothumb'])){
			$thumb = 0;
		}
		
		//url upload
		if(strlen(trim($_POST['url'])) > 0){
				$url = $_POST['url'];
				
				$uuid = gen_uuid();
				$targetfile = '/srv/uploads/'.$uuid;
				file_put_contents($targetfile, file_get_contents($url));
				$imageinfo = getimagesize($targetfile);
				$md5 = md5($targetfile);
				
				
		} else {
			//direct upload
		
			$uploaddir = "/srv/uploads/";
			$md5 = md5($_FILES['pic']['tmp_name']);
			$ext = pathinfo($_FILES['pic']['name'], PATHINFO_EXTENSION);
			$newfile = $md5.'.'.$ext;
			$targetfile = $uploaddir .$newfile;
			
			if (!move_uploaded_file($_FILES['pic']['tmp_name'], $targetfile)) {
				throw new Exception( "<error>File upload failed.</error>");
			}
			//check that file is an image
			$imageinfo = getimagesize($targetfile);
		}
		
		if(!$imageinfo){
			unlink($targetfile);
			throw new Exception( "<error>File must be an image</error>");
		}
		
		$mimetype = $imageinfo['mime'];
		$filetype = $mime[$mimetype];
		//check for jpeg or gif or png
		if(strcmp($filetype, "gif") != 0 && strcmp($filetype,"jpeg") != 0 && strcmp($filetype,"png")){
			error_log("filetype is: ".$filetype);
			unlink($targetfile);
			throw new Exception("<error>Image must be a jpeg, gif, or png file. You submitted a ".strip_tags($filetype).".</error>");

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
		$hashexists = Storage::checkHash($phash);
		if ($hashexists !== true){
			unlink($targetfile);
			throw new Exception("<error>Image already exists in database. <a href=\"pic.lol?id=$hashexists\">View existing image</a></error>");
		}
		
		//check pic resolution before storing permanently
		$minres = 70;
		if(!Storage::checkRes($imageinfo, $minres, $minres)){
			throw new Exception("<error>Image too small. Minimum resolution: $minres pixels.</error>");
		}
		
		//add file to storage system
		$finaldest = Storage::storePic($targetfile,$phash,$filetype);
		if(!$finaldest){
			throw new Exception("<error>Error storing pic.</error>");
		}
		
		
		//parse bbcode in description
		include_once('Comments.lol');
		$description = Comments::bbParse($description_orig);
		
		//insert entry in database
		$query = sprintf("INSERT INTO pics (title,description,description_orig,md5,phash,user_id,filetype,date_added,category,nsfw,thumb) 
		VALUES('%s','%s','%s','%s',%s,%d,'%s',FROM_UNIXTIME(%d),'%s',%d,%d)",
		mysql_real_escape_string($title),
		mysql_real_escape_string($description),
		mysql_real_escape_string($description_orig),
		$md5,
		$phash,
		$userid,
		$filetype,
		time(),
		$category,
		$nsfw,
		$thumb);
		
		$result = mysql_query($query);
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
			throw new Exception("<error>Database trouble.</error>");
		}
		
		//insert tags into tags table
		
		if (strlen(trim($tags))>0){
			//find id of pic in database
			$query = "SELECT id FROM pics WHERE md5='$md5'";
			$result = mysql_query($query);
			if (!$result){
				error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
				throw new Exception("<error>Database trouble finding id.</error>");
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
					throw new Exception("<error>Database trouble on tag insertion.</error>");
				}
			}
		}
		
		
		//upload stored pic to mirror (requires picid)
		$result = mysql_query("SELECT id from pics where phash='$phash'");
		$row = mysql_fetch_row($result);
		$mirror = mirrorPic($row[0], $finaldest);
		if (!$mirror){
			echo ("<message>Image uploaded successfully</message> <picid>$row[0]</picid><error>failed to mirror</error>");
			error_log("Image failed to mirror. Pic id: ".$row[0]);
		} else {
			echo ("<message>Image uploaded successfully.</message><picid>$row[0]</picid>");
		}
		
	}
	catch(Exception $e){
		echo $e->getMessage();
	}
	echo ("<br />");
}


?>