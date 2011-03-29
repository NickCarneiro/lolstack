function showPasswordRequest(formData, jqForm, options) {

	
    var queryString = $.param(formData); 
	var form = jqForm[0]; 
	
	
    if (!form.current_password.value || form.current_password.value.trim() == "") { 
		//alert('empty');
		$('#accounterrors').html('Current password cannot be empty.');
		
        return false; 
    } 
	
    // here we could return false to prevent the form from being submitted; 
    // returning anything other than false will allow the form submit to continue 
    return true; 
} 
 	
 
function showPasswordResponse(responseText, statusText, xhr, $form)  { 

	if(responseText.indexOf('<error>') > -1){
	//alert('error detected');
		
		$("#accounterrors").html(responseText.between("<error>","</error>"));
	} else { 
		$('#accounterrors').html('Password successfully changed.');
	}
	
}

function showEmailRequest(formData, jqForm, options) {

    //no local validation on email address
    return true; 
} 
 	
 
function showEmailResponse(responseText, stsatusText, xhr, $form)  { 
    
	if(responseText.indexOf('<error>') > -1){
	//alert('error detected');
		$("#accounterrors").html(responseText.between("<error>","</error>"));
	} else { 
		$('#accounterrors').html('Email successfully changed.');
	}
	
}

function showPasswordResetRequest(formData, jqForm, options) {
	$('#resetbutton').hide();
    //no local validation on email address
    return true; 
} 
 	
 
function showPasswordResetResponse(responseText, stsatusText, xhr, $form)  { 
    
	if(responseText.indexOf('<error>') > -1){
	//alert('error detected');
		$('#resetbutton').show();
		$("#accounterrors").html(responseText.between("<error>","</error>"));
	} else { 
		$('#passwordresetform').hide();
		$('#accounterrors').html('Check your email for a link to reset your password.');
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
	
	$('.changeemail').submit(function() { 
		
		var optionsSubmit = { 
        //target:        '#commenterrors',   // target element(s) to be updated with server response 
        beforeSubmit:  showEmailRequest,  // pre-submit callback 
        success:       showEmailResponse,  // post-submit callback 
 
        // other available options: 
        url:       'processaccount.lol',        // override for form's 'action' attribute 
        type:      'post'        // 'get' or 'post', override for form's 'method' attribute 
        
    }; 
        $(this).ajaxSubmit(optionsSubmit);  
        return false; 
    });
	
	$('.resetpassword').submit(function() { 
		
		var optionsSubmit = { 
        //target:        '#commenterrors',   // target element(s) to be updated with server response 
        beforeSubmit:  showPasswordResetRequest,  // pre-submit callback 
        success:       showPasswordResetResponse,  // post-submit callback 
 
        // other available options: 
        url:       'processaccount.lol',        // override for form's 'action' attribute 
        type:      'post'        // 'get' or 'post', override for form's 'method' attribute 
        
    }; 
        $(this).ajaxSubmit(optionsSubmit);  
        return false; 
    });
});