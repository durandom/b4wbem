use strict;

########################
package CIM::MethodCall;
########################
use Carp;

use base qw(CIM::Base);


sub new {
    my ($class, %args) = @_;
    
    my $self = $class->SUPER::new();
    
    $self->{'CIM::MethodCall::_methodName'} = undef;
    $self->{'CIM::MethodCall::_localPath'} = undef;
    $self->{'CIM::MethodCall::_params'} = [];
    
    $self->{_identifier} = 'MethodCall';
    
    $self->{_childAccessors} = {
				LOCALINSTANCEPATH => 'localPath',
				LOCALCLASSPATH    => 'localPath',
				PARAMVALUE        => 'addParameter',
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
    defined $args{LocalPath} or $self->error("No LocalPath");
    
    $self->{_methodName} = $args{MethodName};
    $self->{_localPath} = $args{LocalPath};
}


sub localPath {
    my $self = shift;

    $self->{_localPath} = $_[0] if defined $_[0];

    return $self->{_localPath};
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
    
    # METHODCALL
    my $mc = $doc->createElement('METHODCALL');
    $mc->setAttribute('NAME', scalar $self->{_methodName});
    $doc->appendChild($mc);
    
    # LOCAL*PATH:
    my $lp = $self->{_localPath}->toXML;
    $lp->getDocumentElement()->setOwnerDocument($doc);
    $mc->appendChild($lp->getDocumentElement());
    
    # PARAMVALUE
    foreach my $param (@{$self->{_params}}) {
	my $p = $param->toXML;
	$p->getDocumentElement()->setOwnerDocument($doc);
	$mc->appendChild($p->getDocumentElement);
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

CIM::MethodCall - a representation of the XML tag "METHODCALL"



=head1 SYNOPSIS

 use CIM::MethodCall;

 $mc = CIM::MethodCall->new(	MethodName  => $method,
				LocalPath   => $on);

 $mc->parameters(@params);

 $doc = $mc->toXML();
 $mc2 = CIM::MethodCall->new(	XML => $doc );


=head1 DESCRIPTION

CIM::MethodCall - a representation of the CIM METHODCALL message element,
which defines a single extrinsicmethod invocation on a class or instance. 
A MethodCall contains the local path of the target class or instance 
and zero or more PARAMVALUE subelements (= parameter values to be passed to the method).
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

B<LocalPath> - Mandatory unless B<XML> is given. 
A CIM::ObjectName with local NamespacePath, 
the LOCALCLASSPATH or LOCALINSTANCEPATH part of the CIM query.



=head1 METHODS

=item _init([OPTIONS])

Called only by new(). Initialization of class variables.

=item localPath( [$localpath] )

Get/set function for the  LOCALCLASSPATH or LOCALINSTANCEPATH.
Input: optional, a CIM::ObjectName object with local NamespacePath.
Return value: CIM::ObjectName object with local NamespacePath.

=item methodName( [$methodName] )

Get/set function for the MethodName.
Input: optional, string.
Return value: string, name of the method.


=item addParameter( @params )

Adds a list of ParamValues to the Methodcall instance. 
No return value.

=item parameters( [@params] )

Get/set function for the ParamValues.
Input: optional, list of CIM::ParamValues
Return value: array of CIM::ParamValue objects with self->convertType eq
'PARAMVALUE'.


=item getParameterByName($paramName)

Input: parameter name, string.
Returns the CIM::ParamValue instance with the given name.


=item toXML()

Returns a XML::DOM document representation of the instance.

=item fromXML($node)

Creates an instance from the XML::DOM::Element $node and returns it.
Completely inherited from L<CIM::Base>.

=item toString()

Returns the instance as a string (for debugging purposes only).



=head1 SEE ALSO

L<CIM::Base>, L<CIM::ObjectName>, L<CIM::ParamValue>


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
