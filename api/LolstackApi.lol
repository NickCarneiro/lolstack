<?php
include_once("../User.lol");
include_once("../Database.lol");
include_once("../User.lol");
include_once("../Storage.lol");
include_once("../PicClass.lol");
include_once("../Categories.lol");
include_once("OAuth.php");

Database::DatabaseConnect();
date_default_timezone_set('America/Chicago');


class LolstackApi {
	static function getResponseObject($requestData){
		//first verify the signature
		try {
			
			$method = LolstackApi::get_string_between($requestData->getUrl(),"/api/","/");
			if(method_exists('LolstackApi',$method)){
				//verify signature
				$data = $requestData->getRequestVars();
				//error_log(json_encode($data));
				if(!isset($data['oauth_signature'])){
					throw new Exception("Missing parameter: oauth_signature","400");
				}
				if(!isset($data['api_key'])){
					throw new Exception("Missing parameter: api_key","400");
				}
					
				$secretKey = LolstackApi::getSecretKey($data['api_key']);
				if($secretKey == false){
					
					throw new Exception("Unknown or banned api_key","401");				
				}
				
				
				$sig = LolstackApi::calcSignatureREST($secretKey, LolstackApi::full_url(), $data,$requestData->getMethod());
				if ($sig != $data['oauth_signature']){
					throw new Exception("Incorrect signature","401");
				}
				
				//passed all checks
				//TODO: anyone can call any method in this class if 
				//they know the name and pass it in the url. must filter out invalid methods.
				
				//all api methods can throw exceptions
				return LolstackApi::$method($requestData);
			} else {
				throw new Exception("Nonexistent method","400");
			}
		} catch(Exception $e){
			$error_response = new responseObject($e->getCode(),json_encode(Array('message'=>$e->getMessage())));
			return $error_response;
		}
	}
	
	/**
	request parameters:
	userid
	response parameters:
	username, join_date, last_login
	**/
	/* This method was just for testing. The API should not be able to get 
	the email or lolbucks of any user but the person logged in.
	static function user($requestData){
		$params = $requestData->getRequestVars();
		if(!isset($params['user_id'])){
			throw new Exception("Missing parameter: userid","400");
		}
		$vitals = User::getVitals($params['user_id']);
		return new responseObject("200",json_encode($vitals));
	}
	*/
	
	static function pic($requestData){
		$params = $requestData->getRequestVars();
		if(!isset($params['pic_id'])){
			throw new Exception("Missing parameter: pic_id","400");
		}
		if(!isset($params['user_id'])){
			throw new Exception("Missing parameter: user_id","400");
		}
		$vitals = PicClass::picVitals($params['pic_id'], $params['user_id']);
		if($vitals == false){
			throw new Exception("pic not found","404");
		}
		return new responseObject("200",json_encode($vitals));
	}
	
	static function listing($requestData){
		global $categories;
		$params = $requestData->getRequestVars();
		if(!isset($params['user_id'])){
			throw new Exception("Missing parameter: user_id","400");
		}
		if(!isset($params['timeframe'])){
			throw new Exception("Missing parameter: timeframe","400");
		}
		if(!isset($params['category'])){
			throw new Exception("Missing parameter: category","400");
		}
		if(!isset($params['page'])){
			throw new Exception("Missing parameter: page","400");
		}
		if (!in_array($params['category'], $categories)){
			throw new Exception("Invalid category","400");
		}
		$listing = PicClass::picList($params['page'], $params['category'],$params['timeframe'],$params['user_id']);
		if($listing == false){
			throw new Exception("No pics found for given parameters","404");
		}
		return new responseObject("200",json_encode($listing));
	}
	
	//no params
	static function categories($requestData){
		global $categories;
		
		return new responseObject("200",json_encode($categories));
	}
	
	static function calcSignatureREST($secretKey, $httpUrl, $parameters,$httpMethod) {
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
	static function get_string_between($string, $start, $end){
		$string = " ".$string;
		$ini = strpos($string,$start);
		if ($ini == 0) return "";
		$ini += strlen($start);
		$len = strpos($string,$end,$ini) - $ini;
		return substr($string,$ini,$len);
	}
	
	//returns false if apikey doesn't exist,
	//associated secret key otherwise
	static function getSecretKey($apikey){
		$query = sprintf("SELECT secret_key,status from api WHERE api_key='%s'",
		mysql_real_escape_string($apikey));
		$result = mysql_query($query);
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");	
			return false;
		}
		$row = mysql_fetch_assoc($result);
		
		if(mysql_num_rows($result) < 1){
			
			return false;
		} else {
			if($row['status'] == 1){
				//api key has been banned
				
				return false;
			} else {
				return $row['secret_key'];
			}
		}
	}
	
	static function full_url(){
		$s = empty($_SERVER["HTTPS"]) ? '' : ($_SERVER["HTTPS"] == "on") ? "s" : "";
		$protocol = substr(strtolower($_SERVER["SERVER_PROTOCOL"]), 0, strpos(strtolower($_SERVER["SERVER_PROTOCOL"]), "/")) . $s;
		$port = ($_SERVER["SERVER_PORT"] == "80") ? "" : (":".$_SERVER["SERVER_PORT"]);
		return $protocol . "://" . $_SERVER['SERVER_NAME'] . $port . $_SERVER['REQUEST_URI'];
	}
}


class responseObject {
	public $code = '';
	public $jsondata = '';
	function __construct($code,$jsondata){
		$this->code = $code;
		$this->jsondata= $jsondata;
	}
	
}
?>