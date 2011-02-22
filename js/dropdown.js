 var droppedDown = "";
 $(document).ready(function() {
 
	$(".dropdown_more dt a").click(function() {
		
		$(".dropdown_more dd ul").toggle();
		droppedDown = "more";
		
	});
	
	
	$(".dropdown_more dd ul li a").click(function() {
		var text = $(this).html();
		$(".dropdown_more dd ul").hide();
	});
	
	$(".dropdown_cat dt a").click(function() {

		$(".dropdown_cat dd ul").toggle();
		droppedDown = "cat";
		
	});
	
	
	$(".dropdown_cat dd ul li a").click(function() {
		var text = $(this).html();
		//$(".dropdown_cat dt a span").html(text);
		$(".dropdown_cat dd ul").hide();
		
	   // $("#result").html("Selected value is: " + getSelectedValue("sample"));
	});
	
	$(".dropdown_time dt a").click(function() {
		droppedDown = "time";
		$(".dropdown_time dd ul").toggle();
	});
	
	
	$(".dropdown_time dd ul li a").click(function() {
		var text = $(this).html();
		//$(".dropdown_time dt a span").html(text);
		$(".dropdown_time dd ul").hide();
	   // $("#result").html("Selected value is: " + getSelectedValue("sample"));
	});  
	  
	function getSelectedValue(id) {
		return $("#" + id).find("dt a span.value").html();
	}
	
	$(document).bind('click', function(e) {
		var $clicked = $(e.target);       
		if(!$clicked.parents().hasClass("dropdown_cat")){
			
			$(".dropdown_cat dd ul").hide();
		} 
		if( !$clicked.parents().hasClass("dropdown_time")) {
			$(".dropdown_time dd ul").hide();
		}
		
		if( !$clicked.parents().hasClass("dropdown_more")) {
			$(".dropdown_more dd ul").hide();
		}
	});
	
	
	$(".searchtext").click(function() {
		$(this).attr('value','');
		$(this).css('color','black');
	});
	
	$(".usernametext").click(function() {
		$(this).attr('value','');
		$(this).css('color','black');
	});
	$(".passwordtext").click(function() {
		$(this).attr('value','');
		$(this).css('color','black');
	});
	
});
