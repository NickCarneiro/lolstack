$(document).ready(function(){
	$(".formattinghelp").live('click', function () {
		$( "#formattingdialog" ).dialog({ title: 'Style your posts' });
			$('#formattingdialog').dialog('open');
			$( "#formattingdialog" ).dialog( "option", "width", 650 );
			$( "#formattingdialog" ).dialog( "option", "position", 'bottom' )
	});
});