<?php
include_once("OAuth.php");
$api_key = 'd584c96e6c1ba3ca448426f66e552e8e'; // Your API key.
$secret_key = 'e2dc0eb89b62426ca92a8f79e97fb532';
$http_url = 'http://dev.lolstack.com/api/pic/';
  $ch = curl_init();
  curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
  curl_setopt($ch, CURLOPT_POST, 1);
  curl_setopt($ch, CURLOPT_URL, $http_url);
 //curl_setopt($ch, CURLOPT_HEADER, true); // Display headers
  //prepare the field values being posted to the service
  $data = array(
    'user_id' => '8',
	'pic_id' => '9406',
	'category' => 'funny',
	'timeframe'=>'today',
    'timestamp' => time(), 
    'nonce' => str_rot13(time()),
	'api_key'=>$api_key
  );
  
  $sig = calcSignatureREST($secret_key, $http_url, $data,"post");
  $data['oauth_signature'] = $sig;
  curl_setopt($ch, CURLOPT_POSTFIELDS, $data);

  //make the request
  $result = curl_exec($ch);
  echo substr($result,0, 10000)."\n";
 // print_r(curl_getinfo($ch));  // get error info
 
 
 
 	function calcSignatureREST($secretKey, $httpUrl, $parameters,$httpMethod) {
		/*
		error_log("calculating sig.");
		error_log("secret_key: ".$secretKey);
		error_log(	"httpUrl: $httpUrl" );
		error_log("http method: $httpMethod");
		error_log("params ".json_encode($parameters)."\n");
		*/
		$req = OAuthRequest::from_request($httpMethod,$httpUrl, $parameters);
		$baseString = $req->get_signature_base_string();    
		return  base64_encode(hash_hmac('sha1', $baseString, base64_decode($secretKey), true));
	}
?>