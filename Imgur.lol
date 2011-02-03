<?php
class Imgur {
	
	private $requrl = "https://api.imgur.com/oauth/request_token";
    private $authurl = "https://api.imgur.com/oauth/authorize";
    private $accurl = "https://api.imgur.com/oauth/access_token";
	private $apiurl = "http://api.imgur.com/2/";
	private $conkey = "7307a23ddf8f41d2302c1205fbe1a3a004cd03256";
	private $consec = "6e3e59fc609f6bb9f6351cd2cc150dfb";
	private $apikey = "c668d4e21af177da1e598c280490c953";
	
	/**
	returns url to image or false on failure.
	*/
	public function uploadPic($filename){
		try {
			
			$handle = fopen($filename, "r");
			$data = fread($handle, filesize($filename));

			// $data is file data
			$pvars   = array('image' => base64_encode($data), 'key' => $this->apikey);
			$timeout = 30;
			$curl    = curl_init();

			curl_setopt($curl, CURLOPT_URL, 'http://api.imgur.com/2/upload.xml');
			curl_setopt($curl, CURLOPT_TIMEOUT, $timeout);
			curl_setopt($curl, CURLOPT_POST, 1);
			curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);
			curl_setopt($curl, CURLOPT_POSTFIELDS, $pvars);
			//curl_setopt($curl, CURLINFO_HEADER_OUT, 1); 
			$xmlstr = curl_exec($curl);
			//$info = curl_getinfo($curl);
			//$header = $info['request_header'];
			//error_log($header);
			curl_close ($curl);
			
			//error_log( $xmlstr);
			//echo "<br>";
			$xml = new SimpleXMLElement($xmlstr); 
			$result['directurl'] = $xml->links[0]->original; //get direct link to image
			$result['landingurl'] = $xml->links[0]->imgur_page; //get landing page link
			//echo "original: ".$original;
			if(strpos($result['directurl'],"http") == 0){
				return $result;
			}
			else {
				return false;
			}
		}
		catch(Exception $e){
			error_log($e->getMessage());
			return false;
		}
	}
}
/*
$imgur = new Imgur();
print_r($imgur->uploadPic("/srv/uploads/2010-11-02/11121689129564129429.jpeg"));
*/

?>