use strict;

###################
package CIM::Error;
###################
use Carp;

use CIM::Utils;

use base qw(CIM::Base);



use constant CIM_ERR_FAILED                       =>  1;
use constant CIM_ERR_ACCESS_DENIED                =>  2;
use constant CIM_ERR_INVALID_NAMESPACE            =>  3;
use constant CIM_ERR_INVALID_PARAMETER            =>  4;
use constant CIM_ERR_INVALID_CLASS                =>  5;
use constant CIM_ERR_NOT_FOUND                    =>  6;
use constant CIM_ERR_NOT_SUPPORTED                =>  7;
use constant CIM_ERR_CLASS_HAS_CHILDREN           =>  8;
use constant CIM_ERR_CLASS_HAS_INSTANCES          =>  9;
use constant CIM_ERR_INVALID_SUPERCLASS           => 10;
use constant CIM_ERR_ALREADY_EXISTS               => 11;
use constant CIM_ERR_NO_SUCH_PROPERTY             => 12;
use constant CIM_ERR_TYPE_MISMATCH                => 13;
use constant CIM_ERR_QUERY_LANGUAGE_NOT_SUPPORTED => 14;
use constant CIM_ERR_INVALID_QUERY                => 15;
use constant CIM_ERR_METHOD_NOT_AVAILABLE         => 16;
use constant CIM_ERR_METHOD_NOT_FOUND             => 17;


use constant ERROR_DEFINITIONS =>
    { 1 => 'A general error occured that is not covered by a more specific ' .
           'error code',
      2 => 'Access to a CIM resource was not available to the client',
      3 => 'The target namespace does not exist',
      4 => 'One or more parameter values passed to the method were invalid',
      5 => 'The specified Class does not exist',
      6 => 'The requested object could not be found',
      7 => 'The requested operation is not supported',
      8 => 'Operation cannot be carried out on this class since it has ' .
           'subclasses',
      9 => 'Operation cannot be carried out on this class since it has ' .
           'instances',
      10 => 'Operation cannot be carried out since the specified superclass ' .
            'does not exist',
      11 => 'Operation cannot be carried out because an object already exists',
      12 => 'The specified Property does not exist',
      13 => 'The value supplied is incompatible with the type',
      14 => 'The query language is not recognized or supported',
      15 => 'The query is not valid for the specified query language',
      16 => 'The extrinsic Method could not be executed',
      17 => 'The specified extrinsic Method does not exist'
    };


sub new {
    my ($class, %args) = @_;

    my $self = $class->SUPER::new();

    $self->{'CIM::Error::_code'} = undef;
    $self->{'CIM::Error::_description'} = undef;

    $self->{_identifier} = 'CIMError';

    $self->{_attrAccessors} = {
			       CODE        => 'code',
			       DESCRIPTION => 'description',
			      };
    
    $self->processArgs(%args);

    return $self;
}

sub _init {
    my ($self, %args) = @_;

    defined $args{Code} or $self->error("No error code given");
    $self->code($args{Code});	
    $self->{_description} = $args{Description} if defined $args{Description};
}


# get/set routine
sub code {
    my ($self, $code) = @_;

    if (defined $code) {
	($code >= 1 and $code <= 17) or fatal "Illegal error code: $code\n";
	$self->{_code} = $code;
	$self->{_description} = ERROR_DEFINITIONS->{$code};
    }
    
    return $self->{_code};
}


# get/set routine
sub description {
    my $self = shift;
    
    $self->{_description} = $_[0] if defined $_[0];
    
    return $self->{_description};
}


sub toXML {
    my $self = shift;
    
    my $doc = XML::DOM::Document->new();
    
    my $error = $doc->createElement('ERROR');
    
    $error->setAttribute('CODE', scalar $self->{_code});
    $error->setAttribute('DESCRIPTION', scalar $self->{_description}) 
	if $self->{_description};

    # get xml of property object

    $doc->appendChild($error);

    return $doc;       
}	


# fromXML() completely inherited from CIM::Base


sub toString {
    my $self = shift;
    
    my $text = "CIMError (code: $self->{_code}";
    $text .= ", description: $self->{_description}"
	if defined $self->{_description};
    $text .= ')';
    
    return $text;
}


1;


__END__

=head1 NAME

 CIM::Error - class representing CIM ERROR message elements.



=head1 SYNOPSIS

 use CIM::Error;

 $error = 
    CIM::Error->new( Code => CIM::Error::CIM_ERR_NO_SUCH_PROPERTY);

 $doc = error->toXML();
 $error2 = CIM::Error->new( XML => $doc);


=head1 DESCRIPTION

This module represents CIM ERROR message elements. 
A CIM::Error is used only as element of a CIM::IMethodResponse or 
a CIM::MethodResponse.


=head1 CONSTRUCTOR

=over 4   

=item new([OPTIONS])

C<OPTIONS> are passed in a hash like fashion, using key and value pairs.
The possible options are:

B<XML> - Read the instance from the given XML::DOM element or document. 
Only used as sole option. If additional options are given they
will be ignored.

B<Code> - Mandatory unless B<XML> is given, code signifying the error.

B<Description> - Optional, description of the error. Normally this
option isn't used, as descriptions are provided for each error
code.


=head1 METHODS

=item code([$arg])

Get/set function for the error code (a number). Also sets the error description
to the appropriate text for that code.
Return value: number.

=item description([$arg])

Get/set function for the error description.
Return value: string.

=item toXML()

Returns a XML::DOM document representation of the instance.

=item fromXML($node)

Creates an instance from the XML::DOM::Element $node and returns it.
Completely inherited from L<CIM::Base>.

=item toString()

Returns the instance as string (for debugging purposes only).


=head1 SEE ALSO

L<CIM::Base>, L<CIM::IMethodResponse>



=head1 AUTHORS

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
