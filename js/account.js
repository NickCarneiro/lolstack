function showPasswordRequest(formData, jqForm, options) {

	
    var queryString = $.param(formData); 
 
    // jqForm is a jQuery object encapsulating the form element.  To access the 
    // DOM element for the form do this: 
    // var formElement = jqForm[0]; 
 
    //alert('About to submit: \n\n' + queryString); 
	var form = jqForm[0]; 
    if (!form.current_password.value || form.current_password.value.trim() == "") { 
		//alert('empty');
		$('#accounterrors').html('Current password cannot be empty.');

        return false; 
    } 
	
	
	
	$('#processingdialog').dialog('open');
    // here we could return false to prevent the form from being submitted; 
    // returning anything other than false will allow the form submit to continue 
    return true; 
} 
 
 	
 
// post-submit callback 
function showPasswordResponse(responseText, statusText, xhr, $form)  { 
    
	

		if(responseText.indexOf('<error>') > -1){
		//alert('error detected');
			$("#accounterrors").html(responseText.between("<error>","</error>"));
		} else { 
			$('#accounterrors').html('Password successfully changed.');
		}
	
}

$(document).ready(function(){
  $('.changepassword').submit(function() { 
		
		var optionsSubmit = { 
        //target:        '#commenterrors',   // target element(s) to be updated with server response 
        beforeSubmit:  showPasswordRequest,  // pre-submit callback 
        success:       showPasswordResponse,  // post-submit callback 
 
        // other available options: 
        url:       'processaccount.lol',        // override for form's 'action' attribute 
        type:      'post'        // 'get' or 'post', override for form's 'method' attribute 
        
    }; 
        $(this).ajaxSubmit(optionsSubmit); 
 
       
        return false; 
    });
	
});