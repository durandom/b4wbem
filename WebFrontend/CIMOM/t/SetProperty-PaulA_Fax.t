use strict;
use lib "t";
use common;

my $className = 'PaulA_Fax';
my $keyBindings = {};     # (i.e. keyless class)


sub test_1 {
    _setProperty_ok($className, $keyBindings, 'DefaultMailForward', 
		    'string', undef);
    _setProperty_notok($className, $keyBindings, 'DefaultMailForward', 
		    'string', '', 4);
    _setProperty_ok($className, $keyBindings, 'DefaultMailForward', 'string', 
		    'bbunny' );
}
sub test_2 {
    _setProperty_notok($className, $keyBindings, 'ValidFaxExtensions', 
		    'string', [ qw(1234 456) ], 4 );
    _setProperty_ok($className, $keyBindings, 'ValidFaxExtensions', 'string', 
		    [ qw(1234 4567) ] );
    _getProperty_ok($className, $keyBindings, 'NumLength', '14' );

    _setProperty_notok($className, $keyBindings, 'ValidFaxExtensions', 
		    'string', [], 4);
    _setProperty_ok($className, $keyBindings, 'ValidFaxExtensions', 
		    'string', undef);
    _setProperty_ok($className, $keyBindings, 'ValidFaxExtensions', 'string', 
		    [ qw(123) ] );
    _getProperty_ok($className, $keyBindings, 'NumLength', '13' );
}

sub test_3{
    _setProperty_altok($className, $keyBindings, 'FaxEnabled', 'boolean', 
		    '0', 'FALSE');
    _setProperty_altok($className, $keyBindings, 'FaxEnabled', 'boolean', 
		    '1', 'TRUE');
    _setProperty_altok($className, $keyBindings, 'FaxEnabled', 'boolean', 
		    '0', 'FALSE' );
}

sub test_4 {
    restoreSandbox();

    _setProperty_ok($className, $keyBindings, 'BaseNumber', 'string', 
		    '5555' );
    _setProperty_ok($className, $keyBindings, 'BaseNumber', 'string', 
		    undef);
    _setProperty_notok($className, $keyBindings, 'BaseNumber', 'string', 
		    '', 4);
    _setProperty_ok($className, $keyBindings, 'BaseNumber', 'string', 
		    '5555' );
    _setProperty_ok($className, $keyBindings, 'BaseNumber', 'string', 
		    '6666' );
    _getProperty_ok($className, $keyBindings, 'NumLength', '12' );
    _getProperty_ok($className, $keyBindings, 'Prefix', '492286666' );
    _getProperty_ok($className, $keyBindings, 'ValidFaxExtensions', 
		    [ qw(300 301 302 303) ] );
}

callTests();

########################
# FaxEnabled tests     #
########################
{
    _setProperty_altok($className, $keyBindings, 'FaxEnabled', 'boolean', 
		    '0', 'FALSE');
    _setProperty_altok($className, $keyBindings, 'FaxEnabled', 'boolean', 
		    '1', 'TRUE');
    _setProperty_altok($className, $keyBindings, 'FaxEnabled', 'boolean', 
		    '0', 'FALSE' );
}

########################
# HeaderIDString tests #
########################
{
    _setProperty_notok($className, $keyBindings, 'HeaderIDString', 'string', 
		    '', 4);
    _setProperty_ok($className, $keyBindings, 'HeaderIDString', 'string', 
		    undef);
    _setProperty_ok($className, $keyBindings, 'HeaderIDString', 'string', 
		    'ID-PRO Deutschland GmbH');
    _setProperty_ok($className, $keyBindings, 'HeaderIDString', 'string', 
		    'ID-PRO');
}

#########################
# HeaderFaxNumber tests #
#########################
{
    _setProperty_notok($className, $keyBindings, 'HeaderFaxNumber', 'string', 
		    '', 4);
    _setProperty_ok($className, $keyBindings, 'HeaderFaxNumber', 'string', 
		    undef);
    _setProperty_ok($className, $keyBindings, 'HeaderFaxNumber', 'string', 
		    '+49.228.42154300');
}
#########################
# NumLength tests	#
#########################
{
    _setProperty_ok($className, $keyBindings, 'NumLength', 'uint16', 
		    undef);
    _setProperty_notok($className, $keyBindings, 'NumLength', 'uint16', 
		    '', 4);
    _setProperty_ok($className, $keyBindings, 'NumLength', 'uint16', 
		    '10' );
}
#########################
# Prefix  tests		#
#########################
{
    _setProperty_ok($className, $keyBindings, 'Prefix', 'string', 
		    undef);
    _setProperty_notok($className, $keyBindings, 'Prefix', 'string', 
		    '', 4);
    _setProperty_ok($className, $keyBindings, 'Prefix', 'string', 
		    '102030' );
}
#########################
# AreaCode tests	#
#########################
{
    restoreSandbox();

    _setProperty_ok($className, $keyBindings, 'AreaCode', 'string', 
		    undef);
    _getProperty_ok($className, $keyBindings, 'NumLength', '10' );
    _getProperty_ok($className, $keyBindings, 'Prefix', '4942154' );

    _setProperty_notok($className, $keyBindings, 'AreaCode', 'string', 
		    '', 4);
    _setProperty_ok($className, $keyBindings, 'AreaCode', 'string', 
		    '01' );
    _getProperty_ok($className, $keyBindings, 'Prefix', '490142154' );
    _getProperty_ok($className, $keyBindings, 'NumLength', '12' );
    _getProperty_ok($className, $keyBindings, 'ValidFaxExtensions', 
		    [ qw(300 301 302 303) ] );
}
#########################
# CountryCode tests	#
#########################
{
    restoreSandbox();

    _setProperty_ok($className, $keyBindings, 'CountryCode', 'string', 
		    undef);
    _setProperty_notok($className, $keyBindings, 'CountryCode', 'string', 
		    '', 4);
    _getProperty_ok($className, $keyBindings, 'Prefix', '22842154' );
    _getProperty_ok($className, $keyBindings, 'NumLength', '11' );
    
    _setProperty_ok($className, $keyBindings, 'CountryCode', 'string', 
		    '011' );
    _getProperty_ok($className, $keyBindings, 'Prefix', '01122842154' );
    _getProperty_ok($className, $keyBindings, 'NumLength', '14' );
    _getProperty_ok($className, $keyBindings, 'ValidFaxExtensions', 
		    [ qw(300 301 302 303) ] );
}
#############################
# ValidFaxExtensions  tests #
#############################
{
    restoreSandbox();

    _setProperty_notok($className, $keyBindings, 'ValidFaxExtensions', 
		    'string', [ qw(1234 456) ], 4 );
    _setProperty_ok($className, $keyBindings, 'ValidFaxExtensions', 'string', 
		    [ qw(1234 4567) ] );
    _getProperty_ok($className, $keyBindings, 'NumLength', '14' );

    _setProperty_notok($className, $keyBindings, 'ValidFaxExtensions', 
		    'string', [], 4);
    _setProperty_ok($className, $keyBindings, 'ValidFaxExtensions', 
		    'string', undef);
    _setProperty_ok($className, $keyBindings, 'ValidFaxExtensions', 'string', 
		    [ qw(123) ] );
    _getProperty_ok($className, $keyBindings, 'NumLength', '13' );
}

#########################
# BaseNumber tests	#
#########################
{
    restoreSandbox();

    _setProperty_ok($className, $keyBindings, 'BaseNumber', 'string', 
		    undef);
    _setProperty_notok($className, $keyBindings, 'BaseNumber', 'string', 
		    '', 4);
    _setProperty_ok($className, $keyBindings, 'BaseNumber', 'string', 
		    '5555' );
    _getProperty_ok($className, $keyBindings, 'NumLength', '12' );
    _getProperty_ok($className, $keyBindings, 'Prefix', '492285555' );
    _getProperty_ok($className, $keyBindings, 'ValidFaxExtensions', 
		    [ qw(300 301 302 303) ] );
}
############################
# DefaultMailForward tests #
############################
{
    _setProperty_ok($className, $keyBindings, 'DefaultMailForward', 
		    'string', undef);
    _setProperty_notok($className, $keyBindings, 'DefaultMailForward', 
		    'string', '', 4);
    _setProperty_ok($className, $keyBindings, 'DefaultMailForward', 'string', 
		    'bbunny' );
}
    
BEGIN { $numOfTests = 71; print "$numOfTests\n"; }


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
