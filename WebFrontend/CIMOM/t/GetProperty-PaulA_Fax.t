use strict;
use lib "t";
use common;

my $className = 'PaulA_Fax';
my $keyBindings = {};     # (i.e. keyless class)


sub test_1 {
    _getProperty_ok($className, $keyBindings, 'DefaultMailForward', 
		    'bbunny' );
}
    

callTests();


{
    _getProperty_ok($className, $keyBindings, 'HeaderIDString', 
		    'ID-PRO' );
    _getProperty_ok($className, $keyBindings, 'HeaderFaxNumber', 
		    '+49.228.42154300' );
}
{
    _getProperty_ok($className, $keyBindings, 'CountryCode', 
		    '49' );
    _getProperty_ok($className, $keyBindings, 'AreaCode', 
		    '228' );
}
{
    _getProperty_ok($className, $keyBindings, 'Prefix', 
		    '4922842154' );
    _getProperty_ok($className, $keyBindings, 'BaseNumber', 
		    '42154' );
    _getProperty_ok($className, $keyBindings, 'NumLength', 
		    '13' );
}
{
    _getProperty_ok($className, $keyBindings, 'ValidFaxExtensions', 
		    [ qw(300 301 302 303) ] );
}
{
    _getProperty_ok($className, $keyBindings, 'DefaultMailForward', 
		    'bbunny' );
}   
{
    _getProperty_ok($className, $keyBindings, 'FaxEnabled', 
		    'FALSE' );
}
    
BEGIN { $numOfTests = 10; print "$numOfTests\n"; }


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
