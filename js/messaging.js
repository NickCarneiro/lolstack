var comPage = 1;
var picPage = 1;
var pmPage = 1;

function loadComments(direction){

	//show spinner
	$('#comSpinner').css('display','inline');
	//increment or decrement current page, depending on direction
	 comPage += (direction.indexOf('old') > -1) ? 1 : -1;
	 //reset page to 1 if less than 1
	 comPage = (comPage < 1) ? 1 : comPage;
	 //hide newer button if page is 1
	 if(comPage == 1){
		$('#commentsNewer').css('display','none');
	 } else {
		$('#commentsNewer').css('display','inline');
	 }
	 
	 //undo increment if last page reached
	 comPage = (comPage > lastComPage) ? comPage - 1 : comPage;
	 //hide older button if on last page
	 if(comPage == lastComPage){
		$('#commentsOlder').css('display','none');
	 } else {
		$('#commentsOlder').css('display','inline');
	 }
	 
	//load older comments
	$.post("messagingData.lol", { type: "commentReply", comPage: comPage },
   function(data){
		//print returned rows
    // alert("Data Loaded: " + data);
	 
	
	 //comPage += 1;
	 //hide spinner
	$('#comSpinner').css('display','none');
	 //replace rows with response
	 if(data.indexOf('<error>') > -1){
		alert('error: ' + data.between('<error>','</error>'));
	 } else {
		$('#comReplyList').html(data);
	 }
	 
   });
}

function loadPicComments(direction){

	//show spinner
	$('#picSpinner').css('display','inline');
	//increment or decrement current page, depending on direction
	 picPage += (direction.indexOf('old') > -1) ? 1 : -1;
	 //reset page to 1 if less than 1
	 picPage = (picPage < 1) ? 1 : picPage;
	 //hide newer button if page is 1
	 if(picPage == 1){
		$('#picCommentsNewer').css('display','none');
	 } else {
		$('#picCommentsNewer').css('display','inline');
	 }
	 
	 //undo increment if last page reached
	 picPage = (picPage > lastPicPage) ? picPage - 1 : picPage;
	 //hide older button if on last page
	 if(picPage == lastPicPage){
		$('#picCommentsOlder').css('display','none');
	 } else {
		$('#picCommentsOlder').css('display','inline');
	 }
	 
	//load older comments
	$.post("messagingData.lol", { type: "picCommentReply", picPage: picPage },
   function(data){
		//print returned rows
    // alert("Data Loaded: " + data);
	 
	
	 //picPage += 1;
	 //hide spinner
	$('#picSpinner').css('display','none');
	 //replace rows with response
	 if(data.indexOf('<error>') > -1){
		alert('error: ' + data.between('<error>','</error>'));
	 } else {
		$('#picReplyList').html(data);
	 }
	 
   });
}

function loadPrivateMessages(direction){

	//show spinner
	$('#pmSpinner').css('display','inline');
	//increment or decrement current page, depending on direction
	 pmPage += (direction.indexOf('old') > -1) ? 1 : -1;
	 
	 //hide newer button if page is 1
	 if(picPage == 1){
		$('#privateMessagesNewer').css('display','none');
	 } else {
		$('#privateMessagesNewer').css('display','inline');
	 }
	 
	 //undo increment if last page reached
	 pmPage = (pmPage > lastPmPage) ? picPage - 1 : picPage;
	 //reset page to 1 if less than 1
	 pmPage = (pmPage < 1) ? 1 : pmPage;
	 //hide older button if on last page
	
	 if(pmPage == lastPmPage){
		$('#privateMessagesOlder').css('display','none');
	 } else {
		$('#privateMessagesOlder').css('display','inline');
	 }
	 
	//load older comments
	$.post("messagingData.lol", { type: "privateMessage", pmPage: pmPage },
   function(data){
		//print returned rows
    // alert("Data Loaded: " + data);
	 
	
	 //picPage += 1;
	 //hide spinner
	$('#pmSpinner').css('display','none');
	 //replace rows with response
	 if(data.indexOf('<error>') > -1){
		alert('error: ' + data.between('<error>','</error>'));
	 } else {
		$('#privateMessages').html(data);
	 }
	 
   });
}

$(document).ready(function(){
	
	 
	lastComPage = $('#lastComPage').attr('value');
	lastPicPage = $('#lastPicPage').attr('value');
	lastPmPage = $('#lastPmPage').attr('value');
	if(pmPage == lastPmPage){
		$('#privateMessagesOlder').css('display','none');
	 } else {
		$('#privateMessagesOlder').css('display','inline');
	 }
	 if(picPage == lastPicPage){
		$('#picCommentsOlder').css('display','none');
	 } else {
		$('#picCommentsOlder').css('display','inline');
	 }
	 if(comPage == lastComPage){
		$('#commentsOlder').css('display','none');
	 } else {
		$('#commentsOlder').css('display','inline');
	 }
	 
	 if(comPage == 1){
		$('#commentsNewer').css('display','none');
	 } else {
		$('#commentsNewer').css('display','inline');
	 }
	 
	 if(picPage == 1){
		$('#picCommentsNewer').css('display','none');
	 } else {
		$('#picCommentsNewer').css('display','inline');
	 }
	 
	 if(pmPage == 1){
		$('#privateMessagesNewer').css('display','none');
	 } else {
		$('#privateMessagesNewer').css('display','inline');
	 }
	 
	 /*
	 
		*/
});