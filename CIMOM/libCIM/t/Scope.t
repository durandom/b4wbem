use strict;
use lib "t";
use common;

use CIM::Scope;


my $scope = CIM::Scope->new(Scopes => [ qw(CLASS ASSOCIATION) ]);


# Tests 1-4:

assert($scope->scopes() == 2);  # Test 1
$scope->deleteScopes();
assert($scope->scopes() == 0);  # Test 2
$scope->scopes( qw(METHOD INDICATION) );
$scope->addScopes( qw(REFERENCE) );
assert($scope->scopes() == 3);  # Test 3

$scope->addScopes( qw(CLASS ASSOCIATION METHOD) );
assert($scope->scopes() == 5);  # Test 4



# Test 5:

my $doc = $scope->toXML();
my $expectedOutput = $scope->toString();
my $generatedOutput = $doc->toString();
chomp($generatedOutput);

#print "From CIMScope: ", $expectedOutput, "\n";
#print "From XML::DOM: ", $generatedOutput, "\n";

assert($generatedOutput eq $expectedOutput);



# Test 6:

my $newScope = CIM::Scope->new(XML => $doc->getDocumentElement());

$newScope->addScopes('INDICATION');

my $newDoc = $newScope->toXML();

$expectedOutput = $newScope->toString();
$generatedOutput = $newDoc->toString();
chomp($generatedOutput);

#print "From CIMScope: ", $expectedOutput, "\n";
#print "From XML::DOM: ", $generatedOutput, "\n";

assert($generatedOutput eq $expectedOutput);



#Test 7:

$newScope->fromXML($doc->getDocumentElement());

$expectedOutput = $newScope->toString();
$generatedOutput = $doc->toString();
chomp($generatedOutput);

#print "From CIMScope: ", $expectedOutput, "\n";
#print "From XML::DOM: ", $generatedOutput, "\n";

assert($generatedOutput eq $expectedOutput);


BEGIN { $numOfTests = 7; print "$numOfTests\n"; }


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
