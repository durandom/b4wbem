use strict;
use lib "t";
use common;

my $className = 'Test_User';
my $keyBindings;

my $hsimpson = { Login => 'hsimpson' };
my $bbunny   = { Login => 'bbunny' };
my $mmouse   = { Login => 'mmouse' };
my $lluke    = { Login => 'lluke' };



sub test_1 {
    ;
}


callTests();


{
    #######################################
    $keyBindings = { Login => 'hsimpson' };
    #######################################
    
    # "Signature" tests
    {
	_setProperty_ok($className, $keyBindings, 'Signature', 'string',
			"New sig: homer\@springfield\n");
  	_setProperty_ok($className, $keyBindings, 'Signature', 'string',
  			undef);
	_setProperty_ok($className, $keyBindings, 'Signature', 'string',
			"");
  	_setProperty_ok($className, $keyBindings, 'Signature', 'string',
  			undef);
	_setProperty_ok($className, $keyBindings, 'Signature', 'string',
			"This signature is false.");
    }
    
    # "SystemGroups" tests
    {
	_setProperty_ok($className, $keyBindings, 'SystemGroups', 'string',
			[ qw(admins users) ]);
	
	_setProperty_ok($className, $keyBindings, 'SystemGroups', 'string',
			[ qw(admins dialout users) ]);
	
	_setProperty_ok($className, $keyBindings, 'SystemGroups', 'string',
			[ qw(dialout users) ]);
	
	_setProperty_ok($className, $keyBindings, 'SystemGroups', 'string',
			[ qw(admins) ]);
	
	_setProperty_ok($className, $keyBindings, 'SystemGroups', 'string',
			[ qw() ]);
    }
}


###############
# error tests #
###############
{
    # invalid key
    _setProperty_notok($className, { InvalidKey => 'hsimpson' },
		       'LoginShell', 'string', 'bash', 6);
    
    # invalid username
    _setProperty_notok($className, { Login => 'invaliduser' },
		       'Signature', 'string', 'mysig', 6);
    
    # invalid property name
    _setProperty_notok($className, { Login => 'hsimpson' },
		       'InvalidName', 'string', 'foobar', 12);
}



    
BEGIN { $numOfTests = 23; print "$numOfTests\n"; }


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
