use strict;
use lib "t";
use common;

my $className = 'PaulA_Group';
my $paula_admin = { Name => 'paula_admin' };

sub test_1 {

}
    
callTests();

{
    _getProperty_ok($className, $paula_admin, 'Permissions',
		    [ qw(ADMINGROUPS_w ADMINMAILINGLISTS_w BACKUPSETTINGS_w CREATEDOMAIN_w CREATEGROUP_r CREATEMAILSERVERIN_w CREATERAS_w CREATEUSER_w DEFAULTMAILSERVEROUT_w DEFGATEWAY_w DELETEDOMAIN_w DELETEGROUP_r DELETEMAILSERVERIN_w DELETERAS_w DELUSER_w DHCPACTIVATE_w DNSSERVER_w DOMAINSETTINGS_w DOWNLOADDATABACKUP_w DOWNLOADSETTINGS_w FAX_w FILTER_w FIREWALL_w GETINTERVAL_w GETMAIL_w GLOBALALIASES_w HALT_w INTRANET_w IPADDRESSES_w MAILSERVERINSETTINGS_w NETDATA_w PROVIDERDATA_w RASUSER_w REBOOT_w STATICADDRESSES_w SYSTEMSETTINGS_w UPDATEPAUL_w UPLOADDATABACKUP_w UPLOADSETTINGS_w USERFAX_ALL_w USERFAX_SELF_w USERGROUPS_ALL_w USERGROUPS_SELF_w USERLOGIN_ALL_w USERLOGIN_SELF_w USERMAILINGLISTS_ALL_w USERMAILINGLISTS_SELF_w USERMAIL_ALL_w USERMAIL_SELF_w USERPRIVATEMAIL_ALL_w USERPRIVATEMAIL_SELF_w USERSECURITY_ALL_w USERSECURITY_SELF_w USERVACATION_ALL_w USERVACATION_SELF_w VPN_w WEBSTATISTICS_w) ]);
}


###############
# error tests #
###############
{
    # invalid key
    _getProperty_notok($className, { InvalidKey => 'paula_admin' },
		       'Permissions', 6);
    
    # invalid key value
    _getProperty_notok($className, { Name => 'invalidname' },
                       'Permissions', 6);

    # invalid property name
    _getProperty_notok($className, { Name => 'paula_admin' },
                       'InvalidName', 12);
}

BEGIN { $numOfTests = 4; print "$numOfTests\n"; }


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
