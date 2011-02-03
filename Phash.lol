<?php






class Phash{

	public static function checkPhash ($hashToCheck){
		//returns id if there is a match, -1 if no match
		//error_log("check hash: ".$hashToCheck);
		return exec("cpp/phash checkhash $hashToCheck");
	}
	
	public static function compareHashes($hash1, $hash2){
		return exec("cpp/phash compare $hash1 $hash2");
	}
	
	public static function getPhash ($imagepath){
		return exec("cpp/phash gethash $imagepath");
	}
	
}
//echo getPhash("/home/burt/programming/obama1.jpg");
?>