package Apache::PaulGetCim;

use XML::DOM;
use Apache::Constants qw(OK FORBIDDEN REDIRECT);
use Apache::TicketTool;

use Apache::Utilities;
use Apache::Paula;
use CIM::Utils;

use strict;
use CGI qw/:standard :html3 *table *Tr/;

#
# For safty reasons we check the entire handler for any exceptions and
# thus can guarantee proper exit states from this module - even a die()
# within subroutines is safe
#

sub handler
{
	my $r = shift;

	green("### PaulGetCim.pm ##########################################\n");

	my $frontendHome = $ENV{WEBFRONTEND_HOME};
	my ( $rc, $user );

$rc = eval 
{

	
	#
	# There are two different xsl-files: one for read-only, the other one for
	# read/write permission - it depents on 'Paula_Rights' which one will be used.
	#
	# append [r|w].xsl
	#
	
	my $xslFile = "paula_";
	
	# Get CGI-parameters

	my @params = split( "_", param('form'), 2 );	# even a ADMIN_paula_user should work!
	my $form = $params[0];
	my $classifier = $params[1] ? $params[1] : "";

	#
	# Create TicketTool-object for security check
	#
    
	my $ticketTool = Apache::TicketTool->new($r);
	my $result;
	( $result, $user ) = $ticketTool->fetch_user($r);

	return FORBIDDEN unless $result;

	my $msg;
	( $result, $msg ) = $ticketTool->verify_ticket($r);	
	unless( $result )
	{
		sayInHTML( $r,	{
				Title	=> "Authentifiziert",
				Message => "$msg",
				Request => "/paul-login",
				Delay	=> "1",
				Destroy	=> "$user"
				} );
		return OK;
	}

	#
	# Logout if form eq LOGOUT
	#

	if ($form eq 'LOGOUT')
	{
		sayInHTML( $r,	{
				Title	=> "Logout",
				Message => "Bye...",
				Request => "/paul-admin",
				Delay	=> "1",
				Destroy	=> "$user"
				} );
		return OK;
	}






	####################################################
	# Check if Request is allowed according Paula_Rights
	####################################################

  	my $permission = $ticketTool->fetch_permission($r);
	#my $accessMode = requestRight( $user, $classifier, $form );
	my $accessMode = requestRight( $user, $classifier, $form, $permission);
	
	if( $accessMode eq "n" )
	{
		sayInHTML( $r,	{
				Title	=> "*** Zugriff verweigert!",
				Message	=> "Keine Zugriffsrechte!"
				}
		);
		return OK;
	}
	else
	{
		# append correct extention for xsl-file
		
		$xslFile .= $accessMode.".xsl";
		
	}

	################
	# Access granted
	################



	################################################################
	#
	# <Main>
	#
	################################################################
	
	
	my $fd = getFormDocument( $form, $classifier, $frontendHome."/xml/paula.xml" );
	
	showDocument( $r, $fd, $frontendHome."/xml/".$xslFile );
	
	$fd->dispose();
	
	return OK;

	################################################################
	#
	# </Main>
	#
	################################################################

}; # end of eval-block

	if( $@ )
	{
		#
		# maybe we should print out a message to the user
		#
		sayInHTML( $r,	{
				Title	=> "Logout",
				Message => "<br/><br/><h1><span style='color:red'>".
					"Leider ist bei der Verarbeitung Ihrer Eingaben ein Fehler aufgetreten:".
					"</span></h1><br/><br/><br/> $@"
				} );

		LOG( "*** exception raised in PaulGetCim.pm: $@\n" );
		$rc=OK;	# return anyway
	}
	
	$r->child_terminate;	#????????
	
	green("### Ende von PaulGetCim.pm #################################\n");
	
	return $rc;
}

1;
