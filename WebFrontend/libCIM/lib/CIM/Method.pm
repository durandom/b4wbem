use strict;

######################
package CIM::Method;
######################
use Carp;
use CIM::Utils;

use base qw(CIM::Base);

use CIM::Parameter; # mark

sub new {
    my ($class, %args) = @_;
    
    my $self = $class->SUPER::new();
    
    $self->{'CIM::Method::_name'} = undef;
    $self->{'CIM::Method::_type'} = undef;
    $self->{'CIM::Method::_qualifiers'} = [];
    $self->{'CIM::Method::_parameters'} = [];
    $self->{'CIM::Method::_propagated'} = 0;
    
    $self->{_identifier} = 'CIMMethod';
    
    $self->{_childAccessors} = {
				QUALIFIER		=> 'addQualifiers',
				PARAMETER		=> 'addParameters',
				'PARAMETER.ARRAY'	=> 'addParameters',
				'PARAMETER.REFERENCE'	=> 'addParameters',
				'PARAMETER.REFARRAY'	=> 'addParameters',
			       };
    $self->{_attrAccessors} = {
				NAME => 'name',
				TYPE           => 'type',
				PROPAGATED     => 'propagated',
#				CLASSORIGIN    => '???'            # TODO!
			      };

    $self->processArgs(%args);
    
    return $self;
}

sub _init {
    my ($self, %args) = @_;
    
    # name is required
    defined $args{Name} or $self->error("No Name");
    $self->name($args{Name});

    # qualifiers are optional
    $self->{_qualifiers} =
        (defined $args{Qualifier})? $args{Qualifier} : undef;

    # parameters are optional
    $self->{_parameters} =
        (defined $args{Parameter})? $args{Parameter} : undef;

    # type is optional (when not given the method has no return value) 
    $self->type($args{Type})
	if (defined $args{Type});

    # propagated is optional
    $self->propagated($args{Propagated})
	if defined $args{Propagated};

}

# get/set routine
sub name {
    my $self = shift;

    $self->{_name} = $_[0] if defined $_[0];

    return $self->{_name};
}

# get/set routine
sub type {	# mark, get from Parameter if given?
    my $self = shift;

    $self->{_type} = $_[0] if defined $_[0];

    return $self->{_type};
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
sub parameters {
    my ($self, @p) = @_;
    
    if (@p) {
        $self->{_parameters} = undef;
        push @{$self->{_parameters}}, @p;
    }

    return $self->{_parameters};
}

sub addParameters {
    my ($self, @p) = @_;

    push @{$self->{_parameters}}, @p;

    return $self->{_parameters};
}

sub parameterByName {
    my ($self, $name) = @_;
    
    foreach (@{$self->{_parameters}}) {
	return $_
	    if ($_->name() eq $name);
    }
    
    return undef;
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

    my $class = $doc->createElement('METHOD');

    $class->setAttribute('NAME', scalar $self->{_name});
    
    $class->setAttribute('PROPAGATED', bool2string(scalar $self->{_propagated}))
	if $self->{_propagated} != 0;  # only set if not default
    
    $class->setAttribute('TYPE', scalar $self->{_type})
	if (defined $self->{_type} and
	    $self->{_type} ne 'CIM::DataType::reference');

    # get xml of qualifier object
    $self->_appendElements($doc, $class, $self->{_qualifiers});

    # get xml of parameter object
    $self->_appendElements($doc, $class, $self->{_parameters});

    $doc->appendChild($class);

    return $doc;
}


# fromXML() completely inherited from CIM::Base


# internal function for appending a qualifier or parameter list to a 
# XML::DOM document
sub _appendElements {
    my ($self, $doc, $class, $elements) = @_;

    foreach my $elem (@{$elements}) {
        my $e = $elem->toXML;

        $e->getDocumentElement()->setOwnerDocument($doc);
        $class->appendChild($e->getDocumentElement());
    }

    return $doc;
}

sub toString {
    my $self = shift;

    my $qualifiers;
    foreach my $quali (@{$self->{_qualifiers}}) {
        $qualifiers .= "\n" .  $quali->toString . " ";
    }
    my $parameters;
    foreach my $prop (@{$self->{_parameters}}) {
        $parameters .= "\n" .  $prop->toString . " ";
    }

    my $text =  "Method:\n Name: >$self->{_name}< " . 
		"\n qualifiers: >";

    $text .=  $qualifiers  if defined $qualifiers;
    $text .=  "<" . "\n parameters: >";
    $text .= $parameters if defined $parameters;
    $text .= "<";

    return $text;
}


1;

__END__

=head1 NAME

 CIM::Method - class encapsulating CIM methods



=head1 SYNOPSIS

 use CIM::Method;

 $method = CIM::Method->new(XML => $node);

 $method = CIM::Method->new(name => 'someName');

 $method->name();

 $method->qualifiers($qualifierObj1, $qualifierObj2);

 $method->addQualifiers($qualifierObj3);

 $qualifier = $method->qualifierByName('QualifierName');

 $method->parameters($parameterObj1, $parameterObj2);

 $method->addParameters($parameterObj3);

 $parameter = $method->parameterByName('ParameterName');

 print $method->toXML->toString;



=head1 DESCRIPTION

This module encapsulates CIM methods. 


=head1 CONSTRUCTOR

=over 4

=item new([OPTIONS])

C<OPTIONS> are passed in a hash like fashion, using key and value pairs.
The possible options are:

B<XML> - Read the method from the given XML::DOM element or document. 
Only used as sole option. If additional options are given they
will be ignored.

B<Name>	- Mandatory unless B<XML> is given. 

B<Parameter> - Optional, value is a reference to an array
of CIM::Parameter objects

B<Qualifier> - Optional, value is a reference to an array 
of CIM::Qualifier objects

B<Type>	- Optional, it's the type (a CIM::DataType) of the 
methods return value.  When not given the method has no return value!

B<Propagated> - Optional, boolean, default is B<0>



=head1 METHODS

=item _init([OPTIONS])

Called only by new(). Initialization of class variables.


=item name(['someName'])

Get/set accessor.  Called with an argument (string): name is changed to that
value, the new value is returned.
Called with no argument: the current name is returned.

=item type( [ CIM::DataType::someType ] )

Get/set accessor for the type of the methods return value.
Input: optional, CIM::DataType.
Return value: CIM::DataType.

=item qualifiers([$qualifierObj1 [, $qualifierObj2, ...]])

Get/set accessor. Called with one or more qualifier objects as arguments
the qualifier array will be zapped and then filled by the given qualifiers.
The function returns a reference to the array of all qualifier objects of the
CIM class.

=item addQualifiers($qualifierObj1 [, $qualifierObj2, ...])

Adds qualifiers to the qualifier array.
Input: one or more CIM qualifier objects. Return value: array reference.

=item qualifierByName($name)

Returns the qualifier with the given name (string) if existent, undef else.


=item parameters([$parameterObj1 [, $parameterObj2, ...]])

Same as qualifiers(), but for parameters.

=item addParameters($parameterObj1 [, $parameterObj2, ...])

Same as addQualifiers(), but for parameters.

=item parameterByName($name)

Same as qualifierByName(), but for parameters.


=item propagated( [ { 'true' | 'false' | 0 | 1} ] );

Get/set accessor. Valid values for the propagated flag are the strings B<true>
and B<false> and the corresponding integers B<1> and B<0>.
True means that the method was propagated from another class without 
modification. Default is false.
Return value: 0 or 1.

=item toXML()

Returns a XML::DOM document representation of the method.

=item fromXML($node)

Creates an instance from the XML::DOM::Element $node and returns it.
Completely inherited from L<CIM::Base>.

=item toString()

Returns the method as a string (for debugging purposes only).



=head1 OPERATORS

see L<CIM::Base>



=head1 SEE ALSO

L<CIM::Base>, L<CIM::Qualifier>, L<CIM::Parameter>



=head1 AUTHORS

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
