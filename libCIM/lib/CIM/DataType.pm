use strict;

######################
package CIM::DataType;
######################
use Carp;

use Tie::SecureHash;


sub boolean   { 'boolean'   }
sub string    { 'string'    }
sub char16    { 'char16'    }
sub uint8     { 'uint8'     }
sub sint8     { 'sint8'     }
sub uint16    { 'uint16'    }
sub sint16    { 'sint16'    }
sub uint32    { 'uint32'    }
sub sint32    { 'sint32'    }
sub uint64    { 'uint64'    }
sub sint64    { 'sint64'    }
sub datetime  { 'datetime'  }
sub real32    { 'real32'    }
sub real64    { 'real64'    }

sub reference { 'reference' }

sub true      { 'true'      }
sub false     { 'false'     }



sub new {
    my ($class, $type) = @_;
    
    my $self = Tie::SecureHash->new($class);
    
    croak "[CIMDataType] Invalid DataType" unless isValid($type);
    
    $self->{'CIM::DataType::_type'} = $type;
    
    return $self;
}

sub type {
    my $self = shift;
    
    return $self->{_type};
}


sub isValid {
    my $type = shift;
    my @types = qw(boolean string char16
		   sint8 sint16 sint32 sint64
		   uint8 uint16 uint32 uint64
		   real32 real64
		   datetime
		   reference);
    return (not defined $type or scalar (grep { /^$type$/ } @types));
}



##
## overloading the standard operators:
##

use overload "=="  => \&_equals,
             "!="  => sub { not _equals(@_) },
             q{""} => sub { ($_[0]->{_type}) };

sub _equals {
    my $lhs = $_[0]->{_type};
    my $rhs = (ref $_[1] eq 'CIM::DataType' ? $_[1]->{_type} : $_[1]);
    ($lhs eq $rhs);
}


1;


__END__

=head1 NAME

CIM::DataType - represents a simple CIM data type



=head1 SYNOPSIS

 use CIM::DataType;

 $t1 = CIM::DataType->new('string');
 $t2 = CIM::DataType->new(CIM::DataType::boolean);

 print "type of t1 is '$t1'\n";
 $t1->type('char');
 print "type of t1 is '", $t1->type(), "'\n";

 print "equal\n" if ($t1 == $t2);
 print "not equal\n" if ($t1 != $t2);

 print "isString\n" if ($t1 == 'string');
 print "isNoReal32\n" if ($t1 != CIM::DataType::real32);

 print "ok\n" if CIM::DataType::isValid('sint64');



=head1 DESCRIPTION

This module represents a simple CIM data type.

Supported data types are
B<boolean>, B<string>, and B<char16> for character and texts,
B<sint8>, B<sint16>, B<sint32>, and B<sint64> for signed decimal values,
B<uint8>, B<uint16>, B<uint32>, and B<uint64> for unsigned decimal values,
B<real32> and B<real64> for floating point values,
B<datetime> for a datetime value, and
B<reference> if the corresponding value is a reference.


=head1 CONSTRUCTOR

=over 4

=item new($type)

$type (a string) must be a valid CIM data type.



=head1 METHODS

=item type()

Returns the current data type, string.

=item isValid($type)

Checks if a given data type $type is a valid CIM data type.
Returns the CIM data type or undef.


=head1 OPERATORS

=item ==, !=

If not implemented in the derived class it compares the XML output of
the instance.

=item ""

In scalar context the toString() function will be called. So you can do
a shorter "print $cimobject" instead of a "print $cimobject->toString()".



=head1 SEE ALSO

L<CIM::Value>



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
