<?php
include_once("header.lol");
renderHeader("lolstack: faq");

?>

<div class="grid_2 alpha">
	<?php
		$bar = new Sidebar(Sidebar::currentFile());
		$bar->printSidebar();
	?>
</div>	
<div class="grid_8">
	<div class="grid_8 entry">
	<span class="welcomeheadline">How do I use lolstack?</span>
	<br />
	<span class="errortext">Check out the <a class="loginlink" href="welcome.lol"><strong>welcome page</strong></a> for a crash course.</span><br /> <br />
	<span class="welcomeheadline">How does lolstack know what content is original?</span>
	<span class="errortext">lolstack runs a discrete cosine transform (DCT) image hashing algorithm on every picture that is submitted. Hamming distances are computed for the image in question against all other images in the database.
	Any image closer than a certain threshhold is rejected.<br />
	<strong>tl;dr:</strong> Computers never forget.</span><br /> <br />

	<span class="welcomeheadline">What's up with that stick figure?</span>
	<br />
	<span class="errortext">Cereal guy always has something to say. He will give you some context clues when you're using the site.</span><br /> <br />
	
	
	</div>
</div>
<div class="grid_6 omega">
<div class="grid_6 entryguy">
	<div class="cerealguytext">Now you know who I am.</div>
</div>
</div>
<?php
include_once("htmlfooter.lol");
?>