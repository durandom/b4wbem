package Apache::TicketMaster;

use strict;

use Apache::Constants qw(OK SERVER_ERROR REDIRECT);
use Apache::TicketTool ();
use Apache::Paula;
use Apache::Utilities;

use CGI '-autoload';

use CIM::Utils;

sub handler
{
	my $r = shift;

	green("### TicketMaster.pm ##########################################\n");

	my $rc;

$rc = eval
{
	my ( $user, $pass ) = map { param($_) } qw(user password);
	
	my $ticketTool = Apache::TicketTool->new( $r );
	
	if( $user and $pass )
	{
		my ( $result, $msg ) = $ticketTool->authenticate( $user, $pass );
	
		LOG( "### (RC=$result) message from authenticate($user,****) is: $msg\n" );

		unless( $result )
		{
			if( $msg eq "MISMATCH" )
			{
				$msg =	"<br/><br/><h1><span style='color:red'>".
					"Es ist ein Fehler ist aufgetreten:".
					"</span></h1><br/><br/><br/><h2>Das eingegebene Passwort stimmt nicht!</h2>";

				sayInHTML( $r,	{
						Title	=> "Fehler",
						Message => "$msg",
						Request => "/paul-login",
						Delay	=> "3"
						} );
			}
			if( $msg =~ /^CIM::Error/ )
			{
				$msg =	"<br/><br/><h1><span style='color:red'>".
					"Es ist ein Fehler ist aufgetreten:".
					"</span></h1><br/><br/><br/><h2>Den Benutzer $user gibt es nicht!</h2>";

				sayInHTML( $r,	{
						Title	=> "Fehler",
						Message => "$msg",
						Request => "/paul-login",
						Delay	=> "3"
						} );
			}
			return OK;
		}

		if( $result )
		{
			my $ticket = $ticketTool->make_ticket( $r, $user );
			
			unless ($ticket)
			{
				$r->log_error("Couldn't make ticket -- missing secret?");
				return SERVER_ERROR;
			}
			
			print header(-refresh => "0; URL=/paul-admin", -cookie => $ticket),
			start_html(-title => 'Successfully Authenticated', -bgcolor => 'white'),
			end_html();
			
			return OK;
		}
	}
	
	make_login_screen();

	return OK;
	
}; # end of eval - exception-handling

	if( $@ )
	{
		sayInHTML( $r,	{
				Title	=> "Error",
				Message => "<br/><br/><h1><span style='color:red'>".
					"Ein Fehler ist aufgetreten:".
					"</span></h1><br/><br/><br/> $@"
				} );

		LOG( "*** exception raised in TicketMaster.pm: $@\n" );
		
		$rc = OK;	# return anyway
	}
	
	$r->child_terminate;
	
	green("### Ende von TicketMaster.pm ##########################################\n");

	return $rc;
}

sub make_login_screen
{
	my $linkName = $ENV{ LINK_NAME };
	
	my $scriptN = script_name();
	
	my $HTML = <<"EOF";
<table border="0" cellpadding="0" cellspacing="0" width="100%">
 <tr>
  <td align="center"><img src="/${linkName}/images/paul2.gif" width=129 height=64 alt="" border="0">
   <br>&nbsp;
  </td>
 </tr>
 <tr>
  <td align="center" valign="middle">
   <table border="0" cellpadding="10" cellspacing="0" bgcolor="#e6f0ff">
	<form onSubmit="prepForm();return false;">
	 <tr>
	  <td>
	   <font class="content">Login:</font>
	  </td>
	  <td>
	   <input type="text" size="30">
	  </td>
	 </tr>
	</form>
	<form action="$scriptN" method="post" onSubmit="prepForm(); return true;">
	 <tr>
	  <td>
	   <font class="content">Passwort:</font>
	  </td>
	  <td>
	   <input type="password" name="password" size="30">
	   <input type="hidden" name="user" value="">
	  </td>
	 </tr>
	 <tr>
	  <td align="left">&nbsp;</td>
	  <td align="right"><input type="submit" value="Login" size="20"></td>
	 </tr>
	</form>
   </table>
  </td>
 </tr>
 <tr>
  <td align="center">
   <br><img src="/${linkName}/images/id-pro.gif" width=130 height=50 alt="" border="0">
  </td>
 </tr>
</table>
EOF
	$HTML =~ s/\n/\\n/g;
	my $JSCRIPT_HEAD = <<EOF;
function init() {
  if (document.forms[0]) document.forms[0].elements[0].focus();
}

function prepForm() {
  document.forms[1].user.value = document.forms[0].elements[0].value;
  document.forms[1].password.focus();
}
EOF
	my $JSCRIPT_BODY = <<EOF;
if (top.frames.length > 0) {
  //document.write("<blockquote>Zugriffszeit abgelaufen...</blockquote>");
  //setTimeout("top.location.href=location.href",100);
  top.location.href=location.href;
} else {
  document.write('$HTML');
}
EOF

	print header(-link => [Link({ -rel => 'stylesheet', -href => '${linkName}/styles/style.css' })]),
	start_html(-title => 'PaulA Login',
		   -bgcolor => 'white',
		   -marginheight => '100',
		   -script=>$JSCRIPT_HEAD,
		   -onload => 'init()');
	print "<script>$JSCRIPT_BODY</script>";
	print end_html();
	
	return;
}

# called when the user tries to log in without a cookie
sub no_cookie_error
{
	print header(),
	start_html(-title => 'Unable to Log In', -bgcolor => 'white'),
	h1('Unable to Log In'),
	"This site uses cookies for its own security.  Your browser must be capable ", 
	"of processing cookies ", em('and'), " cookies must be activated. ",
	"Please set your browser to accept cookies, then press the ",
	strong('reload'), " button.", hr();
	
	return;
}

1;
__END__
