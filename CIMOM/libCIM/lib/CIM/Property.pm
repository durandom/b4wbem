use strict;

######################
package CIM::Property;
######################
use Carp;

use CIM::Utils;
use CIM::Value;

use base qw(CIM::Base);


sub new {
    my ($class, %args) = @_;

    my $self = $class->SUPER::new();

    $self->{'CIM::Property::_name'} = undef;
    $self->{'CIM::Property::_value'} = undef;
    $self->{'CIM::Property::_type'} = undef;
    $self->{'CIM::Property::_referenceClass'} = undef;
    $self->{'CIM::Property::_isArray'} = undef;
    $self->{'CIM::Property::_propagated'} = 0;
    $self->{'CIM::Property::_qualifiers'} = [];

    $self->{_identifier} = 'CIMProperty';

    $self->{_childAccessors} = {
				VALUE	          => 'value',
				'VALUE.ARRAY'     => 'value',
				'VALUE.REFERENCE' => 'value',
				QUALIFIER         => 'addQualifiers',
			       };
    
    $self->{_attrAccessors} = {
			       NAME           => 'name',
			       TYPE           => 'type',
			       PROPAGATED     => 'propagated',
  			       REFERENCECLASS => 'referenceClass',
#    			       CLASSORIGIN    => '???'            # TODO!
			      };
    
    $self->processArgs(%args);
    
    return $self;
}

sub _init {
    my ($self, %args) = @_;
    
    # name is required
    defined $args{Name} or $self->error("No Name");
    $self->name($args{Name});
    
    # if isArray is not given, it's no array: 0
    # (if a value is given use the isArray() of this one)
    $self->{_isArray} = (defined $args{isArray}) ? $args{isArray} : 0;
    
    # value is optional
    $self->value($args{Value})
	if (defined $args{Value});
    
    # type is required (maybe indirectly via "Value"):
    $self->type($args{Type})
	if (defined $args{Type});
    $self->error("No Type") unless defined $self->{_type};
    
    # qualifiers are optional
    $self->addQualifiers($args{Qualifier})
	if (defined $args{Qualifier});
    
    # propagated is optional
    $self->propagated($args{Propagated})
	if defined $args{Propagated};
    
    # referenceClass is optional
    $self->referenceClass($args{ReferenceClass})
	if defined $args{ReferenceClass};
    
    return $self;
}


# get/set routine
sub isArray {
    my $self = shift;

    $self->{_isArray} = $_[0] if $_[0];

    return $self->{_isArray};
}


# get routine
sub isReference {
    my $self = shift;
    
    return (($self->{_type} eq CIM::DataType::reference) ? 1 : 0);
}


# get/set routine
sub name {
    my $self = shift;

    $self->{_name} = $_[0] if defined $_[0];

    return $self->{_name};
}

# get/set routine
sub type {
    my $self = shift;

    $self->{_type} = $_[0] if defined $_[0];

    return $self->{_type};
}

# get/set routine
sub referenceClass {
    my $self = shift;

    $self->{_referenceClass} = $_[0] if defined $_[0];

    return $self->{_referenceClass};
}

# get/set routine
sub value {
    my $self = shift;	
    
    if ($_[0]) {
	$self->{_value} = $_[0];
	$self->{_isArray} = $self->{_value}->isArray;
	$self->{_type} = $self->{_value}->type;
    }
    
    return $self->{_value};
} 

# set/get routine
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

sub isKeyProperty {
    my $self = shift;
    
    foreach my $q (@{$self->{_qualifiers}}) {
	return 1 if $q->name eq 'key';
    }
    return 0;
}



# get/set routine
sub propagated {
    my $self = shift;
    
    $self->{_propagated} = string2bool($_[0]) if ($_[0]);
    
    return $self->{_propagated};
} 


sub toXML {
    my $self = shift;
    
    my $doc = XML::DOM::Document->new();
    
    my $elemName = 'PROPERTY';
    $elemName = 'PROPERTY.ARRAY' if $self->{_isArray};
    $elemName = 'PROPERTY.REFERENCE' if $self->isReference();
    
    my $p = $doc->createElement($elemName);
    
    $p->setAttribute('NAME', scalar $self->{_name});
    
    $p->setAttribute('PROPAGATED', bool2string(scalar $self->{_propagated}))
	if $self->{_propagated} != 0;  # only set if not default
    
    $p->setAttribute('TYPE', scalar $self->{_type})
	if (defined $self->{_type} and
	    $self->{_type} ne CIM::DataType::reference);
    
    $p->setAttribute('REFERENCECLASS', scalar $self->{_referenceClass})
	if (defined $self->{_referenceClass} and
	    $self->{_type} eq CIM::DataType::reference);
    
    # get XML of value object:
    if (defined $self->{_value}) {   
	my $e = $self->{_value}->toXML;	
    
        $e->getDocumentElement()->setOwnerDocument($doc);
        $p->appendChild($e->getDocumentElement());
    }
    
    # get xml of qualifier objects:
    $self->_appendElements($doc, $p, $self->{_qualifiers});
    
    $doc->appendChild($p);
    
    return $doc;
} 

sub _appendElements {
    my ($self, $doc, $node, $elements) = @_;

    foreach my $elem (@{$elements}) {
        my $e = $elem->toXML;

        $e->getDocumentElement()->setOwnerDocument($doc);
        $node->appendChild($e->getDocumentElement());
    }

    return $doc;
}


sub fromXML {
    my ($self, $node) = @_;
    
    my $nodeName = $node->getNodeName;
    $self->{_isArray} = ($nodeName eq 'PROPERTY.ARRAY' ? 1 : 0);
    $self->{_type} = CIM::DataType::reference
	if $nodeName eq 'PROPERTY.REFERENCE';
    
    $self->SUPER::fromXML($node);
}


# get routine, for debugging purposes
sub toString {
    my $self = shift;

    my $qualifiers = "";
    foreach my $quali (@{$self->{_qualifiers}}) {
        $qualifiers .= "\n" .  $quali->toString . " ";
    }
    
    my $value = "";
    if (defined $self->{_value}) {
	$value = join(", ", $self->{_value}->convertValueToXML());
    }
    
    my $propagated = bool2string(scalar $self->{_propagated});
    
    my $text = "#Property:\n" .
	       "  name:        >" . $self->{_name} .		"<\n" .
	       "  type:        >" . $self->{_type} .		"<\n" .
	       "  isArray:     >" . $self->{_isArray} .		"<\n" .
	       "  isReference: >" . $self->isReference() .	"<\n" .
	       "  value:       >" . $value .			"<\n" .
	       "  propagated:  >" . $propagated .		"<\n" .
	       "  qualifiers:  >" . $qualifiers .		"<\n";
   
    return $text;
} 


1;



__END__

=head1 NAME

 CIM::Property - Class encapsulating CIM properties


=head1 SYNOPSIS

 use CIM::Property;

 my $prop1 = CIM::Property->new(XML => $node);

 my $prop2 = CIM::Property->new(Name       => 'someName'
				Type       => CIM::DataType::string,
				Value      => $valueObj1,
				Qualifier  => $qualifierObj1,
				Propagated => 'true',
			       );
  
 $prop2->name();

 $prop2->type();

 $prop2->value();

 $prop2->qualifiers($qualifierObj2, $qualifierObj3);

 $prop2->addQualifiers($qualifierObj4);

 $prop2->isArray();

 $prop2->isReference();

 $prop2->propagated('true');

 pprint $class->toXML->toString;



=head1 DESCRIPTION

This module represents CIM properties. 
It covers the XML representations of PROPERTY, PROPERTY.ARRAY and 
PROPERTY.REFERENCE, depending on the CIM::Value of the property.


=head1 CONSTRUCTOR

=over 4

=item new([OPTIONS])

C<OPTIONS> are passed in a hash like fashion, using key and value pairs.
The possible options are:

B<XML> - Read the instance from the given XML::DOM element or document. 
Only used as sole option. If additional options are given they
will be ignored.

B<Name>	- Name of the property (string), mandatory unless C<XML> is given.

B<Type>	- Mandatory unless C<XML> is given or the type was indirectly
specified with the C<Value> option.
The value is a string (e.g. "boolean"), it should be given 
in the form: CIM::DataType::boolean.

B<Qualifier> - Optional, value is a reference to an array 
of CIM::Qualifier objects.

B<Value> - Optional, value is a CIM::Value. If the type of the
CIM::Value is different from the properties type, the type of the value
will precede and change the one of the property.

B<isArray> - Optional, boolean, default is the corresponding variable 
of the property's CIM::Value, otherwise B<0>

B<Propagated> - Optional, boolean, default is B<0>



=head1 METHODS

=item _init([OPTIONS])

Called only by new(). Initialization of class variables.

=item isArray([{ 0 | 1 }])

Get/set accessor. Valid values for the isArray flag - which discerns between 
PROPERTY and PROPERTY.ARRAY - are the integers B<0> and B<1>.

=item isReference()

Returns B<0> or B<1>, depending on the type of the value.

=item name(['someName']);

Get/set accessor for the property's name (a string).

=item type([CIM::DataType::someType]);

Get/set accessor for the property's type.
Input: optional, string, preferably in the form of e.g. CIM::DataType::boolean 
(which returns the string "boolean").
Return value: string.

=item referenceClass();

Get/set accessor for the referenceClass.
Input: optional, string.
Return valeu: string.

=item value([$valueObj]);

Get/set accessor for the property's value.
Input: a single CIM::Value object.
Return value: CIM::Value object.

=item qualifiers([$qualifierObj1 [, $qualifierObj2, ...]]);

Get/set accessor. 
Input: optional, array of CIM::Qualifier objects.
Called with one or more qualifier instances as arguments
the qualifier array will be zapped and then filled by the given qualifiers.
Return value: array of CIM::Qualifier objects.

=item addQualifiers($qualifierObj1 [, $qualifierObj2, ...]);

Adds qualifiers to the qualifier array.
Input: array of CIM::Qualifier objects.
Return value: array of CIM::Qualifier objects.

=item isKeyProperty()

Returns 1 if the property is a key property, 0 otherwise.


=item propagated([{ 'true' | 'false' | 0 | 1 }]);

Get/set accessor. Valid values for the propagated flag are the strings B<true>
and B<false> and the corresponding integers B<1> and B<0>.
True means that the property was propagated from another class without
modification. Default is false.
Return value: 0 or 1.

=item toXML()

Returns a XML::DOM document representation of the instance.

=item _appendElements($doc, $class, $elements)
 
Called by toXML. Appends elements to the XML::DOM document.
No return value.

=item fromXML($node)

Creates an instance from the XML::DOM::Element $node and returns it.
Not inherited, function from CIM::Base is overloaded.

=item toString()

Returns the property as a string (for debugging purposes only).



=head1 OPERATORS

see CIM::Base



=head1 SEE ALSO

L<CIM::Base>, L<CIM::Value>, L<CIM::DataType>



=head1 AUTHOR

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
