use strict;

######################
package CIM::Instance;
######################
use Carp;

use base qw(CIM::Base);


sub new {
    my ($class, %args) = @_;
    
    my $self = $class->SUPER::new();
    
    $self->{'CIM::Instance::_className'} = undef;
    $self->{'CIM::Instance::_qualifiers'} = [];
    $self->{'CIM::Instance::_properties'} = [];
    
    $self->{_identifier} = 'CIMInstance';
    
    $self->{_childAccessors} = {
				QUALIFIER            => 'addQualifiers',
				PROPERTY             => 'addProperties',
				'PROPERTY.ARRAY'     => 'addProperties',
				'PROPERTY.REFERENCE' => 'addProperties',
			       };
    $self->{_attrAccessors} = {
				CLASSNAME => 'className',
			      };
    
    # processArgs must not be called from a derived class!
    $self->processArgs(%args)
	if ref $self eq "CIM::Instance";
    
    return $self;
}

sub _init {
    my ($self, %args) = @_;
    
    # ClassName is required
    defined $args{ClassName} or $self->error("No ClassName");
    $self->{_className} = $args{ClassName};

    # Test for valid Classnames?

    # qualifiers are optional
    $self->{_qualifiers} =
        (defined $args{Qualifier})? $args{Qualifier} : undef;

    # properties are optional
    $self->{_properties} =
        (defined $args{Property})? $args{Property} : undef;
}

# get/set routine
sub className {
    my $self = shift;

    $self->{_className} = $_[0] if defined $_[0];

    return $self->{_className};
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


sub toXML {
    my $self = shift;

    my $doc = XML::DOM::Document->new();

    my $class = $doc->createElement('INSTANCE');

    $class->setAttribute('CLASSNAME', scalar $self->{_className});

    # get xml of qualifier object
    $self->_appendElements($doc, $class, $self->{_qualifiers});

    # get xml of property object
    $self->_appendElements($doc, $class, $self->{_properties});

    $doc->appendChild($class);

    return $doc;
}


# fromXML() completely inherited from CIM::Base


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

sub toString {
    my $self = shift;

    my $qualifiers;
    foreach my $quali (@{$self->{_qualifiers}}) {
        $qualifiers .= "\n" . $quali->toString . " ";
    }
    my $properties;
    foreach my $prop (@{$self->{_properties}}) {
        $properties .= "\n" . $prop->toString . " ";
    }
    
    $qualifiers = $qualifiers ? $qualifiers : "";
    $properties = $properties ? $properties : "";
    
    my $text = "#Instance:\n".
               "  ClassName:   >" . $self->{_className} .	"<\n" . 
               "  Iqualifiers: >" . $qualifiers .		"<\n" .
               "  Iproperties: >" . $properties .		"<\n";

    return $text;
}


1;

__END__

=head1 NAME

 CIM::Instance - class encapsulating CIM instances



=head1 SYNOPSIS

 use CIM::Instance;

 $instance = CIM::Instance->new(XML => $node);

 $instance = CIM::Instance->new(ClassName => 'someName');

 $instance->className();

 $instance->qualifiers($qualifierObj1, $qualifierObj2);

 $instance->addQualifiers($qualifierObj3);

 $qualifier = $instance->qualifierByName('QualifierName');

 $instance->properties($propertyObj1, $propertyObj2);

 $instance->addProperties($propertyObj3);

 $property = $instance->propertyByName('PropertyName');

 print $instance->toXML->toString;



=head1 DESCRIPTION

This module encapsulates CIM instances. 


=head1 CONSTRUCTOR

=over 4

=item new([OPTIONS])

C<OPTIONS> are passed in a hash like fashion, using key and value pairs.
The possible options are:

B<XML> - Read the instance from the given XML::DOM element or document. 
Only used as sole option. If additional options are given they
will be ignored.

B<ClassName>	- Mandatory unless B<XML> is given. 

B<Property>	- Optional, value is a reference to an array
of CIM::Property objects

B<Qualifier>	- Optional, value is a reference to an array 
of CIM::Qualifier objects



=head1 METHODS

=item _init([OPTIONS])

Called only by new(). Initialization of class variables.

=item className(['someName'])

Get/set accessor.  Called with an argument (string): 
ClassName is changed to that value, the new value is returned.
Called with no argument: the current class name (string) is returned.

=item qualifiers([$qualifierObj1 [, $qualifierObj2, ...]])

Get/set accessor. Called with one or more qualifier
objects as arguments the qualifier array will be
zapped and then filled by the given qualifiers.
Return value: reference to an array containing CIM qualifier objects.

=item addQualifiers($qualifierObj1 [, $qualifierObj2, ...])

Adds qualifiers to the qualifier array.
Input: list of qualifier objects.
Return value: reference to an array containing CIM qualifier objects.

=item qualifierByName($name)

Returns the qualifier object with the given name if existent, undef else.


=item properties([$propertyObj1 [, $propertyObj2, ...]])

Same as qualifiers(), but for properties.

=item addProperties($propertyObj1 [, $propertyObj2, ...])

Same as addQualifiers(), but for properties.

=item propertyByName($name)

Same as qualifierByName(), but for properties.


=item toXML()

Returns a XML::DOM document representation of the instance.

=item _appendElements($doc, $class, $elements)
 
Called by toXML. Appends elements to the XML::DOM document.
No return value.

=item fromXML($node)

Creates an instance from the XML::DOM::Element $node and returns it.
Completely inherited from L<CIM::Base>.

=item toString()

Returns the instance as a string (for debugging purposes only).



=head1 OPERATORS

see L<CIM::Base>



=head1 SEE ALSO

L<CIM::Base>, L<CIM::Qualifier>, L<CIM::Property>



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
