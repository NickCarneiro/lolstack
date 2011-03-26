
var votePackContents = '';
$(document).ready(function(){
	$("a.upvotecomment_gray, a.downvotecomment_gray").live("click", function(event){
		if(loggedIn == 0){
			$( "#logindialog" ).dialog({ title: 'Login or register to vote' });
			$('#logindialog').dialog('open');
			return;
		}
		
		//get the id
	the_id = $(this).parent().attr('id').substring(12);
	//alert('id '+the_id);
	//save pack contents
	votePackContents = $("#votes_count"+the_id).parent().html();
	//alert(votePackContents);
	// show the spinner
	$("#votes_count"+the_id).html('<img src="images/spinner.gif"/>');
	//the main ajax request
		$.ajax({
			type: "POST",
			data: "action=clearvote&commentid="+the_id,
			url: "commentVote.lol",
			success: function(msg)
			{
				//bring back the pack contents
				//alert(msg);
				$("span#votes_count"+the_id).parent().html(votePackContents);
				$("#upvote_button"+the_id).addClass('upvotecomment');
				$("#upvote_button"+the_id).removeClass('upvotecomment_gray');
				$("#upvote_button"+the_id).removeClass('downvotecomment_gray');
				$("#downvote_button"+the_id).addClass('downvotecomment');
				$("#downvote_button"+the_id).removeClass('upvotecomment_gray');
				$("#downvote_button"+the_id).removeClass('downvotecomment_gray');
				$("span#votes_count"+the_id).html(msg);
				
			}
		});	
	});
	
	$("a.upvote_gray, a.downvote_gray").live("click", function(event){
		if(loggedIn == 0){
			$( "#logindialog" ).dialog({ title: 'Login or register to vote' });
			$('#logindialog').dialog('open');
			return;
		}
		
		//get the id
	the_id = $(this).parent().attr('id').substring(12);
	//alert('id '+the_id);
	//save pack contents
	votePackContents = $("#votes_count"+the_id).parent().html();
	//alert(votePackContents);
	// show the spinner
	$("#votes_count"+the_id).html('<img src="images/spinner.gif"/>');
	//the main ajax request
		$.ajax({
			type: "POST",
			data: "action=clearvote&id="+the_id,
			url: "vote.lol",
			success: function(msg)
			{
				//bring back the pack contents
				//alert(msg);
				$("span#votes_count"+the_id).parent().html(votePackContents);
				$("#upvote_button"+the_id).addClass('upvote');
				$("#upvote_button"+the_id).removeClass('upvote_gray');
				$("#upvote_button"+the_id).removeClass('downvote_gray');
				$("#downvote_button"+the_id).addClass('downvote');
				$("#downvote_button"+the_id).removeClass('upvote_gray');
				$("#downvote_button"+the_id).removeClass('downvote_gray');
				$("span#votes_count"+the_id).html(msg);
				
			}
		});	
	});
	
	
	
	$("a.upvote").live("click",function(event){
		
		if(loggedIn == 0){
			$( "#logindialog" ).dialog({ title: 'Login or register to vote' });
			$('#logindialog').dialog('open');
			return;
		}
	//get the id
	the_id = $(this).parent().attr('id').substring(12);
	//alert('id '+the_id);
	//save pack contents
	votePackContents = $("#votes_count"+the_id).parent().html();
	//alert(votePackContents);
	// show the spinner
	$("#votes_count"+the_id).html('<img src="images/spinner.gif"/>');
	//the main ajax request
		$.ajax({
			type: "POST",
			data: "action=upvote&id="+the_id,
			url: "vote.lol",
			success: function(msg)
			{
				
				//bring back the pack contents
				//alert(msg);
				$("span#votes_count"+the_id).parent().html(votePackContents);
				$("#upvote_button"+the_id).removeClass('upvote');
				$("#upvote_button"+the_id).toggleClass('upvote_gray');
				$("#downvote_button"+the_id).removeClass('downvote');
				$("#downvote_button"+the_id).toggleClass('upvote_gray');
				$("span#votes_count"+the_id).html(msg);
				
			}
		});
	});
	
	$("a.downvote").live("click",function(event){
	if(loggedIn == 0){
			$( "#logindialog" ).dialog({ title: 'Login or register to vote' });
			$('#logindialog').dialog('open');
			return;
		}
	//get the id
	the_id = $(this).parent().attr('id').substring(12);
	//alert('id '+the_id);
	//save pack contents
	votePackContents = $("#votes_count"+the_id).parent().html();
	//alert(votePackContents);
	// show the spinner
	$("#votes_count"+the_id).html('<img src="images/spinner.gif"/>');
	//the main ajax request
		$.ajax({
			type: "POST",
			data: "action=downvote&id="+the_id,
			url: "vote.lol",
			success: function(msg)
			{
				
				//bring back the pack contents
				//alert(msg);
				$("span#votes_count"+the_id).parent().html(votePackContents);
				$("#upvote_button"+the_id).removeClass('upvote');
				$("#upvote_button"+the_id).addClass('downvote_gray');
				$("#downvote_button"+the_id).removeClass('downvote');
				$("#downvote_button"+the_id).addClass('downvote_gray');
				$("span#votes_count"+the_id).html(msg);
				
			}
		});
	});
	
	$(".upvotecomment").live("click",function(event){
	if(loggedIn == 0){
			$( "#logindialog" ).dialog({ title: 'Login or register to vote' });
			$('#logindialog').dialog('open');
			return;
		}
	//get the id
	the_id = $(this).parent().attr('id').substring(12);
	//save pack contents
	votePackContents = $("#votes_count"+the_id).parent().html();
	// show the spinner
	$("#votes_count"+the_id).html('<img src="images/spinner.gif"/>');
	//the main ajax request
		$.ajax({
			type: "POST",
			data: "action=upvote&commentid="+the_id,
			url: "commentVote.lol",
			success: function(msg)
			{
				
				//bring back the pack contents
				//alert(msg);
				$("span#votes_count"+the_id).parent().html(votePackContents);
				$("#upvote_button"+the_id).removeClass('upvotecomment');
				$("#upvote_button"+the_id).toggleClass('upvotecomment_gray');
				$("#downvote_button"+the_id).removeClass('downvotecomment');
				$("#downvote_button"+the_id).toggleClass('upvotecomment_gray');
				$("span#votes_count"+the_id).html(msg);
				
			}
		});
	});	
	
	$(".downvotecomment").live("click",function(event){
		if(loggedIn == 0){
			$( "#logindialog" ).dialog({ title: 'Login or register to vote' });
			$('#logindialog').dialog('open');
			return;
		}
	
	//get the id
	the_id = $(this).parent().attr('id').substring(12);
	
	//save pack contents
	votePackContents = $("#votes_count"+the_id).parent().html();
	// show the spinner
	$("#votes_count"+the_id).html('<img src="images/spinner.gif"/>');
	//the main ajax request
		$.ajax({
			type: "POST",
			data: "action=downvote&commentid="+the_id,
			url: "commentVote.lol",
			success: function(msg)
			{
				
				//bring back the pack contents
				//alert(msg);
				$("span#votes_count"+the_id).parent().html(votePackContents);
				$("#upvote_button"+the_id).removeClass('upvotecomment');
				$("#upvote_button"+the_id).toggleClass('downvotecomment_gray');
				$("#downvote_button"+the_id).removeClass('downvotecomment');
				$("#downvote_button"+the_id).toggleClass('downvotecomment_gray');
				$("span#votes_count"+the_id).html(msg);
				
			}
		});
	});
});
