package Apache::FullQualifiedName;

use strict;

use Apache::Utilities;

########################################################################
#
# $fqn		= new( $Sting );
# $fqn		= new( $Class, $Identifier, $IsEnumerated [, $Keybinding ... ] );
#
# $string	= toString();
# $rc		= isEnumeration( );
# ( ... )	= getComponents();
# $rc		= equals( $FQN );
# $rc		= equals( $Class, $Identifier );
# $className	= getClass();
# $identifier	= getIdentifier();
# $keybindings	= getKeybindings( );
#


########################################################################
#
# $fqn = Apache::FullQualifiedName::new( $Sting );
# $fqn = Apache::FullQualifiedName::new( $Class, $Identifier, $IsEnumerated [, $Keybinding ... ] );
#
# Parameter:
#	$String		- string
#
#	$Class		- string
#	$Identifier	- string
#	$IsEnumerated	- boolean
#	$Keybinding	- string
#
# Result:
#	$fqn		- Apache::Apache::FullQualifiedName
#
# Exceptions:
#	string
#
sub new
{
	my ( $class, @args ) = @_;
	
	my $self = {};
	
	if( scalar @args == 1 )
	{
		my $String = shift @args;

		# at least a classname and an identifier must be given

		unless( $String =~ /.+::.+/ )
		{
			die( "*** ".$class."::new( '$String' ) -> not a full qualified name as parameter");
		}
		
		my ( $at, $className, $rest ) = $String =~ /^(@)?(.+?)::(.+)/;
		
		my @keybindings = split( ":", $rest );
		my $identifier = shift @keybindings;	# first element of rest is identifier

		$self->{ Class }	= $className;
		$self->{ Identifier }	= $identifier;
		$self->{ IsEnumerated }	= defined $at ? 1 : 0;
		$self->{ Keybindings }  = \@keybindings;
	}
	elsif( scalar @args > 2 )
	{
		$self->{ Class }	= shift @args;
		$self->{ Identifier }	= shift @args;
		$self->{ IsEnumerated }	= shift @args;
		
		my @keys = ();
		
		while( defined( $_ = shift @args ) )
		{
			push( @keys, $_ );
		}
		$self->{ Keybindings }	= \@keys;
	}
	else
	{
		die( "*** invalid number of arguments" );
	}
	
	bless $self, $class;

	return $self;

} # new()
		
########################################################################
#
# $string = Apache::FullQualifiedName::toString();
#
# Parameter:
#	none
#
# Result:
#	$string		- string
#
# Exceptions:
#	none
#
sub toString
{
	my $self = shift;

	#
	# At the moment a FQN looks like this: [@]<className>::<identifier>[:key,...]
	#
	my $FQN = $self->{ IsEnumerated } ? "@" : "";
	
	$FQN .= $self->{ Class }."::".$self->{ Identifier };
	
	foreach my $key ( @{ $self->{ Keybindings } } )
	{
		$FQN .= ":".$key;
	}

	return $FQN;
} # toString()


########################################################################
#
# $rc = Apache::FullQualifiedName::isEnumeration( );
#
# Parameter:
#	none
# Result:
#	$rc		- boolean
#
# Exceptions:
#	none
sub isEnumeration
{
	my $self = shift;
	
	return $self->{ IsEnumerated } ? 1:0;
} # isEnumeration


########################################################################
#
# ( $ClassName, $Identifier, $isEnumeration [, $Keybinding, ... ] ) = Apache::FullQualifiedName::getComponents();
#
# Parameter:
#	none
#
# Result:
#	$ClassName	- string
#	$Identifier	- string
#	$isEnumeration	- string
#	$Keybindings	- \@string
#
# Exceptions:
#	none
#
sub getComponents
{
	my $self = shift;
	
	my @components;
	
	push( @components, $self->getClass() );
	push( @components, $self->getIdentifier() );
 	push( @components, @{ $self->getKeybindings() } );
	
	return @components;
	
} # getComponents()


########################################################################
#
# $rc = Apache::FullQualifiedName::equals( $FQN );
# $rc = Apache::FullQualifiedName::equals( $Class, $Identifier );
#
# Parameter:
#	$FQN		- Apache::FullQualifiedName
#	$Class		- string
#	$Identifier	- string
#
# Result:
#	$rc		- boolean
#
# Exceptions:
#	string
#
sub equals
{
	my ( $self, @args ) = @_;
	
	unless( defined $args[0] ) { die( "*** invalid number of arguments" ); }
	
	if( ref( $args[0] ) eq "Apache::FullQualifiedName" )	# ok, bad style ... #-/
	{
		my $obj = shift @args;
		#
		# class plus identifier identify a property - the other stuff are attributes
		#
		if(	$self->getClass()	eq $obj->getClass() &&
			$self->getIdentifier()	eq $obj->getIdentifier() )
		{
			return 1;
		}
	}
	elsif( not ref( $args[0] ) )
	{
		unless( defined $args[1] ) { die( "*** invalid number of arguments" ); }
		
		my ( $Class, $Identifier ) = @args;

		if(	$self->getClass()	eq $Class &&
			$self->getIdentifier()	eq $Identifier )
		{
			return 1;
		}
	}
	else
	{
		die( "*** invalid type of argument" );
	}
	
	return 0;
	
} # equals()


########################################################################
#
# $className = Apache::FullQualifiedName::getClass();
#
# Parameter:
#	none
#
# Result:
#	$className	- string
#
# Exceptions:
#	none
#
sub getClass
{
	my $self = shift;

	return $self->{ Class };
} # getClass()


########################################################################
#
# $identifier = Apache::FullQualifiedName::getIdentifier();
#
# Parameter:
#	none
#
# Result:
#	$identifier	- string
#
# Exceptions:
#	none
#
sub getIdentifier
{
	my $self = shift;

	return $self->{ Identifier };
} # getIdentifier()


########################################################################
#
# $keybindings = Apache::FullQualifiedName::getKeybindings( );
#
# Parameter:
#	none
#
# Result:
#	$keybindings	- \@string
#
# Exceptions:
#	none
#
sub getKeybindings
{
	my $self = shift;

	return $self->{ Keybindings };
} # getKeybindings()


1;
