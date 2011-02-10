<?php

if(isset($_GET['type'])){
	switch($_GET['type']){
		case 1:
			$error = "Image not found";
			break;
		case 2:
			$error = "User not found";
			break;
		case 3:
			$error = "404 Page not found";
			break;
		default:
			$error = "Something went wrong. Try again.";
			break;
	}
} else {
	$error = "Something went wrong. Try again.";
}
include_once("header.lol");
renderHeader("error: ".$error);
?>
<!--leftcol-->
<div class="grid_10 alpha">
<div class="entry grid_10">
	<span class="welcomeheadline">
		<?php echo($error);?>
	</span>
</div>
</div>
<!--rightcol-->
<div class="grid_6 omega">
<div class="grid_6 omega entryguy">
		<div class="cerealguytext">Found a bug? <span class="link"><a href="contact.lol"> Contact Nick</a>.</span></div>
	</div>
</div>
<?php
include_once("htmlfooter.lol");
?>