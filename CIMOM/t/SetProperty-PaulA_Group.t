use strict;
use lib "t";
use common;

my $className = 'PaulA_Group';
my $paula_admin = { Name => 'paula_admin' };

my $validPermissions = [ qw(ADMINGROUPS_w ADMINMAILINGLISTS_x BACKUPSETTINGS_r CREATEDOMAIN_n CREATEGROUP_r CREATEMAILSERVERIN_r CREATERAS_n CREATEUSER_n DEFAULTMAILSERVEROUT_r DEFGATEWAY_r DELETEDOMAIN_n DELETEGROUP_r DELETEMAILSERVERIN_r DELETERAS_n DELUSER_n DHCPACTIVATE_n DNSSERVER_r DOMAINSETTINGS_r DOWNLOADDATABACKUP_r DOWNLOADSETTINGS_r FAX_r FILTER_r FIREWALL_r GETINTERVAL_r GETMAIL_r GLOBALALIASES_r HALT_n INTRANET_r IPADDRESSES_r MAILSERVERINSETTINGS_r NETDATA_r PROVIDERDATA_r RASUSER_r REBOOT_n STATICADDRESSES_r SYSTEMSETTINGS_r UPDATEPAUL_r UPLOADDATABACKUP_r UPLOADSETTINGS_r USERFAX_ALL_n USERFAX_SELF_r USERGROUPS_ALL_n USERGROUPS_SELF_r USERLOGIN_ALL_n USERLOGIN_SELF_w USERMAILINGLISTS_ALL_n USERMAILINGLISTS_SELF_r USERMAIL_ALL_w USERMAIL_SELF_r USERPRIVATEMAIL_ALL_n USERPRIVATEMAIL_SELF_r USERSECURITY_ALL_n USERSECURITY_SELF_r USERVACATION_ALL_n USERVACATION_SELF_w VPN_r WEBSTATISTICS_w) ];

sub test_1 {
}
    
callTests();

{
    _setProperty_ok($className, $paula_admin, 'Permissions', 'string',
		    $validPermissions);
}    


###############
# error tests #
###############
{
    # invalid key
    _setProperty_notok($className, { InvalidKey => 'paula_admin' },
		       'Permissions', 'string', $validPermissions, 6);
    
    # invalid key value
    _setProperty_notok($className, { Name => 'invalidname' },
                       'Permissions', 'string', [ ], 6);
    
    # invalid property name
    _setProperty_notok($className, { Name => 'paula_admin' },
                       'InvalidName', 'string', 'foobar', 12);

    # invalid value
    _setProperty_notok($className, { Name => 'paula_admin' },
		       'Permissions', 'string', 
		       [ 'ADMINADMIN_w' ], 4);
    
}
    
BEGIN { $numOfTests = 6; print "$numOfTests\n"; }


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
