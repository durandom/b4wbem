use strict;
use lib "t";
use common;

my $className = 'PaulA_VPN';
my $keyBindings = {};		# (i.e. keyless class)


sub test_1 {
    _setProperty_altok($className, $keyBindings, 'RouteLocalNetwork', 'boolean',
		       '1', 'TRUE');
    _setProperty_altok($className, $keyBindings, 'RouteLocalNetwork', 'boolean',
		       '0', 'FALSE');
    _setProperty_altok($className, $keyBindings, 'RouteLocalNetwork', 'boolean',
		       '1', 'TRUE');
}
sub test_2 {
    _setProperty_ok($className, $keyBindings, 'ServerIP', 'string',
		    '34.56.67.89');
    _setProperty_notok($className, $keyBindings, 'ServerIP', 'string',
		       undef, 4);
    _setProperty_ok($className, $keyBindings, 'ServerIP', 'string',
		       '');
    _getProperty_ok($className, $keyBindings, 'ServerPort', '');
}

sub test_4 {
    _setProperty_ok($className, $keyBindings, 'ServerPort', 'string',
		    '34.56.67.89');
    _setProperty_notok($className, $keyBindings, 'ServerPort', 'string',
		       undef, 4);
    _setProperty_ok($className, $keyBindings, 'ServerPort', 'string',
		       '');
    _getProperty_ok($className, $keyBindings, 'ServerIP', '195.227.34.59');
}
sub test_3 {
    _setProperty_altok($className, $keyBindings, 'VPNEnabled', 'boolean',
		       '1', 'TRUE');
    _setProperty_altok($className, $keyBindings, 'VPNEnabled', 'boolean',
		       '0', 'FALSE');
    _setProperty_altok($className, $keyBindings, 'VPNEnabled', 'boolean',
		       '1', 'TRUE');
}


callTests();


##################
# ServerIP tests #
##################
{
    _setProperty_ok($className, $keyBindings, 'ServerIP', 'string',
		    '12.123.456.78');
    _setProperty_notok($className, $keyBindings, 'ServerIP', 'string',
		       undef, 4);
    _setProperty_ok($className, $keyBindings, 'ServerIP', 'string',
		       '');
    _getProperty_ok($className, $keyBindings, 'ServerPort', '');
}

####################
# ServerPort tests #
####################
{
    restoreSandbox();
    
    _setProperty_ok($className, $keyBindings, 'ServerPort', 'uint32',
		    '1000');
    _setProperty_ok($className, $keyBindings, 'ServerPort', 'uint32',
		       '');
    _getProperty_ok($className, $keyBindings, 'ServerIP', '195.227.34.59');

    _setProperty_notok($className, $keyBindings, 'ServerPort', 'uint32',
		       undef, 4);
    _setProperty_ok($className, $keyBindings, 'ServerPort', 'uint32',
		    '2000');
}

################
# Remote tests #
################
{
    _setProperty_ok($className, $keyBindings, 'Remote', 'string',
		    '34.56.67.89');
    _setProperty_ok($className, $keyBindings, 'Remote', 'string', '');
    _setProperty_notok($className, $keyBindings, 'Remote', 'string',
		       undef, 4);
    # kann leider nicht so getestet werden: 
    # ob die Änderung der route Zeile korrekt erfolgt 
}

###############
# Local tests #
###############
{
    _setProperty_ok($className, $keyBindings, 'Local', 'string',
		    '34.56.67.89');
    _setProperty_ok($className, $keyBindings, 'Local', 'string', '');
    _setProperty_ok($className, $keyBindings, 'Local', 'string',
		    '89.67.56.34');
}

##################
# IsServer tests #
##################
{
    _setProperty_altok($className, $keyBindings, 'IsServer', 'boolean',
		       '0', 'FALSE');
    _setProperty_altok($className, $keyBindings, 'IsServer', 'boolean',
		       '1', 'TRUE');
}

####################
# VPNEnabled tests #
####################
{
    _setProperty_altok($className, $keyBindings, 'VPNEnabled', 'boolean',
		       '1', 'TRUE');
    _setProperty_altok($className, $keyBindings, 'VPNEnabled', 'boolean',
		       '0', 'FALSE');
    _setProperty_altok($className, $keyBindings, 'VPNEnabled', 'boolean',
		       '1', 'TRUE');
}


BEGIN { $numOfTests = 35; print "$numOfTests\n"; }


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
