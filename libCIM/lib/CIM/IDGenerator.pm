use strict;

#########################
package CIM::IDGenerator;
#########################

use Tie::SecureHash;


sub new {
    my ($proto, %args) = @_;
    my $class = ref($proto) || $proto;
    
    my $self = Tie::SecureHash->new($class);
    
    $self->{'CIM::IDGenerator::_id'} = int 1E8 * rand;  # do it better!
    
    return $self;
}

sub id {
    my $self = shift;
    
    return $self->{_id};
}


1;


__END__

=head1 NAME

CIM::IDGenerator - A simple ID Generator



=head1 SYNOPSIS

 use CIM::IDGenerator;

 $id = new CIM::IDGenerator()->id();



=head1 DESCRIPTION

The CIM::IDGenerator defines identifiers for B<CIM> messages. The content
of the value is not constrained by the B<CIM> specification, but the
intention is this be used as a correlation mechanism between two CIM
entities.

An Operation Request Message MUST contain a non-empty value for the ID
attribute of the MESSAGE element.  The corresponding Operation
Response Message MUST supply the same value for that attribute.
Clients SHOULD employ a message ID scheme that minimizes the chance of
receiving a stale Operation Response Message.



=head1 METHODS

=over

=item new()

Creates a new CIM::IDGenerator instance. Currently each new instance
is created completely independed at random.

=item id()

Returns the ID of a CIM::IDGenerator instance without changing it.

=back



=head1 OPTIONS

There are no options implemented yet, but some to discuss:

=over

=item Prefix

Add a prefix string before the ID

=item Postfix

Add a postfix string after the ID

=item Method

This could either be B<random> B<incremental>

=item Encoding

This could be B<Num>, B<Hex> or B<B64>.

=back



=head1 NOTES

The current implementation just returns a random number. This
implementation is therefore not able to constrain network wide
uniq transaction IDs. The next version may implement network
wide IDs to allow nested 3 phase CIM transactions.

The B<new> method will create IDs dependend on their parent IDs.

The B<OPTIONS> proposed above could be used to create URI references
as defined by RFC2396; this means the ID can have a fragment identifier
and can be relative. A relative URI should be resolved into an
absolute URI during CIM processing: the URIs of B<MESSAGE> elements
in the data model should be absolute. Full URI processing is
an other can of worms that should be resolved by the URI class.



=head1 AUTHORS

 Volker Moell <moell@gmx.de>
 Michael Koehne <Kraehe@Copyleft.De>



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
