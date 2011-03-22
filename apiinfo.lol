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
	<span class="welcomeheadline">lolstack API</span>
	<br />
	<span class="errortext">lolstack has an API in private beta. Contact Nick if you want to build something.
	</span>
	</div>
</div>
<div class="grid_6 omega">
<div class="grid_6 entryguy">
	<div class="cerealguytext">We're looking for someone to build an iPhone app.</div>
</div>
</div>
<?php
include_once("htmlfooter.lol");
?>