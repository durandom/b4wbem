package Apache::Paula;

#
# See <HARDCODED>...</HARDCODED> sections for hardcoded stuff ;)
#
use strict;

use XML::DOM;
use XML::Simple;
use Apache::Forms;
use Apache::Utilities;
use Apache::FullQualifiedName;

use CIM::Client;
use CIM::Utils;

use vars qw(@ISA @EXPORT);

use Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(
	requestRight
	getAllRights
	setFormDocument
	getFormDocument
	getMenuDocument
	);

my	$isInitialized = 0;

my	$CimClient;


########################################################################
#
# $error = setFormDocument( $Parameter_ref );
#
# Parameter:
#	$Parameter_ref	- { <Form|User|Classifier|...> => <Value> }
#
# Result:
#	$error		- string|undef
#
# Exceptions:
#	CIM-Exceptions
#
sub setFormDocument
{
	my ( $Parameter_ref ) = @_;
	
	LOG("in setFormDocument()\n");

	unless( $isInitialized ) { init(); }
	
	my ( $form, $user, $classifier, $error );
	my %modifiedValue;		# -> { <id> => <value> }
	
	LOG( "Create hash with modified properties...\n" );
	foreach my $parameter ( keys %$Parameter_ref )
	{
		my $value = $Parameter_ref->{ $parameter };
		   if( $parameter eq "Form" )		{ $form = $value; }
		elsif( $parameter eq "User" )		{ $user = $value; }
		elsif( $parameter eq "Classifier" )	{ $classifier = $value; }
		else
		{
			LOG("...adding $parameter => $value\n");
			$modifiedValue{ $parameter } = $value;
		}

	}

	#
	# maybe better check wheter Form-, User- and Classifier-values are set or not
	#
	
	my $errormsg = callSetMethodFor( $form, $classifier, \%modifiedValue );

	cleanUp();
	
	return $errormsg;

} # setFormDocument()


########################################################################
#
# $errormsg = callSetMethodFor( $Form, $Classifier, $IDValues_ref );
#
# Parameter:
#	$Form		- string
#	$Classifier	- string
#	$IDValues_ref	- { <id> => <value> }
#
# Result:
#	$errormsg	- string
#
# Exceptions:
#	CIM-Exceptions
#
sub callSetMethodFor
{
	my ( $Form, $Classifier, $IDValues_ref ) = @_;
	
	LOG("in callGetMethodFor()\n");
	
	my ( $ids, $ID, %FQN, $errormsg );
	
	my $propDefs_ref = getPaulAProperties();	# { <FQN>  => { <Class|Type|IsArray> => <value> } }
	
	#
	# Paul needs full qualified names (FQNs) instead of ids!
	#
	LOG("ID-Values:\n".present($IDValues_ref)."\n");
	
	$ids = [ keys( %$IDValues_ref ) ];
	
	# map only if there are ids!!!
	if( scalar( @$ids ) > 0 )
	{
		$ID = mapIDs( $ids );		# $ID->{ <FQN> => <id> }
		%FQN = reverse( %$ID );		# %FQN={ <id> => <FQN> }
	}
	
	#
	# now map ids to FQNs
	#
	my $FQNValues_ref = {};
	foreach my $id ( @$ids )
	{
		$FQNValues_ref->{ $FQN{ $id } } = $IDValues_ref->{ $id };
	
	}
	
	LOG("FQNValues:\n".present($FQNValues_ref)."\n");
	
	my $func_ref = getFormFunction( $Form, "set" );
	
	if( $func_ref )
	{
		$errormsg = &$func_ref( $CimClient, $Classifier, $FQNValues_ref, $propDefs_ref );
	}
		
	return $errormsg;

} # callSetMethodFor()


########################################################################
#
# $result = callGetMethodFor( $Form, $Classifier, $IDs_ref );
#
# Parameter:
#	$Form		- string
#	$Classifier	- string
#	$IDs_ref	- [ <id>... ]
#
# Result:
#	$result		- { <id> => <CIM::Property> }
#
# Exceptions:
#	CIM-Exceptions
#
sub callGetMethodFor
{
	my ( $Form, $Classifier, $IDs_ref ) = @_;
	
	LOG("in callGetMethodFor()\n");
	
	my $reply = ();		# { <FQN> => <CIM::Property> }
	
	#
	# Paul needs full qualified names (FQNs) instead of ids!
	#
	my $FQNs = mapIDs( $IDs_ref );		# -> $FQNs = { <FQN> => <id> }

	LOG("Calling Method get_$Form() for $Classifier\n");
	my $func_ref = getFormFunction( $Form, "get" );
	
	if( $func_ref )
	{
		$reply = &$func_ref( $CimClient, $Classifier, [ keys %$FQNs ] );
	}
	
	LOG("Reply: ".present($reply)."\n");
	
	#
	# now "unmap" the result: { <id> => <CIM::Property> }
	#
	my $result = ();
	foreach my $FQN ( keys %$reply )
	{
		LOG("Unmapping $FQN to ".$FQNs->{ $FQN }."\n");
		$result->{ $FQNs->{ $FQN } } = $reply->{ $FQN };
	
	}
	
	return $result;

} # callGetMethodFor



########################################################################
#
# $doc = getFormDocument( $Form, $Classifier, $Filename );
#
# Parameter:
#	$Form		- string
#	$Classifier	- string
#	$Filename	- string
#
# Result:
#	$doc		- DOM::Document or undef if no such form
#
# Exceptions:
#	CIM-Exceptions
#	string
#
sub getFormDocument
{
	my ( $Form, $Classifier, $Filename ) = @_;

	LOG("in getFormDocument()\n");

	unless( $isInitialized ) { init(); }

	my $parser = new XML::DOM::Parser;
	my ( $paulaDoc, $doc, $docStr );

	#
	# Extract the requested form from the xml-file and
	# parse it
	#
	
	my $tmp = $/;
	$/ = undef();	# enable whole-file mode
		open( FILE, "$Filename") or die( "*** Unable to open '$Filename'\n");
		my ($formText) = (<FILE> =~ m|(<form\s+name="$Form".*?>.*?</form>)|s);
		close( FILE );
	$/ = $tmp;
	
	$formText = "<?xml version='1.0' encoding='iso-8859-1'?>\n<paula>\n$formText</paula>\n";

	$formText =~ /aha/;		# uh, don't remove that!!!

	LOG( "Text:\n".$formText."\n" );
	eval
	{
		$paulaDoc = $parser->parse( $formText );
	};

	if( $@ ) { die("*** parsing of XML-Form failed: $@\n") }

	my $tmp2 = $paulaDoc->toString();		# uh, don't remove that!!!
	
	insertProperties( $paulaDoc, $Form, $Classifier );

	cleanUp();

	return $paulaDoc;

} # getFormDocument()


########################################################################
#
# insertProperties( $Document, $Form, $Classifier );
#
# Parameter:
#	$Document	- DOM::Document
#	$Form		- string
#	$Classifier	- string
#
# Result:
#	void
#
# Exceptions:
#	CIM-Exceptions
#	string
#
sub insertProperties
{
	my ( $Document, $Form, $Classifier ) = @_;
	
	LOG("in insertProperties()\n");
	
	my $root = $Document->getDocumentElement();
	
	#
	# that's not really safe - ok, we are shure there is a form
	# with an appropriate name
	#
	my $unit = getFirstTagNamed( "form", "$Form", $root, 1 );
	
	unless( $unit )
	{
		LOG("*** form $Form not found!\n");
		return;
	}
	
	#
	# Build a hash, using the CIM-property as key and
	# store all nodes for later write back
	#

	my %cimNodes;
	
	LOG( "Searching for cimproperties:\n" );
	foreach my $node ( $unit->getElementsByTagName('*') )
	{
		my $ID = $node->getAttribute('cimproperty');
		
		if( $ID ne "" )
		{
			LOG( "...found $ID ... " );
			#
			# If a choosefrom-property exists use it instead of
			# cimproperty, if choosefrom is empty, use none of them!
			#
			# Well, that's useful if get and set have different properties
			# and the get method should request properties which will be
			# set by the user -> createUser
			#
			my $getID = $node->getAttribute('choosefrom');
			
			if( $getID ne "" )
			{
				if( $getID ne "nothing" )
				{
					$cimNodes{ $getID } = $node;
					LOG( "using >choosefrom=$getID< instead!\n" );
				}
				else
				{
					LOG( ">choosefrom< tells us not to use this id for a request - kicking $ID!\n" );
				}
			}
			else
			{
				LOG( "ok\n" );
				$cimNodes{ $ID } = $node;
			}
		}
	}


	#
	# call method to retrieve properties for all ids
	#

	# $result: { <id> => <CIM:Property> }

	my $result = callGetMethodFor( $Form, $Classifier, [ keys %cimNodes ] );
	
	#
	# get actionsNode to store hiddenfields
	#

	LOG("\n\nResult: ".present($result)."\n");

	my $actionsNode;
	foreach ( $unit->getElementsByTagName('actions',0) )
	{
		$actionsNode = $_;
		last;	# there should be only one
	}


	#
	# Insert the values into the DOM-tree
	#
	
	insertValues( \%cimNodes, $result, $Document );

	#
	# Add a hidden field that obtains form and classifier
	#
	
	my $newElem = $Document->createElement('hiddenfield');
	$newElem->setAttribute('name','form');
	$newElem->setAttribute('value',$Form."_".$Classifier);
	$actionsNode->appendChild($newElem) if $actionsNode;

	return;
} # insertProperties()


########################################################################
#
# $doc = getMenuDocument( $OpenSubmenu, $User, $Filename, $Permissions );
#
# Parameter:
#	$OpenSubmenu	- string
#	$User		- string
#	$Filename	- string
#	$Permissions	- string: <form>[_<ALL|SELF>]_<r|w|n>
#
# Result:
#	$doc		- DOM::Document or undef
#
# Exceptions:
#	CIM-Exceptions
#	string
#
sub getMenuDocument
{
	my ( $OpenSubmenu, $User, $Filename, $Permissions ) = @_;

	LOG("in getMenuDocument()\n");

	unless( $isInitialized ) { init(); }

	my $parser = new XML::DOM::Parser;
	my ( $menuDoc );

	#
	# Extract the menu from the xml-file and parse it
	#
	
	my $tmp = $/;
	$/ = undef();	# enable whole-file mode
	open( FILE, "$Filename") or die( "*** Unable to open '$Filename': $!\n");
	my ($menuStr) = (<FILE> =~ m|(<node\s+.*>.*</node>)|s);
	close( FILE );
	$/ = $tmp;
	
	$menuStr = "<?xml version='1.0' encoding='iso-8859-1'?>\n$menuStr";

	eval { $menuDoc = $parser->parse( $menuStr ); };

	if( $@ ) { die("*** parsing of XML-Form failed: $@\n") }
	
	insertMenuProperties( $OpenSubmenu, $menuDoc, $User, $Permissions );

	cleanUp();

	return $menuDoc;

} # getMenuDocument()

########################################################################
#
# insertMenuProperties( $OpenSubmenu, $Document, $User, $Permissions );
#
# Parameter:
#	$OpenSubmenu	- string
#	$Document	- DOM::Document
#	$User		- string
#	$Permissions	- string: <form>[_<ALL|SELF>]_<r|w|n>
#
# Result:
#	void
#
# Exceptions:
#	CIM-Exceptions
#	string
#
sub insertMenuProperties
{
	my ( $OpenSubmenu, $Document, $User, $Permissions ) = @_;
	
	LOG("in insertMenuProperties()\n");
	
	my $unit = $Document->getDocumentElement();
	
	# first node is <node name="PAULA"> - that's what we need ;)
	
	if( $OpenSubmenu )
	{
		LOG( "Open submenu ... $OpenSubmenu\n" );
		
		#
		# Build a hash, using the CIM-property as key and
		# store all nodes for later write back
		#

		my %cimNodes;
		
		my $submenu = getFirstTagNamed( "node", "NODE-".$OpenSubmenu, $unit, 1 );
		if( $submenu )
		{
			my $ID = $submenu->getAttribute('cimproperty');

			if ( $ID )
			{				
				$cimNodes{ $ID } = $submenu;
			}
		}
		LOG( "cimNodes: ".present( \%cimNodes )."\n" );
		#
		# call method to retrieve properties for all ids
		#

		# $result: { <id> => <CIM:Property> }

		my $result = callGetMethodFor( "PAULAMENU", $User, [ keys %cimNodes ] );

		LOG("Result: ".present($result)."\n");

		#
		# Insert the values into the DOM-tree
		#

		insertValues( \%cimNodes, $result, $Document );
		

	}
	
	#
	# insert an empty node at dynamic submenues except the opened (if there is one open)
	# I admit, this is quite a hack, but it'll do for the moment
	#
	foreach my $menuName ( "NODE-USER", "NODE-GROUPRIGHTS", "NODE-RECEIVE", "NODE-SEND" )
	{
		if( $menuName ne "NODE-".$OpenSubmenu )
		{
			my $menu = getFirstTagNamed( "node", $menuName, $unit, 1 );

			if( $menu )
			{
				$menu->appendChild( $Document->createElement('node') );
			}
		}
	}
	
	#
	# Allow only Nodes with PaulARights
	# Set LOGOUT permission for everybody on "r"
	#

	# userRights = <form> => <[rwn]>;
	my %userRights = map{ /^(.*)_([rwn])$/ } split( ",", $Permissions );
		
	$userRights{ LOGOUT } = "r";
	
	foreach my $node ( $unit->getElementsByTagName('node') )
	{
		#
		# form und classifier trennen!  <form>[_<classifier>]
		#
		my ( $form, $classifier ) = split( /_/, $node->getAttribute('name'), 2);

		next if (!$form);

		#
		# Add suffix _SELF or _ALL to nodename (when USER-form/node),
		# depending on rights of logged user
		#
		# menu-nodes in user menu look like this "NODE-<username>"
		#

		my $group = "";
		if( $form =~ /^USER/ )
		{
			$group = ( $classifier eq $User ) ? "_SELF" : "_ALL";
		}

		#
		# Remove current node only if it is not a menu-node AND not readable.
		# Check for menu nodes first since they don't have $userRights!!
		#
		if( ( $form !~ /^NODE-/ ) && ( $userRights{$form.$group} !~ /^[rw]$/ ) )
		{
			LOG( "removing $form$group( $classifier )\n" );
			$node->getParentNode->removeChild( $node );
		}
	}

	#
	# Remove User Node if no Children-Nodes exist (all permission "n")
	#
	_removeDeadlinks( $unit );

	return;
	
} # insertMenuProperties()


########################################################################
#
# insertValues( $CimNodes_ref, $Result_ref, $Document );
#
# Parameter:
#	$CimNodes_ref	- { <ID> => <XML::DOM::Element> }
#	$Result_ref	- { <ID> => <CIM::Property> }
#	$Document	- XML::DOM::Element
#
# Result:
#	void
#
# Exceptions:
#	CIM-Exceptions
#
sub insertValues
{
	my ( $CimNodes_ref, $Result_ref, $Document ) = @_;
	
	my $newElem;

	#
	# Insert proper XML-tags into tree for each property
	#
	
	foreach my $ID ( keys %$Result_ref )
	{
		my $property	= $Result_ref->{ $ID };
		my $node	= $CimNodes_ref->{ $ID };
		my $tagName	= $node->getTagName();
		
		#
		# now insert the value into the DOM-tree
		#
		# MAKE SURE THERE IS NO ROUTINE FOR default-TAGS !! They are handled in the appropriate
		# superior tag routine!
		#
		my $value = getValueAsRef( $property );		# this may be a reference to an array [of hashes]!!!!
		
		unless( defined $value ){ next; }	# no value? nothing to insert
		
		if( ref( $value ) eq "ARRAY" )
		{
			if( $tagName eq 'singleselect' )
			{
				createSingleSelect( $node, $value, $Result_ref );
			}
			elsif( $tagName eq 'list' )
			{
				createListMembers( $node, $value );
			}
			elsif( $tagName eq 'permissionlist' )
			{
				createPermissionList( $node, $value );
			}
			elsif( $tagName eq 'node' )
			{
				insertMenuNodes( $node, $value );
			}
		}
		else # else für if( ARRAY )
		{
			if ( $tagName eq 'text' )
			{
				_insertText( $node, $value );
			}
			elsif ( $tagName eq 'inputrange' )
			{
				createRange( $node, $value );
			}
			elsif ( $tagName eq 'title' )
			{
				_insertText( $node, $value );
			}
			elsif ( $tagName eq 'inputfield' )
			{
				_insertText( $node, $value );
			}
			elsif ( $tagName eq 'inputtime' )
			{
				_insertText( $node, $value );
			}
			elsif ( $tagName eq 'inputvalue' )
			{
				_insertText( $node, $value );
			}
			elsif ( $tagName eq 'inputIP' )
			{
				_insertText( $node, $value );
			}
			elsif ( $tagName eq 'inputarea' )
			{
				_insertText( $node, $value );
			}
			elsif ($tagName eq 'boolselect')
			{
				$node->setAttribute('value',$value);
			}
			elsif( $tagName eq 'singleselect' )
			{
				# SCALAR singleselect only if the choices are hardcoded in XML!?!?!?!
				
				red("####################################still hardcoded singleselects in paula.xml???????????\n");
				
				for my $d ($node->getElementsByTagName('default',0))
				{
					$d->setTagName('choice');
				}
			
				for my $ch ($node->getElementsByTagName('choice',0))
				{
					if ($ch->getAttribute('value') eq $value )
					{
						$ch->setTagName('default');
						last;
					}
				}
			}
		}
		
	} # for ( keys %$Result_ref )

} # insertValues()




########################################################################
#
# $Access = requestRight( $User, $Classifier, $Form );
#
# Parameter
# 	$User		- string
# 	$Classifier	- string
# 	$Form		- string
#
# Result:
# 	$Access		- string < w|r|n >
#
# Exceptions:
#	CIM-Exceptions
#
sub requestRight_cim_request_version     # obsolet
{
	my ( $User, $Classifier, $Form ) = @_;

	my %rights=();
	
	getAllRights( $User, \%rights );
	
	my $group="";
	
	if( $Form =~ /^USER/ )
	{
		$group = ("$Classifier" eq "$User") ? "_SELF" : "_ALL";
	}
	
	return $rights{ $Form.$group };

} # requestRight_cim_request_version()

sub requestRight
{
	my ( $User, $Classifier, $Form, $Permission ) = @_;

	my @currRightsArr = split(",",$Permission);
	
	my %currRight = map {/^(.*)_([rwn])$/} @currRightsArr;
	
	my $group="";

	if( $Form =~ /^USER/ )
	{
		$group = ("$Classifier" eq "$User") ? "_SELF" : "_ALL";
	}

	return $currRight{$Form.$group};
}

########################################################################
#
# getAllRights( $User, $Rights_ref );
#
# Parameter
# 	$User		- string
#	$Rights_ref	- { <form> => <r|w|n> }
#
# Result:
#	void
#
# Exceptions:
#	CIM-Exceptions
#
sub getAllRights
{
	my ( $User, $Rights_ref ) = @_;
	
	LOG("in getAllRights()\n");

	unless( $isInitialized ) { init(); }
	
	my $on = CIM::ObjectName->new( ObjectName => 'PaulA_User', KeyBindings => { Login => $User } );
	my $i = $CimClient->GetInstance( InstanceName => $on, PropertyList => ['PaulAPermissions'] );
	my @rightsArr = $i->propertyByName('PaulAPermissions')->value()->value();
	
	#
	# create Rights-hash: %userRights : { "<form>" => "[rwn]" }
	#
	
	%$Rights_ref = map {/^(.*)_([rwn])$/} @rightsArr;
	
	return;
	
} # getAllRights()




########################################################################
# $propertiesDef_ref = getPaulAProperties( );
#
# Parameter
#	none
#
# Result:
# 	$propertiesDef_ref	- { <FQN> => { Class => <className>, Type => <type>, IsArray => <boolean> } }
#
# Exceptions:
#	CIM-Exceptions
#
sub getPaulAProperties
{
	my $propertiesDef_ref;
	
	LOG("in getPaulAProperties\n");

	unless( $isInitialized ) { init() };
	
	#
	# If a PropertiesDef file exists, is not empty and not older than one day
	# load it and use the definitions found there
	#
	# <HARDCODED>
	my $defFile = $ENV{ WEBFRONTEND_HOME }."/etc/PropertiesDef.xml";
	# </HARDCODED>
	
	if( -e $defFile && -s $defFile && -M $defFile < 1 )
	{
		LOG("### Loading $defFile ...");
		$propertiesDef_ref = XMLin( $defFile );
		LOG(" done.\n");
	}
	else
	{
		my ( $className, $sysClass, $properties );
		
		$propertiesDef_ref = {};
		
		#
		# Hier evtl. später ein enumerateClasses machen
		#
		
		foreach my $class (
			"PaulA_User", "PaulA_System", "PaulA_Group", "PaulA_DHCP", "PaulA_MTA",
			"PaulA_HTTPD", "PaulA_WWWFilter", "PaulA_Mail", "PaulA_VPN", "PaulA_IncomingMailServer",
			"PaulA_OutgoingMailDomain", "PaulA_Instance", "PaulA_ISP", "PaulA_Firewall", "PaulA_Fax" )
		{
			eval
			{
				$className	= CIM::ObjectName->new( ObjectName => $class );
				$sysClass	= $CimClient->GetClass( ClassName => $className );
				my $tmp = $sysClass->toXML()->toString();
				my $tmp2 = $sysClass->toXML()->toString();
				$tmp =~ /(aha)/;
				$properties	= $sysClass->properties();
			};
			LOGERROR( $@, "*** can't get properties!" ) and die("*** failed in Apache::Utilities::getPaulAProperties\n");
			
			my $keys = ();	# array of key properties
			foreach my $property ( @$properties )
			{
				if( $property->isKeyProperty() )
				{
					push( @{$keys}, $property->name() );
				}
			}
			#
			# save definition of each property of this class
			#
			foreach my $property ( @$properties )
			{
				my $name	= $property->name();
				my $fqn		= Apache::FullQualifiedName->new( $class, $name, 0, @$keys );
				my $FQN		= $fqn->toString();
				
				$propertiesDef_ref->{ $FQN } =
				{
					Class	=> $class,
					Type	=> $property->type(),
					IsArray	=> $property->isArray()
				};
				LOG( "$FQN:\t".
					$propertiesDef_ref->{ $FQN }{ Class }." -\t".
					$propertiesDef_ref->{ $FQN }{ Type }." -\t".
					$propertiesDef_ref->{ $FQN }{ IsArray }."\n" );
			}
			
			#
			# save definition of each method of this class
			#
if( 0 )
{
			my $methods = $sysClass->methods();
			foreach my $method ( @$methods )
			{
				my $name =  $method->name();

				my $fqn = Apache::FullQualifiedName->new( $class, $name, 0 );
				
				$propertiesDef_ref->{ $fqn->toString() } = { Type => $method->type() };
				
				foreach my $parameter ( @{$method->parameters()} )
				{
					$propertiesDef_ref->{ $fqn->toString() }{ $parameter->name() } =
					{
						Type => $parameter->type(),
						IsArray => $parameter->isArray()
					}
				}
			}
} # 
		}
		my $defStr = XMLout( $propertiesDef_ref );
		
		LOG("### Writing to $defFile ...");
		open( FILE, ">", $defFile ) or ( LOG("*** could not write to file $defFile: $!\n") and return $propertiesDef_ref );
		print FILE $defStr,"\n";
		close( FILE );
		LOG(" done.\n");
		
	} # defFile was older than a day
	
	return $propertiesDef_ref;
	
} # getPaulAProperties()


########################################################################
#
# init();
#
# Parameter:
#
# Result:
#
# Exceptions:
#	CIM-Exceptions
#
# maybe this resists one day in the new-operator ;))
#
sub init
{
	LOG("in init()\n");
	#
	# Build a (global) CIM-Client
	#

	$CimClient = CIM::Client->new( UseConfig => 1 );

	$isInitialized = 1;
	
} # init()


########################################################################
#
# init();
#
# Parameter:
#
# Result:
#
# Exceptions:
#
# maybe this resists one day in the new-operator ;))
#
sub cleanUp
{
	$isInitialized = 0;
	
	$CimClient = undef;

} # cleanUp()

########################################################################
#
# $FQNs_ref = mapIDs( $IDs_ref );
#
# Parameter:
#	$IDs_ref	- [ <id>, ... ]
#
# Result:
#	$FQNs_ref	- { <FQN> => <id> }
#
# Exceptions:
#	string
#
# Description:
#	The frontend has its own IDs for properties. Only these IDs are
#	transmitted from and to the frontend. Therefore we have to map
#	IDs to F_ull Q_ualified property N_ames and vice versa.
#
sub mapIDs
{
	my ( $IDs_ref ) = @_;
	
	# <HARDCODED>
	my $mapFile = $ENV{ WEBFRONTEND_HOME }."/etc/Mapping.xml";
	# </HARDCODED>
	
	my $fqnMappings;
	
	if( -e $mapFile && -s $mapFile )
	{
		LOG("### Loading $mapFile ...");
		$fqnMappings = XMLin( $mapFile );
		LOG(" done.\n");
	}
	else
	{
		die("*** can't open $mapFile!");
	}
	
	my $FQNs_ref = ();
	
	foreach my $ID ( @$IDs_ref )
	{
		if( exists $fqnMappings->{ $ID } )
		{
			my $FQN = $fqnMappings->{ $ID }{ QualifiedName };
			
			$FQNs_ref->{ $FQN } = $ID;
		}
		else
		{
			LOG("**** no mapping for ID $ID found!\n");
		}
	}
	
	return $FQNs_ref;
} # mapIDs()


########################################################################
#
# createPermissionList( $Node, $Value );
#
# Parameter:
#	$Node		- XML::DOM::Element
#	$Value		- string | [ <string>, ... ]
#
# Result:
#	void
#
# Exceptions:
#	CIM-Exceptions
#
# Description:
#
# This is my personal horror vision of a hack around!
#
sub createPermissionList
{
	my ( $Node, $Value ) = @_;
	
	LOG("in createPermissionList()\n");
	
	#
	# unfortunately we have to sort the forms by label and that's not as easy
	# as to say "select * from $formAttr ORDER by label; :-((((
	#
	# ( do yourself a favour and don't even try to understand the following )
	#
	
	my $formAttrs = getFormAttrs();	# ->{ <form> => { <attr> => <value> } }
	
	my $labels = ();
	
	foreach my $form ( keys %$formAttrs )
	{
		$labels->{ $formAttrs->{ $form }{ label } } = $form;
	
	}
	
	# now we have "<label> => <form>" and may sort by label (thank god labels are non-ambiguous!!)
	
	
	
	my $formPerms = ();
	if( ref( $Value ) eq "ARRAY" )
	{
		my %deleteEm;
		
		foreach my $permission ( @$Value )
		{
			$permission =~ m/(\w+)_(.)$/;
			my $formClassifier = $1;
			my $rwn = $2;
			
			my ( $form, $classifier ) = split( "_", $formClassifier );
			
			if( defined $classifier )
			{
				my $label = $formAttrs->{ $form }{ label };
				
				my $newForm = $form."_".$classifier;
				
				# unfortunately no umlauts possible in this text - don't ask me why
				my $newLabel = ($classifier eq "SELF") ? "$label bei sich selbst" : "$label bei anderen";
				
				$labels->{ $newLabel } = $newForm;
				
				my %oldAttrs = %{ $formAttrs->{ $form } };	# copy content, not the reference!
				$formAttrs->{ $newForm } = \%oldAttrs;
				$formAttrs->{ $newForm }{ label } = $newLabel;
				
				$deleteEm{ $label } = "yeah, kick it! ;)";
				
				$form = $newForm;
			}
			
			$formPerms->{ $form } = $rwn;
		}
		
		# kill the rotten
		foreach my $label ( keys %deleteEm )
		{
			delete $labels->{ $label };
		}
	}
	else
	{
		LOG("*** this shouldn't have happened!!!!\n");
		return;
	}
	
	#
	# now we have a "formPerms: <form_classifier> => { Permission => <r|w|n>, Classifier => <classifier> }"
	# and a corrected "labels: <label[+ xxx]> => <$form[_classifier]>"
	# and finally can do the twist ;))
	#
	
	foreach my $label ( sort keys %$labels )
	{
		my $formClassifier = $labels->{ $label };

		my ( $form, $classifier ) = split( "_", $formClassifier );
		
		my $permission = $formPerms->{ $formClassifier };
		
		LOG( "---> creating permissionselect for $form ($classifier) = '$permission'  Label: '$label'\n" );
		
		# this time the form is also the name of the "cimproperty" - submit sends name-attributes
		$formAttrs->{ $formClassifier }{ name } = $formClassifier;
		
		my $selectNode = appendNewNode( $Node, "permissionselect", $formAttrs->{ $formClassifier } );
		my $defaultNode = appendNewNode( $selectNode, "default", { value => $permission } );

		foreach my $key ( "r_lesen", "w_schreiben", "n_kein Zugriff" )
		{
			my ( $right, $text ) = split( "_", $key );

			if( $right eq $permission )
			{
				$defaultNode->addText( $text );
				next;
			}

			my $node = appendNewNode( $selectNode, "choice", { value => $right } );
			$node->addText( $text );
		}
		# That's what it should look like:
		#
		# <permissionselect label="Login">
		#   <default value="r">Lesen</default>
		#   <choice value="N">Keine Berechtigung</choice>
		# </permissionselect>
	}
	LOG("Done!\n");
	return;	
	
} # createPermissionList()


########################################################################
#
# insertMenuNodes( $Node, $Value );
#
# Parameter:
#	$Node		- XML::DOM::Element
#	$Value		- string | \@string		# should be an array anyway
#
# Result:
#
# Exceptions:
#
sub insertMenuNodes
{
	my ( $Node, $Value ) = @_;
	
	my $propertyName = $Node->getAttribute( "cimproperty" );
	
	#
	# IMPORTANT: If there is more than one classifier, separate them with "_" in alphabetical
	# order of their keys!!!
	#
	
	if( $propertyName eq "MenuUsers" )
	{
		for my $xmlKeys ( @$Value )
		{
			my $values	= XMLin( $xmlKeys );
			my $login	= $values->{ Login };
			my $realname	= $values->{ RealName } ? $values->{ RealName } : $login;
			
			LOG( "...appending node NODE-$realname\n" );
			
			my $userNode = appendNewNode( $Node, "node", { label => $realname, name => "NODE-".$login } );

			appendNewNode( $userNode, "node", { label => 'Login',		name => 'USERLOGIN_'.$login } );
			appendNewNode( $userNode, "node", { label => 'Faxdurchwahl',	name => 'USERFAX_'.$login } );
			appendNewNode( $userNode, "node", { label => 'Gruppe',		name => 'USERGROUPS_'.$login } );
			appendNewNode( $userNode, "node", { label => 'Mail-Aliasse',	name => 'USERMAIL_'.$login } );
			appendNewNode( $userNode, "node", { label => 'Mail-Verteiler',	name => 'USERMAILINGLISTS_'.$login } );
			appendNewNode( $userNode, "node", { label => 'Sicherheit',	name => 'USERSECURITY_'.$login } );
			appendNewNode( $userNode, "node", { label => 'Private Mails',	name => 'USERPRIVATEMAIL_'.$login } );
			appendNewNode( $userNode, "node", { label => 'Urlaub',	 	name => 'USERVACATION_'.$login } );
		}
	}
	elsif( $propertyName eq "AllGroups" )
	{
		for my $xmlKeys ( @$Value )
		{
			my $values	= XMLin( $xmlKeys );
			my $group	= $values->{ Name };
			
			LOG( "...appending node ADMINGROUPS_$group\n" );
			appendNewNode( $Node, "node", { label => $group, name => "ADMINGROUPS_$group" } );
		}
	}
	elsif( $propertyName eq "AllIncomingServers" )
	{
		for my $xmlKeys ( @$Value )
		{
			my $values	= XMLin( $xmlKeys );
			my $ServerName	= $values->{ ServerName };
			my $Login	= $values->{ Login };
			
			LOG( "...appending node MAILSERVERINSETTINGS_$ServerName\n" );
			appendNewNode( $Node, "node", {
				label => $ServerName."(".$Login.")",
				name => "MAILSERVERINSETTINGS_".$Login."_$ServerName"
				} );
		}
	}
	elsif( $propertyName eq "AllOutgoingDomains" )
	{
		for my $xmlKeys ( @$Value )
		{
			my $values	= XMLin( $xmlKeys );
			my $domain	= $values->{ Domain };
			
			LOG( "...appending node DOMAINSETTINGS_$domain\n" );
			appendNewNode( $Node, "node", { label => $domain, name => "DOMAINSETTINGS_$domain" } );
		}
	}
	else
	{
		LOG( "*** unsupported cimproperty $propertyName in menu!\n" );
	}

	return;

} # insertMenuNodes()

########################################################################
#
# $formAttr = getFormAttrs()
#
# Parameter:
#	none
#
# Result:
#	$formAttr	- { <form> => { <attr> => <value>, ... } }
#
# Exceptions:
#	string
#
sub getFormAttrs
{
	my $fileName = $ENV{ WEBFRONTEND_HOME }."/xml/paula.xml";

	open( FILE, $fileName ) or die("*** konnte die Datei $fileName nicht laden: $!\n");

	my $match = "<?xml version='1.0' encoding='iso-8859-1'?><opt>";
	my $line;
	
	while( $line=<FILE> )
	{
		if( $line =~ /^\s*(<form).*/g )
		{		
			$match .= $line."</form>\n";		
		}

	}

	$match = "$match</opt>";

	my $hash = XMLin( $match, keyattr => "name" );

	close( FILE );
	
	return $hash->{ form };
	
} # getFormAttrs()


########################################################################
#
# $valule_ref = getValueAsRef( $Property )
#
# Parameter:
#	$Property	- CIM::Property
#
# Result:
#	$valule_ref	- string | \@string | \@{ <key> => <value> }
#
# Exceptions:
#
sub getValueAsRef
{
	my ( $Property ) = @_;
	
	
	my $value = $Property->value();
	
	unless( $value ){ return undef; }
	
	my $value_ref = $value->valueAsRef();
	
	# This may be a reference to an array or a string;
	# the array may contain strings in XML notation to support multiple keybindings.

	# At the moment this is only the case for menu entries respectively node tags
	# and they know themselves that the value is XML::Simple encoded. Maybe we'll
	# change that in future versions...

	# ( The reason why only menu entries have XML::Simple encoded values is, that we
	# only encode in get_PAULAMENU !!! )
	
# 	my $fqn;
# 	eval { $fqn = Apache::FullQualifiedName->new( $Property->name() ) };
# 	unless( $@ )
# 	{
# 		if( $fqn->isEnumeration() && ( scalar $value_ref > 0 ) )
# 		{
# 			my @newValues;
# 			
# 			foreach my $v ( @{ $value_ref } )
# 			{
# 				push( @newValues, XMLin( $v ) );
# 			}
# 			return \@newValues;
# 		}
#	}

	return $value_ref;
	
} # getValueAsRef()


########################################################################
#
# createSingleSelect( $Node, $Value, $Result_ref )
#
# Parameter:
#	$Node		- XML::DOM::Node
#	$Value		- string | \@string | \@{ ... }
#	$Result_ref	- { <id> => <CIM::Property> }
#
# Result:
#	void
#
# Exceptions:
#
# Known Bugs:
#	Uuuups, \@{ ... } unchecked! Yet only in MenuEntries
#
sub createSingleSelect
{
	my ( $Node, $Value, $Result_ref ) = @_;
	
	my $document = $Node->getOwnerDocument();
	
	#
	# Now we have to find out if we have a default value and if it is a member of the
	# values returned by paul. There are three cases:
	#
	# - no default:
	#	create a default saying "no value selected!"
	#
	# - default is given and member of the returned values:
	#	select it and remove the given default
	#
	# - default is given but not member of the returned values:
	#	set default to sth. like "invalid default value xxx"
	#	unless it's an empty value -> "no value selected!"
	#

	my $default = getFirstTagNamed( "default", "", $Node, 0 );

	my $defaultValue = "";	# = "#no default#";

	if( defined $default )
	{
		LOG( "--> Ahh, there is a default for this singleselect!\n" );
		# <HARDCODED>
		my $id = $default->getAttribute( "choosefrom" );
		# </HARDCODED>

		my $defaultProperty = $Result_ref->{ $id };

		$defaultValue = defined $defaultProperty ? $defaultProperty->value()->value() : "";

		LOG( "--> Default is >$defaultValue<\n" );
	}

	#
	# Add the tags choice/default
	#

	my $foundDefault = 0;
	foreach my $v ( sort @$Value )
	{
		my ( $value, $text );
		
		if( ref ( $v ) eq "HASH" )
		{
			$value	= $v->{ Value };
			$text	= $v->{ Text };
		}
		else
		{
			$value	= $v;
			$text	= $v;
		}
		
		my $tag = "choice";

		LOG( "--> choice: $text ( $value )\n" );

		if( $value eq $defaultValue )
		{
			LOG( "--> Found default in selection!\n");
			$tag = "default";
			$foundDefault = 1;
		}

		my $newElem = $document->createElement( $tag );
		$newElem->setAttribute( "value", $value );
		$newElem->addText( $text );
		$Node->appendChild( $newElem );
	}

	if( $foundDefault )
	{
		LOG( "--> Removing old default!\n" );
		$Node->removeChild( $default );
	}
	elsif( $defaultValue eq "" )
	{
		my $msg = "--- keine Angabe ---";

		if( $default )
		{
			$default->addText( $msg );
			$default->setAttribute( "value", "" );
			LOG( "--> setting default to special message '$msg'\n" );
		}
		else
		{
			my $newElem = $document->createElement( "default" );
			$newElem->addText( $msg );
			$newElem->setAttribute( "value", "" );
			$Node->appendChild( $newElem );
			LOG( "--> creating default with special message '$msg'\n" );
		}
	}
	else 
	{
		$default->addText("Ungültiger Wert: >$defaultValue<");
		LOG( "-->\n".$default->toString()."\n" );
	}
	
	return;
} # createSingleSelect()


########################################################################
#
# createSingleSelect( $Node, $Value )
#
# Parameter:
#	$Node		- XML::DOM::Node
#	$Value		- string | \@string | \@{ <key> => <value> }
#
# Result:
#	void
#
# Exceptions:
#
sub createListMembers
{
	my ( $Node, $Value ) = @_;
	
	unless( $Value ){ return; }	# nothing to do
	
	#
	# Three cases: string, \@string, \@{ ... }
	#
	
	if( ref( $Value ) eq "ARRAY" )
	{
		unless( $Value->[0] ){ return; }	# empty array -> nothing to do
		
		foreach my $v ( sort @$Value )
		{
			my $newElem = $Node->getOwnerDocument()->createElement( "member" );
			$newElem->addText($v);
			$Node->appendChild($newElem);
		}
	}
	else # we are a scalar (string) - this may or may not be
	{
		my $newElem = $Node->getOwnerDocument()->createElement( "member" );
		$newElem->addText( $Value );
		$Node->appendChild( $newElem );
	}
	
	return;
}

########################################################################
#
# createRange( $Node, $Value )
#
# Parameter:
#	$Node		- XML::DOM::Node
#	$Value		- string | \@string | \@{ <key> => <value> }
#
# Result:
#	void
#
# Exceptions:
#
# Description:
#	$Value looks sth. like "300::303"
#
sub createRange
{
	my ( $Node, $Value ) = @_;
	
	my $startElem	= $Node->getOwnerDocument()->createElement( "rangestart" );
	my $endElem	= $Node->getOwnerDocument()->createElement( "rangeend" );
	
	my ( $startValue, $endValue ) = split( "::", $Value );
	
	$startElem->addText( $startValue );
	$endElem->addText( $endValue );
	
	$Node->addText( $Value );
	$Node->appendChild( $startElem );
	$Node->appendChild( $endElem );
	
	return;
}



########################################################################
#
# --- here are the subroutines defined ---------------------------------
#
########################################################################




########################################################################
# _insertText( $node, $text )
#
# inserts a new textnode or set an existing textnode to the given value
#
sub _insertText
{
	my ( $node, $text ) = @_;
	my $child = $node->getFirstChild();
	
	if( $child )
	{
		my $txt = $child->getData();
		
		if( $txt =~ /^\s*$/ )
		{
			$child->setData( $text );
		}
		else
		{
			$child->appendData( $text );
		}
	}
	else
	{
		$node->addText($text);
	}
}


########################################################################
#
# _removeDeadlinks( $MenuDoc )
#
# Parameter:
#	$MenuDoc	- XML::DOM::Document
#
# Result:
#	void
#
# Exceptions:
#
# Description:
# 	Check recursively whether menu-nodes have children.
# 	If a menu node has no children, remove it.
#
sub _removeDeadlinks
{
	my ( $MenuDoc ) = @_;
	
	foreach my $subnode ( $MenuDoc->getElementsByTagName('node',0) )
	{
		my $nodeName = $subnode->getAttribute('name');
		
		if( $nodeName && ($nodeName =~ /^NODE/) )
		{
			_removeDeadlinks( $subnode );
			
			LOG("### checking node '$nodeName' ");
			
			#
			# check for remaining menu-nodes 
			#
			my @remainder = $subnode->getElementsByTagName('node');

			if( (scalar @remainder) == 0 )
			{
				$subnode->getParentNode()->removeChild( $subnode );
				LOG("... removed\n");
			}
			else
			{
				LOG("... ok\n");
			}
		}
	}
	return;
	
} # removeDeadLinks()


1;
