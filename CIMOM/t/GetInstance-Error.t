use strict;
use lib "t";
use common;

my $className = 'PaulA_User';
my $keyBindings;


sub test_1 {
    $keyBindings = { Login => 'hsimpson' };
    _getInstance_notok($className, $keyBindings, [ 'InvalidProperty' ],
		       12);  # TODO: check it out, if it's an error
}



callTests();


#######################
# general error tests #
#######################

{
    # invalid key
    $keyBindings = { InvalidKey => 'hsimpson' };
    _getInstance_notok($className, $keyBindings, [ 'LoginShell' ],
		       6);
    
    # invalid class
    $keyBindings = { Login => 'invaliduser' };
    _getInstance_notok('Invalid_Class', $keyBindings, [ 'LoginShell' ],
  		       5);
    
    # invalid user
    $keyBindings = { Login => 'invaliduser' };
    _getInstance_notok($className, $keyBindings, [ 'LoginShell' ],
		       6);
    
    # invalid user, empty property list
    $keyBindings = { Login => 'invaliduser' };
    _getInstance_notok($className, $keyBindings, [ ],
		       6);
}



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
