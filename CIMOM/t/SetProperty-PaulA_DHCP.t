use strict;
use lib "t";
use common;

my $className = 'PaulA_DHCP';
my $keyBindings = {};		# (i.e. keyless class)


sub test_1 {
    ;
}


callTests();


#################
# Routers tests #
#################
{
    _setProperty_ok($className, $keyBindings, 'Routers', 'string',
		    '50.60.70.80');
    _setProperty_ok($className, $keyBindings, 'Routers', 'string',
		    undef);
    _setProperty_ok($className, $keyBindings, 'Routers', 'string',
		    '51.61.71.81');
    _setProperty_notok($className, $keyBindings, 'Routers', 'string',
		       '', 4);
}

######################
# HostMappings tests #
######################
{
    _setProperty_ok($className, $keyBindings, 'HostMappings', 'string', 
		    [qw(
			00:10:dc:b0:21:c4-1.2.3.5
			00:10:dc:b0:29:2a-1.2.3.4 
			00:10:dc:b0:37:40-1.2.3.6 
			00:10:dc:b0:39:78-1.2.3.7
			00:40:ca:1e:0e:1a-5.5.6.13 
			00:d0:b7:79:ec:e4-5.5.6.12 
		       )]);
    _setProperty_ok($className, $keyBindings, 'HostMappings', 'string', 
		    undef);
    _setProperty_ok($className, $keyBindings, 'HostMappings', 'string', 
		    [qw(
			00:10:dc:b0:21:c4-1.2.3.5
			00:10:dc:b0:29:2a-1.2.3.4 
			00:40:ca:1e:0e:1a-5.5.6.13 
			00:d0:b7:79:ec:e4-5.5.6.12 
		       )]);
    _setProperty_notok($className, $keyBindings, 'HostMappings', 'string', 
		       [qw() ], 4);
    
}

################
# Ranges tests #
################
{
    _setProperty_ok($className, $keyBindings, 'Ranges', 'string',
		    [qw(1.2.3.4-1.2.3.7 4.5.6.10-4.5.6.13)]);
    _setProperty_ok($className, $keyBindings, 'Ranges', 'string',
		    [qw(7.5.6.10)]);
    _setProperty_ok($className, $keyBindings, 'Ranges', 'string',
		    [qw(1.2.3.4-1.2.3.7 4.5.6.10-4.5.6.13)]);
    
    _setProperty_notok($className, $keyBindings, 'Ranges', 'string',
		       [qw()], 4);
    _setProperty_notok($className, $keyBindings, 'Ranges', 'string',
		       undef, 4);
}

###########################
# DomainNameServers tests #
###########################
{
    _setProperty_ok($className, $keyBindings, 'DomainNameServers', 'string', 
		    [ '55.2.64.62' ]); 
    _setProperty_ok($className, $keyBindings, 'DomainNameServers', 'string', 
		    undef); 
    _setProperty_ok($className, $keyBindings, 'DomainNameServers', 'string', 
		    ['20.2.64.62', '20.2.64.63']); 
    _setProperty_notok($className, $keyBindings, 'DomainNameServers', 'string', 
		       [qw()], 4); 
}

#####################
# DHCPEnabled tests #
#####################
{
    restoreSandbox();
    
    _setProperty_altok($className, $keyBindings, 'DHCPEnabled', 'boolean',
		       '0', 'FALSE');
    _setProperty_altok($className, $keyBindings, 'DHCPEnabled', 'boolean',
		       '1', 'TRUE');
    _setProperty_altok($className, $keyBindings, 'DHCPEnabled', 'boolean',
		       '0', 'FALSE');
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
