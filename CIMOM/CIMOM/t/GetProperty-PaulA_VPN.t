use strict;
use lib "t";
use common;

my $className = 'PaulA_VPN';
my $keyBindings = {};     # (i.e. keyless class)

sub test_1 {
    _getProperty_ok($className, $keyBindings, 'InetAddr', 
		    '10.2.64.100' );
}
sub test_2 {
    _getProperty_ok($className, $keyBindings, 'Mask', 
		    '255.255.252.0' );
}
sub test_3 {
    _getProperty_ok($className, $keyBindings, 'VPNEnabled', 
		    'FALSE' );
}
    
callTests();

{
    _getProperty_ok($className, $keyBindings, 'ServerIP', 
		    '195.227.34.59' );
    _getProperty_ok($className, $keyBindings, 'ServerPort', 
		    '3500' );
    _getProperty_ok($className, $keyBindings, 'Remote', 
		    '10.128.2.1' );
    _getProperty_ok($className, $keyBindings, 'Local', 
		    '10.2.2.2' );
    _getProperty_ok($className, $keyBindings, 'RouteLocalNetwork', 
		    'TRUE' );
    _getProperty_ok($className, $keyBindings, 'VPNEnabled', 
		    'FALSE' );

    _getProperty_ok($className, $keyBindings, 'InetAddr', 
		    '10.2.64.100' );
    _getProperty_ok($className, $keyBindings, 'Mask', 
		    '255.255.252.0' );
}

BEGIN { $numOfTests = 8; print "$numOfTests\n"; }


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
