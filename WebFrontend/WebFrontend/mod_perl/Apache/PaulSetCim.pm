package Apache::PaulSetCim;

use Apache::Constants qw(:common);
use Apache::TicketTool ();

use strict;
use CGI qw/:standard :html3 *table *Tr/;

use CIM::Utils;

use Apache::Utilities;
use Apache::Paula;


sub handler

{
	my $r		= shift;

	red("### PaulSetCim.pm ##########################################\n");

	my $rc;
	
$rc = eval
{
	my $frontendHome = $ENV{WEBFRONTEND_HOME};
	my $htmlStr  = "";

	#
	# Create TicketTool-object for security check
	#
	
	my $ticketTool = Apache::TicketTool->new($r);

	my ( $result, $user ) = $ticketTool->fetch_user($r);

	return FORBIDDEN unless $result;

	my $msg;
	($result, $msg) = $ticketTool->verify_ticket($r);
	unless ($result)
	{
		sayInHTML( $r,	{
				Title	=> "Authentifiziert",
				Message => "$msg",
				Request => "/paul-login",
				Delay	=> "2",
				Destroy	=> "$user"
				}
		) and return OK;
	}
	
	my @paramarr;
	foreach my $key ( param() )
	{
		my $paramStr .= $key."=".param( $key );
		push( @paramarr, $paramStr );
	}
	LOG( "params: ".join( "&", @paramarr)."\n" );

	#
	# Get CGI-parameters - only the sexy ones ;)
	#
	
	my $modifiedProperties = param( "ModifiedProperties" );
	
	my %param = ();
	foreach my $id ( split( "::", $modifiedProperties ) )
	{
		$param{ $id } = param( $id );
	}
		
	LOG("Modified Values:\n");
	for (keys %param)
	{
		LOG( "\t$_ = ".$param{"$_"}."\n");
	}

	my ($form, $classifier) = split( "_", param( "form" ), 2 );
	
	#
	# add user, form and classifier to parameter hash!
	#
	$param{ User } = $user;
	$param{ Form } = $form;
	$param{ Classifier } = $classifier;
	
	LOG("\nForm: $form und Classifier: $classifier\n");



	####################################################
	# Check if Request is allowed according Paula_Rights
	#
	# should be y - otherwise it was a hacked "post"
	####################################################
	
  	my $permission = $ticketTool->fetch_permission($r);
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

	################
	# Access granted
	################

	my $error = setFormDocument( \%param );
	
	if( $error )
	{
		sayInHTML( $r,	{
			Title	=> "Logout",
			Message => "<br/><br/><h1><span style='color:orange'>".
				"Leider ist bei der Verarbeitung Ihrer Eingaben ein Fehler aufgetreten:".
				"</span></h1><br/><br/><br/> $error"
			} );

	}
	else
	{
		sayInHTML( $r,	{
			Title	=> "Ok",
			Message	=> "<br/><br/><br/><h2><span style='color:green'>".
				"Die Daten wurden erfolgreicht bearbeitet".
				"</span><h2>"
			}
		);
	}


	return OK;

}; #------------------------------------- eval

	if( $@ )
	{
		my $diemsg = "<pre> $@ </pre><br/>";
		
		sayInHTML( $r,	{
			Title	=> "Logout",
			Message => "<br/><br/><h1><span style='color:red'>".
				"Es ist ein kritischer Fehler aufgetreten:".
				"</span></h1><br/><br/><br/>".
				$diemsg.
				"<br/><br/><h3>Bitte melden Sie sich bei Ihrem Systemadministrator!</h3>"
			} );

		LOG( "*** exception raised in PaulGetCim.pm: $diemsg\n" );
		$rc=OK;	# return anyway
	}
	
	$r->child_terminate;	#????????
	
	red("### Ende von PaulSetCim.pm #################################\n");
	
	return $rc;

} ####################################### end of handler()

1;
