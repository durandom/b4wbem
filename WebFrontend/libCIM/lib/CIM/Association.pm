#########################
package CIM::Association;
#########################

use strict;
use Carp;
use CIM::Utils;

use base qw(CIM::Instance);

sub new {
    my ($class, %args) = @_;

    my $self = $class->SUPER::new(%args);

    $self->processArgs(%args);

    return $self;
}


sub _init {
    my ($self, %args) = @_;

    # init of CIM::Instance has to be called by hand as processArgs()
    # of that superclass can't be called without fromXML() going wrong 
    $self->SUPER::_init(%args);
    
    # set association qualifier
    my $v1 = CIM::Value->new( Value => 'TRUE',
			      Type  => CIM::DataType::boolean );

    my $q1 = CIM::Qualifier->new( Name  => 'Association',
				  Value	=> $v1	);

    # put it at the beginning of the list
    unshift @{$self->{_qualifiers}}, $q1;
}


1;

__END__

=head1 NAME

CIM::Association - class representing an association instance.



=head1 SYNOPSIS

See L<CIM::Instance>.


=head1 DESCRIPTION

This module inherits from CIM::Instance and differs from that class
only by automatically setting an association qualifier upon 
initialization.



=head1 CONSTRUCTOR

=over 4   

See L<CIM::Instance>.


=head1 METHODS

See L<CIM::Instance>.


=head1 SEE ALSO

L<CIM::Instance>


=head1 AUTHOR

 Eva Bolten <bolten@ID-PRO.de>



=head1 COPYRIGHT

Copyright (c) 2000 ID-PRO Deutschland GmbH. All rights reserved.
This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.    

=cut

