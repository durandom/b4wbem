use strict;
use lib "t";
use common;

my $className = 'PaulA_User';
my $keyBindings;

my $hsimpson = { Login => 'hsimpson' };
my $bbunny   = { Login => 'bbunny' };
my $mmouse   = { Login => 'mmouse' };
my $lluke    = { Login => 'lluke' };



sub test_1 {
    _setProperty_ok($className, $bbunny, 'PrivatePopServer', 'string',
		    'pop1.test.net');
    _setProperty_ok($className, $bbunny, 'PrivatePopLogin', 'string',
		    'bb');
    _setProperty_ok($className, $bbunny, 'PrivatePopPassword', 'string',
		    'password');
    _setProperty_notok($className, $bbunny, 'PrivatePopLogin', 'string',
		    '', 4);
    _setProperty_altok($className, $bbunny, 'PrivatePopLogin', 'string',
		    undef, 'bbunny');
    _setProperty_notok($className, $bbunny, 'PrivatePopServer', 'string',
		    undef, 4);
    _setProperty_notok($className, $bbunny, 'PrivatePopPassword', 'string',
		    undef, 4);
}

sub test_2 {
    _setProperty_ok($className, $hsimpson, 'FaxExtensions', 'string',
		    [ qw(4711 543) ]);
    _setProperty_ok($className, $hsimpson, 'FaxExtensions', 'string',
		    [ qw() ]);
    _setProperty_ok($className, $hsimpson, 'FaxExtensions', 'string',
		    [ qw(4711 543) ]);
    _setProperty_ok($className, $lluke, 'FaxExtensions', 'string',
		    [ qw(4711) ]);
    _setProperty_ok($className, $hsimpson, 'MailAliases', 'string',
		    ['h.simpson@devel-1.bonn.id-pro.net', 'simpson@devel-1.bonn.id-pro.net', 'simpson@id-pro.net']);
    _setProperty_ok($className, $lluke, 'DistributionLists', 'string',
		    [ qw(sales@coffins.com survival@outdoor.com) ]);
    
}
    
callTests();


{
    #######################################
    $keyBindings = { Login => 'hsimpson' };
    #######################################
    
    # "PrivatePop" tests
    _setProperty_ok($className, $bbunny, 'PrivatePopServer', 'string',
		    'pop1.test.net');
    _setProperty_ok($className, $bbunny, 'PrivatePopLogin', 'string',
		    'bb');
    _setProperty_ok($className, $bbunny, 'PrivatePopPassword', 'string',
		    'password');
    
    _setProperty_notok($className, $bbunny, 'PrivatePopLogin', 'string',
		    '', 4);
    
    _setProperty_altok($className, $bbunny, 'PrivatePopLogin', 'string',
		    undef, 'bbunny');
    _setProperty_notok($className, $bbunny, 'PrivatePopServer', 'string',
		    undef, 4);
    _setProperty_notok($className, $bbunny, 'PrivatePopPassword', 'string',
		    undef, 4);

    
    # "Password" test
    _setProperty_ok($className, $keyBindings, 'Password', 'string',
		    'k3lWpAsSwD');
    
    # "RealName" tests
    {
	_setProperty_ok($className, $keyBindings, 'RealName', 'string',
			'Schnucki Baerchen');
	_setProperty_ok($className, $keyBindings, 'RealName', 'string',
			'');
	_setProperty_ok($className, $keyBindings, 'RealName', 'string',
			'Homer');
	_setProperty_altok($className, $keyBindings, 'RealName', 'string',
			   undef, '');
	_setProperty_ok($className, $keyBindings, 'RealName', 'string',
			'Homer');
    }
    
    # "HomeDirectory" tests
    {
	_setProperty_ok($className, $keyBindings, 'HomeDirectory', 'string',
			'/new/home/hsimpson');
	_setProperty_ok($className, $keyBindings, 'HomeDirectory', 'string',
			'');  
	_setProperty_ok($className, $keyBindings, 'HomeDirectory', 'string',
			'/new/home/hs');
	_setProperty_altok($className, $keyBindings, 'HomeDirectory', 'string',
			   undef, "");
    }
    
    # "LoginShell" tests
    {
	_setProperty_ok($className, $keyBindings, 'LoginShell', 'string',
			'/bin/bash');
  	_setProperty_ok($className, $keyBindings, 'LoginShell', 'string',
  			'/bin/false');
    }
    
    # "ReplyText" tests
    {
	_setProperty_ok($className, $keyBindings, 'ReplyText', 'string',
			"New Reply Text\n");
#  	_setProperty_ok($className, $keyBindings, 'ReplyText', 'string',
#  			undef);   #TODO
	_setProperty_ok($className, $keyBindings, 'ReplyText', 'string',
			"");
    }
    
    # "PaulAGroups" tests
    {
	_setProperty_ok($className, $keyBindings, 'PaulAGroups', 'string',
			[ qw(paula_admin paula_user) ]);
	_setProperty_ok($className, $keyBindings, 'PaulAGroups', 'string',
			[ qw() ]);
	_setProperty_ok($className, $keyBindings, 'PaulAGroups', 'string',
			[ qw(paula_admin) ]);
	_setProperty_ok($className, $keyBindings, 'PaulAGroups', 'string',
			[ qw(paula_user) ]);
    }
    
    
    ### TODD's
#      _setProperty_notok($className, $keyBindings, 'PaulAPermissions', 'string',
#    		       7);
}


#####################
# "FaxExtensions" tests #
#####################
{
    _setProperty_ok($className, $hsimpson, 'FaxExtensions', 'string',
		    [qw(4711 543)] );
    _setProperty_ok($className, $hsimpson, 'FaxExtensions', 'string',
		    [ ]);
    _setProperty_ok($className, $hsimpson, 'FaxExtensions', 'string',
		    ['543']);
    _setProperty_ok($className, $bbunny, 'FaxExtensions', 'string',
		    ['333']);
    _setProperty_ok($className, $bbunny, 'FaxExtensions', 'string',
		    [qw(333 543)]);
    _setProperty_ok($className, $mmouse, 'FaxExtensions', 'string',
		    [1101]);
}


#############################
# "DistributionLists" tests #
#############################
{
    _setProperty_ok($className, $lluke, 'DistributionLists', 'string',
		    [ qw() ]);
    _setProperty_ok($className, $lluke, 'DistributionLists', 'string',
		    [ qw(sales@coffins.com survival@outdoor.com) ]);
    _setProperty_ok($className, $lluke, 'DistributionLists', 'string',
		    [ qw(survival@outdoor.com) ]);
    _setProperty_ok($className, $hsimpson, 'DistributionLists', 'string',
		    [ qw(sales@coffins.com survival@outdoor.com) ]);
    _getProperty_ok($className, $bbunny, 'DistributionLists', 
		    [ qw(lonesome-cowboys@devel-1.bonn.id-pro.net survival@outdoor.com) ]);
    
}


restoreSandbox();


#######################
# "MailAliases" tests #
#######################
{
    _setProperty_ok($className, $hsimpson, 'MailAliases', 'string',
		    ['h.simpson@devel-1.bonn.id-pro.net', 'simpson@devel-1.bonn.id-pro.net', 'simpson@id-pro.net']);
    
    _setProperty_ok($className, $hsimpson, 'MailAliases', 'string',
		    ['homer@devel-1.bonn.id-pro.net', 'homer@id-pro.net', 'hsimpson@id-pro.net', 'simpson@devel-1.bonn.id-pro.net', 'simpson@id-pro.net']);
    
    _setProperty_ok($className, $hsimpson, 'MailAliases', 'string',
		    [ ]);
    
    _setProperty_ok($className, $hsimpson, 'MailAliases', 'string',
		    [ 'lluke@devel-1.bonn.id-pro.net' ]);
    
    _setProperty_notok($className, $hsimpson, 'MailAliases', 'string',
		       [ qw(hsimpson@devel-1.bonn.id-pro.net)], 4);
    
#    _setProperty_altok($className, $hsimpson, 'MailAliases', 'string',
#		      undef, []);	# TODO
    
    _getProperty_ok($className, $lluke, 'MailAliases', 
		    [ qw(L.Luke@devel-1.bonn.id-pro.net Lucky.Luke@devel-1.bonn.id-pro.net Luke@cartoon.com) ]);

    _setProperty_notok($className, $mmouse, 'MailAliases', 'string',
	       [ qw(L.Luke@devel-1.bonn.id-pro.net) ], 4);
}


#####################
# MailForward tests #
#####################
{
    _setProperty_ok($className, $bbunny, 'MailForward', 'string',
		    'bunny@vacation.com');
    _setProperty_altok($className, $bbunny, 'MailForward', 'string',
		       '', undef);
    _setProperty_ok($className, $bbunny, 'MailForward', 'string',
		    'bugs.bunny@vacation.com');
#      _setProperty_ok($className, $bbunny, 'MailForward', 'string',
#  		    undef);	# TODO
}

###################
# AutoReply tests #
###################
{
    _setProperty_altok($className, $bbunny, 'AutoReply', 'boolean',
		       '0', 'FALSE');
    _setProperty_altok($className, $bbunny, 'AutoReply', 'boolean',
		       '1', 'TRUE');
}

###################
# WebAccess tests #
###################
{
    _setProperty_altok($className, $bbunny, 'WebAccess', 'boolean',
		       '1', 'TRUE');
    _setProperty_altok($className, $bbunny, 'WebAccess', 'boolean',
		       '0', 'FALSE');
    _setProperty_altok($className, $bbunny, 'WebAccess', 'boolean',
		       '1', 'TRUE');
}

##########################
# HasLocalHomepage tests #
##########################
{
    # default: has a homepage
    _setProperty_altok($className, $bbunny, 'HasLocalHomepage', 'boolean',
		       '1', 'TRUE');
    _setProperty_altok($className, $bbunny, 'HasLocalHomepage', 'boolean',
		       '0', 'FALSE');
    _setProperty_altok($className, $bbunny, 'HasLocalHomepage', 'boolean',
		       '1', 'TRUE');
    
    # default: has no homepage
    _setProperty_altok($className, $hsimpson, 'HasLocalHomepage', 'boolean',
		       '1', 'TRUE');
    
    # default: has no homepage
    _setProperty_altok($className, $lluke, 'HasLocalHomepage', 'boolean',
		       '0', 'FALSE');
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
		       'DistributionLists', 'string', [ ], 6);
    _setProperty_notok($className, { Login => 'invaliduser' },
		       'LoginShell', 'string', '/bin/bash', 6);
    
    # invalid property name
    _setProperty_notok($className, { Login => 'hsimpson' },
		       'InvalidName', 'string', 'foobar', 12);
}



BEGIN { $numOfTests = 109; print "$numOfTests\n"; }


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
