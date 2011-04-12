//trim whitespace function
var editing = -1;
var existing_comment = '';
String.prototype.trim = function() {
	return this.replace(/^\s+|\s+$/g,"");
}

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


function showEditResponse(responseText, statusText, xhr, $form) {
	$("#processingdialog").dialog("destroy");
	//alert('response: ' + responseText);
	if(responseText.indexOf('<error>')> -1){
		alert('error' + responseText.between('<error>','</error>'));
	}
	else {
	//remove form, replace with new comment text, highlight.
	//show edit links
	$('.editcomment').css('display','inline');
	var commentid = responseText.between('<commentid>','</commentid>');
	var comment = responseText.between('<comment>','</comment>');
	$('#text_' + commentid).html(comment);
	}
}

// pre-submit callback 
function showCommentRequest(formData, jqForm, options) {

	//TODO: add form validation here.
    // formData is an array; here we use $.param to convert it to a string to display it 
    // but the form plugin does this for you automatically when it submits the data 
    var queryString = $.param(formData); 
 
    // jqForm is a jQuery object encapsulating the form element.  To access the 
    // DOM element for the form do this: 
    // var formElement = jqForm[0]; 
 
    //alert('About to submit: \n\n' + queryString); 
	var form = jqForm[0]; 
    if (!form.comment.value || form.comment.value.trim() == "") { 
		//alert('empty');
		$('#errormessage').html('Comment cannot be empty.');
		
		$('#errordialog').dialog('open');
        
        return false; 
    } 
	
	
	
	$('#processingdialog').dialog('open');
    // here we could return false to prevent the form from being submitted; 
    // returning anything other than false will allow the form submit to continue 
    return true; 
} 
 
 	
 
// post-submit callback 
function showCommentResponse(responseText, statusText, xhr, $form)  { 
    // for normal html responses, the first argument to the success callback 
    // is the XMLHttpRequest object's responseText property 
 
    // if the ajaxSubmit method was passed an Options Object with the dataType 
    // property set to 'xml' then the first argument to the success callback 
    // is the XMLHttpRequest object's responseXML property 
 
    // if the ajaxSubmit method was passed an Options Object with the dataType 
    // property set to 'json' then the first argument to the success callback 
    // is the json data object returned by the server 
 
    //alert('status: ' + statusText + '\n\nresponseText: \n' + responseText + 
    //    '\n\nThe output div should have already been updated with the responseText.'); 
	
	//close processing dialog
	$("#processingdialog").dialog("destroy");

		if(responseText.indexOf('<error>') > -1){
		//alert('error detected');
			$("#commenterrors").html(responseText.between("<error>","</error>"));
		} 
		
		//$("#successdialog").data('link', responseText).dialog('open');
		//refresh page with new comment
		var newCommentId = responseText.between("<commentid>","</commentid>")
		var href = window.location.href;
		//strip current hash
		href = href.replace(window.location.hash,'');
		href = href + '#container_' + newCommentId;
		//alert('newcommentid '+newCommentId + ' href:'+href);
		//scroll to top of page before refresh
		//window.scroll(0,0);
		window.location.replace(href);
		
		window.location.reload();
	
}


function showDescResponse(responseText, statusText, xhr, $form)  {
	//alert('descresponse '+responseText);
	var responseData = jQuery.parseJSON( responseText );
	if(responseData['error'] != undefined){
		alert('error detected: ' + responseText);			
	} else {
		
		$('#picdescription').html(responseData['desc']);
	}
}
$(document).ready(function(){

			var highlight = '';
			if(window.location.hash) {
			  // hash exists
			  highlight = window.location.hash.substring(11);
			  //scroll to highlighted div
			  if(window.location.hash.indexOf('container') > -1){
				//alert('scrolling');
				//document.getElementById('container_'+highlight).scrollIntoView(true);
			  
			  }
			} 
			
			//highlight comment with id in highlight.
			$('#container_'+highlight).removeClass('commentcontainer');
			$('#container_'+highlight).addClass('commentcontainer_glow');
			
			$('.parentlink').live('click', function () {
				var parentid = $(this).attr('id').substr(7);
				if($('#container_'+parentid).hasClass('commentcontainer_glow')){
					$('#container_'+parentid).removeClass('commentcontainer_glow');
					$('#container_'+parentid).addClass('commentcontainer');
				
				}
				else {
					var offsettop = 25;
					$('html,body').animate({scrollTop: $('#container_'+parentid).offset().top-[offsettop]},500);
					$('#container_'+parentid).removeClass('commentcontainer');
					$('#container_'+parentid).addClass('commentcontainer_glow');
				}
			});
			
			$("#canceldescedit").live('click', function () {
				
				$('#picdescription').html(existing_comment);
				existing_comment = '';
			});
			$(".editdesc").live('click', function () {
				
				//save original desc in case of cancel
				existing_comment = $('#picdescription').html();
				//get description and display as form
				var picid = $(this).attr('id').substr(9);
				$.post("processPic.lol", {picid: picid, getdesc: "true" },
				function(data){
					var responseData = jQuery.parseJSON( data );
					if(responseData['error'] != undefined){	
						alert("Error fetching description for desc edit: " + responseData['error']);
					} else {
						
						var comment_orig = responseData['desc'];
						//original means unparsed bbcode from database
						//existing means already rendered comment on page
						
						$('#descformarea').html(comment_orig);
						$('#picdescription').html($('#descformdiv').html());
						
						
						
					}
				 });
			});
			$(".formattinghelp").live('click', function () {
				//show formatting help in div below
				//unhide
				if($(this).attr('id') == 'link_top'){
					if($('.formatting_none').css('display') == 'none'){
						$('.formatting_none').css('display','block');
					} else {
						$('.formatting_none').css('display','none');
					}
					
					//showHideDiv('formatting_none');
					$('.formatting_none').html($('#formattinghelp').html());
					
				} else {
					var commentid = $(this).attr('id').substr(5);
					$('#formatting_' + commentid).html($('#formattinghelp').html());
					showHideDiv('formatting_' + commentid);
				}

			});
			
			$(".replylink").live('click', function () {
				if(loggedIn == 0){
					$( "#logindialog" ).dialog({ title: 'Login or register to comment' });
					$('#logindialog').dialog('open');
					return;
				}
				var commentid = $(this).attr('id').substr(10);
				//$('#comment_'+commentid).attr('id')
				//showHideDiv("comment_"+commentid);
				if($('#comment_'+commentid).css('display').indexOf('none') > -1){
					$('#comment_'+commentid).css('display','block');
				} else {
					$('#comment_'+commentid).css('display','none');
				}
				
			});
			
			//replace comment with filled-in form of originaltext
			$(".editcomment").live('click', function () {
				var commentid = $(this).attr('id').substr(5);

				//alert(commentid);
				//get original contents of commentid
				$.post("processComment.lol", {commentid: commentid, getcomment: "true" },
				function(data){
					
					if (data.indexOf('<error>') > -1){
						alert("error fetching comment for edit" + data.between('<error>','</error>'));
					} else {
						var comment_orig = data.between('<comment_orig>','</comment_orig>');
						//original means unparsed bbcode from database
						//existing means already rendered comment on page
						
						//place original comment in form field
						//alert("original comment: " + comment_orig);
						//save existing comment in variable in case of cancel
						existing_comment = $('#text_' + commentid).html();
						$('#editcommentid').attr('value',commentid);
						//show filled in form
						$('#editarea').html(comment_orig);
						$('#text_' + commentid).html($('#editform').html());
						editing = commentid;
						//hide edit links
						$('.editcomment').css('display','none');
						
					}
				 });
				 

			});
			$(".cancelbutton").live('click', function () {
				$('#text_' + editing).html(existing_comment);
				//show edit links again
				$('.editcomment').css('display','inline');
				editing = -1;
				existing_comment = '';
				

			});
				
			
			$('#successdialog').dialog({
		modal: true,
		autoOpen: false,
		width: 400,
		buttons: {
			"Return to image": function() { 
				$(this).dialog("close");
				//alert($(this).data('link').between('<commentid>','</commentid>'));
				if($(this).data('link').indexOf("<error>") > -1){
					$("successerror").html("Warning: " + $(this).data('link').between("<error>","</error>"));
				}
				
				window.location.replace('pic.lol?id=' + $(this).data('link').between('<picid>','</picid>')+"#votes_count"+$(this).data('link').between('<commentid>','</commentid>'));
				window.location.reload(true);
			}, 
		}
	});
	
		$('#processingdialog').dialog({
		modal: true,
		autoOpen: false,
		width: 400
	});
	
	$('#errordialog').dialog({
		modal: false,
		autoOpen: false,
		width: 400,
		buttons: {
			"OK": function() { 
				$(this).dialog("close");
				
			}, 
		}
	});
	
		
 
    // bind to the form's submit event 
    $('.submitcomment').submit(function() { 
		//alert('submitting comment');
        // inside event callbacks 'this' is the DOM element so we first 
        // wrap it in a jQuery object and then invoke ajaxSubmit 
		var optionsSubmit = { 
        //target:        '#commenterrors',   // target element(s) to be updated with server response 
        beforeSubmit:  showCommentRequest,  // pre-submit callback 
        success:       showCommentResponse,  // post-submit callback 
 
        // other available options: 
        url:       'processComment.lol',        // override for form's 'action' attribute 
        type:      'post'        // 'get' or 'post', override for form's 'method' attribute 
        //dataType:  null        // 'xml', 'script', or 'json' (expected server response type) 
        //clearForm: true        // clear all form fields after successful submit 
        //resetForm: true        // reset the form after successful submit 
 
        // $.ajax options can be used here too, for example: 
        //timeout:   3000 
    }; 
        $(this).ajaxSubmit(optionsSubmit); 
 
        // !!! Important !!! 
        // always return false to prevent standard browser submit and page navigation 
        return false; 
    });
	
	
 
    // bind to the form's submit event 
	
    $('.submitedit').live('submit', function() {
		
        // inside event callbacks 'this' is the DOM element so we first 
        // wrap it in a jQuery object and then invoke ajaxSubmit 
		//alert('submitting edit');
		var optionsEdit = { 
        //target:        '#commenterrors',   // target element(s) to be updated with server response 
        beforeSubmit:  showCommentRequest,  // pre-submit callback 
        success:       showEditResponse,  // post-submit callback 
 
        // other available options: 
        url:       'processComment.lol',        // override for form's 'action' attribute 
        type:      'post'        // 'get' or 'post', override for form's 'method' attribute 
        //dataType:  null        // 'xml', 'script', or 'json' (expected server response type) 
        //clearForm: true        // clear all form fields after successful submit 
        //resetForm: true        // reset the form after successful submit 
 
        // $.ajax options can be used here too, for example: 
        //timeout:   3000 
		}; 
        $(this).ajaxSubmit(optionsEdit); 
 
        // !!! Important !!! 
        // always return false to prevent standard browser submit and page navigation 
        return false; 
    });
	
	$('.editdescform').live('submit', function() {
		
        // inside event callbacks 'this' is the DOM element so we first 
        // wrap it in a jQuery object and then invoke ajaxSubmit 
		//alert('submitting edit');
		var optionsDesc = { 
        //target:        '#commenterrors',   // target element(s) to be updated with server response 
        //beforeSubmit:  showDescRequest,  // pre-submit callback 
        success:       showDescResponse,  // post-submit callback 
 
        // other available options: 
        url:       'processPic.lol',        // override for form's 'action' attribute 
        type:      'post'        // 'get' or 'post', override for form's 'method' attribute 
        //dataType:  null        // 'xml', 'script', or 'json' (expected server response type) 
        //clearForm: true        // clear all form fields after successful submit 
        //resetForm: true        // reset the form after successful submit 
 
        // $.ajax options can be used here too, for example: 
        //timeout:   3000 
		}; 
        $(this).ajaxSubmit(optionsDesc); 
 
        // !!! Important !!! 
        // always return false to prevent standard browser submit and page navigation 
        return false; 
    });
	$('#formattinghelpdesc').live('click', function() {
		if($('#formattingdescdiv').css('display') == 'none'){
			$('#formattingdescdiv').css('display','block');
			$('#formattingdescdiv').html($('#formattinghelp').html());
		} else {
			$('#formattingdescdiv').css('display','none');
			$('#formattingdescdiv').html('');
		}
		
	});
		});