use strict;
use lib "t";
use common;

my $className = 'Test_User';
my $keyBindings;


my $lluke = { Login => 'lluke' };
my $mmouse = { Login => 'mmouse' };
my $bbunny = { Login => 'bbunny' };
my $hsimpson = { Login => 'hsimpson' };


sub test_1 {
    ;
}

callTests();


{
    #######################################
    $keyBindings = { Login => 'hsimpson' };
    #######################################
    
    _getProperty_ok($className, $keyBindings, 'Login',
		    'hsimpson');
    _getProperty_ok($className, $keyBindings, 'Signature',
		    "Homer Simpson <homer\@springfield.net>
This is my Signature! :-)\n");
    _getProperty_ok($className, $keyBindings, 'MailAddress',
		    'hsimpson@devel-1.bonn.id-pro.net');
    _getProperty_ok($className, $keyBindings, 'SystemGroups',
		    [ qw(admins dialout) ]);
}


{
    ####################################
    $keyBindings = { Login => 'lluke' };
    ####################################
    
    _getProperty_ok($className, $keyBindings, 'Login',
		    'lluke');
    _getProperty_ok($className, $keyBindings, 'Signature',
		    '');
}


{
    #####################################
    $keyBindings = { Login => 'mmouse' };
    #####################################
    
    _getProperty_ok($className, $keyBindings, 'Login',
		    'mmouse');
    _getProperty_ok($className, $keyBindings, 'Signature',
		    undef);

}


###############
# error tests #
###############
{
    # invalid key
    _getProperty_notok($className, { InvalidKey => 'hsimpson' }, 'Signature',
		       6);
    
    # invalid username
    _getProperty_notok($className, { Login => 'invaliduser' }, 'Signature',
		       6);
    
    # invalid property name
    _getProperty_notok($className, { Login => 'hsimpson' }, 'InvalidName',
		       12);
}



BEGIN { $numOfTests = 11; print "$numOfTests\n"; }


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
