package Apache::Forms;
use strict;

use Apache::Utilities;
use Apache::FullQualifiedName;

use XML::DOM;
use XML::Simple;

use CIM::Client;
use CIM::Utils;

use vars qw(@ISA @EXPORT);
@ISA = qw(Exporter);
@EXPORT = qw( getFormFunction );

########################################################################
#
# The signature of get-methods should look like this:
#
# $reply = get_<formName>( $CimClient, $Classifier, $FQNs_ref )
#
# Parameter:
#	$CimClient	- CIM::CimClient
#	$Classifier	- string
#	$FQNs_ref	- [ <FQN>, ... ]
#
# Result:
#	$reply		- { <FQN> => <CIM::Property> }
#
# Exceptions:
#	CIM-Exceptions
#
########################################################################

########################################################################
#
# The signature of set-methods should look like this:
#
# $errormsg = set_<formName>( $CimClient, $Classifier, $FQNValues_ref, $PropDefs_ref )
#
# Parameter:
#	$CimClient	- CIM::CimClient
#	$Classifier	- string
#	$FQNValues_ref	- { <FQN> => <Value> }
#	$PropDefs_ref	- { <FQN> => { ... } }
#
# Result:
#	$errormsg	- undef | string
#
# Exceptions:
#	CIM-Exceptions
#
########################################################################



########################################################################
#
# Default functions, suitable for most functions
#
########################################################################

sub get_Default
{
	my ( $CimClient, $Classifier , $FQNs_ref ) = @_;
	
	red("in get_Default()\n");

	my ( $on, $i );

	my $reply_ref = ();
	my @regularProperties;
	
	#
	# first get all "enumeration" properties
	#
	
	foreach my $FQN ( @$FQNs_ref )
	{
		my $fqn = Apache::FullQualifiedName->new( $FQN );
		
		if( $fqn->isEnumeration() )
		{
			my $property = getEnumerated( $CimClient, $fqn );

			$reply_ref->{ $FQN } = $property;
		}
		else
		{
			push( @regularProperties, $FQN );
		}
	}
	
	#
	# - Properties müssen nach Klassen "sortiert" werden
	# - für jede Klasse muss eine Anfrage gestartet werden (evtl. Fehlerbehandlung)
	# - die Werte müssen in das Hash eingetragen werden
	#
	
	#
	# %cimClasses_ref = { <classFQN> => [ <PropertyName>...] }
	#
	# A classFQN is a full qualified name with a dummy identifier. We need this to
	# keep the keybindings for this class ( if there are any )
	#

	my $cimClasses_ref = getClasses( \@regularProperties );

	LOG( "cimClasses: \n".present($cimClasses_ref)."\n" );
	
	foreach my $cFQN ( keys %$cimClasses_ref )
	{
		my $cfqn	= Apache::FullQualifiedName->new( $cFQN );
		my $class	= $cfqn->getClass();
		my $keys	= $cfqn->getKeybindings();
		
		if( $class eq "Frontend" )
		{
			createFrontendProperty( $cimClasses_ref->{ "Frontend" }, $reply_ref, $Classifier );
			
			next;
		}
		
		LOG("get properties of $class\n");

		if( defined $keys->[0] )
		{
			my $keybindings	= {};
			my @classifier	= split( "_", $Classifier );
			
			LOG( "Keybindings: >". join( ", ", @classifier ) ."\n" );
			
			foreach my $key ( sort @$keys )
			{
				my $c = shift @classifier ;
				
				$keybindings->{ $key } = $c if( defined $c && $c ne "" );
			}
			$on = CIM::ObjectName->new( ObjectName  => $class, KeyBindings => $keybindings );
		}
		else
		{
			$on = CIM::ObjectName->new( ObjectName  => $class );
		}


		LOG( "requested properties of $cFQN:\n\t".join(", ",@{$cimClasses_ref->{ $cFQN }})."\n");

		$i = $CimClient->GetInstance( InstanceName => $on, PropertyList => $cimClasses_ref->{ $cFQN } );

		foreach my $property ( @{$i->properties()} )
		{
			#
			# we know these properties are no enumerations, and regular properties
			# except for PaulA_User have no keybinding; but the mapping for
			# PaulA_User properties ignores this. So, restoring the FQN is no wizards
			# work: we have the classname, the identifier, no enumeration and no keybindings
			#
			my $fqn = Apache::FullQualifiedName->new( $class, $property->name(), 0, @$keys );
			
			$reply_ref->{ $fqn->toString() } = $property;
		}
	}
	
	return $reply_ref;

} # get_Default()


sub set_Default
{
	my ( $CimClient, $Classifier , $FQNValues_ref, $PropDefs_ref ) = @_;

	red("in set_Default()\n");
	
	my ( $on, $i, $vo );
	my $cimClasses_ref = getClasses( [keys %$FQNValues_ref] );

	LOG( "cimClasses: ".present($cimClasses_ref)."\n" );

	foreach my $cFQN ( keys %$cimClasses_ref )
	{
		LOG( "Request for $cFQN ...\n" );
		
		my $cfqn	= Apache::FullQualifiedName->new( $cFQN );
		my $class	= $cfqn->getClass();
		my $keys	= $cfqn->getKeybindings();

		my $propObjects = ();
		
		# Frontend-Klassen nicht bearbeiten - nur für den Fall, daß
		# get_Default von anderen Funktionen benutzt wird!
		
		if( $class eq "Frontend" )
		{
			next;
		}
		
		$propObjects = createPropertyObjects( $cFQN, $cimClasses_ref, $FQNValues_ref, $PropDefs_ref );

		if( defined $keys->[0] )
		{
			my $keybindings	= {};
			my @classifier	= split( "_", $Classifier );
			
			foreach my $key ( sort @$keys )
			{
				$keybindings->{ $key } = shift @classifier;
			}
			
			LOG( "Keybindings are:\n".present($keybindings)."\n" );
			
			$on = CIM::ObjectName->new(
					ObjectName => $class,
					ConvertType => 'INSTANCENAME',
					KeyBindings => $keybindings );
		}
		else
		{
			$on = CIM::ObjectName->new(
					ObjectName => $class,
					ConvertType => 'INSTANCENAME' );
		}

		$i  = CIM::Instance->new( ClassName => $class, Property => $propObjects );

		$vo = CIM::ValueObject->new( ObjectName => $on, Object => $i );
		
		$CimClient->ModifyInstance(ModifiedInstance => $vo);
	}

	return undef;
	
} # set_Default()


########################################################################
#
# get-functions
#
########################################################################



sub get_CREATEGROUP
{
	my ( $CimClient, $Classifier , $FQNs_ref ) = @_;
	
	red("in get_CREATEGROUP()\n");
	
	$Classifier = "paula_user";
	
	my $reply_ref = get_ADMINGROUPS( $CimClient, $Classifier , $FQNs_ref );
	
	return $reply_ref;

} # get_CREATEGROUP()


sub get_USERFAX
{
	my ( $CimClient, $Classifier , $FQNs_ref ) = @_;
	
	red("in get_USERFAX()\n");

	my $reply_ref = get_Default( $CimClient, $Classifier , $FQNs_ref );
	
	my $vfeFQN	= Apache::FullQualifiedName->new( "PaulA_Fax", "ValidFaxExtensions", 0 )->toString();
	my $feFQN	= Apache::FullQualifiedName->new( "PaulA_User", "FaxExtensions", 0, "Login" )->toString();
	
	my $vfe		= $reply_ref->{ $vfeFQN }->value()->valueAsRef();
	my $fe		= $reply_ref->{ $feFQN }->value()->valueAsRef();
	
	
	# it would be nice if one could write if( @fe in @vfe ), hmm....
	
	for( my $i=0; $i < scalar @$fe; $i++ )
	{
		my $found = 0;
		
		foreach my $vfaxNo ( @$vfe )
		{
			if( $vfaxNo == $fe->[ $i ] )
			{
				$found = 1;
				last;
			}
		}
		if( ! $found )
		{
			$fe->[ $i ] .= " - unbrauchbar";
		}
	
	}
	
#	$reply_ref->{ $feFQN } = $fe;
	
	return $reply_ref;

} # get_USERFAX()


sub get_FAX
{
	my ( $CimClient, $Classifier , $FQNs_ref ) = @_;

	red("in get_FAX()\n");

	my $reply_ref = get_Default( $CimClient, $Classifier , $FQNs_ref );
		
	my $faxExFQN	= Apache::FullQualifiedName->new( "PaulA_Fax", "ValidFaxExtensions", 0 )->toString();
	my $baseNoFQN	= Apache::FullQualifiedName->new( "PaulA_Fax", "BaseNumber", 0 )->toString();
	my $exRangeFQN	= Apache::FullQualifiedName->new( "Frontend", "ExtensionRange", 0 )->toString();
	my $useBaseFQN	= Apache::FullQualifiedName->new( "Frontend", "UseBaseNumber", 0 )->toString();
	
		
	#
	# Wenn es eine Rufnummer (BaseNumber) gibt, dann handelt es sich um einen Anlagenanschluss.
	# In diesem Fall werden die kleinste und die größte Durchwahlnummer (ValidFaxExtensions)
	# ermittelt und in FaxMin/MaxExt geschrieben und außerdem UseBaseNumber auf true (1) gesetzt
	#
	
	if( $reply_ref->{ $baseNoFQN }->value() )
	{
		
		my $faxExtensions = $reply_ref->{ $faxExFQN }->value()->valueAsRef();	# !?!?!?!?! array ref
		
		my @numbers	= sort @$faxExtensions;
		my $maxIndex	= $#numbers;
		
		$reply_ref->{ $exRangeFQN } = createStringProperty( $exRangeFQN, join( "::", $numbers[ 0 ], $numbers[ $maxIndex ] ) );
		$reply_ref->{ $useBaseFQN } = createStringProperty( $useBaseFQN, 1 );
		
		delete $reply_ref->{ $faxExFQN };
	}
	else	# UseBaseNumber = 0
	{
		$reply_ref->{ $exRangeFQN } = createStringProperty( $exRangeFQN, "" );
		$reply_ref->{ $useBaseFQN } = createStringProperty( $useBaseFQN, 0 );
	}
	
	return $reply_ref;
}


sub get_DEFAULTMAILSERVEROUT
{
	my ( $CimClient, $Classifier , $FQNs_ref ) = @_;

	red("in get_DEFAULTMAILSERVEROUT()\n");

	my $reply_ref = get_Default( $CimClient, $Classifier , $FQNs_ref );
	
	#
	# there are only two properties and one is a frontend property: "UseRelayHost"
	# ( just as a reminder: frontend properties are not evaluated in get_Default()!! )
	#
	my ( $FQN, $relayHostProp );
	foreach ( @$FQNs_ref )
	{
		if( exists $reply_ref->{ $_ } )
		{
			$relayHostProp = $reply_ref->{ $_ };
		}
		else
		{
			$FQN = $_;	# yeah, finally found my property ;))
		}
	}
	
	my $relayHost = "";
	if( defined $relayHostProp->value() )
	{
		$relayHost = $relayHostProp->value()->value();
	}
	
	$reply_ref->{ $FQN } = createStringProperty( $FQN, ( $relayHost eq "" ? 0 : 1 ) );
	
	return $reply_ref;
}



sub get_USERSECURITY
{
	my ( $CimClient, $Classifier , $FQNs_ref ) = @_;
	
	red("in get_USERSECURITY()\n");

	my $result_ref = get_Default( $CimClient, $Classifier , $FQNs_ref );
	
	my $fqn = Apache::FullQualifiedName->new( "PaulA_System", "ValidLoginShells", 0 );
	
	my $property = $result_ref->{ $fqn->toString() };
	
	my $values = $property->value()->valueAsRef();
	
	my $newValues = ();
	
	foreach my $shell ( @$values )
	{
		$shell =~ /(.*)\/(.+)/;
		my $text = $2;
		
		if( $shell eq "/bin/false" )
		{
			$text = "--- keine ---";
		}
		
		push( @{ $newValues }, { Text => $text, Value => $shell } );
	}
	
	LOG( "Shells:".present( $newValues)."\n" );
	
	$property->value()->value( $newValues );
	
	return $result_ref;
}


sub get_PAULAMENU
{
	my ( $CimClient, $Classifier , $FQNs_ref ) = @_;
	
	red("in get_PAULA()\n");
	
	# $reply_ref = <FQN> => <Property>
	my $reply_ref = ();
	#
	# The menu has several submenus with enumerated instances:
	# 	- AllUsers in the user-menu and
	# 	- AllGroups in the administration/grouprights-menu
	#	- AllOutgoingDomains
	#	- AllIncomingServers
	#
	
	foreach my $FQN ( @$FQNs_ref )
	{
		my $fqn = Apache::FullQualifiedName->new( $FQN );
		
		my $property = getEnumeratedKeybindings( $CimClient, $fqn );
		$reply_ref = { $FQN => $property };
		
	} # foreach...
	
	return $reply_ref;
}


sub get_DELETEMAILSERVERIN
{
	my ( $CimClient, $Classifier , $FQNs_ref ) = @_;
	
	red("in get_DELETEMAILSERVERIN\n");
	
	my $fqn;
	foreach ( @$FQNs_ref )
	{
		$fqn = Apache::FullQualifiedName->new( $_ );
		last;	# there should be only one cimproperty; anyway
	}
	
	my $property = getEnumeratedKeybindings( $CimClient, $fqn );
	
	LOG("Instance:\n $property \n");
	
	my $values = $property->value()->valueAsRef();	# \@string
	
	my $newValues = ();	# \@HASH ; [ { Text => <text>, Value => <value> } ]
	foreach my $xmlStr ( @$values )
	{
		my $hash	= XMLin( $xmlStr );
		my $text	= $hash->{ ServerName }."( ".$hash->{ Login }." )";
		my $value	= "_".$hash->{ Login }."_".$hash->{ ServerName };	# ATTENTION: sorted alphabetically
		
		push( @{ $newValues }, { Text => $text, Value => $value } );
	}
	
	$property->value()->value( $newValues );	# sets new values
	
	return { $fqn->toString() => $property };
}


sub get_ADMINGROUPS
{
	my ( $CimClient, $Classifier , $FQNs_ref ) = @_;
	
	red("in get_ADMINGROUPS()\n");

	my $reply_ref = {};

	foreach my $FQN ( @$FQNs_ref )
	{
		my $fqn = Apache::FullQualifiedName->new( $FQN );
		
		if( $fqn->equals( "PaulA_Group", "Permissions" ) )
		{
			my $on = CIM::ObjectName->new( ObjectName  => "PaulA_Group", KeyBindings => { Name => $Classifier } );

			my $i = $CimClient->GetInstance( InstanceName => $on, PropertyList => [ "Permissions" ] );

			# there is only one Permissions-property - anyway
			foreach my $property ( @{$i->properties()} )
			{
				my $value;

				$reply_ref->{ $FQN } = $property;
			}
		}
		elsif( $fqn->getClass() eq "Frontend" )
		{
			createFrontendProperty( [ $fqn->getIdentifier() ], $reply_ref, $Classifier );

		}
	}
	
	return $reply_ref;
}


########################################################################
#
# set-functions
#
########################################################################

sub set_CREATEGROUP
{
	my ( $CimClient, $Classifier , $FQNValues_ref, $PropDefs_ref ) = @_;

	red("in set_CREATEGROUP()\n");
	
	my $newGroupFQN	= Apache::FullQualifiedName->new( "PaulA_Instance", "Create_Group", 0 )->toString();
	my $permFQN	= Apache::FullQualifiedName->new( "Frontend", "NewPermissions", 0 )->toString();
	
	my $groupName	= $FQNValues_ref->{ $newGroupFQN };
	my $permissions	= $FQNValues_ref->{ $permFQN };
	
	$FQNValues_ref->{ $newGroupFQN } = join( "::", $groupName, $permissions );
	
	delete $FQNValues_ref->{ $permFQN };
	
	set_Default( $CimClient, $Classifier , $FQNValues_ref, $PropDefs_ref );
	
	return undef;
	
} # set_CREATEGROUP()



sub set_USERFAX
{
	my ( $CimClient, $Classifier , $FQNValues_ref, $PropDefs_ref ) = @_;

	red("in set_USERFAX()\n");
	
	my $feFQN	= Apache::FullQualifiedName->new( "PaulA_User", "FaxExtensions", 0, "Login" )->toString();
	
	# No faxextensions -> nothing to do	
	unless( exists $FQNValues_ref->{ $feFQN } ){ return undef; }
	
	my @extensions = split( "::", $FQNValues_ref->{ $feFQN } );
	
	LOG( "Extensions:".join( ", ",@extensions )."\n");
	
	foreach my $faxNo ( @extensions )
	{
		if( $faxNo =~ /.*unbrauchbar/ )
		{
			return "Bitte entfernen Sie zuerst die unbrauchbaren Durchwahlnummern bevor Sie neue setzen!";
		}
	}
	
	set_Default( $CimClient, $Classifier , $FQNValues_ref, $PropDefs_ref );
	
	return undef;
	
} # set_USERFAX()



sub set_FAX
{
	my ( $CimClient, $Classifier , $FQNValues_ref, $PropDefs_ref ) = @_;

       red("in set_FAX()\n");
	
	my $fqnBN	= Apache::FullQualifiedName->new( "PaulA_Fax", "BaseNumber", 0 );
	my $fqnVFE	= Apache::FullQualifiedName->new( "PaulA_Fax", "ValidFaxExtensions", 0 );
	my $fqnNL	= Apache::FullQualifiedName->new( "PaulA_Fax", "NumLength", 0 );
	my $fqnUBN	= Apache::FullQualifiedName->new( "Frontend", "UseBaseNumber", 0 );
	my $fqnER	= Apache::FullQualifiedName->new( "Frontend", "ExtensionRange", 0 );
	
	my @extensions;
	
	unless( exists $FQNValues_ref->{ $fqnUBN->toString() } && exists $FQNValues_ref->{ $fqnBN->toString() } )
	{
		# who's playing around with my source code, eh?
		die( "*** please set 'mandatory'-attribute in property 'UseBaseNumber' and 'BaseNumber'!!!" );
	}
	
	#
	# If UseBaseNumber is set we have to change the given intervall into a list of numbers.
	# At the moment we don't make any assumptions about the size of the interval, nor if the
	# numbers are a valid interval ( start <= end - done via jscript )
	#
	
	if( ( $FQNValues_ref->{ $fqnUBN->toString() } == 1 ) )
	{
		if( $FQNValues_ref->{ $fqnBN->toString() } eq "" )
		{
			return "Wenn Sie Ihren Fax-Anlage verwenden wollen, müssen Sie sowohl die Rufnummer ".
				"als auch die Durchwahlnummern angeben!";
		}
		
		if( exists $FQNValues_ref->{ $fqnER->toString() } )
		{
			# well then, create all the nice numbers of the intervall

			my ( $min, $max ) = split( "::", $FQNValues_ref->{ $fqnER->toString() } );
			
			my $numlength	= length $max;
			
			if( $numlength < length $min )
			{
				return "Die Anzahl der Stellen Ihres Durchwahlnummernbereiches wahl fehlerhaft!<br/>".
					"Bitte achten Sie darauf, dass die Zahlen die gleiche Anzahl an Stellen haben (ggf. Nullen voranstellen)!";
			}
			my $format	= sprintf( "%%0%dd", $numlength );
			
			LOG( "Format: $format\n" );
			
			for( ; $min <= $max; $min++ )
			{
				push( @extensions, sprintf( $format, $min ) );
			}

			$FQNValues_ref->{ $fqnVFE->toString() } = join( "::", @extensions );
		}
	}
	else	# UseBaseNumber == 0 -> we have a list of faxnumbers - haven't we?
	{
		unless( exists $FQNValues_ref->{ $fqnVFE->toString() } )
		{
			$FQNValues_ref->{ $fqnVFE->toString() } = undef;
		}
		
		# even if this value was changed set it to undef in case of UseBaseNumber == 0
		$FQNValues_ref->{ $fqnBN->toString() } = undef;

	}
	
	
	set_Default( $CimClient, $Classifier , $FQNValues_ref, $PropDefs_ref );
	
	return undef;
} # set_FAX()








sub set_DEFAULTMAILSERVEROUT
{
	my ( $CimClient, $Classifier , $FQNValues_ref, $PropDefs_ref ) = @_;

	red("in set_DEFAULTMAILSERVEROUT()\n");
	
	#
	# There are three cases:
	# - UseRelayHost was disabled (0) -> $FQNValues_ref{ RelayHost } = "" !!!!
	# - UseRelayHost was enabled (1) -> send $FQNValues_ref{ RelayHost }
	# - RelayHost was changed -> send $FQNValues_ref{ RelayHost }
	#
	my $useRelayHost = "";
	my $fqnRH;
	my $relayHostFQN;

	my @FQNs = keys %$FQNValues_ref;
	
# 	# If there ain't a property, go home buddy!
# 	unless( scalar @FQNs > 0 ){ return undef; }
	
	foreach my $FQN ( @FQNs )
	{
		my $fqn = Apache::FullQualifiedName->new( $FQN );
		
		LOG( "Property: ".$FQN."\n" );
		
		if( $fqn->equals( "Frontend", "UseRelayHost" ) )
		{
			$useRelayHost = $FQNValues_ref->{ $FQN };
		}
		else	# there are max. only two properties in this form!?!?!!?
		{
			$relayHostFQN	= $FQN;
			$fqnRH		= $fqn;
		}
	}
	
	
	if( $useRelayHost ne "" )
	{
		if( $useRelayHost == 0 )	# send mail immediately - don't user relay host
		{
			unless( $fqnRH )
			{
				$fqnRH = Apache::FullQualifiedName->new( "PaulA_MTA", "RelayHost", 0 );
				$relayHostFQN = $fqnRH->toString();
			}

			$FQNValues_ref->{ $relayHostFQN } = undef;	# set relay host to undef!!!!

		}
		else	# User wants to use a relay host - check if he named a server
		{
			unless( $fqnRH )
			{
				return	"Wenn Sie einen Standard-Mail-Server benutzen wollen, müssen ".
					"Sie dessen URL in dem dafür vorgesehenen Feld eintragen!";
			}
		}
	}
	
	set_Default( $CimClient, $Classifier , $FQNValues_ref, $PropDefs_ref );
	
	return undef;
}






sub set_DELETEMAILSERVERIN
{
	my ( $CimClient, $Classifier , $FQNValues_ref, $PropDefs_ref ) = @_;

	red("in set_DELETEMAILSERVERIN()\n");


	#
	# PaulA_Instance::DeleteMailServerIn ist noch nicht fertig !!!!
	#
	
	
	my $FQN;
	my $value;
	foreach $FQN ( keys %$FQNValues_ref )
	{
		$value = $FQNValues_ref->{ $FQN };
		last;	# just get the FQN and value - there should be only one!
	}
	
	my ( $login, $server ) = $value =~ /^_(.*)_(.+)/;	# if there is no login it looks like __<server>
	
	my $fqn = Apache::FullQualifiedName->new( $FQN );
	
	my $on = CIM::ObjectName->new( ObjectName => $fqn->getClass() );
		
	my $cimType	= $PropDefs_ref->{ $fqn->toString() }{ Type };
	
	my $valueObj	= CIM::Value->new( Value => $value, Type => $cimType );
	
	eval
	{
		$CimClient->SetProperty(
				InstanceName => $on,
				PropertyName => $fqn->getIdentifier(),
				NewValue => $valueObj );
	};
	
	if( $@ )
	{
		my $msg = "<h3>Der angegebene Mailserver konnte nicht gelöscht werden:</h3><br/><pre>";
		
		if( ref( $@ ) eq "CIM::Error" && $@->code() == 6 )
		{
			$msg .= "<br/><h2>Diesen Server gibt es nicht!</h2><br/>";
		}
		return $msg;
	}
	
	return undef;
	
} # set_DELETEMAILSERVERIN





sub set_ADMINGROUPS
{
	my ( $CimClient, $Classifier , $FQNValues_ref, $PropDefs_ref ) = @_;

	red("in set_ADMINGROUPS()\n");
	
	my ( $on, $i, $vo );

	foreach my $FQN ( keys %$FQNValues_ref )
	{
		my $fqn = Apache::FullQualifiedName->new( $FQN );
		my $class = $fqn->getClass();
		
		# precess only permissions
		unless( $fqn->equals( "PaulA_Group", "Permissions" ) ){ LOG( "***Urgggs\n" ); next; }
		
		my $propObjects = ();	# [ <CIM::Propery>, ... ]
		
		# cimClasses_ref{ $fqn->toString() ...} is only a dummy we need to use this function
		$propObjects = createPropertyObjects(
					$fqn->toString(),
					{ $fqn->toString() => [ $fqn->getIdentifier() ] },
					$FQNValues_ref,
					$PropDefs_ref
					);
		
		LOG( "Property:\n".present( $propObjects->[0] )."\n" );
		
		$on = CIM::ObjectName->new(
					ObjectName => $class,
					ConvertType => 'INSTANCENAME',
					KeyBindings => { Name => $Classifier } );

		$i  = CIM::Instance->new( ClassName => $class, Property => $propObjects );

		$vo = CIM::ValueObject->new( ObjectName => $on, Object => $i );
		
		$CimClient->ModifyInstance(ModifiedInstance => $vo);
	}

	return undef;
	
} # set_ADMINGROUPS()




sub set_DELUSER
{
	my ( $CimClient, $Classifier , $FQNValues_ref, $PropDefs_ref ) = @_;

	red("in set_DELUSER()\n");
	
	my ( $fqn, $value );
	
	foreach my $FQN ( keys %$FQNValues_ref )
	{
		$fqn = Apache::FullQualifiedName->new( $FQN );
		$value = $FQNValues_ref->{ $FQN };
		
		last; # there is only one property in DELUSER!
	}

	unless( $value )
	{
		return "<h3>Es wurde kein Benutzer ausgewählt</h3>";
	}
	
	my $on = CIM::ObjectName->new( ObjectName => $fqn->getClass() );
	my $valueObj = CIM::Value->new(	Type => 'string', Value => $value );
	my $paramValue = CIM::ParamValue->new( Name  => $fqn->getIdentifier(), Value => $valueObj );


	my $rc = $CimClient->invokeClassMethod( $on, 'DeleteUser', $paramValue );

	
	$rc->type( CIM::DataType::boolean );	# this is not set by default!! strange but true

	LOG("RC: $rc\n");

	unless( $rc->value() )
	{
		return "<h3>Das Löschen des Benutzers $value war nicht möglich</h3>";
	}
	
	return undef;
}


sub set_CREATEUSER
{
	my ( $CimClient, $Classifier , $FQNValues_ref, $PropDefs_ref ) = @_;

	red("in set_CREATEUSER()\n");

	my $fqnLogin		= Apache::FullQualifiedName->new( "Frontend", "Login", 0 );
	my $fqnPassword		= Apache::FullQualifiedName->new( "Frontend", "Password", 0 );
	my $fqnPaulAGroup	= Apache::FullQualifiedName->new( "Frontend", "PaulAGroup", 0 );

	unless( exists $FQNValues_ref->{ $fqnLogin->toString()      } &&
		exists $FQNValues_ref->{ $fqnPassword->toString()   } &&
		exists $FQNValues_ref->{ $fqnPaulAGroup->toString() } )
	{
		return "<h3>Es müssen zwingend Werte für folgende Felder angegeben werden: Login, Passwort und Gruppe!</h3>";
	}

	my $on = CIM::ObjectName->new( ObjectName => 'PaulA_System' );
	
	my $data;
	my @params;
	
	#
	# Unfortunately the order of the parameters is significant!!
	#
	foreach my $identifier ( "Login", "RealName", "Password", "PaulAGroup" )
	{
		my ( $FQN, $value, $valueType, $valueObj, $property );
		
		my $fqn	= Apache::FullQualifiedName->new( "Frontend", $identifier, 0 );
		
		$FQN = $fqn->toString();
		
		$value		= $FQNValues_ref->{ $FQN };		
		# $valueType	= $PropDefs_ref->{ $FQN }{ Type };
		# <HARDCODED>
		$valueType	= "string";
		# </HARDCODED>
		
		#
		# even if there is no value for a parameter, a ParamValue must exist
		#
		if( $value )
		{
			$valueObj	= CIM::Value->new( Value => $value, Type => $valueType );
			$property	= CIM::ParamValue->new( Name => $identifier, Value => $valueObj );
		}
		else
		{
			$property	= CIM::ParamValue->new( Name => $identifier );
			$value = "";
		}
		push @params, $property;
		
		# concatenate values for error message
		unless( $identifier eq "Password" ) { $data .= "$FQN: $value\n"; }
	}
	
	my $rc = $CimClient->invokeClassMethod( $on, 'CreateUser', @params );
	
	$rc->type( CIM::DataType::boolean );	# !!!!!!!!!!!
	
	LOG("RC: $rc\n");
	
	unless( $rc->value() )
	{
		return "<h3>Es konnte kein Benutzer mit den folgenden Daten angelegt werden:</h3><br/><pre>$data</pre>\n";
	}
	
	return undef;
	
} # set_CREATEUSER






sub set_CREATEDOMAIN
{
	my ( $CimClient, $Classifier , $FQNValues_ref, $PropDefs_ref ) = @_;

	red("in set_CREATEDOMAIN()\n");

	my $domain		= Apache::FullQualifiedName->new( "PaulA_Instance", "Create_OutgoingMailDomain", 0 );
	my $server		= Apache::FullQualifiedName->new( "PaulA_Instance", "Create_OMDServer", 0 );


	unless( exists $FQNValues_ref->{ $domain->toString() } &&
		exists $FQNValues_ref->{ $server->toString() }  )
	{
		return "<h3>Es müssen zwingend Werte für folgende Felder angegeben werden: Domäne und Server!</h3>";
	}

	my $on = CIM::ObjectName->new( ObjectName => $domain->getClass() );
	
	my @values;
	
	#
	# Unfortunately the order of the values is significant!!
	#
	
	push( @values, $FQNValues_ref->{ $domain->toString() } );
	push( @values, $FQNValues_ref->{ $server->toString() } );
	
	LOG( "Values: ".join( ", ", @values )."\n" );
	
	my $cimType	= $PropDefs_ref->{ $domain->toString() }{ Type };
	my $value	= CIM::Value->new( Value => \@values, Type => $cimType );
	LOG( "Value:\n$value\n" );
	
	eval
	{
		$CimClient->SetProperty(
				InstanceName => $on,
				PropertyName => $domain->getIdentifier(),
				NewValue => $value );
	};
	
	if( $@ )
	{
		my $msg = "<h3>Es konnte keine Domäne mit den folgenden Daten angelegt werden:</h3><br/><pre>".
			"Domäne: ".$values[0]."\n".
			"Server: ".$values[1]."</pre><br/>";
		
		if( ref( $@ ) eq "CIM::Error" && $@->code() == 11 )
		{
			$msg .= "<br/><h2>Diese Domäne existiert bereits!</h2><br/>";
		}
		return $msg;
	}
	
	return undef;
	
} # set_CREATEDOMAIN


sub set_CREATEMAILSERVERIN
{
	my ( $CimClient, $Classifier , $FQNValues_ref, $PropDefs_ref ) = @_;

	red("in set_CREATEMAILSERVERIN()\n");
	
	LOG( "Values:\n".present( $FQNValues_ref )."\n" );
	
	my $server		= Apache::FullQualifiedName->new( "PaulA_Instance", "Create_IncomingMailServer", 0 );
	my $protocol		= Apache::FullQualifiedName->new( "PaulA_Instance", "Create_IMSProtocol", 0 );
	my $login		= Apache::FullQualifiedName->new( "PaulA_Instance", "Create_IMSLogin", 0 );
	my $password		= Apache::FullQualifiedName->new( "PaulA_Instance", "Create_IMSPassword", 0 );

	unless( exists $FQNValues_ref->{ $server->toString()	} &&
		exists $FQNValues_ref->{ $protocol->toString()	} )
	{
 			return	"<h3>Es müssen mind. Werte für folgende Felder angegeben werden:</h3><br>".
				"Protokoll ETRN: Server<br>andere Protokolle: Alle Felder!";
	}
	
	if( $FQNValues_ref->{ $protocol->toString() } ne "ETRN" )
	{
 		unless( exists $FQNValues_ref->{ $login->toString()	} &&
 			exists $FQNValues_ref->{ $password->toString()	} )
 		{
 			return	"<h3>Sie haben ".$FQNValues_ref->{ $protocol->toString() }.
				" als Protokoll ausgewählt, dann müssen Sie auch Angaben über Login und Passwort machen!</h3>";
 		}
	}
	
	my $on = CIM::ObjectName->new( ObjectName => $server->getClass() );
	

	my @values;
	
	#
	# Unfortunately the order of the values is significant!!
	#
	
	push( @values, $FQNValues_ref->{ $server->toString() } );
	push( @values, $FQNValues_ref->{ $protocol->toString() } );
	push( @values, $FQNValues_ref->{ $login->toString() } )		if( exists $FQNValues_ref->{ $login->toString() } );
	push( @values, $FQNValues_ref->{ $password->toString() } )	if( exists $FQNValues_ref->{ $password->toString() } );
	
	my $cimType	= $PropDefs_ref->{ $server->toString() }{ Type };
	my $value	= CIM::Value->new( Value => \@values, Type => $cimType );
	
	eval
	{
		$CimClient->SetProperty(
				InstanceName => $on,
				PropertyName => $server->getIdentifier(),
				NewValue => $value );
	};
	
	if( $@ )
	{
		my $msg = "<h3>Es konnte keine Mailserver für eingehende Mail mit den folgenden Daten angelegt werden:</h3><br/><pre>".
			"Server: ".$values[0]."\n".
			"Protokoll: ".$values[1]."\n".
			"Login: ".$values[2]."</pre><br/>";
		
		if( ref( $@ ) eq "CIM::Error" && $@->code() == 11 )
		{
			$msg .= "<br/><h2>Diese Mailserver existiert bereits!</h2><br/>";
		}
		return $msg;
	}


	
	return undef;
	
} # set_CREATEMAILSERVERIN


########################################################################
#
# $CimClasses_ref = getClasses( $FQNs_ref );
#
# Parameter:
#	$FQNs_ref		- [ <FQN>, ... ]
#
# Result:
#	$CimClasses_ref		- { <className>, [ <identifier>... ] }
#
# Exceptions:
#	CIM-Exceptions
#	string
#
# Description:
#	A property's full qualified name looks like this: <scope>::<name>,
#	so when we speak of the property's name (PropertyName) the
#	qualified name is meant.
#	When requesting properties, however, only the name without the scope
#	is needed - we call that the identifier.
#
sub getClasses
{
	my ( $FQNs_ref ) = @_;
	
	my $CimClasses_ref = ();

	LOG( "FQNs:\n".present(	$FQNs_ref )."\n" );
	
	foreach my $FQN ( @$FQNs_ref )
	{
	LOG( "Assign $FQN to " );
		my $fqn	= Apache::FullQualifiedName->new( $FQN );
		
		#
		# wenn der Klassenname der aktuellen Property in %cimClasses_ref bereits
		# existiert, dann füge einfach den Namen (identifier) der aktuellen
		# Property hinten an den unter diesem Klassennamen erreichbaren Array an
		#
		# andernfalls lege einen anonymen Array unter dem Schlüsselwort Class
		# an, der als erstes Element den Namen der Property enthält
		#
		
		my $class	= $fqn->isEnumeration() ? "@".$fqn->getClass() : $fqn->getClass();
		my $identifier	= $fqn->getIdentifier();
		my $keys	= $fqn->getKeybindings();

		my $cfqn	= Apache::FullQualifiedName->new( $class, "xxx", 0, @$keys );
		my $FQN		= $cfqn->toString();
		
		LOG( "$FQN\n" );
		
		if( exists $CimClasses_ref->{ $FQN } )
		{
			push( @{ $CimClasses_ref->{ $FQN } }, $identifier );
		}
		else
		{
			$CimClasses_ref->{ $FQN } = [ $identifier ];
		}
	}

	return $CimClasses_ref;
	
} # getClasses


########################################################################
#
# $propObjects = createPropertyObjects( $ClassFQN, $CimClasses_ref, $FQNValues_ref, $PropDefs_ref );
#
# Parameter:
#	$ClassFQN	- string
#	$CimClasses_ref	- { <classFQN> => [ <identifier>... ] }
#	$FQNValues_ref	- { <FQN> => <value> }
#	$PropDefs_ref	- { <FQN> => { ... } }
#
# Result:
#	$propObjects	- [ <CIM::Property> ... ]
#
# Exceptions:
#	string
#

sub createPropertyObjects
{
	my ( $ClassFQN, $CimClasses_ref, $FQNValues_ref, $PropDefs_ref ) = @_;
	
	my @propObjects	= ();
	my $cfqn	= Apache::FullQualifiedName->new( $ClassFQN );
	my $className	= $cfqn->getClass();
	my $keys	= $cfqn->getKeybindings();
	
	foreach my $identifier ( @{ $CimClasses_ref->{ $ClassFQN } } )
	{
		# we should never have enumerated types here
		
		my $fqn = Apache::FullQualifiedName->new( $className, $identifier, 0, @$keys );

		my $FQN = $fqn->toString();

		if( exists $PropDefs_ref->{ $FQN } )
		{
			my $currentDef_ref = $PropDefs_ref->{ $FQN };

			my $valueType	= $currentDef_ref->{ Type };
			my $value	= $FQNValues_ref->{ $FQN };
			
			# value may be undef! So split only if we have sth. to split.
			# Boolean values are undef if false and therefore 0
			if( $currentDef_ref->{ IsArray } )
			{
				# <HARDCODED>
				$value = [ split("::", $value) ] if ( defined $value );
				# </HARDCODED>
			}
			elsif( $valueType eq "boolean" )
			{
				$value = $value ? 1 : 0;
			}

			LOG("Set $FQN to ".present($value)." ( $valueType )\n");

			my $valueObj = defined $value ? CIM::Value->new( Value => $value, Type => $valueType ) : undef;
			push @propObjects, CIM::Property->new( Name => $identifier, Type => $valueType, Value => $valueObj );
		}
		else
		{
			die("*** no definition found for $FQN\n");
		}
	}
	return \@propObjects;
	
} # createPropertyObjects()


########################################################################
#
# $property = getEnumerated( $CimClient, $Fqn );
#
# Parameter:
#	$CimClient	- CIM::Client
#	$Fqn		- Apache::FullQualifiedName
#
# Result:
#	$property	- CIM::Property
#
# Exceptions:
#	CIM-Exception
#	string
#
sub getEnumerated
{
	my ( $CimClient, $Fqn ) = @_;
	
	my $keybindings = $Fqn->getKeybindings();
	
	
	if( scalar @{$keybindings} >  1 ) { die( "*** no enumeration of ordinary instances with multiple keybindings, yet" ); }
	if( scalar @{$keybindings} == 0 ) { die( "*** no enumeration of instances without keybindings" ); }
	
	my $on = CIM::ObjectName->new( ObjectName  => $Fqn->getClass() );
	
	# returned is an array of ValueObjects not Instances!!!
	my @ni = $CimClient->EnumerateInstances( ClassName => $on, PropertyList => $keybindings );
	
	my @allKeys = ();
	
	foreach my $valueObject (@ni)
	{
		my $instance = $valueObject->object();
		
		foreach my $property ( @{ $instance->properties() } )
		{
			LOG( "Property:\n".present( $property )."\n" );
			
			my $value = $property->value();
			if( $value )
			{
				push( @allKeys, $value->value() );
			}
			else
			{
				LOG( "*** no value object returned for ".$property->name()."\n" );
			}
		}
	}
	
	my $property = createStringProperty( $Fqn->toString(), \@allKeys );
	
	return $property;
	
} # getEnumerated()


########################################################################
#
# $property = getEnumeratedKeybindings( $CimClient, $FQN );
#
# Parameter:
#	$CimClient	- CIM::Client
#	$FQN		- Apache::FullQualifiedName
#
# Result:
#	$property	- CIM::Property
#
# Exceptions:
#	CIM-Exception
#	string
#
# Description:
#	This function is only for menu entries yet!
#
sub getEnumeratedKeybindings
{
	my ( $CimClient, $FQN ) = @_;
	
	my $keybindings = $FQN->getKeybindings();
	
	
	if( scalar @{$keybindings} == 0 ) { die( "*** no enumeration of instances without keybindings" ); }
	
	my $on = CIM::ObjectName->new( ObjectName  => $FQN->getClass() );
	
	# returned is an array of ValueObjects not Instances!!!
	my @ni = $CimClient->EnumerateInstances( ClassName => $on, PropertyList => $keybindings );
	
	my @allKeys = ();
	
	foreach my $valueObject (@ni)
	{
		my %values;
		
		my $instance = $valueObject->object();
		
		foreach my $property ( @{ $instance->properties() } )
		{
			LOG( "Property:\n".present( $property )."\n" );
			
			my $value = $property->value();
			if( $value )
			{
				$values{ $property->name() } = $value->value();
			}
		}
		
		LOG( "XML-Keybindings:\n".XMLout( \%values )."\n" );
		
		push( @allKeys, XMLout( \%values ) );
		
	}
	
	my $property = createStringProperty( $FQN->toString(), \@allKeys );
	
	return $property;
	
} # getEnumeratedKeybindings()



########################################################################
#
# createFrontendProperty( $Identifier_ref, $Reply_ref, $Classifier );
#
# Parameter:
#	$Identifier_ref		- \@string
#	$Reply_ref		- { <FQN> => <CIM::Property> }
#	$Classifier		- string
#
# Result:
#
# Exceptions:
#
sub createFrontendProperty
{
	my ( $Identifier_ref, $Reply_ref, $Classifier ) = @_;
	
	my $property;
	
	foreach my $identifier ( @$Identifier_ref )
	{
		my $fqn = Apache::FullQualifiedName->new( "Frontend", $identifier, 0 );
		
		if( $identifier eq "Classifier" )
		{
			$property = createStringProperty( "Classifier", $Classifier );
		}
		else	# no idea what that could be, but we create an empty Property anyway
		{
			$property = createStringProperty( "Unknown", "xxx" );
		}
		
		$Reply_ref->{ $fqn->toString() } = $property;
	}
	return;
	
} # createFrontendProperty()



########################################################################
#
# $property = createStringProperty( $Name, $Value );
#
# Parameter:
#	$Name		- string
#	$Value		- string	# may be a reference!!
#
# Result:
#	$property	- CIM::Property
#
# Exceptions:
#	CIM-Error
#
sub createStringProperty
{
	my ( $Name, $Value ) = @_;
	
	my $valueObj = CIM::Value->new( Type => CIM::DataType::string, Value => $Value );

	return CIM::Property->new( Name => $Name, Type => CIM::DataType::string, Value => $valueObj );

} # createStringProperty()



########################################################################
#
# $function = getFormFunction( $Form, $Method )
#
# Parameter:
#	$Form		- string
#	$Method		- string
#
# Result:
#	$function	- \&<function>
#
# Exceptions:
#	none
#
sub getFormFunction
{
	my ( $Form, $Method ) = @_;
	
	LOG("in getFormFunction( $Form, $Method )\n");

	my $Functions = {};
	
	$Functions->{ PAULAMENU }	= {	get => \&get_PAULAMENU };

	$Functions->{ ADMINMAILINGLISTS	} = {	get => \&get_Default,
						set => \&set_Default };

	$Functions->{ CREATEUSER }	= { 	get => \&get_Default,
 						set => \&set_CREATEUSER };

	$Functions->{ DELUSER }		= {	get => \&get_Default,
						set => \&set_DELUSER };

	$Functions->{ USERGROUPS }	= {	get => \&get_Default,
						set => \&set_Default };

	$Functions->{ USERLOGIN }	= {	get => \&get_Default,
						set => \&set_Default };

	$Functions->{ USERFAX }		= {	get => \&get_USERFAX,
						set => \&set_USERFAX };

	$Functions->{ USERMAIL }	= {	get => \&get_Default,
						set => \&set_Default };

	$Functions->{ USERMAILINGLISTS }= {	get => \&get_Default,
						set => \&set_Default };
		
	$Functions->{ USERPRIVATEMAIL }	= {	get => \&get_Default,
						set => \&set_Default };
						
	$Functions->{ USERSECURITY }	= {	get => \&get_USERSECURITY,
						set => \&set_Default };

	$Functions->{ USERVACATION }	= {	get => \&get_Default,
						set => \&set_Default };
	
	$Functions->{ GLOBALALIASES }	= {	get => \&get_Default,
						set => \&set_Default };

	$Functions->{ INTRANET }	= {	get => \&get_Default,
						set => \&set_Default };

	$Functions->{ DEFGATEWAY }	= {	get => \&get_Default,
						set => \&set_Default };

	$Functions->{ STATICADDRESSES }	= {	get => \&get_Default,
						set => \&set_Default };

	$Functions->{ DNSSERVER }	= {	get => \&get_Default,
						set => \&set_Default };

	$Functions->{ IPADDRESSES }	= {	get => \&get_Default,
						set => \&set_Default };

	$Functions->{ SYSTEMSETTINGS }	= {	get => \&get_Default,
						set => \&set_Default };

	$Functions->{ DHCPACTIVATE }	= {	get => \&get_Default,
						set => \&set_Default };

	$Functions->{ ADMINGROUPS }	= {	get => \&get_ADMINGROUPS,
						set => \&set_ADMINGROUPS };

	$Functions->{ VPN }		= {	get => \&get_Default,
						set => \&set_Default };

	$Functions->{ GETINTERVAL }	= {	get => \&get_Default,
						set => \&set_Default };

	$Functions->{ FILTER }		= {	get => \&get_Default,
						set => \&set_Default };

	$Functions->{ DOMAINSETTINGS }	= {	get => \&get_Default,
						set => \&set_Default };

	$Functions->{ MAILSERVERINSETTINGS }
					= {	get => \&get_Default,
						set => \&set_Default };

	$Functions->{ DELETEMAILSERVERIN }
					= {	get => \&get_DELETEMAILSERVERIN,
						set => \&set_DELETEMAILSERVERIN };

	$Functions->{ DELETEDOMAIN }	= {	get => \&get_Default,
						set => \&set_Default };

	$Functions->{ CREATEMAILSERVERIN }
					= {	get => \&get_Default,
						set => \&set_CREATEMAILSERVERIN };

	$Functions->{ CREATEDOMAIN }	= {	get => \&get_Default,
						set => \&set_CREATEDOMAIN };

	$Functions->{ DEFAULTMAILSERVEROUT }
					= {	get => \&get_DEFAULTMAILSERVEROUT,
						set => \&set_DEFAULTMAILSERVEROUT };

	$Functions->{ FAX }		= {	get => \&get_FAX,
						set => \&set_FAX };

	$Functions->{ CREATEGROUP }	= {	get => \&get_CREATEGROUP,
						set => \&set_CREATEGROUP };

	$Functions->{ DELETEGROUP }	= {	get => \&get_Default,
						set => \&set_Default };

	if( exists $Functions->{ $Form } )
	{
		return $Functions->{ $Form }{ $Method };
	}
	return undef;

} # getFormFunction()


1;
