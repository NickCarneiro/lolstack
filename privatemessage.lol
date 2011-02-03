<?php
include_once("header.lol");

if (!isLoggedIn()){
	header("Location: login.lol");
	die();
} 
renderHeader("lolstack: Send a private message");
if (isset($_GET['to'])){
$to_username = strip_tags($_GET['to']);
} else {
$to_username = "";
}

echo('
<div id="pmerror"></div>
<div class="entry grid_12">
<h1 class="registertitle">Send a private message</h1>

<form action="javascript:doNothing()" class="submitnewpm">
	<label for="to">To (username):</label><input class="pmtext_username" type="text" name="to" value="'.$to_username.'"/> <br/>
	<label for="subject">Subject: </label><input class="pmtext_subject" type="text" name="subject" /><br />
	<label for="body">Body: </label><textarea class="pmtext_body" name="body"></textarea><br />
	
	<label for="submit"></label><input class="pmsubmit" type="submit" name="submit" value="Send message">
</form>




</div>
');
/*
echo ("

<h1>Send a private message</h1>
<form action='javascript:doNothing()' class='submitnewpm'>
	To (username):<input type='text' name='to' value='$to_username'/> <br/>
	Subject: <input type='text' name='subject' /><br />
	Body: <textarea name='body'> </textarea><br />
	<input type='submit' name='submit' value='Send'> <a id='formattinghelp' href='#'>formatting help</a>
	<div id='formattinghelpdiv' class='hidden'>
<table>
<tr><td>Type this:</td><td>Get this:</td></tr>
<tr><td>[b]bold[/b]</td><td><strong>bold</strong></td></tr>
<tr><td>[i]italic[/i]</td><td><em>italic</em> </td></tr>
<tr><td>[u]underline[/u]</td><td><span style=\"text-decoration:underline;\">underline</span> </td></tr>
<tr><td>[s]strike[/s]</td><td><del>strike</del></td></tr>
<tr><td>[sub]subscript[/sub]</td><td><sub>subscript</sub></td></tr>
<tr><td>[sup]superscript[/sup]</td><td><sup>superscript</sup> </td></tr>
<tr><td>[url]http://www.example.com[/url]</td><td><a href='http://www.example.com/'>http://www.example.com</a> </td></tr>
<tr><td>[url=http://www.example.com]example[/url]</td><td><a href='http://www.example.com/'>example</a></td></tr>

</table>
</div>
</form>
");
	
*/
include_once("htmlfooter.lol");
?>
