use strict;

##############################
package CIM::OperationMessage;
##############################
use Carp;

use base qw(CIM::Base);


sub new {
    my ($class, %args) = @_;
    
    my $self = $class->SUPER::new();

    $self->{'CIM::OperationMessage::_CIMVersion'} = '2.0';
    $self->{'CIM::OperationMessage::_DTDVersion'} = '2.0';
    $self->{'CIM::OperationMessage::_messageID'} = undef;
    $self->{'CIM::OperationMessage::_protocolVersion'} = '1.0';
    
    $self->{_identifier} = 'OperationRequest';
    
    $self->processArgs(%args);
    
    return $self;
}


sub _init {
    my ($self, %args) = @_;
    
    defined $args{MessageID} or $self->error("No MessageID");
    $self->{'_messageID'} = $args{MessageID};
}


sub CIMVersion {
    my $self = shift;

    $self->{_CIMVersion} = $_[0] if defined $_[0];
    
    return $self->{_CIMVersion};
}

sub DTDVersion {
    my $self = shift;

    $self->{_DTDVersion} = $_[0] if defined $_[0];
    
    return $self->{_DTDVersion};
}

sub messageID {
    my $self = shift;

    $self->{_messageID} = $_[0] if defined $_[0];
    
    return $self->{_messageID};
}

sub protocolVersion {
    my $self = shift;

    $self->{_protocolVersion} = $_[0] if defined $_[0];
    
    return $self->{_protocolVersion};
}



1;


__END__

=head1 NAME

CIM::OperationMessage - Base class for CIM Operation Request/Response Messages



=head1 SYNOPSIS

    $opReq = 
	CIM::OperationMessage->new( MessageID => 
					    scalar CIM::IDGenerator->new->id());


=head1 DESCRIPTION

CIM::OperationMessage - Base class for CIM Operation Request/Response Messages


=head1 CONSTRUCTOR

=over 4

=item new([OPTIONS])

C<OPTIONS> are passed in a hash like fashion, using key and value pairs.
The possible options are:

B<XML> - Read the instance from the given XML::DOM element or document. 
Only used as sole option. If additional options are given they
will be ignored.

B<MessageID> - mandatory unless B<XML> is given. A unique number, 
which should be generated via CIM::IDGenerator->new->id().

=head1 METHODS

=item _init([OPTIONS])

Called only by new(). Initialization of class variables.

=item CIMVersion()
    
Get/set accessor for the CIMVersion.
Input, return value: string.

=item DTDVersion()
    
Get/set accessor for the DTDVersion.
Input, return value: string.

=item messageID()
    
Get/set accessor for the messageID.
Input, return value: number.

=item protocolVersion()

Get/set accessor for the protocolVersion.
Input, return value: string.


=head1 SEE ALSO

L<CIM::Base>

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
