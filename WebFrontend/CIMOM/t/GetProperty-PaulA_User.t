use strict;
use lib "t";
use common;

my $className = 'PaulA_User';
my $keyBindings;


my $lluke = { Login => 'lluke' };
my $mmouse = { Login => 'mmouse' };
my $bbunny = { Login => 'bbunny' };
my $hsimpson = { Login => 'hsimpson' };


sub test_1 {
    _getProperty_ok($className, $bbunny, 'PrivatePopLogin',
		    'tiffy');
    _getProperty_ok($className, $bbunny, 'PrivatePopPassword',
		    'secret3');
    _getProperty_ok($className, $bbunny, 'PrivatePopServer',
		    'pop.provider3.net');
}

sub test_2 {
    _getProperty_ok($className, $lluke, 'FaxExtensions',
		    [qw(543 654)]);
    _getProperty_ok($className, $hsimpson, 'FaxExtensions',
		    ['654']);
    _getProperty_ok($className, $hsimpson, 'MailAliases',
 		    [ qw(homer.simpson@devel-1.bonn.id-pro.net homer@cartoon.com) ]);
    _getProperty_ok($className, $hsimpson, 'DistributionLists',
 		    [ qw(lonesome-cowboys@devel-1.bonn.id-pro.net) ]);
}


callTests();


{
    #######################################
    $keyBindings = { Login => 'hsimpson' };
    #######################################
    
    _getProperty_ok($className, $keyBindings, 'Login',
		    'hsimpson');
    _getProperty_ok($className, $keyBindings, 'Password',
		    'ze2Or0Juok782');
    _getProperty_ok($className, $keyBindings, 'RealName',
		    'Homer Simpson');
    _getProperty_ok($className, $keyBindings, 'FaxExtensions',
		    ['654']);
    _getProperty_ok($className, $keyBindings, 'HomeDirectory',
		    '/home/hsimpson');
    _getProperty_ok($className, $keyBindings, 'LoginShell',
		    '/bin/tcsh');
    _getProperty_ok($className, $keyBindings, 'WebAccess',
		    'FALSE');   # argh: don't know here that it's "boolean"
    
    _getProperty_ok($className, $keyBindings, 'HasLocalHomepage',
		    'FALSE');   # argh: don't know here that it's "boolean"
    _getProperty_ok($className, $keyBindings, 'MailForward',
		    undef);
    _getProperty_ok($className, $keyBindings, 'AutoReply',
		    'FALSE');   # argh: don't know here that it's "boolean"
    _getProperty_ok($className, $keyBindings, 'ReplyText',
		    undef);
    
    _getProperty_ok($className, $keyBindings, 'MailAliases',
 		    [ qw(homer.simpson@devel-1.bonn.id-pro.net homer@cartoon.com) ]);
    
    _getProperty_ok($className, $keyBindings, 'DistributionLists',
 		    [ qw(lonesome-cowboys@devel-1.bonn.id-pro.net) ]);
    
    _getProperty_ok($className, $keyBindings, 'PaulAGroups',
		    [ qw() ]);
    _getProperty_ok($className, $keyBindings, 'PaulAPermissions',
		    [ qw() ]);
    
    _getProperty_ok($className, $keyBindings, 'PrivatePopLogin',
		    undef);
    _getProperty_ok($className, $keyBindings, 'PrivatePopPassword',
		    undef);
    _getProperty_ok($className, $keyBindings, 'PrivatePopServer',
		    undef);
}


{
    ####################################
    $keyBindings = { Login => 'lluke' };
    ####################################
    
    _getProperty_ok($className, $keyBindings, 'Login',
		    'lluke');
    
    _getProperty_ok($className, $keyBindings, 'Password',
		    'k/ZVI0LIt1v/Q');
    
    _getProperty_ok($className, $keyBindings, 'PaulAGroups',
		    [ qw(paula_user) ]);
    
    _getProperty_ok($className, $keyBindings, 'PaulAPermissions',
		    [ qw(ADMINGROUPS_r ADMINMAILINGLISTS_r BACKUPSETTINGS_r CREATEDOMAIN_n CREATEGROUP_r CREATEMAILSERVERIN_r CREATERAS_n CREATEUSER_n DEFAULTMAILSERVEROUT_r DEFGATEWAY_r DELETEDOMAIN_n DELETEGROUP_r DELETEMAILSERVERIN_r DELETERAS_n DELUSER_n DHCPACTIVATE_n DNSSERVER_r DOMAINSETTINGS_r DOWNLOADDATABACKUP_r DOWNLOADSETTINGS_r FAX_r FILTER_r FIREWALL_r GETINTERVAL_r GETMAIL_r GLOBALALIASES_r HALT_n INTRANET_r IPADDRESSES_r MAILSERVERINSETTINGS_r NETDATA_r PROVIDERDATA_r RASUSER_r REBOOT_n STATICADDRESSES_r SYSTEMSETTINGS_r UPDATEPAUL_r UPLOADDATABACKUP_r UPLOADSETTINGS_r USERFAX_ALL_n USERFAX_SELF_r USERGROUPS_ALL_n USERGROUPS_SELF_r USERLOGIN_ALL_n USERLOGIN_SELF_w USERMAILINGLISTS_ALL_n USERMAILINGLISTS_SELF_r USERMAIL_ALL_n USERMAIL_SELF_r USERPRIVATEMAIL_ALL_n USERPRIVATEMAIL_SELF_r USERSECURITY_ALL_n USERSECURITY_SELF_r USERVACATION_ALL_n USERVACATION_SELF_w VPN_r WEBSTATISTICS_r) ]);
    
    _getProperty_ok($className, $keyBindings, 'WebAccess',
		    'TRUE');   # argh: don't know here that it's "boolean"
    
    _getProperty_ok($className, $keyBindings, 'MailAliases',
 		    [ qw(L.Luke@devel-1.bonn.id-pro.net Lucky.Luke@devel-1.bonn.id-pro.net Luke@cartoon.com) ]);
    
    _getProperty_ok($className, $keyBindings, 'FaxExtensions',
  		    [qw(543 654)]); 
}


{
    #####################################
    $keyBindings = { Login => 'mmouse' };
    #####################################
    
    _getProperty_ok($className, $keyBindings, 'Login',
		    'mmouse');
    
    _getProperty_ok($className, $keyBindings, 'DistributionLists',
	                        [ ]);
    
    _getProperty_ok($className, $keyBindings, 'WebAccess',
		    'FALSE');   # argh: don't know here that it's "boolean"

    _getProperty_ok($className, $mmouse, 'FaxExtensions',
  		    [qw()]); 
#    _getProperty_ok($className, $keyBindings, 'FaxExtensions',
#  		    undef);	# TODO
}

{
    #####################################
    $keyBindings = { Login => 'bbunny' };
    #####################################
    
    _getProperty_ok($className, $keyBindings, 'MailForward',
		    'bbunny@holiday.com');
    _getProperty_ok($className, $keyBindings, 'AutoReply',
		    'TRUE');  # argh: don't know here that it's "boolean"
    _getProperty_ok($className, $keyBindings, 'ReplyText',
		    "Subject: away from my mail

I will not be reading my mail for a while.
Your mail concerning \"\$SUBJECT\"\nwill be read when I'm back.\n");
    
    _getProperty_ok($className, $keyBindings, 'PrivatePopLogin',
		    'tiffy');
    _getProperty_ok($className, $keyBindings, 'PrivatePopPassword',
		    'secret3');
    _getProperty_ok($className, $keyBindings, 'PrivatePopServer',
		    'pop.provider3.net');
    
    _getProperty_ok($className, $keyBindings, 'HasLocalHomepage',
		    'TRUE');   # argh: don't know here that it's "boolean"
}


###############
# error tests #
###############
{
    # invalid key
    _getProperty_notok($className, { InvalidKey => 'hsimpson' }, 'LoginShell',
		       6);
    
    # invalid username
    _getProperty_notok($className, { Login => 'invaliduser' }, 'DistributionLists',
		       6);
    _getProperty_notok($className, { Login => 'invaliduser' }, 'LoginShell',
		       6);
    
    # invalid property name
    _getProperty_notok($className, { Login => 'hsimpson' }, 'InvalidName',
		       12);
}



BEGIN { $numOfTests = 40; print "$numOfTests\n"; }


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
