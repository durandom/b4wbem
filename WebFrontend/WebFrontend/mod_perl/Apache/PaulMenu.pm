package Apache::PaulMenu;

use strict;

use Apache::Constants qw(:common);
use Apache::TicketTool ();
use Apache::Paula;
use Apache::Utilities;

use CGI qw/:standard :html3 *table *Tr/;

use CIM::Utils;

sub handler
{

	my $r = shift;

	blue("### PaulMenu.pm ##########################################\n");


	my $htmlStr  = "";
	my $frontendHome = $ENV{WEBFRONTEND_HOME};

	my $rc;

$rc = eval
{
	#
	# Build the tree depending on who is user
	#
	
	my $ticketTool = Apache::TicketTool->new($r);
	my ($result, $user) = $ticketTool->fetch_user($r);
	
	return FORBIDDEN unless $result;
	
	LOG("User in PaulMenu: ".$user."\n");
	
	#
	# Retrieve the mask-permissions
	#
		
  	my $permissions = $ticketTool->fetch_permission($r);
	
	#
	# Load XML-File, extract the nodes and parse them to DOM::Document
	# ( insert generated menuitems if a submenu is open )
	#
	
	my $opensubmenu = param('submenu') ? param('submenu') : "";

	my $mdoc = getMenuDocument( $opensubmenu, $user, $frontendHome."/xml/paula.xml", $permissions );

	showDocument( $r, $mdoc, $frontendHome."/xml/menu.xsl" );
	
	$mdoc->dispose();
	
	return OK;

}; # eval()

	if( $@ )
	{
		if( !(ref $@) && "$@" =~ /^NOCIMOM/ )
		{
			sayInHTML( $r,	{
					Title	=> "Cimom-Error",
					Message => "<br/><br/><h1><span style='color:red'>".
						"Es konnte keine Verbindung zum CIM-Server aufgebaut werden!<br/>".
						"Bitte kontaktieren Sie Ihren Systemadministrator.".
						"</span></h1><br/><br/><br/>"
					} );
		}
		else
		{
			print( "*** exception raised in PaulMenu.pm: $@\n" );
			
			LOG( "*** exception raised in PaulMenu.pm: $@\n" );
		}
		
		$rc=OK;	# return anyway
	}
	
	$r->child_terminate;
	
	blue("### Ende von PaulMenu.pm ##########################################\n");

	return $rc;

} # handler()


1;
