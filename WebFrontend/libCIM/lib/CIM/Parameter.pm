use strict;

######################
package CIM::Parameter;
######################
use Carp;

use CIM::Utils;
use CIM::Value;

use base qw(CIM::Base);


sub new {
    my ($class, %args) = @_;

    my $self = $class->SUPER::new();

    $self->{'CIM::Parameter::_name'} = undef;
    $self->{'CIM::Parameter::_type'} = undef;
    $self->{'CIM::Parameter::_referenceClass'} = undef;
    $self->{'CIM::Parameter::_isArray'} = undef;
    $self->{'CIM::Parameter::_qualifiers'} = [];

    $self->{_identifier} = 'CIMParameter';

    $self->{_childAccessors} = {
				QUALIFIER         => 'addQualifiers',
			       };
    
    $self->{_attrAccessors} = {
			       NAME           => 'name',
			       TYPE           => 'type',
  			       REFERENCECLASS => 'referenceClass',
			      };
    
    $self->processArgs(%args);
    
    return $self;
}

sub _init {
    my ($self, %args) = @_;
    
    # name is required
    defined $args{Name} or $self->error("No Name");
    $self->name($args{Name});
    
    # type is required	
    $self->type($args{Type})
	if (defined $args{Type});
    $self->error("No Type") unless defined $self->{_type};
    
    # if isArray is not given, it's no array: 0
    $self->{_isArray} = (defined $args{isArray}) ? $args{isArray} : 0;
    
    # qualifiers are optional
    $self->addQualifiers($args{Qualifier})
	if (defined $args{Qualifier});
    
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



sub toXML { # mark
    my $self = shift;
    
    my $doc = XML::DOM::Document->new();

    my $elemName;
    ## is array:
    if ( $self->{_isArray} ) {
	if ( $self->isReference() ){
	    $elemName = 'PARAMETER.REFARRAY';
	}
	else {
	    $elemName = 'PARAMETER.ARRAY';
	}
    }
    ## no array:
    else {
	if ( $self->isReference() ){
	    $elemName = 'PARAMETER.REFERENCE';
	}
	else {
	    $elemName = 'PARAMETER';
	}
    }
    
    my $p = $doc->createElement($elemName);
    
    $p->setAttribute('NAME', scalar $self->{_name});
    
    $p->setAttribute('TYPE', scalar $self->{_type})
	if (defined $self->{_type} and
	    $self->{_type} ne CIM::DataType::reference);

    $p->setAttribute('REFERENCECLASS', scalar $self->{_referenceClass})
	if (defined $self->{_referenceClass} and
	    $self->{_type} eq CIM::DataType::reference);
    
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


sub fromXML {	# mark
    my ($self, $node) = @_;
    
    my $nodeName = $node->getNodeName;

    $self->{_isArray} = 0;
    if ($nodeName eq 'PARAMETER.ARRAY' || $nodeName eq 'PARAMETER.REFARRAY') {
	$self->{_isArray} = 1;
    }

    if ($nodeName eq 'PARAMETER.REFERENCE' || $nodeName eq 'PARAMETER.REFARRAY') {
	$self->{_type} = CIM::DataType::reference;
    }

    $self->SUPER::fromXML($node);
}

# get routine, for debugging purposes
sub toString {
    my $self = shift;

    my $qualifiers = "";
    foreach my $quali (@{$self->{_qualifiers}}) {
        $qualifiers .= "\n" .  $quali->toString . " ";
    }
    
    my $text = " #Parameter: name: >$self->{_name}< " .
	       "type: >$self->{_type}< " .
	       "isArray: >$self->{_isArray}< " .
	       "isReference: >" . $self->isReference() . "< " .
	       "qualifiers: >$qualifiers< ";
   
    return $text;
} 


1;



__END__

=head1 NAME

 CIM::Parameter - Class encapsulating CIM parameters


=head1 SYNOPSIS

 use CIM::Parameter;

 my $prop1 = CIM::Parameter->new(XML => $node);

 my $prop2 = CIM::Parameter->new(Name       => 'someName',
				Type       => CIM::DataType::string,
				Qualifier  => $qualifierObj1,
			       );
  
 $prop2->name();

 $prop2->type();

 $prop2->qualifiers($qualifierObj2, $qualifierObj3);

 $prop2->addQualifiers($qualifierObj4);

 $prop2->isArray();

 $prop2->isReference();

 pprint $class->toXML->toString;



=head1 DESCRIPTION

This module represents parameters to CIM Methods. 
It covers the XML representations of PARAMETER, PARAMETER.ARRAY, 
PARAMETER.REFARRAY and PARAMETER.REFERENCE.


=head1 CONSTRUCTOR

=over 4

=item new([OPTIONS])

C<OPTIONS> are passed in a hash like fashion, using key and value pairs.
The possible options are:

B<XML> - Read the instance from the given XML::DOM element or document. 
Only used as sole option. If additional options are given they
will be ignored.

B<Name>	- Name of the parameter (string), mandatory unless C<XML> is given.

B<Type>	- Mandatory unless C<XML> is given or the Parameter is of 
reference type.
The value is a string (e.g. "boolean"), it should be given 
in the form: CIM::DataType::boolean.

B<Qualifier> - Optional, value is a reference to an array 
of CIM::Qualifier objects.

B<ReferenceClass> - Optional, only relevant for a PARAMETER.REFERENCE. 
If absent the reference is not strongly typed.
If present it has to be a class name (string).

B<isArray> - Optional, boolean, default is the corresponding variable 
of the parameter's CIM::Value, otherwise B<0>



=head1 METHODS

=item _init([OPTIONS])

Called only by new(). Initialization of class variables.

=item isArray( [{ 0 | 1 }] )

Get/set accessor. Valid values for the isArray flag - which discerns between 
PARAMETER and PARAMETER.ARRAY - are the integers B<0> and B<1>.

=item isReference()

Returns B<0> or B<1>, depending on the type of the value.

=item name(['someName']);

Get/set accessor for the parameter's name (a string).

=item type( [ CIM::DataType::someType ] );

Get/set accessor for the parameter's type.
Input: optional, string, preferably in the form of e.g. CIM::DataType::boolean 
(which returns the string "boolean").
Return value: string.

=item referenceClass();

Get/set accessor for the referenceClass.
Input: optional, string.
Return valeu: string.

=item qualifiers( [$qualifierObj1 [, $qualifierObj2, ...]] );

Get/set accessor. 
Input: optional, array of CIM::Qualifier objects.
Called with one or more qualifier instances as arguments
the qualifier array will be zapped and then filled by the given qualifiers.
Return value: array of CIM::Qualifier objects.

=item addQualifiers( $qualifierObj1 [, $qualifierObj2, ...] );

Adds qualifiers to the qualifier array.
Input: array of CIM::Qualifier objects.
Return value: array of CIM::Qualifier objects.

=item toXML()

Returns a XML::DOM document representation of the instance.

=item _appendElements($doc, $class, $elements)
 
Called by toXML. Appends elements to the XML::DOM document.
No return value.

=item fromXML($node)

Creates an instance from the XML::DOM::Element $node and returns it.
Not inherited, function from CIM::Base is overloaded.

=item toString()

Returns the parameter instance as a string (for debugging purposes only).



=head1 OPERATORS

see CIM::Base



=head1 SEE ALSO

L<CIM::Base>



=head1 AUTHOR

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
