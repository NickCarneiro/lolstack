<?php
include_once("header.lol");
if (!isLoggedIn()){
	
	header("Location: login.lol");
	die();
}

				  
renderHeader("Submit a picture");
//include form javascript
echo('<script type="text/javascript" src="js/picform.js"></script>');



?>
<div class="entry grid_16 alpha" id="picerrorscontainer">
	
		<span class="pic_instructions" id="picerrors">Upload an image</span>
		<span id="debug"></span>
	
</div>
<div class="entry grid_16 omega">
	<form id="submitpic" enctype="multipart/form-data" action="javascript:doNothing()">
<input type="hidden" name="MAX_FILE_SIZE" value="1310720" />


	<div class="inputRow containerFix">
            <div class="inputName">
                <label for="pic">
                    Choose a file:</label>
			</div>
            <div class="inputValue">
				<input id="pic" name="pic" type="file" class="fileInput"/>             
            </div>
    </div>
	<div class="inputRow containerFix">
            <div class="inputName">
                <label for="url">
                    or URL:</label>
			</div>
            <div class="inputValue">
				<input type="text" name="url" id="url" class="txtInput"/>             
            </div>
			
    </div>
	<br />
	<div class="inputRow containerFix">
            <div class="inputName">
                <label for="title">
                    Title:</label>
			</div>
            <div class="inputValue">
				<input name="title" type="text" id="title" class="txtInput">              
            </div>
    </div>
	<div class="inputRow containerFix">
            <div class="inputName">
                <label for="description">
                    Description:</label>
			</div>
            <div class="inputValue">
				<textarea name="description" id="description" class="descArea"></textarea>      
            </div>
    </div>
	<div class="inputRow containerFix">
            <div class="inputName">
                <label for="description">
                    &nbsp;</label>
			</div>
            <div class="inputValue">
				<a class="showhide" id="formattinglink" href="javascript:doNothing()">formatting help</a>
	<div id="formattingdest" class="hidden"></div>      
            </div>
    </div>
	
	<div class="inputRow containerFix">
            <div class="inputName">
                <label for="category">
                    Category:</label>
			</div>
            <div class="inputValue">
				<select name="category" id="category" class="selectInput">
				<?php 
					foreach($categories as $cat){
						if($cat != "all"){
							echo "<option value=\"$cat\">$cat</option>";
						}
						
					}
				?>

			</select>      
            </div>
    </div>
	<div class="inputRow containerFix">
            <div class="inputName">
                <label for="tags">
                    Tags:</label>
			</div>
            <div class="inputValue">
				<input type="text" name="tags" id="tags" class="txtInput" />     
            </div>
    </div>
	<div class="inputRow containerFix">
            <div class="inputName">
                <label for="nsfw">
                    Not work safe?</label>
			</div>
            <div class="inputValue">
				<input class="cbxInput" type="checkbox" name="nsfw" id="nsfw" value="1" />    
            </div>
    </div>
	<div class="inputRow containerFix">
            <div class="inputName">
                <label for="nothumb">
                    No thumbnail</label>
			</div>
            <div class="inputValue">
				<input class="cbxInput" type="checkbox" name="nothumb" id="nothumb" value="1" />    
            </div>
    </div>
	<div class="inputRow containerFix">
            <div class="inputName">
                <label for="submitbutton">
                    &nbsp;</label>
			</div>
            <div class="inputValue">
				<input class="submitbutton" type="submit" id="submitbutton" name="submitbutton" />    
            </div>
    </div>
  <br />

</form>
</div>

<div id="successdialog" title="Image submitted">
			<p>Your image has been submitted.</p><br />
			<span id="successerror"></span>
			
</div>

<div id="processingdialog" title="Processing image">
			<p>Your image is being processed. Stay still and don't touch anything.</p><br />
			<img src="images/loading.gif" />
</div>
<div id="formattingsource" class="hidden">
<table>
<tr><td>Type this:</td><td>Get this:</td></tr>
<tr><td>[b]bold[/b]</td><td><strong>bold</strong></td></tr>
<tr><td>[i]italic[/i]</td><td><em>italic</em> </td></tr>
<tr><td>[u]underline[/u]</td><td><span style="text-decoration:underline;">underline</span> </td></tr>
<tr><td>[s]strike[/s]</td><td><del>strike</del></td></tr>
<tr><td>[sub]subscript[/sub]</td><td><sub>subscript</sub></td></tr>
<tr><td>[sup]superscript[/sup]</td><td><sup>superscript</sup> </td></tr>
<tr><td>[url]http://www.example.com[/url]</td><td><a href=\'http://www.example.com/\'>http://www.example.com</a> </td></tr>
<tr><td>[url=http://www.example.com]example[/url]</td><td><a href=\'http://www.example.com/\'>example</a></td></tr>

</table>
</div>
<?php
include_once("htmlfooter.lol");
?>