use strict;

########################
package CIM::ParamValue;
########################
use Carp;

use base qw(CIM::Base);


sub new {
    my ($class, %args) = @_;
    
    my $self = $class->SUPER::new();
    
    $self->{'CIM::ParamValue::_name'} = undef;
    $self->{'CIM::ParamValue::_value'} = undef;
    
    $self->{_childAccessors} = {
				VALUE                   => 'value',
				'VALUE.ARRAY'           => 'value',
				'VALUE.REFERENCE'       => 'value',
				'VALUE.REFARRAY'        => 'value',
				INSTANCENAME            => 'value',
				CLASSNAME               => 'value',
				'QUALIFIER.DECLARATION' => 'value',
				CLASS                   => 'value',
				INSTANCE                => 'value',
				'VALUE.NAMEDINSTANCE'   => 'value',
			       };
    
    $self->{_attrAccessors} = {
			       NAME => 'name',
			      };
    
    $self->{_validConvertTypes} = [ 'IPARAMVALUE', 'PARAMVALUE' ];
    
    $self->{_identifier} = 'CIMParamValue';
    
    $self->processArgs(%args);
    
    return $self;
}


sub _init {
    my ($self, %args) = @_;
    
    defined $args{Name} or $self->error("No Name");
    
    $self->{_name} = $args{Name};
    $self->{_value} = $args{Value};
    
    $self->convertType($args{ConvertType})
	if defined $args{ConvertType};
}


sub name {
    my $self = shift;
    
    $self->{_name} = $_[0] if defined $_[0];
    
    return $self->{_name};
}


sub value {
    my $self = shift;

    $self->{_value} = $_[0] if defined $_[0];

    return $self->{_value};
}



sub toXML {
    my $self = shift;
    my ($type) = @_;

    my $doc = XML::DOM::Document->new();
    
    my $p = $doc->createElement($self->convertType());
    
    $p->setAttribute('NAME', scalar $self->{_name});

    if (defined $self->{_value}) {
	my $e = $self->{_value}->toXML();
	$e->getDocumentElement()->setOwnerDocument($doc);
	$p->appendChild($e->getDocumentElement());
    }
    
    $doc->appendChild($p);
    
    return $doc;
}


# fromXML() completely inherited from CIM::Base


sub toString {
    my $self = shift;
    
    my $str = "";
    $str .= "CIMParamValue: Name=`" . $self->{_name} . "'";
    $str .= ", Value=" .
	($self->{_value} ? $self->{_value}->toString : "[undefined]") . "\n";
    
    return $str;
}


1;


__END__

=head1 NAME

CIM::ParamValue - represents a CIM PARAMVALUE resp. IPARAMVALUE



=head1 SYNOPSIS

 use CIM::ParamValue;

 $v = CIM::Value->new(Value => [0, 1],
		      Type  => CIM::DataType::boolean);

 $p1 = CIM::ParamValue->new(Name        => 'myName',
			    Value       => $v,
			    ConvertType => 'PARAMVALUE');

 print "type = ", $p1->convertType('IPARAMVALUE'), "\n";
 print "name = ", $p1->name(), "\n";
 print "value = ", $p1->value->toString, "\n";

 $doc = $p1->toXML();
 $p2 = CIM::ParamValue->new(XML => $doc->getDocumentElement);



=head1 DESCRIPTION

This module represents a CIM PARAMVALUE resp. IPARAMVALUE.
A PARAMVALUE resp. IPARAMVALUE is a single named parameter value to be
passed to an extrinsic resp. intrinsic method.


=head1 CONSTRUCTOR

=over 4

=item new([OPTIONS])

C<OPTIONS> are passed in a hash like fashion, using key and value pairs.
The possible options are:

B<XML> - Read the instance from the given XML::DOM element or document. 
Only used as sole option. If additional options are given they
will be ignored.

B<Name> - The name of the parameter (string). 
This option is mandatory if you don't use the B<XML> option.

B<Value> - A CIM::Value object (VALUE, VALUE.ARRAY, VALUE.REFERENCE or 
VALUE.REFARRAY), optional. 

B<ConvertType> - The XML convert type, a string. Optional, but when not 
given has to be set later using the convertType function (or toXML() 
won't work).
Valid convert types are B<IPARAMVALUE> and B<PARAMVALUE>. 


=head1 METHODS

=item _init([OPTIONS])

Called only by new(). Initialization of class variables.

=item name([$arg])

Get/set accessor for the name of the (I)ParamValue.
Input: optional, string.
Return value: string.

=item value([$arg])

Get/set accessor for the value (may be string or array) of the 
(I)ParamValue.
Input: optional, CIM::Value object.
Return Value: CIM::Value object.

=item convertType([ { PARAMVALUE | IPARAMVALUE } ])

Get/set accessor for the convertType.  Valid convert types are B<IPARAMVALUE>
and B<PARAMVALUE>. To call the toXML() function a valid XML convert type is
mandatory.

=item toXML()

Returns a XML::DOM document representation of the instance.

=item fromXML($node)

Creates an instance from the XML::DOM::Element $node and returns it.
Completely inherited from CIM::Base.

=item toString()

Returns the instance as a string (for debugging purposes only).



=head1 SEE ALSO

L<CIM::Base>, L<CIM::Value>



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
