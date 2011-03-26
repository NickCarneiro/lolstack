<?php
include_once("Imgur.lol");
class Storage{

	function png2jpg($originalFile, $outputFile, $quality) {
		$image = imagecreatefrompng($originalFile);
		imagejpeg($image, $outputFile, $quality);
		imagedestroy($image);
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

/**
returns true if hash doesn't exist and adjacent hashes are far enough away
returns id of matching pic if a pic is too close of a match
*/
	public static function checkHash($phash){
		
		$query = "SELECT id from pics WHERE phash='".$phash."'";
		$result = mysql_query($query); 
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
			throw new Exception("Database trouble.");
		}
		$num_rows = mysql_num_rows($result);
		$row = mysql_fetch_row($result);
		if ($num_rows > 0){
			//a pic matches exactly
			
			error_log("exact match: ".$row[0]);
			return $row[0];
			
		}
		
		//$startTime = time();
		$hashResult = Phash::checkPhash($phash);
		//error_log("phash comparison time: ".(time() - $startTime)." seconds");
		if($hashResult == -1){
			//no matching pics found
			return true;
		} else {
			//phash returns a string like "4:15:1234567891:1234567891" ie "matching pic id:hamming distance:phash to check:matching phash"
			$match = explode(":",$hashResult);
			$matchingpic = $match[0];
			
			error_log("matched ".$matchingpic." distance: ".$match[1]." hash to check: ".$match[2]." matching hash: ".$match[2]);
			//pic found within matching ham distance
			return $matchingpic;
		}
		
		
	}
	
		/**
	returns path to file on success, false on failure
	*/
	function storePic($sourcefile,$phash,$filetype){
		try {
			$targetdir = "/srv/uploads/".date("Y-m-d");
			if (!file_exists($targetdir)){
				if(!mkdir($targetdir)){
					throw new Exception("Could not create $targetdir");
				}
			}
			$target = $targetdir."/".$phash.".".$filetype;
			if (!copy($sourcefile, $target)){
				throw new Exception("Could not copy $sourcefile to $target");
			}
			if(!unlink($sourcefile)){
				throw new Exception("Could not delete $sourcefile");
			}

			//create thumbnail and save in same directory with pic
			Storage::Create_Thumbnail($target,$targetdir."/".$phash."_112x70.jpeg");
		}
		catch(Exception $e) {
			error_log($e->getMessage());
			return false;
		}
		return $target;
	}
	
	/*returns true on success, false on failure
	$origPath is path to the big image to shrink
	$thumbDest is the desired output location for the thumbnail
	*/
	public static function Create_Thumbnail($origPath, $thumbDest){
		//this will break if there is more than one "." in the path
		$extArray = explode(".",$origPath);
		$extension = $extArray[1];
		if($extension == "jpeg"){
			$src_img = imagecreatefromjpeg($origPath);
		} else if($extension == "png"){
			$src_img = imagecreatefrompng($origPath);
		} else if($extension == "gif"){
			$src_img = imagecreatefromgif($origPath);
		} else {
			//unknown ext
			error_log("unknown extenstion: ".$extension);
			return false;
		}
		$old_x=imageSX($src_img);
		$old_y=imageSY($src_img);
		$new_w = 112;
		$new_h = 70;
		
		//reduce the shorter dimension to 112 or 70,
		//scale the other dimension proportionally
		
		
		// scale dimensions down, then scale up
		// to maximize 112x70 box.
		if ($old_x < $old_y) {
			$thumb_w=$new_w;
			$thumb_h=$old_y*($new_w/$old_x);
			//error_log("long image");
		}
		else {
			$thumb_h=$new_h;
			$thumb_w=$old_x*($new_h/$old_y);
			//error_log("wide image");
		}
		
		while($thumb_w < $new_w || $thumb_h < $new_h){
			$thumb_h++;
			$thumb_w++;
		}
		
		
		
		
		
		$dst_img=ImageCreateTrueColor($new_w,$new_h);
		//fill background with white
		$bgColor = imagecolorallocate($dst_img, 255,255,255);
		imagefilledrectangle($dst_img, 0, 0, $new_w-1, $new_h-1, $bgColor);
		
		imagecopyresampled($dst_img,$src_img,0,0,0,0,$thumb_w,$thumb_h,$old_x,$old_y);
		//crop shrunken image to 112 x 70
		imagejpeg($dst_img,$thumbDest); 
		imagedestroy($dst_img); 
		imagedestroy($src_img);
		return true;
	}
}



function mirrorPic($picid, $path){
	//first try imgur
	$imgur = new Imgur();
	$imgurresult = $imgur->uploadPic($path);
	if (!$imgurresult){
		error_log("error mirroring on imgur.");
		return false;
	}
	//store imgur url to mirror table
	$query = "INSERT INTO mirrors (picid,directurl,landingurl,name) 
	VALUES('$picid', '$imgurresult[directurl]', '$imgurresult[landingurl]','imgur')";
	$result = mysql_query($query);
	if (!$result){
		error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
		return false;
	}
	
	return true;
}



function gen_uuid() {
    return sprintf( '%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
        // 32 bits for "time_low"
        mt_rand( 0, 0xffff ), mt_rand( 0, 0xffff ),

        // 16 bits for "time_mid"
        mt_rand( 0, 0xffff ),

        // 16 bits for "time_hi_and_version",
        // four most significant bits holds version number 4
        mt_rand( 0, 0x0fff ) | 0x4000,

        // 16 bits, 8 bits for "clk_seq_hi_res",
        // 8 bits for "clk_seq_low",
        // two most significant bits holds zero and one for variant DCE1.1
        mt_rand( 0, 0x3fff ) | 0x8000,

        // 48 bits for "node"
        mt_rand( 0, 0xffff ), mt_rand( 0, 0xffff ), mt_rand( 0, 0xffff )
    );
	}
	
		/*
	* Function to turn a mysql datetime (YYYY-MM-DD HH:MM:SS) into a unix timestamp
	* @param str
	* The string to be formatted
	*/

	function convert_datetime($str) {

	list($date, $time) = explode(' ', $str);
	list($year, $month, $day) = explode('-', $date);
	list($hour, $minute, $second) = explode(':', $time);

	$timestamp = mktime($hour, $minute, $second, $month, $day, $year);

	return $timestamp;
	}
	
	//make article title into seo friendly slug
/**
 * Function: sanitize
 * Returns a sanitized string, typically for URLs.
 *
 * Parameters:
 *     $string - The string to sanitize.
 *     $force_lowercase - Force the string to lowercase?
 *     $anal - If set to *true*, will remove all non-alphanumeric characters.
 */
function sanitize_url($string, $force_lowercase = true, $anal = true) {
    $strip = array("~", "`", "!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "_", "=", "+", "[", "{", "]",
                   "}", "\\", "|", ";", ":", "\"", "'", "&#8216;", "&#8217;", "&#8220;", "&#8221;", "&#8211;", "&#8212;",
                   "—", "–", ",", "<", ".", ">", "/", "?");
    $clean = trim(str_replace($strip, "", strip_tags($string)));
    $clean = preg_replace('/\s+/', "_", $clean);
    $clean = ($anal) ? preg_replace("/[^a-zA-Z0-9_]/", "", $clean) : $clean ;
    return ($force_lowercase) ?
        (function_exists('mb_strtolower')) ?
            mb_strtolower($clean, 'UTF-8') :
            strtolower($clean) :
        $clean;
}



?>