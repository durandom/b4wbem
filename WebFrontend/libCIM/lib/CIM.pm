use strict;

############
package CIM;
############
use vars '$VERSION';

$VERSION = 0.41;


1;

__END__

=head1 NAME

libCIM - fundamental library for CIM in Perl



=head1 SYNOPSIS

 use CIM;

 print "This is libCIM-$CIM::VERSION\n";



=head1 DESCRIPTION


libCIM serves as  a basis for an implementation of the
Common Information Model.

Subsequently, we assume that you are more or less familiar with the
document [1] ("Specification for CIM Operations over HTTP").


=head2 The basics

An essential class is CIM::Client. At the moment it enables you to
translate the Intrinsic Methods described in [1] to Perl.

Let us take a look at the GetClass "prototype":

 <class>  GetClass (
          [IN] <className> ClassName,
          [IN,OPTIONAL] boolean LocalOnly = true,
          [IN,OPTIONAL] boolean IncludeQualifiers = true,
          [IN,OPTIONAL] boolean IncludeClassOrigin = false,
          [IN,OPTIONAL,NULL] string PropertyList [] = NULL)

If you want to do a GetClass() in your CIM Client, you would write
something like 

 use CIM::Client;

 my $cc = CIM::Client->new(UseConfig => 1);

 my $on = CIM::ObjectName->new(ObjectName => 'CIM_ManagedElement');

 my $class;
 eval { $class = $cc->GetClass(ClassName         => $on,
		               IncludeQualifiers => 0) };

 if ($@) {
     if (ref $@ && $@->isa('CIM::Error')) {
         # Handle CIM Error
     } else {
         # Something else happened that is not a CIM error (perhaps
         # we couldn't connect to the cimom)
     }
 } else {
     # Do whatever you intended to do with this class...
     print $class->toXML->toString;
 }

This example shows the principle of "translating" CIM Intrinsic Methods to
Perl: You look at the prototype of the IMethod of your interest in [1].
The parameter names become Named Arguments, and the value of a single
Named Arg is either a "simple" Perl object (in the above example

 IncludeQualifiers => 0,
 
which was the default anyway), and the values of CIM "Pseudotype"
parameters (like <className>) are always appropriate Perl CIM objects
(a CIM::ObjectName in this example). Please take a look at the test
modules in the PaulA package for further examples.

For informations about Client configuration (you noticed the
"UseConfig => 1" in the CIM::Client constructor) see L<CIM::Client>.

=head1 REFERENCES

 1. "Specification for CIM Operations over HTTP",
     Version 1.0, DMTF, August  11th, 1999,
     (http://www.dmtf.org/download/spec/xmls/CIM_HTTP_Mapping10.htm)



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

