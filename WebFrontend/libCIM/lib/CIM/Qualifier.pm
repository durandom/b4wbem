use strict;

#######################
package CIM::Qualifier;
#######################

use Carp;

use CIM::Utils;

use base qw(CIM::Base);


# defaults for qualifier flavors
use vars qw(%DEFAULTS);
%DEFAULTS = (OVERRIDABLE  => 'true',
	     TOSUBCLASS   => 'true',
	     TOINSTANCE   => 'false',
	     TRANSLATABLE => 'false');


sub new {
    my ($quali, %args) = @_;
    
    my $self = $quali->SUPER::new();
    
    $self->{'CIM::Qualifier::_name'} = undef;
    $self->{'CIM::Qualifier::_value'} = undef;
    $self->{'CIM::Qualifier::_flavors'} = {};
    $self->{'CIM::Qualifier::_propagated'} = 0;
    
    # set default flavors
    $self->flavors('DEFAULT');
    
    $self->{_identifier} = 'CIMQualifier';
    
    $self->{_childAccessors} = {
				VALUE	      => 'value',
				'VALUE.ARRAY' => 'value',
			       };
    $self->{_attrAccessors} = {
			       NAME        => 'name',
			       TYPE        => undef,
			       OVERRIDABLE => undef,
			       TOSUBCLASS  => undef,
			       TOINSTANCE  => undef,
			       TRANSLATABLE=> undef,
			       PROPAGATED  => 'propagated',
			      };
    
    $self->processArgs(%args);
    
    return $self;
}


sub _init {
    my ($self, %args) = @_;
    
    # Name and Value are required
    defined $args{Name} or $self->error("No Name");
    defined $args{Value} or $self->error("No Value");
    
    $self->{_value} = $args{Value};
    $self->{_name} = $args{Name};
    
    # giving Flavor is optional, has defaults
    # which were already set in 'new'
    if (defined $args{Flavors}) {
	$self->flavors($args{Flavors});
    }
    
    # propagated is optional
    $self->propagated($args{Propagated})
	if defined $args{Propagated};
    
    return $self;
}


# get/set routine
sub name {
    my $self = shift;

    $self->{_name} = $_[0] if defined $_[0];

    return $self->{_name};
}


# get/set routine
sub flavors {
    my $self = shift;
    
    if (defined $_[0]) {

	# set flavors to defaults 
	%{$self->{_flavors}} = %DEFAULTS;

	if ($_[0] !~ /^DEFAULT/ ) {
	    # minimal check for valid arguments
	    $self->error("Argument of flavors() must be a HASH or 'DEFAULT'!")
		unless (ref $_[0]) eq 'HASH';
	    # add flavors
	    $self->addFlavors($_[0]);
	}
    }

    return $self->{_flavors};
}

# add routine 
sub addFlavors {
    my $self = shift;
    my %flavors = %{$_[0]};

    # set given flavors
    foreach my $key (keys %flavors){
	# check wether the given flavor does exist
	$self->error("'$key' is no valid flavor")
	    unless exists $DEFAULTS{$key};
	
	# set flavor
	$self->{_flavors}{$key} = $flavors{$key};
    }
}


# get/set value
sub value {
    my $self = shift;

    $self->{_value} = $_[0] if $_[0];

    return $self->{_value};
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

    my $q = $doc->createElement('QUALIFIER');

    # handle attributes
    $q->setAttribute('NAME', scalar $self->{_name});
    $q->setAttribute('PROPAGATED', bool2string(scalar $self->{_propagated}))
	if $self->{_propagated} != 0;  # only set if not default
    $q->setAttribute('TYPE', scalar $self->{_value}->type);
    
    # only set a flavor if it's different from the default
    foreach my $key (sort keys %{$self->{_flavors}}) {
	$q->setAttribute($key, ${$self->{_flavors}}{$key})
	    if $self->{_flavors}{$key} ne $DEFAULTS{$key};
    }

    # get XML of value object
    if (defined $self->{_value}) {   
	my $e = $self->{_value}->toXML;	
    
        $e->getDocumentElement()->setOwnerDocument($doc);
        $q->appendChild($e->getDocumentElement());
    }

    $doc->appendChild($q);

    return $doc;
}                    


sub fromXML {
    my ($self, $node) = @_;

    # $node must be a document element 

    my $attrib = $node->getAttributes();
    my $nrOfAttribs = $attrib->getLength();

    # loop over all flavors
    for (my $j = 0; $j < $nrOfAttribs; $j++) {
        my $n = $attrib->item($j)->getName();
        my $v = $attrib->item($j)->getValue();
	
        # override a default flavor (which must already exists to be valid) 
        $self->{_flavors}{$n} = $v if defined $self->{_flavors}{$n};
    }
    
    $self->SUPER::fromXML($node);
}


# get routine, for debugging purposes
sub toString {
    my $self = shift;

    my $flavorString;
    foreach my $key (keys %{$self->{_flavors}}) {
	$flavorString .= "$key => $self->{_flavors}{$key} ";
    }
    
    my $propagated = bool2string(scalar $self->{_propagated});
    
    my $text = " *QualifierName: " . $self->name() . ", " .
	"QdataType: " . $self->{_value}->type() . ", " . 
	"QualifierFlavors: $flavorString, " . 
	"QValue: " . join(", ", $self->{_value}->convertValueToXML()) . ", " .
	"QFlavors: " . $propagated;

    return $text;
}


1;


__END__

=head1 NAME

 CIM::Qualifier - class encapsulating CIM qualifiers



=head1 SYNOPSIS

 use CIM::Qualfier;
  
 my $q = CIM::Qualifier->new(Name    => 'testName',
			     Value   => $valueRef,
			     Flavors => $flavorRef1);

 $q->name('newName');

 $q->addFlavors({   OVERRIDABLE => 0,
		    TOSUBCLASS	=> 0		});

 $q->flavors('DEFAULT');

 $quali->value($valueObj);

 $quali->propagated('true');

 $doc = $q->toXML;



=head1 DESCRIPTION

This module encapsulates CIM qualifiers. 
They must contain one value element (VALUE or VALUE.ARRAY) and 
attributes concerning the qualifier's name and CIM type. 
The type of the qualifier is in libCIM determined by the type of it's value.
Optional attributes are: qualifier flavor and a propagated flag.

=head1 CONSTRUCTOR

=over 4

=item new([OPTIONS])

C<OPTIONS> are passed in a hash like fashion, using key and value pairs.
The possible options are:

B<XML> - Read the instance from the given XML::DOM element or document. 
Only used as sole option. If additional options are given they
will be ignored.

B<Name> - Mandatory unless C<XML> is given, name of the qualifier, a string.

B<Value> - Mandatory unless C<XML> is given, value is a CIM::Value object 
of simple or array type.

B<Flavors> - Optional, the value is a reference to a hash with one or more 
of the keys C<OVERRIDABE>, C<TOSUBCLASS>, C<TOINSTANCE>, C<TRANSLATABLE> and 
their boolean values. Defaults are in the above order: 1, 1, 0, 0.

B<Propagated> - Optional, boolean, default is B<0>.



=head1 METHODS

=item _init([OPTIONS])

Called only by new(). Initialization of class variables.

=item name(['someName'])

Get/set function for the qualifier name.
Input: optional, string.
Return value: string.

=item flavors([$fRef])

Get/set function. When called with C<DEFAULTS> as argument, the default 
flavors  are set.
When called with a reference to a hash of flavors as argument the flavors 
are first set to their defaults and then changed according to the given 
flavors.
When called with no arguments, a reference to the flavor hash is returned.

Input: optional, reference to a hash with the flavors and their values 
or string 'DEFAULT'.
Return value: hash reference.


=item addFlavors($fRef)

Set function. Requires a reference to a hash with flavors as argument.
Changes the flavors to the ones given (without setting the 
defaults before).
No return value.

=item value([$v])

Get/set function for the qualifier's value. 
Input: optional, CIM::Value object (VALUE or VALUE.ARRAY).
Return value:  CIM::Value object (VALUE or VALUE.ARRAY).

=item propagated( [ { 'true' | 'false' | 1 | 0 } ] );

Get/set accessor. Valid values for the propagated flag are the strings B<true>
and B<false> and the corresponding integers B<1> and B<0>.
Return value: 0 or 1.

=item toXML()

Returns a XML::DOM document representation of the instance.

=item fromXML($node)

Creates an instance from the XML::DOM::Element $node and returns it.
Not inherited, function from CIM::Base is overloaded.

=item toString()

Returns the instance as a string (for debugging purposes only).



=head1 OPERATORS

see CIM::Base



=head1 SEE ALSO

L<CIM::Base>, L<CIM::Value>


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
