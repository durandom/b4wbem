use strict;

###################
package CIM::Value;
###################
use Carp;

use CIM::Utils;
use CIM::DataType;

use base qw(CIM::Base);


sub new {
    my ($class, %args) = @_;
    
    my $self = $class->SUPER::new();

    $self->{'CIM::Value::_type'} = undef;
    $self->{'CIM::Value::_isArray'} = undef;
    $self->{'CIM::Value::_value'} = undef;

    $self->{_identifier} = 'CIMValue';

    $self->processArgs(%args);

    return $self;
}


sub _init {
    my ($self, %args) = @_;
    
    # type
    CIM::DataType::isValid($args{Type}) or
	$self->error("No valid data type");
    $self->{_type} =  $args{Type};
    #defined $self->{_type} or $self->error("No Type");
    
    # value
    defined $args{Value} or $self->error("No Value");
    $self->{_value} = $args{Value}; 
    
    # isarray
    $self->{_isArray} = ((ref($self->{_value}) eq 'ARRAY') ? 1 : 0);
}


sub isArray {
    my $self = shift;
    
    return $self->{_isArray};
}


sub isReference {
    my $self = shift;
    
    return (defined $self->{_type} &&
	    $self->{_type} eq CIM::DataType::reference) ? 1 : 0;
}


sub numberOfElements {
    my $self = shift;

    if ($self->{_isArray}) {
	my $num = 0;
	my $val = $self->{_value};
	foreach (@$val) {
	    $num++;
	}
	return $num;
    }
    else {
	return (defined $self->{_value} ? 1 : 0);
    }
}


sub value {
    my ($self, $value) = @_;
    
    # set
    if (defined $value) {
	$self->{_value} = $value; 
	$self->{_isArray} = ((ref($value) eq 'ARRAY') ? 1 : 0);
    }
    
    # get
    if (defined $self->{_value}) {
	if ($self->{_isArray}) {
	    my $val = $self->{_value};
	    return @$val;
	}
	else {
	    return $self->{_value};
	}
    }
    else {
	return undef;
    }
}


sub valueAsRef {
    my $self = shift;
    
    # TODO: This function should replace value() in the next future...
    
    return $self->{_value};
}


sub type {
    my ($self, $type) = @_;
    
    if (defined $type) {
	if (defined $self->{_type}) {
	    $self->error("Conflicting Types: " .
			 "new='$type', old='$self->{_type}'")
		if ($type ne $self->{_type});
	}
	else {
	    CIM::DataType::isValid($type) or
		$self->error("No valid data type");
	    
	    $self->{_type} = $type;
	    
	    if ($self->{_isArray}) {
		my @tmp = $self->convertValueFromXML();
		$self->{_value} =\@tmp;
	    }
	    else {
		$self->{_value} = $self->convertValueFromXML();
	    }
	}
    }
    
    return $self->{_type};
}



##
## toXML
##

sub toXML {
    my $self = shift;
    
    my $doc = XML::DOM::Document->new();

    ## is array:
    if ($self->{_isArray}) {
	my $va;

	## reference:
	if ($self->isReference) {
	    $va = $doc->createElement('VALUE.REFARRAY');
	    
	    my @array;
	    my $val = $self->{_value};
	    foreach (@$val) {
		my $v = $doc->createElement('VALUE.REFERENCE');
		my $c = $_->toXML;
		$c->getDocumentElement()->setOwnerDocument($doc);
		$v->appendChild($c->getDocumentElement);
		$va->appendChild($v);
	    }
	}
	## simple value:
	else {
	    $va = $doc->createElement('VALUE.ARRAY');
	    
	    foreach ($self->convertValueToXML()) {
		my $v = $doc->createElement('VALUE');
		$v->addText($_);
		$va->appendChild($v);
	    }
	}
	$doc->appendChild($va);
    }
    ## no array:
    else {
	my $v;
	
	## reference:
	if ($self->isReference) {
	    $v = $doc->createElement('VALUE.REFERENCE');
	    my $c = $self->{_value}->toXML;
	    $c->getDocumentElement()->setOwnerDocument($doc);
	    $v->appendChild($c->getDocumentElement);
	}
	## simple value:
	else {
	    $v = $doc->createElement('VALUE');
	    my $c = $self->_singleConvertToXML();
	    $v->addText($c) if defined $c;
	}
	$doc->appendChild($v);
    }
    
    return $doc;
}

# converts a single value to XML
sub _singleConvertToXML  {
    my ($self, $text) = @_;
    
    $text = $self->{_value} unless defined $text;
    
    return undef unless defined $text;
    
    return $text unless defined $self->{_type};
    
    # convert boolean:
    if ($self->{_type} eq CIM::DataType::boolean) {
	$text = ($text ne "0" ? 'TRUE' : 'FALSE');
    }
    
    return $text;
}

sub convertValueToXML {
    my $self = shift;
    
    if ($self->{_isArray}) {
	my @array;
	my $val = $self->{_value};
	foreach (@$val) {
	    my $c = $self->_singleConvertToXML($_);
	    push(@array, $c) if defined $c;
	}
	return @array;
    }
    else  {
	return $self->_singleConvertToXML($self->{_value});
    }
}


##
## fromXML
##


sub fromXML {
    my ($self, $root) = @_;
    
    my $type = $self->{_type};
    CIM::DataType::isValid($type) or
	$self->error("Invalid or not specified data type");
    
    # inspect DOM tree:
    $root = $root->getDocumentElement()
	if ($root->getNodeName() eq '#document');
    
    my ($value, $isArray);
    
    if ($root->getNodeName() eq 'VALUE') {                 # single value
	my $child = $root->getFirstChild;
	my $data = ($child ? $child->getData() : "");
	$value = $self->_singleConvertFromXML($data, $type);
	$isArray = 0;
    }
    elsif ($root->getNodeName() eq 'VALUE.ARRAY') {        # array
	foreach my $child ($root->getChildNodes()) {
	    next unless $child->getNodeName() eq 'VALUE';
	    my $data = $child->getFirstChild->getData();
	    push @$value, $self->_singleConvertFromXML($data, $type);
	}
	$value = [] unless defined $value;  # in case of an empty array
	$isArray = 1;
    }
    elsif ($root->getNodeName() eq 'VALUE.REFERENCE') {    # single value, ref.
	my $child = $root->getFirstChild;
	my $class = CIM::TagInfo->class($child->getNodeName);
	$value = $class->new(XML => $child);
	$type = CIM::DataType::reference;
	$isArray = 0;
    }
    elsif ($root->getNodeName() eq 'VALUE.REFARRAY') {     # array, reference
	foreach my $child ($root->getChildNodes()) {
	    next unless $child->getNodeName() eq 'VALUE.REFERENCE';
	    my $c = $child->getFirstChild;
	    my $class = CIM::TagInfo->class($c->getNodeName);
	    push @$value, $class->new(XML => $c);
	}
	$value = [] unless defined $value;
	$type = CIM::DataType::reference;
	$isArray = 1;
    }
    else {
	$self->error("Invalid Root Element: " . $root->getNodeName());
    }
    
    # set the internal variables:
    $self->{_value}   = $value;
    $self->{_isArray} = $isArray;
    $self->{_type}    = $type;
}


# converts a single value from XML
sub _singleConvertFromXML  {
    my ($self, $text, $type) = @_;
    
    $self->error("No text specified.") unless defined $text;
    
    $type = $self->{_type} unless defined $type;
    
    return $text unless defined $type;
    
    # convert boolean:
    if ($type eq CIM::DataType::boolean) {
	my %hash = ('TRUE' => 1, 'FALSE' => 0, '' => '');
	$self->error("Invalid XML value while transforming: $text")
	    unless defined $hash{$text};
	
	$text = $hash{$text};
    }
    
    return $text;
}

sub convertValueFromXML {
    my $self = shift;
    
    if ($self->{_isArray}) {
	my @array;
	my $val = $self->{_value};
	foreach (@$val) {
	    push @array, $self->_singleConvertFromXML($_);
	}
	return @array;
    }
    else  {
	return $self->_singleConvertFromXML($self->{_value});
    }
}



sub toString {
    my ($self) = @_;
    
    my $nv = '[no values]';
    my $num = $self->numberOfElements();
    
    my $reftype = "";
    if ($self->isReference()) {
	$reftype = ($self->{_isArray}
		    ? ($self->value)[0]->id
		    : $self->value->id);
    }
    
    return "\n" .
	"   /------------- CIM::Value ------------\\\n" .
        "   | Value:     " .
	    ($num ? join(", ", $self->value) : $nv) . "\n" .
        "   | XML Value: " .
	    ($num ? join(", ", $self->convertValueToXML()) : $nv) . "\n" .
	"   | Type:      " . ($self->{_type} || '[unspecified]') .
	    ($self->isReference() ? " ($reftype)" : "") . "\n" .
	"   | Array:     " .
	    ($self->{_isArray} ? "yes ($num Elements)" : 'no') . "\n" .
	"   \\-------------------------------------/\n";
}


##
## overloading the standard operators:
##

sub equals {
    my ($lhs, $rhs) = @_;
    
    return 0 unless areEqual(scalar $lhs->{_type},
			     scalar $rhs->{_type});
    
    return 0 unless $lhs->{_isArray} == $rhs->{_isArray};
    
    return 0 unless areEqual(scalar $lhs->{_value},
			     scalar $rhs->{_value});
    
    return 1;
}


1;



__END__

=head1 NAME

CIM::Value - represents a CIM value or array



=head1 SYNOPSIS

 use CIM::Value;

 $v = CIM::Value->new(Value => 'simple string',
		      Type  => CIM::DataType::string);
 print $v->toXML->toString();
 print "value: ", $v->value(), "\n";
 print "type: ", $v->type(), "\n";

 $v = CIM::Value->new(Value => [1, 0, 1, 1, 0]);
 $v->type('boolean');
 $doc = $v->toXML;
 print $doc->toString();
 print "isArray: ", $v->isArray(), "\n";
 print "number of elements: ", $v->numberOfElements(), "\n";

 $v = CIM::Value->new(XML => $doc);
 $v->type('boolean');
 $v->fromXML($doc, CIM::DataType::boolean);

 print "is equal\n" if ($v1 == $v2);



=head1 DESCRIPTION

This module represents the CIM XML elements VALUE, VALUE.ARRAY,
VALUE.REFERENCE, and VALUE.REFARRAY.



=head1 CONSTRUCTOR

=over 4

=item new([OPTIONS])

C<OPTIONS> are passed in a hash like fashion, using key and value pairs.
The possible options are:

B<XML> - Read the values from the given XML::DOM element. If his option
is used you must either specify the B<Type> option or use the type() function 
after the constructor.

B<Type> - The CIM data type. See L<CIM::DataType> for valid values. This
option is mandatory unless B<XML> is given. In the
latter case you have to call the type() function to tell CIM::Value the
data type.

B<Value> - The actual value as any type of scalar. 
This option is mandatory unless B<XML> is given.



=head1 METHODS

=item _init([OPTIONS])

Called only by new(). Initialization of class variables.

=item isArray()

Routine to check if the value is a VALUE.ARRAY resp. VALUE.REFARRAY or not, 
returns 1 (true) or 0 (false). 

=item isReference()

Routine to check if the value is a VALUE.REFERENCE resp. VALUE.REFARRAY 
or not, returns 1 (true) or 0 (false). 

=item numberOfElements()

Returns the number of values included in a CIM::Value object (be it an array 
or not).

=item value([$newValue])

Get-/set function.
Returns the current value(s) in scalar or array context, depending on
isArray().
Input: optional, scalar.
Return value: array or scalar.
    
=item valueAsRef()

Get function.
Returns the current value(s) always as a scalar. 
This function should replace value() in the future. 
    
=item type([$type])

Returns the current data type. If an argument is given and the current data
type was not specified (e.g via the constructor), this one will become the
new data type. Note: You can only change the datatype once (from 'undef' to
something defined). See L<CIM::DataType> for valid values.

=item convertValueToXML()

Returns a scalar resp. an array with the to XML converted values. In the
most cases there is no difference to the value() function behaviour.
Exceptions are:

C<CIM::DataType::boolean>: The C<true> value (=1) will be converted to C<TRUE>,
the C<false> value (=0) to C<FALSE>.

For C<CIM::DataType::datetime> a conversion is planned.

=item _singleConvertValueToXML($text, $type)

Converts a single value to XML. Used internally by convertValueToXML().


=item convertValueFromXML()

Similar to the convertValueToXML() function, just in the reverse order.

=item _singleConvertValueFromXML($text)
    
Converts a single value from XML. Used internally by convertValueFromXML().


=item toXML()

Returns a XML::DOM document representation of the instance.

=item fromXML($node)

Creates an instance from the XML::DOM::Element $node and returns it.
Not inherited, function from CIM::Base is overloaded.

=item toString()

Returns the instance as a string (for debugging purposes only).



=head1 SEE ALSO

L<CIM::Base>, L<CIM::DataType>



=head1 AUTHOR

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
