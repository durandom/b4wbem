use strict;
use lib "t";
use common;


sub test_1 {
    # invalid classname
    _extrinsicMethod_notok('Invalid_Class', {}, 'Class', 'SomeMethod',
			   [], 1);  # TODO! (other error code!)
}


callTests();


# invalid method name
{
    ;
}



BEGIN { $numOfTests = 0; print "$numOfTests\n"; }


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
