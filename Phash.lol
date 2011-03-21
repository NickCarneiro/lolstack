<?php






class Phash{

	public static function checkPhash ($hashToCheck){
		//returns id if there is a match, -1 if no match
		//error_log("check hash: ".$hashToCheck);
		return exec("/srv/dev/cpp/phash checkhash $hashToCheck");
	}
	
	public static function compareHashes($hash1, $hash2){
		return exec("/srv/dev/cpp/phash compare $hash1 $hash2");
	}
	
	public static function getPhash ($imagepath){
		return exec("/srv/dev/cpp/phash gethash $imagepath");
	}
	
}
?>