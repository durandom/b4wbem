use strict;

##########################
package PaulA::Repository;
##########################
use Carp;

use XML::DOM;
use Tie::SecureHash;

use CIM::Error;
use CIM::Utils;
use CIM::Association;
use PaulA::Provider;


my $associationNs = "Assoc";

my %assoFuncs = ( 
		 Associators     => 1,
		 AssociatorNames => 1,
		 References      => 1,
		 ReferenceNames  => 1,
		);

my $verbose = 0;  # for more verbose output (just for developing)


sub new {
    my ($class, %args) = @_;
    
    my $self = Tie::SecureHash->new($class);
    
    $self->{'PaulA::Repository::_CIMOMHandle'} = $args{CIMOMHandle};
    #	or croak "No CIMOMHandle was given to the Repository"; 
    

    defined $self->{_CIMOMHandle}->config->repositoryRoot() 
	or croak "No repository root found";
    -d $self->{_CIMOMHandle}->config->repositoryRoot() or
	croak "Root directory " . 
	    $self->{_CIMOMHandle}->config->repositoryRoot() . 
		" doesn't exist";

    $self->{'PaulA::Repository::_namespacePath'} = $args{NamespacePath};
    croak "No NamespacePath was given to the Repository" 
	unless $args{NamespacePath};

    $self->namespacePath->host("someHost") 
	unless defined $self->namespacePath->host;

    # absolut path for the query
    $self->{'PaulA::Repository::_absolutePath'} = 
	$self->{_CIMOMHandle}->config->repositoryRoot();
    
	my @nsp = $self->namespacePath()->namespace();
	foreach (@nsp) {
	    next if /^root$/;
	    $self->{_absolutePath} .= "/$_";
	}
    
    return $self;
}

sub namespacePath {
    my $self = shift;
    
    $self->{_namespacePath} = $_[0] if defined $_[0];

    return $self->{_namespacePath};
}

use vars '$AUTOLOAD';

sub AUTOLOAD {
    my ($self, %args) = @_;

    return if $AUTOLOAD =~ /::DESTROY$/; # see Conway, p. 112

    # get name of the intrinsic method:
    my $method;
    ($method = $AUTOLOAD) =~ s/.*:://;
    
    black("Method: $method") if $verbose;
    my $info = CIM::IMethodInfo->new;

    # get the object name of the query
    my $qn = $args{$info->extractClass($method)->[0]};

    # set values, defaults if not given
    $info->fillArgsWithDefaultValues(\%args, $method);

    my ($object, $schema, @allAssoc);
    my ($patternA, $patternB);
    my $qnAsString = $qn->objectName();	# object name as string

    # we need 3 different search patterns for the various methods:
    # looking for classes:
    if ($method eq "GetClass" || $qn->convertType eq "CLASSNAME") {
	$schema = $1;
	$patternA = "^\\s*<CLASS\\s+NAME=\"$qnAsString\"";
	# looking for an association class:
	if ($method ne "GetClass") {
	    $patternA = "^\\s*<CLASS\\s+NAME=";
	}
	$patternB = "^\\s*<\/CLASS>";
    }
    # looking for an association instance:
    else {
	$patternA = "^\\s*<INSTANCE CLASSNAME=";
	$patternB = "^\\s*<\/INSTANCE>";
    }	
    
    # getting the absolute pathname
    my $path = $self->{_CIMOMHandle}->config->repositoryRoot();
    # If we're looking for an association instance, set path to Assoc dir
    if ($qn->convertType eq "INSTANCENAME" && $method ne "GetClass") {
	$path .= "/$associationNs" if (-d "$path/$associationNs");
    }
    else { # look in the namespace of the query to the repository   # mark
	$path = $self->{_absolutePath};
	
    # does the complete namespace path exist?
	-d $path 
	    or die CIM::Error->
		new(Code => CIM::Error::CIM_ERR_INVALID_NAMESPACE);
    }

    #black("PATH: $path");

    # getting a handle for the files in $path
    opendir(DIR, $path) or croak "could not open directory $path";
    
#--------------------------------------------------------------------
    
    # filter files
    my @files;
    while (defined (my $file = readdir DIR)) {
	# we want only the text files of DIR
	next unless -T "$path/$file";
	# put files named after the object name at the beginning
	# of the array -> will be searched first
	if ($file eq "C-$qnAsString.xml" && $method eq "GetClass") {
	    unshift @files, $file; 
	}
	# a schema file will be searched if we're looking for a class
	elsif ($file =~ /^S-/ &&
		($qn->convertType eq "CLASSNAME" || $method eq "GetClass")) {
	    push @files, $file;
	}
	# an association file  will be searched if we're dealing with
	# associations
	elsif ($file =~ /^A-/ && $method ne "GetClass" 
		&& $qn->convertType eq "INSTANCENAME") {
	    push @files, $file;
	}
    }
    
    black("Files: @files") if $verbose;
    
    # search files, general file read function:
    
    my $isRightAsso;
    if ($method eq "GetClass") {
	$isRightAsso = 0;
    }
    # for all functions who's target objects can't be identified until later
    else {
	$isRightAsso = 1;
    }
    
    
    foreach my $file (@files) {
	open FILE, "$path/$file" or croak "could not open file $path/$file";
	my $nesting = 0;
	while (<FILE>) {
	    chomp;
	    if (/$patternA/) {
		$nesting++;
	    }
	    # we don't want to save all association objects 
	    # -> preselection of possibly right objects
	    # for classes or instances
	    # not sure whether matching for the REFERENCECLASS value is correct
 	    if (/^\s*<PROPERTY.REFERENCE.+REFERENCECLASS="$qnAsString">\s*$/
		    || /^\s*<INSTANCENAME CLASSNAME="$qnAsString">\s*$/ ) {
		$isRightAsso = 1;
	    }
	    if ($nesting > 0) {
		s/^\s+//;
		s/\s+$//;
		$object .= $_;
	    }
	    if (/$patternB/ && $nesting > 0) {
		$nesting--;
 		if ($nesting == 0) {
 		    if ($method eq "GetClass") {
		    # stop searching this file if the class/instance is found
			last;
		    }
		    if ($isRightAsso) {
			push @allAssoc, $object;
			# reset selection flag to zero	
			$isRightAsso = 0;
		    }
		    undef $object;
		
		}
	    }
	}
	
	close FILE;


	# search no more files if the class is already found
	last if (defined $object);

    }
    closedir DIR;
    # check for success in case of GetClass:
    if ($method eq "GetClass") {
	die CIM::Error->new(Code => CIM::Error::CIM_ERR_NOT_FOUND)
	    unless ($object);
	
	# convert XML text to CIM objects
	my $class = $self->fromXML($info, $method, $object, %args);

	return $class;
    }
    # mark
    # her should be returned undef if we're dealing with an associator function

    # case GetInstance etc?
    
    # convert XML text to CIM objects and select the desired
    # association objects
    else {
	my @allAssocObj =
	    $self->fromXMLAssoc($info, $method, \@allAssoc, %args);
	
	my @assoSelect;

	# if we're dealing with an instance
	if ($qn->convertType eq "INSTANCENAME") {
ASSO:	    foreach my $elem (@allAssocObj) {
		foreach my $prop ($elem->properties) {
		    foreach my $p (@{$prop}) {

			# collect associations refering to the query
			if ($qn == $p->value->value) {
			    push @assoSelect, $elem;
			    next ASSO;
			}
		    }
		}
	    }
	}
	# if we're dealing with a class
	else {
ASSO:	    foreach my $elem (@allAssocObj) {
		foreach my $prop ($elem->properties) {
		    foreach my $p (@{$prop}) {
			# for classes there is no prop. value defined
			# collect associations refering to the query
			# via the referenceClass tag
			if (defined $qn->objectName and
			    defined $p->referenceClass and
			    $qn->objectName eq $p->referenceClass) {
			    push @assoSelect, $elem;
			    next ASSO;
			}
		    }
		}
	    }
	}

	die CIM::Error->new(Code => CIM::Error::CIM_ERR_NOT_FOUND)
	    unless (@assoSelect);
	
	# call the method specific functions
 	my $call = "_" . $method;
 	my @result = $self->$call(\@assoSelect, $qn);
 	
 	return @result;
    }

}


sub _References {
    my ($self, $assocRef) = @_;

    my @result;
    foreach my $elem (@$assocRef) {
	my $on = $self->createObjectName($elem, $self->namespacePath);
	my $vo = $self->createValueObject($elem, $on);	

	push @result, $vo;	
    }
    return @result;
}

sub _ReferenceNames {
    my ($self, $assocRef) = @_;
    
    my @result;
    foreach my $elem (@$assocRef) {
	my $on = $self->createObjectName($elem, $self->namespacePath);
	if ($on->convertType eq "INSTANCENAME") {
	    $on->convertType("OBJECTPATH-INSTANCENAME");
	}
	else {
	    $on->convertType("OBJECTPATH-CLASSNAME");
	}
	push @result, $on;
    }
    return @result;
}

sub _Associators {
    my ($self, $assocRef, $qn) = @_;
    # get objects refered to

    my @selectedProp = $self->selectProperties($assocRef, $qn);
    my @result;
    
    # get the objects conforming to the properties
    foreach my $p (@selectedProp){
	
	if ($qn->convertType eq "CLASSNAME") {

	    my $on = CIM::ObjectName->new(ObjectName    => $p->referenceClass,
					  ConvertType   => "CLASSNAME",
					  NamespacePath => $self->namespacePath,
					  );
	    
	    my $object = $self->GetClass(ClassName => $on);
	    
	    my $vo = $self->createValueObject($object, $on);	
	    
	    push @result, $vo;
	}

	else {
	    my $instance;
	    
	    my $providername = $p->value->value->objectName;

	    my $cimom = $self->{_CIMOMHandle};
	    
	    eval { ($instance) =
		       $cimom->invokeIMethod($self->namespacePath,
					     'GetInstance',
					     InstanceName => $p->value->value)
		   };

	    if ($@) {
		black($@);
	    }
	    
	    # to get an INSTANCEPATH, we need a nsp (with host) 
	    # in the object name:
 	    $p->value->value->namespacePath($self->namespacePath);
		
	    my $vo = $self->createValueObject($instance, $p->value->value);

	    push @result, $vo;
	}
    }
    

    return @result;
}

sub _AssociatorNames {
    my ($self, $assocRef, $qn) = @_;

    # get properties of the association
    my @selectedProp = $self->selectProperties($assocRef, $qn);
    my @result;
    
    # get the object names conforming to the properties
    foreach my $p (@selectedProp){
	my $on;	
	if ($qn->convertType eq "CLASSNAME") {

	    $on = CIM::ObjectName->new(ObjectName    => $p->referenceClass,
				       ConvertType   => "OBJECTPATH-CLASSNAME",
 				       NamespacePath => $self->namespacePath,
				    # as properties in classes don't have values
				      );
	}
	else {
	    $on = CIM::ObjectName->
		new(ObjectName    => $p->value->value->objectName,
		    KeyBindings   => $p->value->value->keyBindings,
		    ConvertType   => "OBJECTPATH-INSTANCENAME",
 		    NamespacePath => $p->value->value->namespacePath,
		   );
	}
	
	push @result, $on;
    }
    
    return @result;
    
}

sub selectProperties {
    my ($self, $assocRef, $qn) = @_;
    
    my @selectedObjects;
    my @selectedProp;
    if ($qn->convertType eq "INSTANCENAME") {
      ASSO:
	foreach my $elem (@$assocRef) {
	    foreach my $prop ($elem->properties) {
		foreach my $p (@{$prop}) {
		    
		    # collect associations refering to the query
		    if ($qn != $p->value->value) {
			# set the namespacePath of the ObjectName pointed
			# to by the property reference according to the
			# one of the query to the repository 
			# (unless it's already set)
			$p->value->value->namespacePath($self->namespacePath)
			    unless defined $p->value->value->namespacePath();

			push @selectedProp, $p;
			next ASSO;
		    }
		}
	    }
	}
    }
    else {
      ASSO:
	foreach my $elem (@$assocRef) {
	    foreach my $prop ($elem->properties) {
		foreach my $p (@{$prop}) {
		    # for classes there is no prop. value defined
		    # collect associations refering to the query
		    # via the referenceClass tag
		    if ($qn->objectName ne $p->referenceClass) {
			push @selectedProp, $p;
			next ASSO;
		    }
		}
	    }
	}
    }
    return @selectedProp;
}


sub findKeys {
    my ($self, $object) = @_;

    # for "GetClass": type of object has to be changed to CLASSNAME,
    # will be changed again in _ReferenceNames
    $object->convertType("CLASSNAME");
    my $class = $self->GetClass(
  				ClassName => $object,
				);

    my @keys;
    foreach my $propArray ($class->properties) {
	foreach my $prop (@{$propArray}) {
	    foreach my $qualiArray ($prop->qualifiers) {
		foreach my $quali (@$qualiArray) {
		    if ($quali->name eq "key" && $quali->value->value eq '1') {
			 push @keys, $prop->name;
		    }
		}
	    }
	}
    }

    # currently we don't search for the key qualifiers in superclasses
    # if the key properties aren't discernible from the current class,
    # we can't find them.
    # It's also assumed here that 2 key properties are required.
    die CIM::Error->new(Code => CIM::Error::CIM_ERR_NOT_SUPPORTED)
	unless ($#keys == 1);
    
    return @keys;
}

sub createObjectName {
    my ($self, $object, $nsp) = @_;
    
    my ($name, $convertType, @keys, %keyBindings, $on);
    if ("CIM::Class" eq ref $object) {

	$on = CIM::ObjectName->new( 
 				ObjectName => $object->name,
				NamespacePath => $nsp,
				ConvertType => "CLASSNAME",
				);
    }
    else {
	$on = CIM::ObjectName->new(
 				ObjectName => $object->className,
				NamespacePath => $nsp,
				# not set as it will be changed anyway:
				# ConvertType => "INSTANCENAME",
				);
	
	# get keyBindings
	@keys = $self->findKeys($on);
	foreach (@keys) {
	    $keyBindings{$_} = $object->propertyByName($_)->value->value;
	}
	
	$on->convertType("INSTANCENAME");
	$on->keyBindings(\%keyBindings);
    }
	
    return $on;
}

sub createValueObject {
    my ($self, $object, $on) = @_;

    my $vo = CIM::ValueObject->new(
				Object => $object,
				ObjectName => $on,
				);

    return $vo;
}


# Assoc functions have to process an array
# => fromXML has to be called several times
sub fromXMLAssoc {	
    my ($self, $info, $method, $assocRef, %args) = @_;

    my @assocObjects;
    foreach (@$assocRef) {
 	my $object = $self->fromXML($info, $method, $_, %args);
	push @assocObjects, $object;
    }
    
    return @assocObjects;
}


# fromXML for a single object
sub fromXML {
    my ($self, $info, $method, $object, %args) = @_;
    
    # creating a DOM tree
    my $parser = new XML::DOM::Parser;
    my $doc = $parser->parse($object);

    # scan arguments given to the method:

    # exclude qualifiers in case of need
    if (exists $args{IncludeQualifiers} &&
	$args{IncludeQualifiers}->value == 0) {

	foreach my $node ($doc->getElementsByTagName('QUALIFIER')) {
	    $node->getParentNode->removeChild($node);
	}
    }
    # exclude properties in case of need
    if (exists $args{PropertyList}) {
	foreach my $node ($doc->getElementsByTagName('PROPERTY')) {
	    my $name =
		$node->getAttributes->getNamedItem('NAME')->getValue;
	    
	    $node->getParentNode->removeChild($node)
		unless (scalar (grep { /^$name$/ } ($args{PropertyList}->value)));
	}
    }

    # conditions may have to be changed when implementing actions for
    # the following parameters
    if ($args{LocalOnly}) {
	# ToDo
    }
    if ($args{ClassOrigin}) {
	# ToDo
    }
    if ($args{Role}) {
	# ToDo
    }
    if ($args{ResultRole}) {
	# ToDo
    }
    if ($args{ResultClass}) {
	# ToDo
    }
    if ($args{AssocClass}) {
	# ToDo
    }
	
	
    # return the class/association instance
    if ($object =~ /^\s*<CLASS/) {
	my $class = CIM::Class->new(XML => $doc);
	return $class;
    }
    return CIM::Association->new(XML => $doc);

}

sub isValidClass {
    my ($self, $classname) = @_;

    my $target = $self->{_absolutePath} . "/C-" . $classname . ".xml";
    
    (-e $target)? 1 : 0;
    
}

1;


__END__


=head1 NAME

PaulA::Repository - Module for retrieving a class or associations from the repository



=head1 SYNOPSIS

 use PaulA::Repository;

 $repository = PaulA::Repository->new(	CIMOMHandle => $cimom_object,
					NamespacePath => $nsp );

 $class = $repository->GetClass(ClassName => $objectName);



=head1 DESCRIPTION

The PaulA::Repository module is needed for working with the repository.
Here all methods which need to extract information from the repository
can be found.

=head1 NOTES

=item Organization of this module

A major reorganization is necessary.
At the moment the intrinsic methods all use the AUTOLOAD function and only 
split up later calling method specific functions.
This all got kind of messy and has to be changed before more functionality 
can be added.

=item Parameters

For all methods implemented, the optional parameters have been neglected 
for the most part. Only those parameters mentioned will work.


=head1 CONSTRUCTOR

=over 4

=item new([OPTIONS])

C<OPTIONS> are passed in a hash like fashion, using key and value pairs.
The possible options are:

B<CIMOMHandle> - mandatory, it's  value is a ServerConfig object.

B<NamespacePath> - mandatory, the value is a CIM::NamespacePath object.


=head1 METHODS

=item GetClass(B<OPTIONS>);

B<ClassName> - mandatory, value has to be a CIM::ObjectName representing a 
CLASSNAME.

B<IncludeQualifiers> - optional, value is boolean.
Mandatory if not called via CIMOM.

B<PropertyList> - optional, value is an array reference,
only properties from the PropertyList are included in the returned
CIM object.
If no 'PropertyList' is given
-> all properties are included in the returned object.
If an empty 'PropertyList' is given
-> no property is included in the returned object.

Returns the CIM class corresponding to the given CLASSNAME.


=item Associators(B<OPTIONS>);

B<ObjectName> - mandatory, value has to be a CIM::ObjectName representing a 
CLASSNAME or an INSTANCENAME.

Returns an array of CIM objects associated to the given source CIM object.


=item AssociatorNames(B<OPTIONS>);

B<ObjectName> - mandatory, value has to be a CIM::ObjectName representing a 
CLASSNAME or an INSTANCENAME.

Returns an array of CIM object names of objects associated to the given 
source CIM object.


=item References(B<OPTIONS>);

B<ObjectName> - mandatory, value has to be a CIM::ObjectName representing a 
CLASSNAME or an INSTANCENAME.

Returns an array of CIM association objects that refer to a given CIM object.


=item ReferenceNames(B<OPTIONS>);

B<ObjectName> - mandatory, value has to be a CIM::ObjectName representing a 
CLASSNAME or an INSTANCENAME.

Returns an array of CIM object names of association objects that refer 
to a given CIM object.


=head2 INTERNAL FUNCTIONS

=item _References 

=item _ReferenceNames 

=item _Associators 

=item _AssociatorNames

=item namespacePath([$nsp])

Get-/set function for the namespace path. 
Input: optional, CIM::NamespacePath object.
Return value: CIM::NamespacePath object.

=item selectProperties($assoc, $queryName)

Function called by _Associators() and _AssociatorNames(), returns an array 
of the property references which point to the related classes.
Input: a CIM::Association object and the object name of the query.
Return value: Array of the selected properties.

=item findKeys($object)

Input: CIM::ObjectName object.
Return value: array with the names of the key properties of the object.
Doesn't work if the key properties aren't listed in the affected class but 
are propagated from a superclass.

=item createObjectName($object, $nsp)

Input: A CIM::Class or Association object and a CIM::NamespacePath object.
Return value: CIM::ObjectName.

=item createValueObject($object, $on)

Input: A CIM::Class or Association object and a CIM::ObjectName.
Return value: CIM::ValueObject.

=item fromXML($info, $method, $object, %args)

Creates an instance from the XML::DOM::Element
Input: CIM::IMethodInfo object, name of the method applied (e.g. "GetClass"),
xml representation of a CIM class, and a hash of the Parameters passed to 
the method (e.g. GetClass) called. 
Return value: A CIM::Class or a CIM::Association object.
    
=item fromXMLAssoc($info, $method, $assocRef, %args)

Queries concerning associations need to deal with an array of at least 
two classes, fromXMLAssoc() calls fromXML() for each class.
Parameters as in fromXML(), only the third parameter is a reference pointing 
to an array of xml representations of CIM classes.
Return value: array of CIM::Association objects.

=item isValidClass($classname)

Checks wether a file C-{$classname}.xml exists.
Input: class name, string.
Return value: boolean.
    

=head1 SEE ALSO

L<PaulA::CIMOM>


=head1 AUTHORS

 Eva Bolten <bolten@ID-PRO.de>
 Volker Moell <moell@gmx.de>


=head1 COPYRIGHT

Copyright (c) 2000 ID-PRO Deutschland GmbH. All rights reserved.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307,
USA.

=cut
