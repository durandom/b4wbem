
__END__

=head1 NAME

styleguide - Coding standards for the libCIM/PaulA project



=head1 ORDINARY PERL

We follow Larry Walls recommendations (see L<perlstyle>), except in the
following point(s):



=head2 Identifier names

Here we follow the usual OO style:

  # Variable/Object names begin with a lowercase character:

  my $objectName;
  my $veryLongVarName;

  # The same for function/method names:

  aFunctionName();
  $object->someMethod();



=head1 OBJECT ORIENTED PERL

Constructors are always called new(), copy constructors are called
clone().

Use named arguments, if a method (especially a constructor) gets more
than, say, 3 arguments.

Use the base and fields modules.

When calling methods with no arguments, it's ok to omit the ()-brackets,
when it's clear, what the code does: 

  print $object->toString;      # ok
  $obj->getSubObject->doit();   # mixing is ok, too



=head1 COMMON

Comment your code when it does non-obvious things. You can do this
with the '#'-character ;-)		

Comment your modules with pod, when you're quite sure, that the interface
is stable. This always has to be a "users documentation", which means,
that you should describe I<how to use the Module>, and I<not> the
algorithms you use to implement the cool things it does.



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
