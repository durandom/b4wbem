use strict;
use lib "t";
use common;

my $className = 'PaulA_User';
my $keyBindings;

sub test_1 {
    $keyBindings = { Login => 'invaliduser' };
    
    _getInstance_notok($className, $keyBindings,
		       undef, 6);
    _getInstance_notok($className, $keyBindings,
  		       [ ], 6);
    _getInstance_notok($className, $keyBindings,
		       [ 'DistributionLists' ], 6);
    _getInstance_notok($className, $keyBindings,
		       [ 'LoginShell' ], 6);
    ;
}


callTests();


{
    #######################################
    $keyBindings = { Login => 'hsimpson' };
    #######################################
    my %Login = ( Login => 'hsimpson' );
    my %Password = ( Password => 'ze2Or0Juok782' );
    my %RealName = ( RealName => 'Homer Simpson' );
    my %FaxExtensions = ( FaxExtensions => ['654'] );
    my %HomeDirectory = ( HomeDirectory => '/home/hsimpson' );
    my %LoginShell = (LoginShell => '/bin/tcsh' );
    my %WebAccess = ( WebAccess => 0 );
    my %HasLocalHomepage = ( HasLocalHomepage => 0 );
    my %MailForward = ( MailForward => undef );
    my %AutoReply = ( AutoReply => 0 );
    my %ReplyText =  ( ReplyText => undef );
    my %PrivatePopLogin = ( PrivatePopLogin => undef );
    my %PrivatePopPassword = ( PrivatePopPassword => undef );
    my %PrivatePopServer = ( PrivatePopServer => undef );
    my %MailAliases = ( MailAliases => [ qw(homer.simpson@devel-1.bonn.id-pro.net homer@cartoon.com) ] );
    my %DistributionLists = ( DistributionLists => [ qw(lonesome-cowboys@devel-1.bonn.id-pro.net) ] );
    my %PaulAGroups = ( PaulAGroups => [ ] );
    my %PaulAPermissions = ( PaulAPermissions => [ ] );
    
    
    my $valueHash0 = { %Login, %Password, %RealName, %FaxExtensions,
		       %HomeDirectory, %LoginShell, %WebAccess,
		       %HasLocalHomepage, %MailForward, %AutoReply,
		       %ReplyText,
		       %PrivatePopLogin, %PrivatePopPassword, %PrivatePopServer,
		       %MailAliases, %DistributionLists,
		       %PaulAGroups, %PaulAPermissions,
		     };
    my $valueHash1 = { %Login, %Password, };
    my $valueHash2 = { %Login, %Password, %RealName, };
    my $valueHash3 = { %PaulAGroups, %PaulAPermissions,
		     };
    
    _getInstance_ok($className, $keyBindings,
		    undef, $valueHash0);
    
    _getInstance_ok($className, $keyBindings,
		    [ keys %$valueHash1 ], $valueHash1);
    
    _getInstance_ok($className, $keyBindings,
		    [ keys %$valueHash2 ], $valueHash2);
    
    _getInstance_ok($className, $keyBindings,
		    [ 'Foo', keys %$valueHash3 ], $valueHash3);
    
    _getInstance_ok($className, $keyBindings,
		    [ 'Foo', keys %$valueHash1 ], $valueHash1);
    
    _getInstance_ok($className, $keyBindings,
		    [ qw(Foo) ], {});
    
    _getInstance_ok($className, $keyBindings,
  		    [ ], {});
}

{
    #####################################
    $keyBindings = { Login => 'bbunny' };
    #####################################
    my %Login = ( Login => 'bbunny' );
    my %Password = ( Password => '7f05srqLfzEBw' );
    my %RealName = ( RealName => 'Bugs Bunny' );
    my %FaxExtensions = ( FaxExtensions => ['543'] );
    my %HomeDirectory = ( HomeDirectory => '/home/bbunny' );
    my %LoginShell = (LoginShell => '/bin/bash' );
    my %WebAccess = ( WebAccess => 1 );
    my %HasLocalHomepage = ( HasLocalHomepage => 1 );
    my %MailForward = ( MailForward => 'bbunny@holiday.com' );
    my %AutoReply = ( AutoReply => 1 );
    my %ReplyText =  ( ReplyText => "Subject: away from my mail\n\nI will not be reading my mail for a while.\nYour mail concerning \"\$SUBJECT\"\nwill be read when I'm back.\n" );
    my %PrivatePopLogin = ( PrivatePopLogin => 'tiffy' );
    my %PrivatePopPassword = ( PrivatePopPassword => 'secret3' );
    my %PrivatePopServer = ( PrivatePopServer => 'pop.provider3.net' );
    my %MailAliases = ( MailAliases => [ qw(bbunny@linux-gamez.com) ] );
    my %DistributionLists = ( DistributionLists => [ qw(lonesome-cowboys@devel-1.bonn.id-pro.net survival@outdoor.com) ] );
    my %PaulAGroups = ( PaulAGroups => [ qw(paula_admin) ] );
    my %PaulAPermissions = ( PaulAPermissions => [ qw(ADMINGROUPS_w ADMINMAILINGLISTS_w BACKUPSETTINGS_w CREATEDOMAIN_w CREATEGROUP_r CREATEMAILSERVERIN_w CREATERAS_w CREATEUSER_w DEFAULTMAILSERVEROUT_w DEFGATEWAY_w DELETEDOMAIN_w DELETEGROUP_r DELETEMAILSERVERIN_w DELETERAS_w DELUSER_w DHCPACTIVATE_w DNSSERVER_w DOMAINSETTINGS_w DOWNLOADDATABACKUP_w DOWNLOADSETTINGS_w FAX_w FILTER_w FIREWALL_w GETINTERVAL_w GETMAIL_w GLOBALALIASES_w HALT_w INTRANET_w IPADDRESSES_w MAILSERVERINSETTINGS_w NETDATA_w PROVIDERDATA_w RASUSER_w REBOOT_w STATICADDRESSES_w SYSTEMSETTINGS_w UPDATEPAUL_w UPLOADDATABACKUP_w UPLOADSETTINGS_w USERFAX_ALL_w USERFAX_SELF_w USERGROUPS_ALL_w USERGROUPS_SELF_w USERLOGIN_ALL_w USERLOGIN_SELF_w USERMAILINGLISTS_ALL_w USERMAILINGLISTS_SELF_w USERMAIL_ALL_w USERMAIL_SELF_w USERPRIVATEMAIL_ALL_w USERPRIVATEMAIL_SELF_w USERSECURITY_ALL_w USERSECURITY_SELF_w USERVACATION_ALL_w USERVACATION_SELF_w VPN_w WEBSTATISTICS_w) ]  );
    
    
    my $valueHash0 = { %Login, %Password, %RealName, %FaxExtensions,
		       %HomeDirectory, %LoginShell, %WebAccess,
		       %HasLocalHomepage, %MailForward, %AutoReply,
		       %ReplyText,
		       %PrivatePopLogin, %PrivatePopPassword, %PrivatePopServer,
		       %MailAliases, %DistributionLists,
		       %PaulAGroups, %PaulAPermissions,
		     };
    
    _getInstance_ok($className, $keyBindings,
		    undef, $valueHash0);
}


{
    ####################################
    $keyBindings = { Login => 'lluke' };
    ####################################
    my %Login = ( Login => 'lluke' );
    my %Password = ( Password => 'k/ZVI0LIt1v/Q' );
    my %RealName = ( RealName => 'Lucky Luke' );
    my %FaxExtensions = ( FaxExtensions => [qw(543 654)] );
    my %HomeDirectory = ( HomeDirectory => '/home/lluke' );
    my %LoginShell = (LoginShell => '/bin/bash' );
    my %WebAccess = ( WebAccess => 1 );
    my %HasLocalHomepage = ( HasLocalHomepage => 0 );
    my %MailForward = ( MailForward => undef );
    my %AutoReply = ( AutoReply => 0 );
    my %ReplyText =  ( ReplyText => undef );
    my %PrivatePopLogin = ( PrivatePopLogin => undef );
    my %PrivatePopPassword = ( PrivatePopPassword => undef );
    my %PrivatePopServer = ( PrivatePopServer => undef );
    my %MailAliases = ( MailAliases => [ qw(L.Luke@devel-1.bonn.id-pro.net Lucky.Luke@devel-1.bonn.id-pro.net Luke@cartoon.com) ] );
    my %DistributionLists = ( DistributionLists => [ qw(lonesome-cowboys@devel-1.bonn.id-pro.net survival@outdoor.com) ] );
    my %PaulAGroups = ( PaulAGroups => [ qw(paula_user) ] );
    my %PaulAPermissions = ( PaulAPermissions => [ qw(ADMINGROUPS_r ADMINMAILINGLISTS_r BACKUPSETTINGS_r CREATEDOMAIN_n CREATEGROUP_r CREATEMAILSERVERIN_r CREATERAS_n CREATEUSER_n DEFAULTMAILSERVEROUT_r DEFGATEWAY_r DELETEDOMAIN_n DELETEGROUP_r DELETEMAILSERVERIN_r DELETERAS_n DELUSER_n DHCPACTIVATE_n DNSSERVER_r DOMAINSETTINGS_r DOWNLOADDATABACKUP_r DOWNLOADSETTINGS_r FAX_r FILTER_r FIREWALL_r GETINTERVAL_r GETMAIL_r GLOBALALIASES_r HALT_n INTRANET_r IPADDRESSES_r MAILSERVERINSETTINGS_r NETDATA_r PROVIDERDATA_r RASUSER_r REBOOT_n STATICADDRESSES_r SYSTEMSETTINGS_r UPDATEPAUL_r UPLOADDATABACKUP_r UPLOADSETTINGS_r USERFAX_ALL_n USERFAX_SELF_r USERGROUPS_ALL_n USERGROUPS_SELF_r USERLOGIN_ALL_n USERLOGIN_SELF_w USERMAILINGLISTS_ALL_n USERMAILINGLISTS_SELF_r USERMAIL_ALL_n USERMAIL_SELF_r USERPRIVATEMAIL_ALL_n USERPRIVATEMAIL_SELF_r USERSECURITY_ALL_n USERSECURITY_SELF_r USERVACATION_ALL_n USERVACATION_SELF_w VPN_r WEBSTATISTICS_r) ] );
    
    
    my $valueHash0 = { %Login, %Password, %RealName, %FaxExtensions,
		       %HomeDirectory, %LoginShell, %WebAccess,
		       %HasLocalHomepage, %MailForward, %AutoReply,
		       %ReplyText,
		       %PrivatePopLogin, %PrivatePopPassword, %PrivatePopServer,
		       %MailAliases, %DistributionLists,
		       %PaulAGroups, %PaulAPermissions,
		     };
    
    _getInstance_ok($className, $keyBindings,
		    undef, $valueHash0);
}


{
    #####################################
    $keyBindings = { Login => 'mmouse' };
    #####################################
    my %Login = ( Login => 'mmouse' );
    my %Password = ( Password => 'j2TZSGP4l3Wnw' );
    my %RealName = ( RealName => 'Mickey Mouse' );
    my %FaxExtensions = ( FaxExtensions => [ ] );
    my %HomeDirectory = ( HomeDirectory => '/home/mmouse' );
    my %LoginShell = (LoginShell => '/bin/sh' );
    my %WebAccess = ( WebAccess => 0 );
    my %HasLocalHomepage = ( HasLocalHomepage => 0 );
    my %MailForward = ( MailForward => undef );
    my %AutoReply = ( AutoReply => 0 );
    my %ReplyText =  ( ReplyText => undef );
    my %PrivatePopLogin = ( PrivatePopLogin => undef );
    my %PrivatePopPassword = ( PrivatePopPassword => undef );
    my %PrivatePopServer = ( PrivatePopServer => undef );
    my %MailAliases = ( MailAliases => [ ] );
    my %DistributionLists = ( DistributionLists => [ ] );
    my %PaulAGroups = ( PaulAGroups => [ qw(paula_user) ] );
    my %PaulAPermissions = ( PaulAPermissions => [ qw(ADMINGROUPS_r ADMINMAILINGLISTS_r BACKUPSETTINGS_r CREATEDOMAIN_n CREATEGROUP_r CREATEMAILSERVERIN_r CREATERAS_n CREATEUSER_n DEFAULTMAILSERVEROUT_r DEFGATEWAY_r DELETEDOMAIN_n DELETEGROUP_r DELETEMAILSERVERIN_r DELETERAS_n DELUSER_n DHCPACTIVATE_n DNSSERVER_r DOMAINSETTINGS_r DOWNLOADDATABACKUP_r DOWNLOADSETTINGS_r FAX_r FILTER_r FIREWALL_r GETINTERVAL_r GETMAIL_r GLOBALALIASES_r HALT_n INTRANET_r IPADDRESSES_r MAILSERVERINSETTINGS_r NETDATA_r PROVIDERDATA_r RASUSER_r REBOOT_n STATICADDRESSES_r SYSTEMSETTINGS_r UPDATEPAUL_r UPLOADDATABACKUP_r UPLOADSETTINGS_r USERFAX_ALL_n USERFAX_SELF_r USERGROUPS_ALL_n USERGROUPS_SELF_r USERLOGIN_ALL_n USERLOGIN_SELF_w USERMAILINGLISTS_ALL_n USERMAILINGLISTS_SELF_r USERMAIL_ALL_n USERMAIL_SELF_r USERPRIVATEMAIL_ALL_n USERPRIVATEMAIL_SELF_r USERSECURITY_ALL_n USERSECURITY_SELF_r USERVACATION_ALL_n USERVACATION_SELF_w VPN_r WEBSTATISTICS_r) ] );
    
    
    my $valueHash0 = { %Login, %Password, %RealName, %FaxExtensions,
		       %HomeDirectory, %LoginShell, %WebAccess,
		       %HasLocalHomepage, %MailForward, %AutoReply,
		       %ReplyText,
		       %PrivatePopLogin, %PrivatePopPassword, %PrivatePopServer,
		       %MailAliases, %DistributionLists,
		       %PaulAGroups, %PaulAPermissions,
		     };
    
    _getInstance_ok($className, $keyBindings,
		    undef, $valueHash0);
}


###############
# error tests #
###############
{
    $keyBindings = { Login => 'invaliduser' };
    
    _getInstance_notok($className, $keyBindings,
		       undef, 6);
    _getInstance_notok($className, $keyBindings,
  		       [ ], 6);
    _getInstance_notok($className, $keyBindings,
		       [ 'DistributionLists' ], 6);
    _getInstance_notok($className, $keyBindings,
		       [ 'LoginShell' ], 6);
}



BEGIN { $numOfTests = 95; print "$numOfTests\n"; }


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
