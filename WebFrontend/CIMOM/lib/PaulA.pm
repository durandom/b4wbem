use strict;

##############
package PaulA;
##############
use vars '$VERSION';

$VERSION = 0.51;



1;

__END__

=head1 NAME

PaulA - library for the percimon CIM Server



=head1 SYNOPSIS

 use PaulA;

 print "This is PaulA, Version $PaulA::VERSION\n";



=head1 DESCRIPTION

PaulA consists essentially of three parts: CIM Object Manager (cimom),
repository, and providers.

Please see L<cimom> for details of cimom usage and L<PaulA::Repository> 
for usage of the intrinsic methods interacting with the repository.

Our repository is in the CIM name space "root/PaulA" which is mapped
to the directory F<PaulA/repository/xmlRoot/PaulA/>.  There lie our XML
class definitions in plain text additionally to the official CIM class
definitions.

The test providers (development status) lie at F<PaulA/lib/PaulA/Provider/test>.
They work with the files and scripts at F<PaulA/t/sandbox>, not on the system.

The directory PaulA/lib/PaulA/Provider/ is the base directory in which
all providers will reside, they will be grouped according to the distribution 
and version they belong to, e.g. in a directory RedHat6.1 for Red Hat, 
version 6.1. 
For working with the "real" providers the link PaulA/lib/PaulA/Provider/PaulA 
has to point to the subdirectory of your distribution.

If you want to write a provider, look in the PaulA/doc directory for more
information.


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
