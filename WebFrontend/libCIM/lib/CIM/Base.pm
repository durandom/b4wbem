use strict;

##################
package CIM::Base;
##################
use Carp;

use Tie::SecureHash;
use XML::DOM;

use CIM::TagInfo;
use CIM::IMethodInfo;
use CIM::Utils;


sub new {
    my ($class) = @_;   
    
    my $self = Tie::SecureHash->new($class);
    
    $self->{'CIM::Base::_childAccessors'} = {};
    $self->{'CIM::Base::_attrAccessors'} = {};
    
    $self->{'CIM::Base::_validConvertTypes'} = undef;
    $self->{'CIM::Base::_convertType'} = undef;
    
    $self->{'CIM::Base::_identifier'} = undef; 

    return $self;
}


sub processArgs {
    my ($self, %args) = @_;

    
    my $class = ref $self;
    my $callingClass = (caller)[0];


    if (exists $args{XML}) {
	
	# If there is an XML argument, we have to call fromXML() --
	# but only if we are in the leaf class:
	return if $class ne $callingClass;
	
	my $node = $args{XML};

	# convert a XML string into a XML node
	unless (ref $node) {
	    my $parser = XML::DOM::Parser->new;
	    $node = $parser->parse($node)->getDocumentElement();
	}
	
	# For convenience: XML can be a Document or a Node
	if ($node->getNodeName eq '#document') {
	    $node = $node->getDocumentElement;
	}

	$self->fromXML($node);
    }
    else {
	# We have to call the _init of the calling class:
	bless $self, $callingClass;
	$self->_init(%args);

	# re-bless to original class:
	bless $self, $class;
    }
}

sub id {
    my $self = shift;
    
    $self->{_identifier} or $self->error("No identifier specified");
}


sub error {
    my ($self, $mesg) = @_;
    
    croak("[" . $self->{_identifier} . "] " . $mesg);
}


sub _isValidConvertType {
    my ($self, $type) = @_;
    
    return 0 unless defined $self->{_validConvertTypes};
    
    return (scalar (grep { /^$type$/ } @{$self->{_validConvertTypes}})? 1 : 0);
}

sub convertType {
    my ($self, $type) = @_;
    
    if (defined $type) {
	$self->_isValidConvertType($type) or
	    $self->error("Invalid convert type: $type");
	
	$self->{_convertType} = $type;
    }
    
    $self->error("no convert type specified")
	unless defined $self->{_convertType};
    
    return $self->{_convertType};
}





sub toXML { croak("Abstract Method"); }
sub _init { croak("Abstract Method"); }


sub getXMLAttribute {
    my ($self, $node, $name) = @_;
    
    if (my $item = $node->getAttributes->getNamedItem($name)) {
	return $item->getValue();
    }
    return undef;
}


sub fromXML {
    my ($self, $node) = @_;
    
    ##
    ## ConvertType:
    ##
    my $nodeName = $node->getNodeName();
    $self->convertType($nodeName)
	if ($self->_isValidConvertType($nodeName));
    
    ##
    ## process all child nodes:
    ##
    foreach my $child ($node->getChildNodes()) {
	my $name = $child->getNodeName;
	my $class = CIM::TagInfo->class($name);

	#next unless defined $class;  # for testing?
	
	fatal("no CIM::TagInfo mapping defined for tag '$name'\n")
	    unless defined $class;
	
	fatal("no _childAccessors mapping defined for child '$name' in '" .
	      ref($self) . "'\n")
	    unless exists $self->{_childAccessors}->{$name};
	
	my $setfunc = $self->{_childAccessors}->{$name};
	next unless $setfunc;  # ignoring "undef" values
	
	my $obj = $class->new(XML => $child);
	
	$self->error("creation of '$class' failed") unless $obj;
	
	# in case of creating a 'CIM::Value' auto-detect the type and set it
	if ($obj->id() eq 'CIMValue') {
	    my $type;
	    
	    # get the type from the TYPE attribute
	    if (my $t = $node->getAttributes->getNamedItem('TYPE')) {
		$type = $t->getValue();
	    }
	    # get the type indirectly via the NAME attribute
	    elsif (my $n = $node->getAttributes->getNamedItem('NAME')) {
		my $name = $n->getValue();
		$type = CIM::IMethodInfo->type($name);
	    }
	    $obj->type($type) if $type;
	}
	
	$self->$setfunc($obj);
    }
    
    ##
    ## process all arguments:
    ##
    my $attrib = $node->getAttributes();
    for (my $i = 0; $i < $attrib->getLength(); $i++) {
	my $name = $attrib->item($i)->getName();
	
	$self->error("no mapping defined for attribute '$name' in '" .
		     ref ($self) . "'")
	    unless exists $self->{_attrAccessors}->{$name};
	
	my $setfunc = $self->{_attrAccessors}->{$name};
	next unless $setfunc;  # ignoring "undef" values
	
	$self->$setfunc($attrib->item($i)->getValue());
    }
}


sub toString {
    my $self = shift;

    pprint $self->toXML->toString;
}


##
## overloading the standard operators:
##

use overload "=="  => "equals",
             "!="  => sub { not $_[0]->equals($_[1]) },
             q{""} => sub { $_[0]->toString() },
             bool  => sub { @_ };

sub equals {
    my ($lhs, $rhs) = @_;
    
    return 0 unless (ref $rhs);
    
    return ($lhs->toXML->toString eq $rhs->toXML->toString);
}


1;


__END__

=head1 NAME

CIM::Base - the base class for a lot of CIM modules

=head1 SYNOPSIS

 package CIM::SomeClass;

 use base qw(CIM::Base);

 sub new {
     my ($class, %args) = @_;
    
     my $self = $class->SUPER::new();
    
     $self->{'CIM::SomeClass::_protected'} = undef;
     $self->{'CIM::SomeClass::__private'}  = undef;
    
     $self->{_identifier} = 'CIMSomeClass';

     $self->{_childAccessors} = {
				 VALUE => 'protected',
			        };

     $self->{_attrAccessors} = {
				NAME => 'private',
				TYPE => undef,
			       };
    
     $self->processArgs(%args);
    
     return $self;
 }

 sub _init {
     my ($self, %args) = @_;
     
     $self->{_protected} = 'some protected value';
     $self->{__private} = 'some private value';
 }

 sub protected {
     my $self = shift;

     $self->{_protected} = $_[0] if defined $_[0];

     return $self->{_protected};
 }

 # ...

 sub toXML {
     # ...
 }

 # ideally completely inherited from CIM::Base
 sub fromXML {
     my ($self, $node) = @_;

     # ...
     
     $self->SUPER::fromXML($node);
 }

 sub toString {
     # ...
 }



=head1 DESCRIPTION

Base.pm is the base class for a lot of CIM modules.



=head1 CONSTRUCTOR

=over 4

=item new()

The new() in CIM::Base actually has no arguments at all. But the inherited
subclasses will have a lot, some of them will be processed in CIM::Base
via the processArgs() function: 

new() functions call processArgs() which in return calls the _init() function 
that initializes the class variables.
Return value: $self.


=head1 METHODS

=item _init()

Abstract method, must be implemented in the derived class. 
Called by the constructor. No return value, variable number of arguments.

=item processArgs([OPTIONS])

C<OPTIONS> are passed in a hash like fashion, using key and value pairs.
The possible options are:

B<XML> - Read the values from the given XML::DOM element.  When specifying
this option the fromXML() function will be called, otherwise the
_init() function is called with the given options.

No return value.

=item id()

Returns the ID string of the class.

=item error($arg)

More verbose die function, prints the class identifier additionally to 
the given string. Uses croak.
    
=item convertType($arg)

Method to set or get the convertType of an instance.
The convertType is used in some classes and allows us to use only
one class for XML elements which are very similar, e.g. CIM::ReturnValue
for 'IRETURNVALUE' and 'RETURNVALUE'.
Return value is a string.

=item _isValidConvertType($arg)

Function used by convertType(), returns 1 or 0 depending on wether 
the given string is one of the elements in the $self->{_validConvertTypes} 
variable of a class or not.
    
=item toXML()

Abstract method to transform an instance to the XML representation, 
must be implemented in the derived class.

=item getXMLAttribute($node, $name)

Returns the value (a string) of the attribute C<name> of the XML node C<node>.

=item fromXML($node)

Function to read the instance from the given XML::DOM element. Ideally this
function will be completely inherited from the base class. Only when parsing
XML childs and arguments in a "non standard" way (i.e. via _childAccessors
resp. _attrAccessors) you should implement a new one.

=item toString()

If not implemented in the derived class it pretty prints the XML output
of the instance. In the other case it should print more or less important
information about the object. The output should be used for debugging only -
don't rely on the output format itself.



=head1 OPERATORS

=item ==, !=

If not implemented in the derived class it compares the XML output of the
instance.

=item ""

In scalar context the toString() function will be called. So you can do a
shorter "print $cimobject" instead of a "print $cimobject->toString()".



=head1 SEE ALSO

L<XML::DOM>, L<CIM::TagInfo>, L<CIM::IMethodInfo>



=head1 AUTHOR

 Axel Miesen <miesen@ID-PRO.de>
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
