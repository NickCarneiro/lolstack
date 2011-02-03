
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

// pre-submit callback 
function showRequest(formData, jqForm, options) { 
	//TODO: add form validation here.
    // formData is an array; here we use $.param to convert it to a string to display it 
    // but the form plugin does this for you automatically when it submits the data 
    var queryString = $.param(formData); 
 
    // jqForm is a jQuery object encapsulating the form element.  To access the 
    // DOM element for the form do this: 
    // var formElement = jqForm[0]; 
 
    //alert('About to submit: \n\n' + queryString); 
	var form = jqForm[0]; 
    if (!form.title.value || form.title.value.trim() == "") { 
		$('#picerrors').html('Error: Please enter a title');
		$('#picerrorscontainer').removeClass('entry');
		$('#picerrorscontainer').addClass('entry_glow');
        return false; 
    } 
	/*
	if (!form.description.value || form.description.value.trim() == "") { 
		
        $('#picerrors').html('Please enter a description.');
        return false; 
    }*/
	
	if (!form.pic.value && !form.url.value) { 
		
        $('#picerrors').html('Error: Please choose an image file to upload or enter a URL.');
        $('#picerrorscontainer').removeClass('entry');
		$('#picerrorscontainer').addClass('entry_glow');
		return false; 
    }
	
	
	$('#processingdialog').dialog('open');
    // here we could return false to prevent the form from being submitted; 
    // returning anything other than false will allow the form submit to continue 
    return true; 
} 
 
 	
 
// post-submit callback 
function showResponse(responseText, statusText, xhr, $form)  { 
    // for normal html responses, the first argument to the success callback 
    // is the XMLHttpRequest object's responseText property 
 
    // if the ajaxSubmit method was passed an Options Object with the dataType 
    // property set to 'xml' then the first argument to the success callback 
    // is the XMLHttpRequest object's responseXML property 
 
    // if the ajaxSubmit method was passed an Options Object with the dataType 
    // property set to 'json' then the first argument to the success callback 
    // is the json data object returned by the server 
 
    //alert('status: ' + statusText + '\n\nresponseText: \n' + responseText ); 
	
	//close processing dialog
	$("#processingdialog").dialog("close");
	responseText = responseText.toLowerCase();
	if(responseText.indexOf('uploaded successfully') > -1){	
		
		//$('#submitpicdiv').addClass('hidden');
		//launch dialog
		//$('#successdialog').dialog('open');
		//$("#debug").html(responseText);
		
		
		$("#successdialog").data('link', responseText).dialog('open');
	} else {
		
		$("#picerrors").html(responseText.between("<error>","</error>"));
		$('#picerrorscontainer').removeClass('entry');
		$('#picerrorscontainer').addClass('entry_glow');
	}
}

$(document).ready(function(){

$("#formattinglink").live('click', function () {
				//show formatting help in div below
				//unhide
				if ($(this).html().indexOf('hide') > -1){
					$(this).html('show formatting help');
				} else {
					$(this).html('hide formatting help');
				}
				
				
				var commentid = $(this).attr('id').substr(5);
				//alert(commentid);
				$('#formattingdest').html($('#formattingsource').html());
				showHideDiv('formattingdest');
				
			});

 // Setting up the suggestion box

            $("#title").inputTip({
                // Text displayed when the input passes the validation
                goodText: "Hey-oh! Looks good!",
                // Text displayed when the input doesn't pass the validation
                badText: "Ouch, it looks empty!",
                // Text displayed as a tip when the input field is focused
                tipText: "Enter a title for your image.",
                /* Function called to validate the input. It should fire "callback" with the following parameters
                *  First parameter:
                *  - 0: validation failed
                *  - 1: validation succeeded
                *  - 2: show the tip text
                * Second parameter: optional text to display instead of the standard text */

                validateText: function(inputValue, callback) {
                    // Checking if the input field contains text.
                    if (inputValue.length > 0) callback(1);
                    else callback(0);
                },
                // True if the validation should be performed on every key/up event (false by default)
                validateInRealTime: false
            });


			$("#url").inputTip({
                // Text displayed when the input passes the validation
                goodText: "That will do.",
                // Text displayed when the input doesn't pass the validation
                badText: "example: http://example.com/image.jpg",
                // Text displayed as a tip when the input field is focused
                tipText: "Enter a direct url to an image. (instead of uploading a file from your computer)",
                /* Function called to validate the input. It should fire "callback" with the following parameters
                *  First parameter:
                *  - 0: validation failed
                *  - 1: validation succeeded
                *  - 2: show the tip text
                * Second parameter: optional text to display instead of the standard text */
                validateText: function(inputValue, callback) {
                // Checking if the input field contains text.
                    if (inputValue.indexOf("http://") == 0 || !inputValue) callback(1);
                    else callback(0);

                },
                // True if the validation should be performed on every key/up event (false by default)
                validateInRealTime: false
            });
          
			
			$("#description").inputTip({
                // Text displayed when the input passes the validation
                goodText: "This is optional.",
                // Text displayed when the input doesn't pass the validation
                badText: "This is optional. No biggie.",
                // Text displayed as a tip when the input field is focused
                tipText: "Say something meaningful about the image.",
                /* Function called to validate the input. It should fire "callback" with the following parameters
                *  First parameter:
                *  - 0: validation failed
                *  - 1: validation succeeded
                *  - 2: show the tip text
                * Second parameter: optional text to display instead of the standard text */
                validateText: function(inputValue, callback) {
                // Checking if the input field contains text.
                    if (inputValue.length > 0) callback(1);
                    else callback(1);
                },
                // True if the validation should be performed on every key/up event (false by default)
                validateInRealTime: false
            });
			
            $("#tags").inputTip({
                // Text displayed when the input passes the validation
                goodText: "Nice tags!",
                // Text displayed when the input doesn't pass the validation
                badText: "Please enter some tags. It helps us out.",
                // Text displayed as a tip when the input field is focused
                tipText: "Enter some comma-separated tags",
                /* Function called to validate the input. It should fire "callback" with the following parameters
                *  First parameter:
                *  - 0: validation failed
                *  - 1: validation succeeded
                *  - 2: show the tip text
                * Second parameter: optional text to display instead of the standard text */
                validateText: function(inputValue, callback) {
                // Checking if the input field contains text.
                    if (inputValue.length > 0) callback(1);
                    else callback(0);
                },
                // True if the validation should be performed on every key/up event (false by default)
                validateInRealTime: false
            });
			
			$('#successdialog').dialog({
		modal: true,
		autoOpen: false,
		width: 400,
		buttons: {
			"Go to image": function() { 
				$(this).dialog("close");
				if($(this).data('link').indexOf("<error>") > -1){
					$("successerror").html("Warning: " + $(this).data('link').between("<error>","</error>"));
				}
				var picid = $('#picid').attr('value');
				window.location.replace('pic.lol?id=' + $(this).data('link').between('<picid>','</picid>'));
				//window.location.reload(true);
			}, 
		}
	});
	
		$('#processingdialog').dialog({
		modal: true,
		autoOpen: false,
		width: 400
	});
	
	var options = { 
        target:        '#picerrors',   // target element(s) to be updated with server response 
        beforeSubmit:  showRequest,  // pre-submit callback 
        success:       showResponse,  // post-submit callback 
 
        // other available options: 
        url:       'processPic.lol',        // override for form's 'action' attribute 
        type:      'post'        // 'get' or 'post', override for form's 'method' attribute 
        //dataType:  null        // 'xml', 'script', or 'json' (expected server response type) 
        //clearForm: true        // clear all form fields after successful submit 
        //resetForm: true        // reset the form after successful submit 
 
        // $.ajax options can be used here too, for example: 
        //timeout:   3000 
    }; 
 
    // bind to the form's submit event 
    $('#submitpic').submit(function() { 
        // inside event callbacks 'this' is the DOM element so we first 
        // wrap it in a jQuery object and then invoke ajaxSubmit 
        $(this).ajaxSubmit(options); 
 
        // !!! Important !!! 
        // always return false to prevent standard browser submit and page navigation 
        return false; 
    }); 
		});