<?php
include("header.lol");
include_once("BotGlue.lol");
class Bots {
	public static function createBot($username){
		//adds a bot to the users table (privilege level = 2)
		$query = sprintf("INSERT INTO users (username, password, join_date, privilege) 
		VALUES('%s','%s',FROM_UNIXTIME(%d),2)",
		mysql_real_escape_string($username),
		mysql_real_escape_string(md5("c4siokey")),
		time() - rand(1,7200));

		// Perform Query
		if(mysql_query($query)){
			return "Successfully added user ".$username;
		}
		else {
			echo ("SQL error: ".mysql_error()."\nOriginal query: $query\n");
			return "sql error adding bot";
		}
	}
	
	public static function submitLink($title, $url, $landingurl, $category){
		//pick a random bot
		$bot = Bots::getRandomBot();
		//echo "chose $bot[id], id: $bot[username]";
		echo("adding $title...");
		$picresult = picClass::add($title, $url, $landingurl, $bot['username'], $bot['id'], $category);
		if( $picresult == true){	
			echo(" success\n");
		} else {
			echo(" $picresult \n");
		}
	}
	
	/**
	* returns the array of id and username of a random bot
	*/
	private static function getRandomBot(){
		$query = "SELECT id, username FROM users WHERE privilege=2";
		$result = mysql_query($query) or die(mysql_error());
		$rowcount = mysql_num_rows($result);
		$randomindex = rand(0, $rowcount - 1);
		$i = 0;
		while($row = mysql_fetch_row($result)){
			if($i == $randomindex){
				return Array('id'=>$row[0], 'username'=>$row[1]);
			}
			$i++;
		}
		echo("could not get random bot");
	}
	
	
	public static function scrapeUrls($url, $category){
		
		$page = file_get_contents($url);

		$doc = new DOMDocument();
		$doc->loadHTML($page);
		$links = $doc->getElementsByTagName( "a" );
		foreach( $links as $link ){
			if ($link->getAttribute('class') == "title "){
				$title = $link->nodeValue."\n";
				$url = $link->getAttribute('href');
				
				if(strpos($url, "i.imgur.com") != false ){

					//$url is direct link to imgur image
					$landingurl = "http://imgur.com/".substr($url,19, -4);
				}
				else if((strpos($url, ".jpg") == false 
				|| strpos($url, ".png") == false
				|| strpos($url, ".gif") == false)
				&& strpos($url,"imgur.com") != false){
					//$url is link to landing page
					//split on m
					$landingurl = $url;
					$url = "http://i.imgur.com/".substr($url,17).".jpg";	
				} else {
					//echo("invalid url: ".$url." \n");
					continue;
				}
				//echo("landingurl: $landingurl \n");
				//echo("direct link: ".$url." \n");
				if(strpos($url,"/a/") != false || strpos($url,".com/.imgu") != false){
					error_log("bad url ".$url);
					continue;
				}
				if(strpos($url,".com/com/") != false){
					error_log("bad url ".$url);
					continue;
				}
				
				if(strpos($url,"jpg.jpg") != false){
					$url = substr($url,0,-4);
					$landingurl = substr($landingurl,0,-4);
					
				}
				
				Bots::submitLink(trim($title), trim($url), trim($landingurl), $category);	
			
			}
		}
	}
	
}

$urls = Array(
'political'=>Array('http://www.reddit.com/r/politics/'),
'wtf'=>Array('http://www.reddit.com/r/WTF/'),
'trees'=>Array('http://www.reddit.com/r/trees/','http://www.reddit.com/r/marijuana'),
'funny'=>Array('http://www.reddit.com/','http://www.reddit.com/r/pics/','http://www.reddit.com/r/funny/'));
libxml_use_internal_errors(true);
foreach($urls as $category=>$url){
	foreach($url as $link){
		echo("scraping $link for $category \n");
		Bots::scrapeUrls($link, $category);
	}
}
/*
//create bots from file
$lines = file('botnames.txt');

// Loop through our array, show HTML source as HTML source; and line numbers too.
foreach ($lines as $line_num => $line) {
    if(User::exists($line) == false){
		echo("adding bot: $line");
		Bots::createBot(trim($line));
	} else {
		echo("user $line exists");
	}
}
*/


?>