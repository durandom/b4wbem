package Apache::Utilities;

use strict;

use CGI qw/:standard :html3 *table *Tr/;

use XML::Sablotron;

use CIM::Utils;

use vars qw(@ISA @EXPORT);

use Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(
	LOG
	LOGERROR
	sayInHTML
	showDocument
	getFirstTagNamed
	appendNewNode
	);


my	$debug = 1;

########################################################################
#
# showDocument( $r, $Document, $XSLFile );
#
# Parameter:
#	$r		- ???
#	$Document	- DOM::Document
#	$XSLFile	- string
#
# Result:
#	void
#
# Exceptions:
#	CIM-Exceptions
#	string
#

sub showDocument
{
	my ( $r, $Document, $XSLFile ) = @_;
	
	#
	# Now create the XML-string, that will be transformed
	#

	my $xmlStr = $Document->toString();
	
	my $tmp = $/;
	
	undef $/;
	open (IN, $XSLFile) or die "Cannot open XSL file: $XSLFile\n";
	my $xslStr = <IN>;
	close IN;
	
	$/ = $tmp;

	#
	# Merge XML with XSL to HTML, using Sablotron
	#

	my $htmlStr = "";
	XML::Sablotron::ProcessStrings($xslStr, $xmlStr, $htmlStr);

	$r->content_type('text/html');
	$r->send_http_header;
	$r->print($htmlStr);

} # showDocument();


########################################################################
# sayInHTML( $r,{ [<Key> => <Value>] } )
#
# Parameter:
#	$r		- ???
# 	$Options	- \%string
#
# Result:
#	allways true(1)
#
# Exceptions:
#	CIM-Exceptions
#
sub sayInHTML
{
	my ( $r, $Options ) = @_;
	my $Title	= "";
	my $Message	= "";
	my @header	= ();
	
	if( exists $Options->{ Request } )
	{
		my $delay = exists $Options->{ Delay } ? ($Options->{ Delay }) : "0";
		
		push @header, "-Refresh", "$delay; URL=".$Options->{ Request };
	}
	if( exists $Options->{ Destroy } )
	{
		# copied from TicketTool
		
		my $ip_address = $r->connection->remote_ip;
		my $destroy_ticket = CGI::Cookie->new(-name => 'Ticket',
			    -path => '/',
			    -expires => '+1s',
			    -value => '');

		push @header, "-cookie", "$destroy_ticket";
	}
	if( exists $Options->{ Title } )	{ $Title = $Options->{ Title }; }
	if( exists $Options->{ Message } )	{ $Message = $Options->{ Message }; }
	
	print header( @header ),
	start_html(-title => '$Title', -bgcolor => 'white');
	print "<br><blockquote>$Message</blockquote>";
	print end_html();
	
	return 1;

} # sayInHTML()


########################################################################
#
# $Node = getFirstTagNamed( $Tag, $Name, $Node, $Recurse );
#
# Parameter:
#	$Tag	- string
#	$Name	- string
#	$Node	- XML::DOM::Node|Element
#	$Recurse- boolean
#
# Result:
#	$Node		- XML::DOM::Node|undef
#
# Exceptions:
#
# Description:
#	This function returns the first tag <$Tag> which has an
#	attribute name set to "$Name"; for eg.:
#
#	$Node = getFirstTagNamed( "node", "myNode", $AnyNode, 1 );
#
#	<node name="xy">Any data...</node>
#	<node name="foo">
#		<node name="myNode">...</node>	# <--- returns this node
#	</node>
#
#	if $AnyNode "pointed" to the first node "xy".
#
#	If $Name is undef, the first tag <$Tag> is returned.
#
sub getFirstTagNamed
{
	my ( $Tag, $Name, $Node, $Recurse ) = @_;

	foreach ( $Node->getElementsByTagName( "$Tag", $Recurse ) )
	{
		if( $Name )
		{
			if( $_->getAttribute( "name" ) eq "$Name" )
			{
				return $_;
			}
		}
		else
		{
			return $_;
		}
	}
	
	return undef();
} # getFirstTagNamed

########################################################################
#
# $NewNode = appendNewNode( $CurrentNode, $NodeName, $Attributes_ref );
#
# Parameter:
#	$CurrentNode	- XML::DOM::Node
#	$NodeName	- string
#	$Attributes	- { <key> => <value> }
#
# Result:
#	$NewNode	- XML::DOM::Node
#
# Exceptions:
#	???
sub appendNewNode
{
	my ( $CurrentNode, $NodeName, $Attributes_ref ) = @_;
	
	my $doc		= $CurrentNode->getOwnerDocument();
	my $newNode	= $doc->createElement( $NodeName );
	
	foreach my $key ( keys %$Attributes_ref )
	{
		$newNode->setAttribute( $key, $Attributes_ref->{ $key } );
	}
	
	$CurrentNode->appendChild($newNode);

	return $newNode;
} # appendNewNode


########################################################################
sub LOG
{
	if( $debug )
	{
		print STDERR @_;
	}
}


########################################################################
# boolean $error = _LOGERROR( < $@ | undef >, <message[s]>... );
#
# example;
#	eval { $x = log($y); }
#	_LOGERROR( $@, "no negative values allowed!" ) and die("math-error!");
#
#
sub LOGERROR
{
	my $error = shift;
	my @paras = @_;
	
	if( $error )
	{
		LOG( "*** an error occured:\n".join("",@_) );
		LOG( "\nException: ".present($error)."\n" );
		return 1;
	}
	
	return 0;
}


1;
