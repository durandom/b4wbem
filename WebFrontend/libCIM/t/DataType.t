use strict;
use lib "t";
use common;

use CIM::DataType;


my $t1 = CIM::DataType->new('string');
my $t2 = CIM::DataType->new(CIM::DataType::string);
my $t3 = CIM::DataType->new('boolean');

assert($t1->type() eq 'string');
assert($t1 == 'string');
assert($t1 != CIM::DataType::boolean);
assert($t1 == $t2);
assert($t1 != $t3);

assert(CIM::DataType::isValid('sint64'));
assert(!CIM::DataType::isValid('foo'));



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
