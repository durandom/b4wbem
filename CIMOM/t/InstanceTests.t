use strict;
use lib "t";
use common;

my $className = 'PaulA_Instance';
my $keyBindings = {};     # (i.e. keyless class)

sub test_1 {
    _setProperty_altok($className, $keyBindings, 'Create_Group', 'string',
		    [ "my.net", 'ADMIN_GROUPS_w', 'BACKUPSETTINGS_r' ], [] );
    _getProperty_ok("PaulA_Group", { Name => "my.net" }, 
		    'Permissions', [ 'ADMIN_GROUPS_w', 'BACKUPSETTINGS_r' ] );
}
sub test_2 {
    _setProperty_altok($className, $keyBindings, 'Delete_Group', 
		    'string', 'paula_admin', [] );  
    # permissions is an array
    _setProperty_notok($className, $keyBindings, 'Delete_Group', 
		    'string', 'foo', 6 );
    _getProperty_notok("PaulA_Group", { Name => "paula_admin" }, 
		    'Permissions', 6 );

    _setProperty_altok($className, $keyBindings, 'Delete_Group', 
		    'string', 'paula_pnd', [] );  
    _setProperty_altok($className, $keyBindings, 'Delete_Group', 
		    'string', 'paula_user', [] );  

    _setProperty_altok($className, $keyBindings, 'Create_Group', 'string',
		    [ "my.net", 'ADMINGROUPS_w', 'BACKUPSETTINGS_r' ], [] );
    _getProperty_ok("PaulA_Group", { Name => "my.net" }, 
		    'Permissions', [ 'ADMINGROUPS_w', 'BACKUPSETTINGS_r' ] );
}
sub test_3 {
    
    _enumerateInstanceNames_ok( 'PaulA_OutgoingMailDomain', 
				[ 
				{ Domain => "bar.org"},
				{ Domain => "foo.org"},
				]);
    
}
    
callTests();

# OutgoingMailDomain
{
    _setProperty_notok($className, $keyBindings, 'Create_OutgoingMailDomain', 
		    'string', [ qw(bar.org gateway.bar.org) ], 11 );
    _setProperty_altok($className, $keyBindings, 'Delete_OutgoingMailDomain', 
		    'string', 'bar.org', 1 );
    _setProperty_notok($className, $keyBindings, 'Delete_OutgoingMailDomain', 
		    'string', 'boo.org', 6 );
    _setProperty_altok($className, $keyBindings, 'Delete_OutgoingMailDomain', 
		    'string', 'foo.org', 1 );

    _enumerateInstanceNames_ok( 'PaulA_OutgoingMailDomain', [  ]);
    
    _setProperty_altok($className, $keyBindings, 'Create_OutgoingMailDomain', 
		    'string', [ qw(test.org gate.test.org) ], [] );
    _setProperty_altok($className, $keyBindings, 'Create_OutgoingMailDomain', 
		    'string', [ qw(bar.org gateway.bar.org) ], [] );

    _enumerateInstanceNames_ok( 'PaulA_OutgoingMailDomain', 
				[ 
				{ Domain => "bar.org"},
				{ Domain => "test.org"},
				]);
    _getProperty_ok("PaulA_OutgoingMailDomain", { Domain => "bar.org" }, 
		    'ServerName', 'gateway.bar.org' );

}
# Group
{
    _setProperty_altok($className, $keyBindings, 'Delete_Group', 
		    'string', 'paula_admin', [] );  
    # permissions is an array
    _setProperty_notok($className, $keyBindings, 'Delete_Group', 
		    'string', 'foo', 6 );
    _getProperty_notok("PaulA_Group", { Name => "paula_admin" }, 
		    'Permissions', 6 );

    _setProperty_altok($className, $keyBindings, 'Delete_Group', 
		    'string', 'paula_pnd', [] );  
    _setProperty_altok($className, $keyBindings, 'Delete_Group', 
		    'string', 'paula_user', [] );  

    _setProperty_altok($className, $keyBindings, 'Create_Group', 'string',
		    [ "my.net", 'ADMINGROUPS_w', 'BACKUPSETTINGS_r' ], [] );
    _getProperty_ok("PaulA_Group", { Name => "my.net" }, 
		    'Permissions', [ 'ADMINGROUPS_w', 'BACKUPSETTINGS_r' ] );
}
    
BEGIN { $numOfTests = 24; print "$numOfTests\n"; }


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
