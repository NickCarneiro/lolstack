/**
 * Usage  var you = 'hello you guys'.between('hello ',' guys');
 * you = 'you';
 */
 

String.prototype.between = function(prefix, suffix) {
  s = this;
  var i = s.indexOf(prefix);
  if (i >= 0) {
    s = s.substring(i + prefix.length);
  }
  else {
    return '';
  }
  if (suffix) {
    i = s.indexOf(suffix);
    if (i >= 0) {
      s = s.substring(0, i);
    }
    else {
      return '';
    }
  }
  return s;
}
//trim whitespace function
String.prototype.trim = function() {
	return this.replace(/^\s+|\s+$/g,"");
}

function showHideDiv(div)
{
	var divstyle = new String();
	divstyle = document.getElementById(div).getAttribute('class','className');
	if(divstyle.toLowerCase()=="unhidden")
	{
		document.getElementById(div).setAttribute('class','hidden');
	}
	else
	{
		document.getElementById(div).setAttribute('class','unhidden');
	}
}

function showHideBlock(block){
	var blockstyle = new String();
	blockstyle = $('#'+block).css('display');
	if(blockstyle.indexOf('none') > -1){
		$('#'+block).css('display','block');
	}
	else{
		$('#'+block).css('display','none');
	}
}


function showDiv(div)
{
	document.getElementById(div).setAttribute('class','unhidden');
}	

function hideDiv(div)
{
	document.getElementById(div).setAttribute('class','hidden');
}	

	
function renderDeleteResponse(data){
	//alert('render');
	$('#dialog').dialog('open');
	
}	

function renderSubmitResponse(data){
	//alert('render');
	$('#dialog2').dialog('open');
	
}





function doNothing(){
	
}

var confirmDeleteStorage = '';
$(document).ready(function(){
	$('#pmreplybutton').live('click',
		function(){
		//alert('pmreply');
		$('#reply').html($('#pmbox').html());		
		});
		
	$('#formattinghelp').click( function(){
		
		if ($('#formattinghelpdiv').css('display') == 'none'){
			$('#formattinghelpdiv').css('display','block');
		} else {
			$('#formattinghelpdiv').css('display','none');
		}
	});
    // comment Dialog			
	$('#dialog').dialog({
		autoOpen: false,
		width: 400,
		buttons: {
			"Ok": function() { 
				$(this).dialog("close");
				//reload page.
				var commentid = $('#dialogid').attr('value');
				
				
				var picid = $('#picid').attr('value');
				window.location.replace('pic.lol?id='+picid+'#comment_' + commentid);
				window.location.reload(true);
			}, 
		}
	});
	
	//delete comment dialog
	$('#dialog2').dialog({
	autoOpen: false,
	width: 400,
	buttons: {
		"Ok": function() { 
			$(this).dialog("close");
			//reload page.
			
			var picid = $('#picid').attr('value');
			window.location.replace('pic.lol?id='+picid);
			window.location.reload(true);
		}, 
	}
	});
		
	$('#logindialog').dialog({
	autoOpen: false,
	width: 400,
	buttons: {
		"Cancel": function() { 
			$(this).dialog("close");
		}, 
	}
	});
	
	$(".leavecomment").live('click', function () {
		window.location.replace('#commentform');	
	});
	
	$("#toploginlink").live('click', function () {
		
		$( "#logindialog" ).dialog({ title: 'Login for even more fun!' });
		$('#logindialog').dialog('open');	
	});
	
    $(".delete").live('click', function () {
		confirmDeleteStorage = $(this).parent().html();
      $(this).replaceWith("for real? <a class=\"confirmdelete\" id=\""+$(this).attr('id')+"\" href=\"#"+$(this).attr('id')+"\">yes</a> / <a class=\"canceldelete\"  id=\""+$(this).attr('id')+"\" href=\"#"+$(this).attr('id')+"\">no</a>");
		
	});

	$(".confirmdelete").live('click',function() {
      //perform comment delete
	  //replace link with spinner
	$(this).parent().replaceWith("<span id=\"spinner\"><img src='images/spinner.gif'/></span>");
	var commentid = $(this).attr('id').substr(7);
	
	//save commentid for redirect later.
	$('#dialogid').attr('value',commentid);
	
	
		$.post("deleteComment.lol", { comment_id: commentid},
			function(data){
			
			renderDeleteResponse(data);
				

			}
		);
		$("span#spinner").remove();
	
	});
	
	
	$(".canceldelete").live('click',function() {
      //replace with delete button
	var commentid = $(this).attr('id').substr(7);
	  
	$(this).parent().html(confirmDeleteStorage);

   });
   
   $(".replylink").click(function() {
		window.scrollBy(0,70);
	});
	
	
	
	
	$(".submitnewpm").submit(function() {
		
	$.post("processmessage.lol", $(this).serialize(),
	function(data){
		if (data.indexOf('<error>') > -1 ){
			//alert(data.between('<error>','</error>'));
			$('#pmerror').addClass('grid_12');
			$('#pmerror').addClass('entry_glow');
			$('#pmerror').html('<span class="pic_instructions">'+data.between('<error>','</error>')+'</span>');
		} else {
			var from_id = data.between('<fromid>','</fromid>')
			window.location.replace('messageThread.lol?from_id='+from_id);
		}

		});
    });
	
	$(".submitpm").live('submit', function() {
		
	$.post("processmessage.lol", $(this).serialize(),
	function(data){
		if (data.indexOf('<error>') > -1 ){
			//alert(data.between('<error>','</error>'));
			$("#reply").before('<div class="grid_12 entry_glow"><span class="pic_instructions">'+data.between('<error>','</error>')+'</span></div>');
			
		} else {
			var from_id = data.between('<fromid>','</fromid>')
			window.location.replace('messageThread.lol?from_id='+from_id);
		}

		});
    });
	  
	  
	 
	
  });
