use strict;

#########################
package CIM::IMethodCall;
#########################
use Carp;

use CIM::IMethodInfo;

use base qw(CIM::Base);


sub new {
    my ($class, %args) = @_;
    
    my $self = $class->SUPER::new();
    
    $self->{'CIM::IMethodCall::_methodName'} = undef;
    $self->{'CIM::IMethodCall::_namespacePath'} = undef;
    $self->{'CIM::IMethodCall::_params'} = [];
    
    $self->{_identifier} = 'IMethodCall';
    
    $self->{_childAccessors} = {
				LOCALNAMESPACEPATH => 'namespacePath',
				IPARAMVALUE        => 'addParameter',
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
    $self->{_namespacePath} = $args{NamespacePath};
}


sub namespacePath {
    my $self = shift;

    $self->{_namespacePath} = $_[0] if defined $_[0];

    return $self->{_namespacePath};
}


sub methodName {
    my $self = shift;
    
    $self->{_methodName} = $_[0] if defined $_[0];
    
    return $self->{_methodName};
}


sub addParameter {
    my ($self, @param) = @_;

    push @{$self->{_params}}, @param;
}


sub parameters {
    my ($self, @args) = @_;
    
    $self->{_params} = \@args if @args;

    return @{$self->{_params}};
}


sub getParameterByName {
    my ($self, $name) = @_;
    foreach my $param (@{$self->{_params}}) {
	return $param if $param->name() eq $name;
    }
}



sub toXML {
    my $self = shift;
    
    my $doc = XML::DOM::Document->new();
    
    # IMETHODCALL
    my $mt = $doc->createElement('IMETHODCALL');
    $mt->setAttribute('NAME', scalar $self->{_methodName});
    $doc->appendChild($mt);
    
    # LOCALNAMESPACEPATH:
    my $lns = $self->{_namespacePath}->toXML;
    $lns->getDocumentElement()->setOwnerDocument($doc);
    $mt->appendChild($lns->getDocumentElement());
    
    # IPARAMVALUE
    foreach my $param (@{$self->{_params}}) {
	my $p = $param->toXML;
	$p->getDocumentElement()->setOwnerDocument($doc);
	$mt->appendChild($p->getDocumentElement);
    }
    
    return $doc;
}


# fromXML() completely inherited from CIM::Base



sub toString {
    my $self = shift;

    my $str = "";
    
    $str .= "*** NAME: " . $self->{_methodName} . " ***\n";
    $str .= $self->{_namespacePath}->toString . "\n";

    foreach my $param (@{$self->{_params}}) {
	print $param->toString();
    }
    
    return $str;
}

1;


__END__

=head1 NAME

CIM::IMethodCall - a representation of the XML tag "IMETHODCALL"



=head1 SYNOPSIS

 use CIM::IMethodCall;

 $imc = CIM::IMethodCall->new(	MethodName	=> $method,
				NamespacePath   => $nsp);

 $imc->parameters(@params);

 $doc = $imc->toXML();
 $imc2 = CIM::IMethodCall->new(	XML => $doc );




=head1 DESCRIPTION

CIM::IMethodCall - a representation of the CIM IMETHODCALL message element,
which defines a single intrinsic method invocation. 
An IMethodCall contains the target local namespace and zero or more 
IPARAMVALUE subelements (= parameter values to be passed to the method).
It has one attribute, the name of the method called.


=head1 CONSTRUCTOR

=over 4

=item new([OPTIONS])

C<OPTIONS> are passed in a hash like fashion, using key and value pairs.
The possible options are:

B<XML> - Read the instance from the given XML::DOM element or document. 
Only used as sole option. If additional options are given they
will be ignored.

B<MethodName> - Mandatory unless B<XML> is given.  
The name of the intrinsic method.

B<NamespacePath> - Optional. A CIM::NamespacePath, the LOCALNAMESPACEPATH 
part of the CIM query.



=head1 METHODS

=item _init([OPTIONS])

Called only by new(). Initialization of class variables.

=item namespacePath( [$namespacePath] )

Get/set function for the NamespacePath.
Input: optional, a CIM::NamespacePath object.
Return value: CIM::NamespacePath object.

=item methodName( [$methodName] )

Get/set function for the MethodName.
Input: optional, string.
Return value: string, name of the method.

=item addParameter( @params )

Adds a list of IParamValues to the IMethodcall instance. 
No return value.

=item parameters( [@params] )

Get/set function for the IParamValues.
Input: optional, list of CIM::ParamValues
Return value: array of CIM::ParamValue objects with self->convertType eq
'IPARAMVALUE'.


=item getParameterByName($paramName)

Input: parameter name, string.
Returns the CIM::ParamValue instance with self->convertType eq 'IPARAMVALUE' 
and with the given name.


=item toXML()

Returns a XML::DOM document representation of the instance.

=item fromXML($node)

Creates an instance from the XML::DOM::Element $node and returns it.
Completely inherited from L<CIM::Base>.

=item toString()

Returns the instance as a string (for debugging purposes only).



=head1 SEE ALSO

L<CIM::Base>, L<CIM::IMethodInfo>, L<CIM::NamespacePath>, L<CIM::ParamValue>



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
