use strict;

use common;


#
# GetProperty tests
#

sub _getProperty {
    my ($className, $keyBindings, $propertyName, $onlyHeader) = @_;

    my $on = CIM::ObjectName->new(ObjectName  => $className,
				  KeyBindings => $keyBindings);
    
    return "GetProperty $on, $propertyName"
	if $onlyHeader;
    
    my $value;
    
    eval { $value = $cc->GetProperty(InstanceName => $on,
				     PropertyName => $propertyName) };
    
    if ($@) {
        print $@, "\n";
    } else {
        if (defined $value) {
	    cpprint $value->toXML->toString;
        } else {
            print "No value returned\n";
        }
    }
}

# ---------------------------------------------------------------------------

sub test11 {
    my $keyBindings = { Login => 'hsimpson' };
    _getProperty('PaulA_User', $keyBindings, 'Password',
		 (@_ ? 1 : 0));
}

sub test12 {
    my $keyBindings = { Login => 'hsimpson' };
    _getProperty('PaulA_User', $keyBindings, 'LoginShell',
		 (@_ ? 1 : 0));
}

sub test13 {
    my $keyBindings = { Login => 'hsimpson' };
    _getProperty('PaulA_User', $keyBindings, 'RealName',
		 (@_ ? 1 : 0));
}

sub test14 {
    my $keyBindings = { Login => 'hsimpson' };
    _getProperty('PaulA_User', $keyBindings, 'Signature',
		 (@_ ? 1 : 0));
}

sub test15 {
    my $keyBindings = { Login => 'hsimpson' };
    _getProperty('PaulA_User', $keyBindings, 'Login',
		 (@_ ? 1 : 0));
}

sub test16 {
    my $keyBindings = { Login => 'bbunny' };
    _getProperty('PaulA_User', $keyBindings, 'PaulAGroups',
		 (@_ ? 1 : 0));
}

sub test17 {
    my $keyBindings = { Login => 'bbunny' };
    _getProperty('PaulA_User', $keyBindings, 'SystemGroups',
		 (@_ ? 1 : 0));
}

sub test18 {
    my $keyBindings = { Login => 'bbunny' };
    _getProperty('PaulA_User', $keyBindings, 'PaulAPermissions',
		 (@_ ? 1 : 0));
}

sub test19 {
    my $keyBindings = { Login => 'mmouse' };
    _getProperty('PaulA_User', $keyBindings, 'MailAddress',
		 (@_ ? 1 : 0));
}

sub test20 {
    my $keyBindings = { Login => 'lluke' };
    _getProperty('PaulA_User', $keyBindings, 'MailAliases',
		 (@_ ? 1 : 0));
}

sub test21 {
    my $keyBindings = { Login => 'bbunny' };
    _getProperty('PaulA_User', $keyBindings, 'FaxNumber',
		 (@_ ? 1 : 0));
}

sub test22 {
    my $keyBindings = { Login => 'bbunny' };
    _getProperty('PaulA_User', $keyBindings, 'DistributionLists',
		 (@_ ? 1 : 0));
}

sub test23 {
    my $keyBindings = { Login => 'bbunny' };
    _getProperty('PaulA_User', $keyBindings, 'PrivatePopServer',
		 (@_ ? 1 : 0));
}

sub test24 {
    my $keyBindings = { Login => 'bbunny' };
    _getProperty('PaulA_User', $keyBindings, 'PrivatePopLogin',
		 (@_ ? 1 : 0));
}

sub test25 {
    my $keyBindings = { Login => 'bbunny' };
    _getProperty('PaulA_User', $keyBindings, 'PrivatePopPassword',
		 (@_ ? 1 : 0));
}

sub test26 {
    my $keyBindings = { Login => 'bbunny' };
    _getProperty('PaulA_User', $keyBindings, 'MailForward',
		 (@_ ? 1 : 0));
}

sub test27 {
    my $keyBindings = { Login => 'bbunny' };
    _getProperty('PaulA_User', $keyBindings, 'AutoReply',
		 (@_ ? 1 : 0));
}

sub test28 {
    my $keyBindings = { Login => 'bbunny' };
    _getProperty('PaulA_User', $keyBindings, 'ReplyText',
		 (@_ ? 1 : 0));
}

sub test29 {
    my $keyBindings = { Login => 'bbunny' };
    _getProperty('PaulA_User', $keyBindings, 'WebAccess',
		 (@_ ? 1 : 0));
}

sub test30 {
    my $keyBindings = { Login => 'bbunny' };
    _getProperty('PaulA_User', $keyBindings, 'HasLocalHomepage',
		 (@_ ? 1 : 0));
}

sub test31 {
    my $keyBindings = { Login => 'bbunny' };
    _getProperty('PaulA_User', $keyBindings, 'HomeDirectory',
		 (@_ ? 1 : 0));
}

# ---------------------------------------------------------------------------

sub test41 {
    _getProperty('PaulA_System', undef, 'ValidLoginShells',
		 (@_ ? 1 : 0));
}

sub test42 {
    _getProperty('PaulA_System', undef, 'DomainName',
		 (@_ ? 1 : 0));
}

sub test44 {
    my ($args) = @_;
    
    _getProperty('PaulA_System', undef, 'ValidDistributionLists',
		 (@_ ? 1 : 0));
}
# ---------------------------------------------------------------------------

sub test96 {
    my $keyBindings = { Login => 'hsimpson' };
    _getProperty('PaulA_User', $keyBindings, 'Invalid',
		 (@_ ? 1 : 0));
}

sub test97 {
    my $keyBindings = { Login => 'hsimpson' };
    _getProperty('Invalid', $keyBindings, 'Signature',
		 (@_ ? 1 : 0));
}

sub test98 {
    my $keyBindings = { Invalid => 'hsimpson' };
    _getProperty('PaulA_User', $keyBindings, 'Signature',
		 (@_ ? 1 : 0));
}

sub test99 {
    my $keyBindings = { Login => 'invalid' };
    _getProperty('PaulA_User', $keyBindings, 'Signature',
		 (@_ ? 1 : 0));
}

# ---------------------------------------------------------------------------


1;

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
