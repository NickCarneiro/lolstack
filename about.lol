<?php
include_once("header.lol");
renderHeader("lolstack: about");

?>
<div class="grid_2 alpha">
	<?php
		$bar = new Sidebar(Sidebar::currentFile());
		$bar->printSidebar();
	?>
</div>	
<div class="grid_8">
	<div class="grid_8 entry">
	<span class="welcomeheadline">What is lolstack?</span>
	<br />
	<span class="errortext">lolstack is an image-sharing community dedicated to original content. There are a few basic components: <br /> <br />
		1) <strong>Uploading</strong><br />
		Users introduce funny, amusing, or otherwise interesting images to the community by uploading them. lolstack <strong>automatically rejects</strong> images that have been submitted before. This ensures that users don't get bored with images that were funny last week.
		<br /><br />
		2) <strong>Voting</strong><br />
		Those orange squares on the home page are vote buttons. Good content rises to the top.
		<br /> <br />
		3) <strong>Discussion</strong> <br />
		Each image or "pic" has its own dedicated page where users can talk about it.
	</span>
	</div>
</div>
<div class="grid_6 omega">
<div class="grid_6 entryguy">
	<div class="cerealguytext">Trust me. It's fun and it feels good.</div>
</div>
</div>
<?php
include_once("htmlfooter.lol");
?>