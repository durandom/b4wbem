use strict;
use lib "t";
use common;

my $className = 'PaulA_MTA';
my $keyBindings = {};		# (i.e. keyless class)

sub test_1 {
    _setProperty_ok($className, $keyBindings, 'MyDomain', 
		    'string', 'devel-1.bonn.id-pro.net' );
    _setProperty_ok($className, $keyBindings, 'MyDomain', 
		    'string', 'some.other.domain.com' );
    _setProperty_notok($className, $keyBindings, 'MyDomain', 
		    'string', undef, 4);
    _setProperty_notok($className, $keyBindings, 'MyDomain', 
		    'string', '', 4);
# test changes in virtual?
}

sub test_2 {
    _setProperty_ok($className, $keyBindings, 'RelayHost', 
		    'string', 'smtp-2.bonn.id-pro.net');
    _setProperty_ok($className, $keyBindings, 'RelayHost', 
		    'string', undef);
    _setProperty_notok($className, $keyBindings, 'RelayHost', 
		    'string', '', 4);
    _setProperty_ok($className, $keyBindings, 'RelayHost', 
		    'string', 'smtp3.bonn.id-pro.net');
}

sub test_3 {
    _setProperty_ok($className, $keyBindings, 'MailAliasRoot', 
		    'string', 'mmouse');
    _setProperty_notok($className, $keyBindings, 'MailAliasRoot', 
		    'string', '', 4);
    _setProperty_ok($className, $keyBindings, 'MailAliasRoot', 
		    'string', undef);
    _setProperty_ok($className, $keyBindings, 'MailAliasRoot', 
		    'string', 'hsimpson');
}

sub test_4 {
    _setProperty_altok($className, $keyBindings, 'ValidDistributionLists', 
		       'string', [ qw(lonesome-cowboys) ],
		       [qw(lonesome-cowboys@devel-1.bonn.id-pro.net)]);
    
    _setProperty_notok($className, $keyBindings, 'ValidDistributionLists', 
		    'string', [ qw() ], 4);
    
    _setProperty_ok($className, $keyBindings, 'ValidDistributionLists', 
		    'string', undef);
    
    _setProperty_altok($className, $keyBindings, 'ValidDistributionLists', 
		       'string', [ qw(fun work) ],
		       [ qw(fun@devel-1.bonn.id-pro.net work@devel-1.bonn.id-pro.net) ]);
    
    _setProperty_altok($className, $keyBindings, 'ValidDistributionLists', 
		       'string', [ qw(fun) ],
		       [ qw(fun@devel-1.bonn.id-pro.net) ]);
    
    _setProperty_altok($className, $keyBindings, 'ValidDistributionLists', 
		       'string', [ qw(test@test.com testliste1) ],
		       [ qw(test@test.com testliste1@devel-1.bonn.id-pro.net) ]);
}

callTests();


# ValidDistributionLists tests
{
    _setProperty_altok($className, $keyBindings, 'ValidDistributionLists', 
		       'string', [ qw(lonesome-cowboys) ],
		       [qw(lonesome-cowboys@devel-1.bonn.id-pro.net)]);
    
    _setProperty_notok($className, $keyBindings, 'ValidDistributionLists', 
		    'string', [ qw() ], 4);
    
    _setProperty_ok($className, $keyBindings, 'ValidDistributionLists', 
		    'string', undef);

    _setProperty_altok($className, $keyBindings, 'ValidDistributionLists', 
		       'string', [ qw(fun work) ],
		       [ qw(fun@devel-1.bonn.id-pro.net work@devel-1.bonn.id-pro.net) ]);
    
    _setProperty_altok($className, $keyBindings, 'ValidDistributionLists', 
		       'string', [ qw(fun) ],
		       [ qw(fun@devel-1.bonn.id-pro.net) ]);
    
    _setProperty_altok($className, $keyBindings, 'ValidDistributionLists', 
		       'string', [ qw(test@test.com testliste1) ],
		       [ qw(test@test.com testliste1@devel-1.bonn.id-pro.net) ]);
}

# MailAliasRoot
{
    _setProperty_ok($className, $keyBindings, 'MailAliasRoot', 
		    'string', 'mmouse');
    _setProperty_notok($className, $keyBindings, 'MailAliasRoot', 
		    'string', '', 4);
    _setProperty_ok($className, $keyBindings, 'MailAliasRoot', 
		    'string', undef);
    _setProperty_ok($className, $keyBindings, 'MailAliasRoot', 
		    'string', 'hsimpson');
}

# MailAliasPostmaster
{
    _setProperty_ok($className, $keyBindings, 'MailAliasPostmaster', 
		    'string', 'mmouse');
    _setProperty_notok($className, $keyBindings, 'MailAliasPostmaster', 
		    'string', undef, 4);
    _setProperty_notok($className, $keyBindings, 'MailAliasPostmaster', 
		    'string', '', 4);
    _setProperty_ok($className, $keyBindings, 'MailAliasPostmaster', 
		    'string', 'hsimpson');
}
# MyDomain
{
    _setProperty_ok($className, $keyBindings, 'MyDomain', 
		    'string', 'devel-1.bonn.id-pro.net' );
    _setProperty_ok($className, $keyBindings, 'MyDomain', 
		    'string', 'some.other.domain.com' );
    _setProperty_notok($className, $keyBindings, 'MyDomain', 
		    'string', undef, 4);
    _setProperty_notok($className, $keyBindings, 'MyDomain', 
		    'string', '', 4);
}
# RelayHost
{
    _setProperty_ok($className, $keyBindings, 'RelayHost', 
		    'string', 'smtp-2.bonn.id-pro.net');
    _setProperty_ok($className, $keyBindings, 'RelayHost', 
		    'string', undef);
    _setProperty_notok($className, $keyBindings, 'RelayHost', 
		    'string', '', 4);
    _setProperty_ok($className, $keyBindings, 'RelayHost', 
		    'string', 'smtp3.bonn.id-pro.net');
}
    
BEGIN { $numOfTests = 37; print "$numOfTests\n"; }


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
