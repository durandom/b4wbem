use strict;
use lib "t";
use common;

my $className = 'PaulA_User';
my $keyBindings;


sub test_1 {
    ;
}


callTests();


# correct authentification
{
    $keyBindings = { Login => 'mmouse' };
    my $params =
	[
	 CIM::ParamValue->new(Name  => 'Password',
			      Value => CIM::Value->new(Value => 'mmouse',
						       Type  => 'string')),
	];
    
    _extrinsicMethod_ok($className, $keyBindings, 'Object', 'Authenticate',
			$params, 'TRUE');
}


# false authentification (of an existing user)
{
    $keyBindings = { Login => 'mmouse' };
    my $params =
	[
	 CIM::ParamValue->new(Name  => 'Password',
			      Value => CIM::Value->new(Value => 'foobar',
						       Type  => 'string')),
	];
    
    _extrinsicMethod_ok($className, $keyBindings, 'Object', 'Authenticate',
			$params, 'FALSE');
}


###############
# error tests #
###############
{
    # invalid key
    $keyBindings = { InvalidKey => 'mmouse' };
    _extrinsicMethod_notok($className, $keyBindings, 'Object', 'Authenticate',
			   [], 6);
    
    # invalid username
    $keyBindings = { Login => 'invaliduser' };
    _extrinsicMethod_notok($className, $keyBindings, 'Object', 'Authenticate',
			   [], 6);
    
    # invalid extrinsic method name
    $keyBindings = { Login => 'mmouse' };
    _extrinsicMethod_notok($className, $keyBindings, 'Object', 'InvalidName',
			   [], 17);
    _extrinsicMethod_notok($className, undef, 'Class', 'InvalidName',
			   [], 17);
}



BEGIN { $numOfTests = 6; print "$numOfTests\n"; }


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
