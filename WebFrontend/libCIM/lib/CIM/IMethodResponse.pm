use strict;

#############################
package CIM::IMethodResponse;
#############################
use Carp;

use CIM::IMethodInfo;

use base qw(CIM::Base);


sub new {
    my ($class, %args) = @_;
    
    my $self = $class->SUPER::new();
    
    $self->{'CIM::IMethodResponse::_methodName'} = undef;
    $self->{'CIM::IMethodResponse::_returnValue'} = undef;
    $self->{'CIM::IMethodResponse::_error'} = undef;
    
    $self->{_identifier} = 'IMethodResponse';
    
    $self->{_childAccessors} = {
				IRETURNVALUE => 'returnValue',
				ERROR        => 'error',
			       };
    
    $self->{_attrAccessors} = {
			       NAME => 'methodName',
			      };
    
    $self->processArgs(%args);
    
    return $self;
}


sub _init {
    my ($self, %args) = @_;
    
    defined $args{MethodName} or $self->error("No MethodName");
    CIM::IMethodInfo->isValidIMethodName($args{MethodName}) or
	$self->error("Invalid MethodName '$args{MethodName}'");
    $self->{_methodName} = $args{MethodName};
    
    $self->{_returnValue} = $args{ReturnValue};
    $self->{_error} = $args{Error};
}


sub methodName {
    my $self = shift;
    
    $self->{_methodName} = $_[0] if defined $_[0];
    
    return $self->{_methodName};
}


sub returnValue {
    my $self = shift;
    
    $self->{_returnValue} = $_[0] if defined $_[0];
    
    return $self->{_returnValue};
}


sub error {
    my $self = shift;
    
    $self->{_error} = $_[0] if defined $_[0];
    
    return $self->{_error};
}


sub toXML {
    my $self = shift;
    
    my $doc = XML::DOM::Document->new();
    
    # IMETHODRESPONSE
    my $mr = $doc->createElement('IMETHODRESPONSE');
    $mr->setAttribute('NAME', scalar $self->{_methodName});
    $doc->appendChild($mr);
    
    # (I)RETURNVALUE
    if (defined $self->{_returnValue}) {
	my $v = $self->{_returnValue}->toXML;
	$v->getDocumentElement()->setOwnerDocument($doc);
	$mr->appendChild($v->getDocumentElement());
    }
    
    # ERROR
    if (defined $self->{_error}) {
	my $e = $self->{_error}->toXML;
	$e->getDocumentElement()->setOwnerDocument($doc);
	$mr->appendChild($e->getDocumentElement());
    }
    
    return $doc;
}


# fromXML() completely inherited from CIM::Base



sub toString {
    my $self = shift;

    my $str = "";
    
    $str .= "*** NAME: " . $self->{_methodName} . " ***\n";
    
    $str .= "ReturnValue: " . $self->{_returnValue}->toString() . "\n"
	if defined $self->{_returnValue};
    
    $str .= "Error: " . $self->{_error}->toString() . "\n"
	if defined $self->{_error};
    
    return $str;
}


1;

__END__

=head1 NAME

CIM::IMethodResponse - class encapsulating the CIM IMETHODRESPONSE
element



=head1 SYNOPSIS

 use CIM::IMethodResponse;

 $imr = CIM::IMethodResponse->new( MethodName => $methodName);

 $doc = $imr->toXML();
 $imr2 = CIM::IMethodResponse->new( XML => $doc);


=head1 DESCRIPTION

This module represents the CIM IMETHODRESPONSE message element, which 
defines the response to an intrinsic CIM method invocation.
An IMethodResponse contains a CIM::Error or an optional CIM::ReturnValue.
It has one attribute, the name of the invoked method.

=head1 CONSTRUCTOR

=over 4

=item new([OPTIONS])

C<OPTIONS> are passed in a hash like fashion, using key and value pairs.
The possible options are:

B<XML> - Read the instance from the given XML::DOM element or document. 
Only used as sole option. If additional options are given they
will be ignored.

B<MethodName> - Mandatory unless B<XML> is given. Name of the method 
which gives the response.

B<ReturnValue> - Optional, value is a CIM::ReturnValue. 

B<Error> - Optional, value is a CIM::Error.

Only one of the options B<ReturnValue> and B<Error> can be set in one 
IMethodResponse.


=head1 METHODS

=item _init([OPTIONS])

Called only by new(). Initialization of class variables.

=item methodName([$name])

Get/set function for the MethodName.
Return value: string, name of the method.

=item returnValue([$rv])

Get/set function for the ReturnValue element.
Input: optional, CIM::ReturnValue object.
Return value: CIM::ReturnValue object.

=item error([$error])

Get/set function for the Error element.
Input: optional, CIM::Error object.
Return value: CIM::Error object.

=item toXML()

Returns a XML::DOM document representation of the instance.

=item fromXML($node)

Creates an instance from the XML::DOM::Element $node and returns it.
Completely inherited from L<CIM::Base>.

=item toString()

Returns the instance as string (for debugging purposes only).



=head1 SEE ALSO

L<CIM::Base>, L<CIM::ReturnValue>, L<CIM::Error>


=head1 AUTHOR

 Axel Miesen <miesen@ID-PRO.de>



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
