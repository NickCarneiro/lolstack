
var votePackContents = '';
$(document).ready(function(){
	$("a.upvote").click(function(){
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
	
	$("a.downvote").click(function(){
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
				$("#upvote_button"+the_id).toggleClass('downvote_gray');
				$("#downvote_button"+the_id).removeClass('downvote');
				$("#downvote_button"+the_id).toggleClass('downvote_gray');
				$("span#votes_count"+the_id).html(msg);
				
			}
		});
	});
	
	$(".upvotecomment").click(function(){
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
	
	$(".downvotecomment").click(function(){
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
