package Apache::TicketTool;

use strict;
use CGI::Cookie ();
use MD5 ();
use Apache::URI ();

use XML::Simple;
use CIM::Client;
use CIM::NamespacePath;
use CIM::MethodCall;
use CIM::Utils;

use Apache::Paula;
use Apache::Utilities;

# my $ServerName = Apache->server->server_hostname;

my %DEFAULTS = (
	'TicketExpires'  => 240,
	'TicketDomain'   => undef );

my %CACHE;  # cache objects by their parameters to minimize time-consuming operations

# Set up default parameters by passing in a request object
sub new
{
	my($class, $r) = @_;

	my %self = ();

	foreach (keys %DEFAULTS)
	{
		$self{ $_ } = $r->dir_config( $_ ) || $DEFAULTS{ $_ };
	}
	
	# post-process TicketDatabase and TicketDomain
	($self{TicketDomain} = $r->server->server_hostname)
	unless $self{TicketDomain};

	# try to return from cache
	my $id = join '', sort values %self;
	return $CACHE{$id} if $CACHE{$id};

	# otherwise create new object
	return $CACHE{$id} = bless \%self, $class;
} 

# TicketTool::authenticate()
# Call as:
# ($result,$explanation) = $ticketTool->authenticate($user,$passwd)
sub authenticate
{
	my( $self, $user, $passwd ) = @_;
	
#	my( $table, $userfield, $passwdfield ) = split ':', $self->{ TicketTable };

	#
	# Build a CIM Client cc according CIM-classes
	#

	my $cc = CIM::Client->new(UseConfig => 1);

	#
	# Check if Login-User exists
	#
	
	my $passwdOk;

	my $on = CIM::ObjectName->new( ObjectName => 'PaulA_User', KeyBindings => { Login => $user } );
	my $valueObj = CIM::Value->new( Type => 'string', Value => $passwd );
	my $p = CIM::ParamValue->new( Name => 'Password', Value => $valueObj );
	
	eval { $passwdOk = $cc->invokeObjectMethod( $on, 'Authenticate', $p ) };

	my $e = $@;
	if( $e )
	{
		if( ref $e && $e->isa( 'CIM::Error' ) )
		{
			# TODO:
			# Error
			return (undef, "CIM::Error-> $e")
		}
		else
		{
			die "nach invokeObjectMethod(Authenticate): $e";
		}
	}
	
	$passwdOk->type('boolean');
	LOG( "Result: ".$passwdOk->value()."\n" );
	
	return ( undef, "MISMATCH" ) unless ( $passwdOk->value() );
	
	return (1, '');
}

# TicketTool::fetch_secret()
# Call as:
# $ticketTool->fetch_secret();
sub fetch_secret
{
	my $self = shift;
	unless( $self->{ SECRET_KEY } )
	{
		$self->{ SECRET_KEY } = "w4RZt";
	}
	return $self->{ SECRET_KEY };
}

# invalidate the cached secret
sub invalidate_secret
{
	undef shift->{ SECRET_KEY };
}

# TicketTool::fetch_user()
# Call as:
# ($result, $user) = $ticketTool->fetch_user($r);
sub fetch_user
{
	my ( $self, $r ) = @_;
	
	my %cookies = CGI::Cookie->parse( $r->header_in( 'Cookie' ) );
	
	return ( 0, 'user has no cookie' ) unless %cookies;
	return ( 0, 'user has no ticket' ) unless $cookies{ 'Ticket' };
	
	my %ticket = $cookies{'Ticket'}->value;
	
	return ( 0, 'user unknown' ) unless $ticket{ 'user' };
	return ( 1, $ticket{ 'user' } );
}

# TicketTool::fetch_permission()
# Call as:
# ($result, $permission) = $ticketTool->fetch_permission($r);
sub fetch_permission
{
	my ( $self, $r ) = @_;

	my %cookies = CGI::Cookie->parse( $r->header_in('Cookie') );
	
	return ( 0, 'user has no cookie' ) unless %cookies;
	return ( 0, 'user has no ticket' ) unless $cookies{ 'Ticket' };
	
	my %ticket = $cookies{ 'Ticket' }->value;
	
	return ( 0, 'permission unknown' ) unless $ticket{ 'pe' };
	return ( 1, $ticket{ 'pe' } );
}

# TicketTool::make_ticket()
# Call as:
# $cookie = $ticketTool->make_ticket($r);
#
sub make_ticket
{
	my ( $self, $r, $user_name ) = @_;
	
	my $ip_address = $r->connection->remote_ip;
	
	my $expires = $self->{ TicketExpires };
	my $now = time;
	my $secret = $self->fetch_secret() or return undef;

	#
	# Retrieve the rights of a user
	#
	my %userRights = ();
	
	getAllRights( $user_name, \%userRights );
		
	my @tmp;
	foreach my $key ( keys %userRights )
	{
		push( @tmp, $key."_".$userRights{ $key } );
	}
	my $permission = join( ",", @tmp );
	
	# Create a hash
	my $ticket = join( ':', $secret, $ip_address, $now, $expires, $user_name, $permission);
	my $hash = MD5->hexhash( $secret. MD5->hexhash( $ticket ) );

	#
	# -domain => $self->{TicketDomain} ??? Doesn't work...
	#
	
	return CGI::Cookie->new(-name => 'Ticket',
				-path => '/',
				-value => {
				'ip' => $ip_address,
				'time' => $now,
				'user' => $user_name,
				'hash' => $hash,
				'expires' => $expires,
				'pe' => $permission,
				});
}

sub destroy_ticket
{
	my ( $self, $r, $user_name ) = @_;
	
	my $ip_address = $r->connection->remote_ip;
	my $expires = 0;
	my $now = time;
	
	return CGI::Cookie->new(-name => 'Ticket',
				-path => '/',
				-expires => '+1s',
				-value => '');
}

# TicketTool::verify_ticket()
# Call as:
# ($result,$msg) = $ticketTool->verify_ticket($r)
sub verify_ticket
{
	my ( $self, $r ) = @_;
	
	my %cookies = CGI::Cookie->parse( $r->header_in( 'Cookie' ) );
	
	return ( 0, 'user has no cookies') unless %cookies;
	return ( 0, 'user has no ticket') unless $cookies{'Ticket'};
	
	my %ticket = $cookies{'Ticket'}->value;
	
	return ( 0, 'malformed ticket')
	unless $ticket{'hash'} && $ticket{'user'} && 
		$ticket{'time'} && $ticket{'expires'} &&
		$ticket{'pe'};
	
	return ( 0, 'IP address mismatch in ticket')
	unless $ticket{'ip'} eq $r->connection->remote_ip;
	
	return (0, 'ticket has expired')
	unless (time - $ticket{'time'})/60 < $ticket{'expires'};
	
	my $secret;
	
	return (0, "can't retrieve secret") 
	unless $secret = $self->fetch_secret;
	
	my $test = join( ':', $secret,@ticket{ qw( ip time expires user pe ) } );
	my $newhash = MD5->hexhash($secret.MD5->hexhash( $test ) );

	unless( $newhash eq $ticket{'hash'} )
	{
		$self->invalidate_secret;  #maybe it's changed?
		return ( 0, 'ticket mismatched' );
	}
	
	$r->connection->user( $ticket{'user'} );
	
	return (1, 'ok');
}

# Call as:
# $cookie = $ticketTool->make_return_address()
sub make_return_address
{
	my($self, $r) = @_;
	
	my $uri = Apache::URI->parse($r, $r->uri);
	
	$uri->scheme("http");
	$uri->hostname($r->get_server_name);
	$uri->port($r->get_server_port);
	$uri->query(scalar $r->args);

	return CGI::Cookie->new(-name => 'request_uri',
				-value => $uri->unparse,
				-domain => $self->{TicketDomain},
				-path => '/');
}

1;
__END__
