<?php
class Comments{

    public $parents  = array();
    public $children = array();
	public $picid;
    /**
     * @param array $comments
     */
    function __construct($picid)
    {
		//we want to display gray up or down arrows if the user has already voted
		//but can't do this is nobody is signed in
		$userid = isset($_SESSION['userid']) ? $_SESSION['userid']:-1;
		$comments = $this->getPicComments($picid,$userid);
		$this->picid = $picid;
        foreach ($comments as $comment)
        {
            if ($comment['parent_id'] === NULL)
            {
                $this->parents[$comment['id']][] = $comment;
            }
            else
            {
                $this->children[$comment['parent_id']][] = $comment;
            }
        }
    }
	
	public static function addComment($picid,$parentid,$comment,$userid){
		$query = sprintf("INSERT INTO comments (picid,parentid,comment,timesubmitted,userid)
		VALUES(%d,%s,'%s',FROM_UNIXTIME(%d),%d)",
		mysql_real_escape_string($picid),
		mysql_real_escape_string($parentid),
		mysql_real_escape_string($comment),
		time(),
		mysql_real_escape_string($userid));
		
		$result = mysql_query($query);
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
			return false;	
		}
	}
	
	//returns true if parent_id refers to a real commment on the specified pic
	//false otherwise
	public static function parentExists($parentid, $picid){
		$query = sprintf("SELECT commentid FROM comments WHERE parentid=%d
		AND picid=%d",
		mysql_real_escape_string($parentid),
		mysql_real_escape_string($picid));
		$result = mysql_query($query);
		if(mysql_num_rows($result) < 1){
			return false;
		} else {
			return true;
		}
	}
	//returns most recent comment made by a user. false if no comments
	public static function getLatestComment($userid){
		$query = sprintf("SELECT commentid FROM comments WHERE userid=%d ORDER BY
		timesubmitted DESC LIMIT 1",
		mysql_real_escape_string($userid));
		$result = mysql_query($query);
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
			return false;
		}
		$row = mysql_fetch_row($result);
		if(isset($row[0])){
			return $row[0];
		} else {
			return false;	
		}			
	}
	//returns number of comments on given pic
	public static function commentCount($picid){
		$query = sprintf("SELECT COUNT(*) FROM comments WHERE picid=%d",
		mysql_real_escape_string($picid));
		//error_log("pic id is $picid");
		$result = mysql_query($query);
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
			return 0;
		} else {
			$row = mysql_fetch_row($result);
			return $row[0];
		}
	}
	
	public static function getPicComments($picid,$userid){
		$query = sprintf("SELECT comments.*, users.username, users.id, commentvotes.type 
		FROM comments LEFT JOIN (commentvotes) 
		ON (comments.commentid=commentvotes.commentid AND commentvotes.userid=%d) INNER JOIN (users) 
		ON (comments.userid = users.id ) WHERE comments.picid=%d  
		ORDER BY comments.timesubmitted ASC",
		mysql_real_escape_string($userid),
		mysql_real_escape_string($picid));
		$result = mysql_query($query);
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
		}
		$commentarray = array();
		$i = 0;
		while ($row = mysql_fetch_assoc($result)){
			$voted = ($row['type'] == null ? false : $row['type']);
			
			$commentarray[$i] = array('id'=>$row['commentid'], 'parent_id'=>$row['parentid'], 
			'username'=>$row['username'],'text'=>$row['comment'], 'timesubmitted'=>$row['timesubmitted'],
			'upvotes'=>$row['upvotes'],'downvotes'=>$row['downvotes'], 'pic_id'=>$picid, 'user_id'=>$row['id'],'edited'=>$row['edited'],'voted'=>$voted);
			$i++;
		}
		//echo "is is:".$i;
		return $commentarray;
	}
	
	/**
	* Loads comments into memory from database for given picid
	*
	*/
	private function getComments($picid){
		$query = "SELECT comments.*, users.username, users.id, commentvotes.type 
		FROM comments LEFT JOIN (commentvotes) 
		ON (comments.commentid=commentvotes.commentid) INNER JOIN (users) 
		ON (comments.userid = users.id ) WHERE comments.picid=$picid  
		ORDER BY comments.timesubmitted ASC";
		$result = mysql_query($query);
		if (!$result){
			error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
		}
		$commentarray = array();
		$i = 0;
		while ($row = mysql_fetch_assoc($result)){
			$voted = ($row['type'] == null ? false : $row['type']);
			
			$commentarray[$i] = array('id'=>$row['commentid'], 'parent_id'=>$row['parentid'], 
			'username'=>$row['username'],'text'=>$row['comment'], 'timesubmitted'=>$row['timesubmitted'],
			'upvotes'=>$row['upvotes'],'downvotes'=>$row['downvotes'], 'pic_id'=>$picid, 'user_id'=>$row['id'],'edited'=>$row['edited'],'voted'=>$voted);
			$i++;
		}
		//echo "is is:".$i;
		return $commentarray;
	}
	
    /**
     * @param array $comment
     * @param int $depth
     */
    private function format_comment($comment, $depth)
    {	
		$origdepth = $depth;
        for ($depth; $depth > 0; $depth--)
        {
            echo "&nbsp;&nbsp;&nbsp;&nbsp;\t";
        }
		//put comment text in div that can be replaced by jquery
		//if user clicks edit
		
		for ($depth; $depth > 0; $depth--)
        {
            //echo "&nbsp;&nbsp;&nbsp;&nbsp;\t";
			echo('bump');
        }		
		
        echo "<div class='commentcontainer' id='container_$comment[id]'>";
		$depth = $origdepth;
		
		$effectivevotes = $comment['upvotes'] - $comment['downvotes'];
		if(is_numeric($comment['voted'])){
			if($comment['voted'] == 1){
				$class = "upvotecomment_gray";
			} else {
				$class = "downcomment_gray";
			}
		} else {
			$class = '';
		}
		
		echo " 
		<div class='commentvotepack'>
		<span class='vote_buttons' id='vote_buttons$comment[id]'>
		
			<a href='javascript:;' class='commentvotebutton ".($class != false ? $class : 'upvotecomment')."' id='upvote_button$comment[id]'></a><br />
			<span class='votes_count' id='votes_count$comment[id]'>$effectivevotes</span><br />
			<a href='javascript:;' class='commentvotebutton ".($class != false ? $class : 'downvotecomment')."' id='downvote_button$comment[id]'></a>
		
		</span>
		</div>
		";
		echo "<a class='username' href='userInfo.lol?id=$comment[user_id]'>"
		.$comment['username']."</a><span class='commentlink'> "
		.User::time_since(convert_datetime($comment['timesubmitted'])).
		" ago".($comment['edited'] ? '*' : '')."</span>";
		//get properties for comment
		echo ("
		<br />
		<div class='commenttext' id='text_$comment[id]'>".Comments::bbParse(htmlentities($comment['text'],ENT_QUOTES,'UTF-8'))."</div>
		<br />
	<span>
	<a class=\"replylink commentlink\" id='replylink_$comment[id]' href=\"javascript:doNothing()\">reply</a> ");
	//show delete and edit buttons if comment belongs to current user
	if(isLoggedIn() && $comment['user_id'] == $_SESSION['userid']){
		echo("<a class=\"delete commentlink\" id=\"delete_$comment[id]\" href=\"#comment_$comment[id]\">delete</a> ");
		echo("<a class=\"editcomment commentlink\" id=\"edit_$comment[id]\" href=\"#comment_$comment[id]\">edit</a>");

	}
	if($comment['parent_id'] != ''){
		echo(' <a id="parent_'.$comment['parent_id'].'" class="commentlink parentlink" href="javascript:doNothing()">parent</a>');
	}
	
	echo("</span>");

        //render hidden reply box
		echo("
		</div>
		");
		echo("<div numid='$comment[id]' id='comment_$comment[id]' class='reply_comment_container'>
		<form id='commentform_$comment[id]' class='submitcomment' action='javascript:doNothing()'>
			<input type='hidden' name='picid' value='$comment[pic_id]' />
			<input type='hidden' name='parentid' value='$comment[id]' />
			<textarea class='top_comment_area' name='comment'></textarea> <br />
			<input class='commentbutton' type='submit' name='submit' value='Add reply' /> 
			<input class='commentbutton' type='button' name='cancel' value='Cancel' onclick=\"javascript:showHideBlock('comment_$comment[id]')\" /> <a class='formattinghelp link_top' href='javascript:doNothing()'>formatting help</a>
		</form>
		<div id='formatting_$comment[id]' class='hidden'></div>
		</div>");
		echo "<br />\n";
    }

    /**
     * @param array $comment
     * @param int $depth
     */
    private function print_parent($comment, $depth = 0)
    {
        foreach ($comment as $c)
        {
            $this->format_comment($c, $depth);

            if (isset($this->children[$c['id']]))
            {
                $this->print_parent($this->children[$c['id']], $depth + 1);
            }
        }
    }

    public function print_comments()
    {
		//print_r($this->parents);
        foreach ($this->parents as $c)
        {
            $this->print_parent($c);
        }
    }
	
	public function deleteComment($id, $userid){
		try{
		
			$query = sprintf("SELECT commentid FROM comments WHERE commentid=%d AND userid=$userid",
			mysql_real_escape_string($id));

			$result = mysql_query($query);
			if (!$result){
				error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
				throw new Exception("Database trouble.");
			}
			if(mysql_num_rows($result) <1){
				throw new Exception("Can't delete this.");
			}
			//user 6048 has the username "[deleted]"
			$query = sprintf("UPDATE comments SET comment='[deleted]', userid='6048' WHERE commentid=%d",
			mysql_real_escape_string($id));

			mysql_query($query) or error_log("SQL error: ".mysql_error()."\nOriginal query: $query\n");
			
		} catch(Exception $e) {
			error_log($e->getMessage());
			return $e->getMessage();
		}
		return true;
	}

	public static function bbParse($input){
		$input = str_replace("\n", "<br />", $input);
		//bbParse library is a pear package copied to include/bbcode.
		//original files are stored at /usr/share/pear
		require_once('PEAR.php');
		require_once('HTML/BBCodeParser.php');
		$config = parse_ini_file('include/bbcode/config.ini', true);
		
		$options = &PEAR::getStaticProperty('HTML_BBCodeParser', '_options');
		
		$options = $config['HTML_BBCodeParser'];
		unset($options);
	
		/* do yer stuff! */
		$parser = new HTML_BBCodeParser();
		
		$parser->setText(@$input);
		$parser->parse();
		
		return $parser->getParsed();
	}
}
?>