var orig_width = -1;
var orig_height = -1;
var width = -1;
var height = -1;
var first_load = 0;

$(document).ready(function(){
	$("#newcomment").hide();
	
	//resize pic to fit screen
	$("#theActualPic").load(function(){
		
		orig_width = $("#theActualPic").width();
		orig_height = $("#theActualPic").height();
		//alert('orig_width ' + orig_width + ' orig height: ' + orig_height);
		if(first_load == 0 && (orig_width > 960 || orig_height > 800)){
		//shrink image
			first_load = 1;
			$( "#theActualPic" ).aeImageResize({ height: 800, width: 940 });
		}
		
	});
	//or however you get a handle to the IMG
	
	
	 $( "#theActualPic" ).click(function(){
		width = $("#theActualPic").width();
		height = $("#theActualPic").height(); 
	 
	 //alert('resizing from ' + width + ' ' + height+'\n'+
	 //'to orig width: ' + orig_width);
		if(width == orig_width ){
			alert('shrinking');
			//image at full size. shrink down	
			//shrink image
			$( "#theActualPic" ).aeImageResize({ height: 800, width: 940 });
	
		} else {
			//image already shrunk. show full size
			$( "#theActualPic" ).aeImageResize({ height: orig_height, width: orig_width });
		}
		
	 });
	 $('#clicktozoom').hide();
	 $( "#theActualPic" ).mouseover(function(){
		
		width = $("#theActualPic").width();
		height = $("#theActualPic").height(); 
	 //alert('width'+width + ' orig_width '+orig_width + ' orig_height' + orig_height);
		if(width < orig_width && (orig_width > 960 || orig_height > 800)){
			//alert('showing');
			$('#clicktozoom').show();
		}
	 });
	 $( "#theActualPic" ).mouseout(function(){
		$('#clicktozoom').hide();
	 });
	 
	 $("#commentform").live('click', function () {
		if(loggedIn == 0){
			
			$( "#logindialog" ).dialog({ title: 'Login or register to comment' });
			$('#logindialog').dialog('open');
			return;
		}
		$("#newcomment").toggle();
		
		//showHideDiv('newcomment');	
	});

	 
		$(".link_top").live('click', function () {
			
			$( "#formattingdialog" ).dialog({ title: 'Style your posts' });
			$('#formattingdialog').dialog('open');
			$( "#formattingdialog" ).dialog( "option", "width", 650 );
		});
		
		$(".reply_comment_container").css('display','none');
	});
	