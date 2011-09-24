<?php
class Database {
public static function DatabaseConnect(){
		$link = mysql_connect('localhost', 'root', 'InterestingBlowhol3');
		if (!$link) {
			error_log("could not connect to database");
			die('Not connected : ' . mysql_error());
		}

		// make foo the current db
		$db_selected = mysql_select_db('lolstack', $link);
		if (!$db_selected) {
			error_log("could not select database");
			die ('Can\'t use database : ' . mysql_error());
		}
	}
}
?>
