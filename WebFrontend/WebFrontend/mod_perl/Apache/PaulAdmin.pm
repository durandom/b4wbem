package Apache::PaulAdmin;

use Apache::Constants qw(:common);
use Apache::TicketTool ();
use Apache::Utilities;

use XML::Simple;
use CIM::Client;
use CIM::Utils;

use strict;
use CGI qw/:standard :html3 *table *Tr/;

sub handler
{
	my $r		= shift;

	white("### PaulAdmin.pm ##########################################\n");

	my $rc;
$rc = eval
{
	my $htmlStr  = "";
	my $linkName = $ENV{LINK_NAME};

	#
	# Create TicketTool-object for security check
	#
	
	my $ticketTool = Apache::TicketTool->new($r);

	#
	# Paste n copy from TicketAccess.pm
	#
	my($result, $msg) = $ticketTool->verify_ticket($r);
	
	LOG( "Result: $result -> Message: $msg\n" );
	
	unless( $result )
	{
		mark();
		# $r->internal_redirect('/paul-login');
		# <beta>
		print header( -refresh => "0; URL=/paul-login" ),
		start_html(-title => '$msg', -bgcolor => 'white'),
		end_html();
		# </beta>

		LOG( "redirect to /paul-login\n" );
		
		return OK;
	}
	
	#
	# otherwise create Pauls frames
	#
	$htmlStr = <<"EOF";
<html><head>
 <title>Paul</title>
</head>
<frameset border="0" rows="90,*">
 <frameset border="0" cols="150,500">
  <frame marginheight="0" marginwidth="0" name="paul" src="/$linkName/html/paul.html" scrolling="no">
  <frame marginheight="0" marginwidth="0" name="header" src="/$linkName/html/header.html" scrolling="no">
 </frameset>
 <frameset border="0" cols="150,500">
  <frame marginheight="0" marginwidth="0" name="menu" src="/paul-menu">
  <frame name="content" src="/$linkName/html/content.html" marginheight="0" marginwidth="0">
 </frameset>
</frameset> 
</html>
EOF
	
	$r->content_type('text/html');
	$r->send_http_header;
	$r->print($htmlStr);

	return OK;
	
}; # ende von eval - Exception-handling

	if( $@ )
	{
		#
		# maybe we should print out a message to the user
		#
		sayInHTML( $r,	{
				Title	=> "Logout",
				Message => "<br/><br/><h1><span style='color:red'>".
					"Leider ist ein Fehler aufgetreten:".
					"</span></h1><br/><br/><br/> $@"
				} );

		LOG( "*** exception raised in PaulAdmin.pm: $@\n" );
		$rc=OK;	# return anyway
	}
	
#	$r->child_terminate;
	
	white("### Ende von PaulAdmin.pm ##########################################\n");

	return $rc;
}

1;
