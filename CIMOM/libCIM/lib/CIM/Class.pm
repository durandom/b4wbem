use strict;

###################
package CIM::Class;
###################
use Carp;

use base qw(CIM::Base);

use CIM::Method;   

sub new {
    my ($class, %args) = @_;

    my $self = $class->SUPER::new();

    $self->{'CIM::Class::_name'} = undef;
    $self->{'CIM::Class::_superclass'} = undef;
    $self->{'CIM::Class::_qualifiers'} = [];
    $self->{'CIM::Class::_properties'} = [];
    $self->{'CIM::Class::_methods'} = [];

    $self->{_identifier} = 'CIMClass';

    $self->{_childAccessors} = {
				QUALIFIER            => 'addQualifiers',
				PROPERTY             => 'addProperties',
				'PROPERTY.ARRAY'     => 'addProperties',
				'PROPERTY.REFERENCE' => 'addProperties',
				METHOD               => 'addMethods',
			       };
    
    $self->{_attrAccessors} = {
			       NAME       => 'name',
			       SUPERCLASS => 'superclass',
			      };
    
    $self->processArgs(%args);

    return $self;
}

sub _init {
    my ($self, %args) = @_;

    # Name is required
    defined $args{Name} or $self->error("No Name");
    $self->{_name} =  $args{Name};	

    # Superclass is optional
    # but when omitted that means there is no superclass to this class
    $self->{_superclass} = 
	(defined $args{Superclass})? $args{Superclass} : undef;

    # qualifiers are optional
    $self->{_qualifiers} = 
	(defined $args{Qualifier})? $args{Qualifier} : undef;

    # properties are optional
    $self->{_properties} = 
	(defined $args{Property})? $args{Property} : undef;
    
    # methods are optional
    $self->{_methods} = 
	(defined $args{Method})? $args{Method} : undef;
}


# get/set routine
sub name {
    my $self = shift;
    
    $self->{_name} = $_[0] if defined $_[0];
    
    return $self->{_name};
}


# get/set routine
sub superclass {
    my $self = shift;
    
    $self->{_superclass} = $_[0] if defined $_[0];
    
    return $self->{_superclass};
}


# get/set function
sub qualifiers {
    my ($self, @q) = @_;

    if (@q) {
    	$self->{_qualifiers} = undef;
    	push @{$self->{_qualifiers}}, @q;
    }
    
    return $self->{_qualifiers};     
}

sub addQualifiers {
    my ($self, @q) = @_;

    push @{$self->{_qualifiers}}, @q;

    return $self->{_qualifiers};     
}

sub qualifierByName {
    my ($self, $name) = @_;
    
    foreach (@{$self->{_qualifiers}}) {
	return $_
	    if ($_->name() eq $name);
    }
    
    return undef;
}


# get/set function
sub properties {
    my ($self, @p) = @_;
    
    if (@p) {
    	$self->{_properties} = undef;
    	push @{$self->{_properties}}, @p;
    }

    return $self->{_properties};     
}

sub addProperties {
    my ($self, @p) = @_;

    push @{$self->{_properties}}, @p;

    return $self->{_properties};     
}

sub propertyByName {
    my ($self, $name) = @_;
    
    foreach (@{$self->{_properties}}) {
	return $_
	    if ($_->name() eq $name);
    }
    
    return undef;
}


# get function
sub keyProperties {
    my ($self) = @_;
    
    my @keyproperties = ();
    foreach (@{$self->{_properties}}) {
	push @keyproperties, $_
	    if $_->isKeyProperty;
    }
    return \@keyproperties;
}


# get/set function
sub methods {
    my ($self, @m) = @_;
    
    if (@m) {
    	$self->{_methods} = undef;
    	push @{$self->{_methods}}, @m;
    }

    return $self->{_methods};     
}

sub addMethods {
    my ($self, @m) = @_;

    push @{$self->{_methods}}, @m;

    return $self->{_methods};     
}

sub methodByName {
    my ($self, $name) = @_;
    
    foreach (@{$self->{_methods}}) {
	return $_
	    if ($_->name() eq $name);
    }
    
    return undef;
}

sub isAssociation {
    my $self = shift;

    my $bool;
    foreach ( @{$self->{_qualifiers}} ) {
		
	$bool =  ($_->name eq 'Association')? 1 : 0;
	last if $bool;
    }
    return $bool;
}



sub toXML {
    my $self = shift;
    
    my $doc = XML::DOM::Document->new();
    
    my $class = $doc->createElement('CLASS');
    
    $class->setAttribute('NAME', scalar $self->{_name});
    $class->setAttribute('SUPERCLASS', scalar $self->{_superclass}) 
	if $self->{_superclass};

    # get xml of qualifier object
    $self->_appendElements($doc, $class, $self->{_qualifiers});

    # get xml of property object
    $self->_appendElements($doc, $class, $self->{_properties});

    # get xml of methods object
    $self->_appendElements($doc, $class, $self->{_methods});

    $doc->appendChild($class);

    return $doc;       
}	


# fromXML() completely inherited from CIM::Base


sub toString {
    my $self = shift;

    my $qualifiers = "";
    foreach my $quali (@{$self->{_qualifiers}}) {
	$qualifiers .= "\n" .  $quali->toString . " ";  
    }
    
    my $properties = "";
    foreach my $prop (@{$self->{_properties}}) {
	$properties .= "\n" .  $prop->toString . " ";  
    }

    my $methods = "";
    foreach my $method (@{$self->{_methods}}) {
	$methods .= "\n" .  $method->toString . " ";  
    }
    
    my $text = "ClassName: >$self->{_name}< " .
	       "Superclass: >$self->{_superclass}<" .
# 	       "\n ClassQualifiers: >" . $qualifiers . "<" .	#mark
# 	       "\n ClassProperties: >" . $properties . "<" .
	       "\n ClassMethods: >" . $methods . "<";

    return $text;
}


# internal function for appending a qualifier or property list to a 
# XML::DOM document
sub _appendElements {
    my ($self, $doc, $class, $elements) = @_;

    foreach my $elem (@{$elements}) {
        my $e = $elem->toXML;

        $e->getDocumentElement()->setOwnerDocument($doc);
        $class->appendChild($e->getDocumentElement());
    }
    
}


1;

__END__



=head1 NAME

CIM::Class - class encapsulating CIM classes



=head1 SYNOPSIS

 use CIM::Class;

 $class = CIM::Class->new(XML => $node);

 $class = CIM::Class->new(Name       => 'someName',
			  Superclass => 'someClass');

 $class->name();

 $class->superclass();

 $class->qualifiers($qualifierObj1, $qualifierObj2);

 $class->addQualifiers($qualifierObj3);

 @q = @{$class->qualifiers};

 $qualifier = $instance->qualifierByName('QualifierName');

 $class->properties($propertyObj2);

 $class->addProperties($propertyObj);

 $property = $instance->propertyByName('PropertyName');

 pprint $class->toXML->toString;



=head1 DESCRIPTION

 This module encapsulates CIM classes. 



=head1 CONSTRUCTOR

=over 4

=item new([OPTIONS])

C<OPTIONS> are passed in a hash like fashion, using key and value pairs.
The possible options are:

B<XML> - Read the instance from the given XML::DOM element or document. 
Only used as sole option. If additional options are given they
will be ignored.

B<Name> - Mandatory unless B<XML> is given. 
Name (a string) of the class to be created.

B<Superclass> - Name (a string) of the superclass of the class to be created.
Optional, but when omitted means there really is no superclass to this class. 

B<Property> - Optional, value is a reference to an array
of CIM::Property objects

B<Qualifier> - Optional, value is a reference to an array 
of CIM::Qualifier objects

B<Method> - Optional, value is a reference to an array 
of CIM::Method objects



=head1 METHODS

=item _init([OPTIONS])

Called only by new(). Initialization of class variables.


=item name([$someName])

Get/set accessor.  
Called with an argument (string): Name is changed to that value, 
the new value is returned.
Called with no argument: the current name is returned.

=item superclass([$someName])

Get/set accessor. 
Optional input: string. Return value: string, the name of the superclass.

=item qualifiers([$qualifierObj1 [, $qualifierObj2, ...]])

Get/set accessor. Called with one or more qualifier objects as arguments
the qualifier array will be zapped and then filled by the given qualifiers.
The function returns a reference to the array of all qualifier objects of the
CIM class.

=item addQualifiers($qualifierObj1 [, $qualifierObj2, ...])

Adds qualifiers to the qualifier array.
Input: one or more CIM qualifier objects. Return value: array reference.

=item qualifierByName($name)

Returns the qualifier object with the given name (string) if existent, 
undef else.


=item properties([$propertyObj1 [, $propertyObj2, ...]])

Same as qualifiers, but for properties.

=item addProperties($propertyObj1 [, $propertyObj2, ...])

Same as addQualifiers, but for properties.

=item propertyByName($name)

Same as qualifierByName(), but for properties.

=item keyProperties()

Return value: array reference, the array contains the property objects 
of the key properties.


=item methods([$methodObj1 [, $methodObj2, ...]])

Same as qualifiers, but for methods.

=item addMethods($methodObj1 [, $methodObj2, ...])

Same as addQualifiers, but for methods.

=item methodsByName($name)

Same as qualifierByName(), but for methods.



=item isAssociation()

Checks wether the name of one of the class' qualifiers is "Association". 
Returns 1 or 0.


=item toXML()

Returns a XML::DOM document representation of the instance.

=item _appendElements($doc, $class, $elements)
 
Called by toXML. Appends elements to the XML::DOM document.
No return value.
    
=item fromXML($node)

Creates an instance from the XML::DOM::Element $node and returns it.
Completely inherited from L<CIM::Base>.

=item toString()

Returns the class instance as a string (for debugging purposes only).



=head1 OPERATORS

see L<CIM::Base>



=head1 SEE ALSO

L<CIM::Base>, L<CIM::Property>, L<CIM::Qualifier>



=head1 AUTHORS

 Axel Miesen <miesen@ID-PRO.de>
 Eva Bolten <bolten@ID-PRO.de>



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
