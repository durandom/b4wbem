#
# Template for Perl modules test scripts.
#
# Delete these lines.
#
use strict;
use vars qw($test $numOfTests);

BEGIN { print "1.."; $| = 1; }

sub assert {
    my $expr = shift;
    print "not " unless $expr;
    ++$test;
    print "ok $test\n";
}

#
# Insert "use" statements here.
#
# use Some::Module;
# use Some::Other::Module;
#
# Delete these lines.
#





#
# Tests section:
#
# Do whatever you want, check your results with assert(EXPRESSION).
# Every assert() is a test.
#
# Delete these lines.
#



# Test 1:
assert(2 * 3 == 6);


# Test 2: (would fail!)
my $testString = "Hello World!";

assert($testString eq 'hello world');



#
# Insert number of tests here:
#
BEGIN { $numOfTests = 2; print "$numOfTests\n"; }

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
