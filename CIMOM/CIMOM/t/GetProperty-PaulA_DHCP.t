use strict;
use lib "t";
use common;

my $className = 'PaulA_DHCP';
my $keyBindings = {};     # (i.e. keyless class)

sub test_1 {
    _getProperty_ok($className, $keyBindings, 'DHCPEnabled', 
		    'FALSE' );
}
sub test_2 {
    _getProperty_ok($className, $keyBindings, 'HostMappings', 
		    [qw(
			00:10:dc:b0:21:c4-1.2.3.5
			00:10:dc:b0:29:2a-1.2.3.4 
			00:10:dc:b0:37:40-1.2.3.6 
			00:10:dc:b0:39:78-1.2.3.7
			00:10:dc:b0:c5:ce-4.5.6.10 
			00:10:dc:b0:c6:cb-4.5.6.11
			00:40:ca:1e:0e:1a-4.5.6.13 
			00:d0:b7:79:ec:e4-4.5.6.12 
			)]
		    );
}
sub test_3 {
    _getProperty_ok($className, $keyBindings, 'Ranges', 
		    undef );
}
    
callTests();

{
    _getProperty_ok($className, $keyBindings, 'Routers', '10.20.30.40');

    
    _getProperty_ok($className, $keyBindings, 'HostMappings', 
		    [qw(
			00:10:dc:b0:21:c4-1.2.3.5
			00:10:dc:b0:29:2a-1.2.3.4 
			00:10:dc:b0:37:40-1.2.3.6 
			00:10:dc:b0:39:78-1.2.3.7
			00:10:dc:b0:c5:ce-4.5.6.10 
			00:10:dc:b0:c6:cb-4.5.6.11
			00:40:ca:1e:0e:1a-4.5.6.13 
			00:d0:b7:79:ec:e4-4.5.6.12 
			)]
		    );
    _getProperty_ok($className, $keyBindings, 'Ranges', 
		    [qw(1.2.3.4-1.2.3.7 4.5.6.10-4.5.6.13)] );
    
    _getProperty_ok($className, $keyBindings, 'DomainNameServers', 
	    [ '10.2.64.62' ]); 

    _getProperty_ok($className, $keyBindings, 'DHCPEnabled', 
		    'FALSE' );
}


BEGIN { $numOfTests = 5; print "$numOfTests\n"; }


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
