use strict;
use lib "t";
use common;

my $className = 'Test_System';
my $keyBindings = {};     # (i.e. keyless class)


sub test_1 {
    ;
}


callTests();


# MouseDevice tests
{
    _setProperty_ok($className, $keyBindings, 'MouseDevice', 'string',
		    '/dev/ttyS1');
}


########
# TODO #
########

#  _setProperty_ok($className, $keyBindings, 'KeyboardProtocol', 'string',
#  		'Xqueue');  # TODO

#  _setProperty_altok($className, $keyBindings, 'Emulate3Buttons', 'boolean',
#  		   0, 'FALSE');


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
