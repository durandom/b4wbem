use strict;

#########################
package CIM::ReturnValue;
#########################
use Carp;

use base qw(CIM::Base);


sub new {
    my ($class, %args) = @_;
    
    my $self = $class->SUPER::new();
    
    $self->{'CIM::ReturnValue::_values'} = [];
    
    $self->{_childAccessors} = {
				CLASSNAME                   => 'addValue',
				INSTANCENAME                => 'addValue',
				OBJECTPATH		    => 'addValue',
				VALUE                       => 'addValue',
				'VALUE.OBJECTWITHPATH'      => 'addValue',
				'VALUE.OBJECTWITHLOCALPATH' => 'addValue',
				'VALUE.OBJECT'              => 'addValue',
				'VALUE.OBJECTPATH'          => 'addValue',
				'QUALIFIER.DECLARATION'     => 'addValue',
				'VALUE.ARRAY'               => 'addValue',
  				'VALUE.REFERENCE'           => 'addValue',
				CLASS                       => 'addValue',
				INSTANCE                    => 'addValue',
				'VALUE.NAMEDINSTANCE'       => 'addValue',
			       };
    
    $self->{_validConvertTypes} = [ 'IRETURNVALUE', 'RETURNVALUE' ];
    
    $self->{_identifier} = 'CIMReturnValue';
    
    $self->processArgs(%args);
    
    return $self;
}


sub _init {
    my ($self, %args) = @_;
    
    $self->convertType($args{ConvertType})
	if defined $args{ConvertType};
}


sub addValue {
    my ($self, @v) = @_;
    
    push @{$self->{_values}}, @v;
}


sub values {
    my ($self, @args) = @_;
    
    $self->{_values} = \@args if @args;
    
    return defined $self->{_values} ? @{$self->{_values}} : ();
}



sub toXML {
    my $self = shift;
    my ($type) = @_;

    my $doc = XML::DOM::Document->new();
    
    my $p = $doc->createElement($self->convertType());
    
    foreach my $value (@{$self->{_values}}) {
	my $v = $value->toXML;
	$v->getDocumentElement()->setOwnerDocument($doc);
	$p->appendChild($v->getDocumentElement);
    }
    
    $doc->appendChild($p);
    
    return $doc;
}


# fromXML() completely inherited from CIM::Base


sub toString {
    my $self = shift;
    
    my $str = "";
    $str .= "CIMReturnValue: ";
    
    foreach my $value (@{$self->{_values}}) {
	$str .= "Value=" . $value->toString(). "\n";
    }
    
    return $str;
}


1;



__END__

=head1 NAME

CIM::ReturnValue - class representing the CIM RETURNVALUE and IRETURNVALUE
message elements


=head1 SYNOPSIS

 use CIM:::ReturnValue;

 $rv = CIM:::ReturnValue->new( ConvertType => 'IRETURNVALUE' );      

 $rv->addValue(@values);

 $doc = $rv->toXML();
 $rv2 = CIM:::ReturnValue->new( XML => $doc );      


=head1 DESCRIPTION

The CIM::ReturnValue module represents both the CIM RETURNVALUE and
IRETURNVALUE message elements. A ReturnValue contains the value(s) 
returned from a method call. 
For RETURNVALUE that is one CIM::Value object, for IRETURNVALUE 
possible objects belong to the classes
CIM::Value, CIM::ObjectName, CIM::ValueObject, CIM::Class, CIM::Instance.

=head1 CONSTRUCTOR

=over 4   

=item new([OPTIONS])

C<OPTIONS> are passed in a hash like fashion, using key and value pairs.
The possible options are:

B<XML> - Read the instance from the given XML::DOM element or document. 
Only used as sole option. If additional options are given they
will be ignored.

B<ConvertType> - The XML convert type. Optional, but when not given has 
to be set later using the convertType function (or toXML() won't work). 
Valid values are "IRETURNVALUE" and "RETURNVALUE".


=head1 METHODS

=item _init([OPTIONS])

Called only by new(). Initialization of class variables.

=item convertType([ { RETURNVALUE | IRETURNVALUE } ])

Get/set function for the XML convert type.  
Input: optional, strings 'RETURNVALUE' or 'IRETURNVALUE'.
Return value: strings 'RETURNVALUE' or 'IRETURNVALUE' (or undef). 

=item values([@args])

Get/set function for the value(s) included in the ReturnValue.
Input: optional, one CIM::Value object in case of a RETURNVALUE,
in case of an IRETURNVALUE possible objects belong to the classes
CIM::Value, CIM::ObjectName, CIM::ValueObject, CIM::Class, CIM::Instance.
Return value: array of objects of one of the above classes or undef.

=item addValue(@args)

Adds value(s) to the set of values which are included in the ReturnValue.
Input: array of objects of the above mentioned classes.
No return value.

=item toXML()

Returns a XML::DOM document representation of the instance.

=item fromXML()

Creates an instance from the XML::DOM::Element $node and returns it.
Completely inherited from CIM::Base.


=item toString()

Returns the instance as string (for debugging purposes only).



=head1 SEE ALSO

L<CIM::Base>, L<CIM::IMethodResponse>, L<CIM::MethodResponse>

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
