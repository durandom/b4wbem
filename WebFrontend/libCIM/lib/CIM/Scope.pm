use strict;

###################
package CIM::Scope;
###################
use Carp;

use base qw(CIM::Base);


# Constants:
sub ANY         { @_ ? 'ANY'         : 0; }
sub CLASS       { @_ ? 'CLASS'       : 1; }
sub ASSOCIATION { @_ ? 'ASSOCIATION' : 2; }
sub REFERENCE   { @_ ? 'REFERENCE'   : 3; }
sub PROPERTY    { @_ ? 'PROPERTY'    : 4; }
sub METHOD      { @_ ? 'METHOD'      : 5; }
sub PARAMETER   { @_ ? 'PARAMETER'   : 6; }
sub INDICATION  { @_ ? 'INDICATION'  : 7; }


sub new {
    my ($class, %args) = @_;
    
    my $self = $class->SUPER::new();
    
    $self->{'CIM::Scope::_scopes'} = {};
    
    $self->{_identifier} = 'CIMScope';
    
    $self->processArgs(%args);
    
    return $self;
}


sub _init {
    my ($self, %args) = @_;
    
    $self->{_scopes} = {};
    my @scopes = ();
    
    if (defined $args{Scopes})
    {
	push @scopes, @{$args{Scopes}};
	$self->scopes(@scopes);
    }
}


sub scopes {
    my $self = shift;
    
    if (defined $_[0]) {
	$self->deleteScopes();
	$self->addScopes(@_);
    }
    
    return (keys %{$self->{_scopes}});
}


sub deleteScopes {
    my $self = shift;
    
    $self->{_scopes} = {};
}


sub addScopes {
    my ($self, @scopes) = @_;
    
    foreach (@scopes) {
	no strict 'refs';
	eval { &{$_}() };
	$self->error("Invalid scope") if $@;
	
	if (/^ANY$/) {
	    $self->{_scopes} = { CLASS       => 'true',
				 ASSOCIATION => 'true',
				 REFERENCE   => 'true',
				 PROPERTY    => 'true',
				 METHOD      => 'true',
				 PARAMETER   => 'true',
				 INDICATION  => 'true' };
	}
	else {
	    $self->{_scopes}->{$_} = 'true';
	}
    }
}



sub toXML {
    my $self = shift;
    
    my $doc = XML::DOM::Document->new();
    
    my $scp = $doc->createElement('SCOPE');
    
    $doc->appendChild($scp);

    foreach my $key (sort keys %{$self->{_scopes}}) {
	my $value = $self->{_scopes}->{$key};
        $scp->setAttribute($key, $value);   
    }
    
    return $doc;       
}


sub fromXML {
    my ($self, $node) = @_;
    
    $node->getNodeName() eq 'SCOPE'
	or $self->error("Invalid Root Element: " . $node->getNodeName());
    
    my $attrib = $node->getAttributes();
    my @scopes = ();
    
    for (my $i = 0; $i < $attrib->getLength(); $i++) {
	next unless ($attrib->item($i)->getValue() =~ /^true$/i);
	
	push @scopes, $attrib->item($i)->getName();
    }
    
    $self->scopes(@scopes);
}


sub toString {
    my $self = shift;
    
    my $s = "<" . "SCOPE";
    
    my @keyValuePairs = ();
    foreach my $key (sort keys %{$self->{_scopes}}) {
	my $value = $self->{_scopes}->{$key};
	push @keyValuePairs, "$key=\"$value\"";
    }
    
    $s .= ' ' if scalar @keyValuePairs;
    $s .= join ' ', @keyValuePairs;
    $s .= "/>";
    return $s;
}



1;

__END__

=head1 NAME

CIM::Scope - Class encapsulating CIM scopes



=head1 SYNOPSIS

 use CIM::Scope;

 $scope = CIM::Scope->new(Scopes => [ qw(CLASS METHOD) ]);
 $scope = CIM::Scope->new(XML => $doc);



=head1 DESCRIPTION

This module encapsulates CIM scopes. It determines to what CIM objects
a CIM qualifier applies.
(E.g. the ABSTRACT qualifier applies to Classes, Associations and
Indications.)



=head1 CONSTRUCTOR

=over 4

=item new([OPTIONS])

C<OPTIONS> are passed in a hash like fashion, using key and value pairs.
The possible options are:

B<XML> - Read the instance from the given XML::DOM element or document. 
Only used as sole option. If additional options are given they
will be ignored.

B<Scopes> - Mandatory unless B<XML> is given. The value is an array
reference, valid scopes are: B<CLASS>, B<ASSOCIATION>, B<REFERENCE>, 
B<PROPERTY>, B<METHOD>, B<PARAMETER>, and B<INDICATION>.
The B<ANY> scope sets all scopes.



=head1 METHODS

=item scopes(scope1, scope2, ...)

Get/set-accessor. When called with arguments, it deletes the current
scopes and sets the ones given in the arguments list.
Input: optional, list of scopes (strings).
Return value: array.

=item deleteScopes()

Deletes all scopes.
No return value.

=item addScopes(scope1, scope2, ...)

Adds scopes. (Does not delete current scopes.) 
No return value.

=item toXML()

Returns a XML::DOM document representation of the instance.

=item fromXML($node)

Creates an instance from the XML::DOM::Element $node and returns it.
Not inherited, function from CIM::Base is overloaded.

=item toString()

Returns the instance as a string (for debugging purposes only).



=head1 SEE ALSO

L<CIM::Base>


=head1 AUTHOR

 Axel Miesen <miesen@ID-PRO.de>
 Friedrich Fox <fox@ID-PRO.de>



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
