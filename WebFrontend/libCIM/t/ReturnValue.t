use strict;
use lib "t";
use common;

use CIM::ReturnValue;


#### Tests 1+3:

my $v = CIM::Value->new(Value => [0, 1],
			Type  => CIM::DataType::boolean);

my $p1 = CIM::ParamValue->new(Name        => 'myName',
			      Value       => $v,
			      ConvertType => 'PARAMVALUE');
my $p2 = CIM::ParamValue->new(XML => $p1->toXML);
$p2->value->type('boolean');

assert($p1 == $p2);
assert($p1->convertType('IPARAMVALUE') eq 'IPARAMVALUE');
assert($p1->name() eq 'myName');


BEGIN { $numOfTests = 3; print "$numOfTests\n"; }


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
