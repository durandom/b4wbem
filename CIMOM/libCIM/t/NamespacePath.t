use strict;
use lib "t";
use common;

use XML::DOM;
use CIM::NamespacePath;


# Test 1:
my $ns = CIM::NamespacePath->new();
$ns->namespace("root/My/Namespace");
# $ns->namespace( ["root", "My", "Namespace"]);

assert($ns->namespace() eq 'root/My/Namespace');

# print STDERR $ns->toString, "\n";

# Test 2:
my @namespaceParts = $ns->namespace();

assert($namespaceParts[2] eq 'Namespace');


# Test 3:
my $parser = XML::DOM::Parser->new();
my $doc = $parser->parse('<LOCALNAMESPACEPATH><NAMESPACE NAME="root"/><NAMESPACE NAME="cimv2"/></LOCALNAMESPACEPATH>');

my $ns2 = CIM::NamespacePath->new(XML => $doc);
assert($ns2->namespace() eq 'root/cimv2');


# Test 4:
$ns->host("someHostName");

my $compare = '<NAMESPACEPATH><HOST>someHostName</HOST><LOCALNAMESPACEPATH><NAMESPACE NAME="root"/><NAMESPACE NAME="My"/><NAMESPACE NAME="Namespace"/></LOCALNAMESPACEPATH></NAMESPACEPATH>' . "\n";
assert($ns->toXML->toString eq $compare);


BEGIN { $numOfTests = 4; print "$numOfTests\n"; }


# Copyright (c) 2000 ID-PRO Deutschland GmbH. All rights reserved.

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307,
# USA.


