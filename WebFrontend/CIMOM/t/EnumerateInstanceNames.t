use strict;
use lib "t";
use common;


sub test_1 {
    ;
}


callTests();


################
# some classes #
################
{
    _enumerateInstanceNames_ok('PaulA_Administration',
			       [ {} ]);
    _enumerateInstanceNames_ok('PaulA_DHCP',
			       [ {} ]);
    _enumerateInstanceNames_ok('PaulA_Fax',
			       [ {} ]);
    _enumerateInstanceNames_ok('PaulA_Group',
			       [
				{ Name => 'paula_admin' },
				{ Name => 'paula_pnd' },
				{ Name => 'paula_user' },
			       ]);
    _enumerateInstanceNames_ok('PaulA_HTTPD',
			       [ {} ]);
    _enumerateInstanceNames_ok('PaulA_IncomingMailServer',
			       [
				{ Login => 'bert',
				  ServerName => 'test1.provider.net' },
				{ Login => 'ernie',
				  ServerName => 'test1.provider.net' },
				{ ServerName => 'test3.provider.net' },
				{ Login => 'multidropname',
				  ServerName => 'test2.provider.net' },
				{ Login => 'multidropname4',
				  ServerName => 'test4.provider.net' },
			       ]);
    _enumerateInstanceNames_ok('PaulA_MTA',
			       [ {} ]);
    _enumerateInstanceNames_ok('PaulA_Mail',
			       [ {} ]);
    _enumerateInstanceNames_ok('PaulA_OutgoingMailDomain',
			       [
				{ Domain => 'bar.org' },
				{ Domain => 'foo.org' }
			       ]);
    _enumerateInstanceNames_ok('PaulA_System',
			       [ {} ]);
    _enumerateInstanceNames_ok('PaulA_User',
			       [
				{ Login => 'bbunny' },
				{ Login => 'hsimpson' },
				{ Login => 'lluke' },
				{ Login => 'mmouse' },
			       ]);
    _enumerateInstanceNames_ok('PaulA_VPN',
			       [ {} ]);
    _enumerateInstanceNames_ok('PaulA_WWWFilter',
			       [ {} ]);
}


###############
# error tests #
###############
{
    # invalid classname
    _enumerateInstanceNames_notok('InvalidClass', 5);
}



BEGIN { $numOfTests = 14; print "$numOfTests\n"; }


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
