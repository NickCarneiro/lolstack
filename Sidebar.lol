<?php
class Sidebar{
/**
returns the name of the current file without the extension
**returns name of caller, not just "Sidebar"
*/
public static function currentFile(){
	$file = $_SERVER["SCRIPT_NAME"];
	$break = Explode('/', $file);
	$pfile = $break[count($break) - 1];
	$dotpos = strrpos ( $pfile , ".");
	return substr($pfile,0,$dotpos);

}
//array of file names (without extensions) and display names
private $pages = Array("about"=>"About","faq"=>"FAQ",
"contact"=>"Contact","terms"=>"Terms","apiinfo"=>"API");
private $page;
	function __construct($page){
		$this->page = $page;
	}
	
	public function printSidebar(){
		echo('<div class="grid_2 entry">
	<ul class="navlist">');
	foreach($this->pages as $pagename =>$displayname){
		if($pagename == $this->page){
			echo('<li><a class="navlist_selected" href="'.$pagename.'.lol"><span>'.$displayname.'</span></a></li>');
		} else {
			echo('<li><a href="'.$pagename.'.lol"><span>'.$displayname.'</span></a></li>');			
		}
	}

	echo('
	</ul>
	</div>');
	}
}
?>