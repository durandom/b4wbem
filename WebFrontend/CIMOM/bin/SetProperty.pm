use strict;

use common;


#
# SetProperty tests
#

sub _setProperty {
    my ($className, $keyBindings, $propertyName, $newValue, $onlyHeader) = @_;
    
    my $on = CIM::ObjectName->new(ObjectName  => $className,
				  KeyBindings => $keyBindings);

    my $valtext = present($newValue->valueAsRef);
    return "SetProperty $on, $propertyName => $valtext"
	if $onlyHeader;
    
    my $value;
    
    eval { $cc->SetProperty(InstanceName => $on,
			    PropertyName => $propertyName,
			    NewValue     => $newValue) };
    
    if ($@) {
        print $@, "\n";
    } else {
	print "Property set.\n";
    }
}

# ---------------------------------------------------------------------------

sub test11 {
    my $keyBindings = { Login => 'hsimpson' };
    my $newValue = CIM::Value->new(Value => 'k3lWpAsSwD',
				   Type  => 'string');
    _setProperty('PaulA_User', $keyBindings, 'Password', $newValue,
		 (@_ ? 1 : 0));
}

sub test12 {
    my $keyBindings = { Login => 'hsimpson' };
    my $newValue = CIM::Value->new(Value => 'perl',
				   Type  => 'string');
    _setProperty('PaulA_User', $keyBindings, 'LoginShell', $newValue,
		 (@_ ? 1 : 0));
}

sub test13 {
    my $keyBindings = { Login => 'hsimpson' };
    my $newValue = CIM::Value->new(Value => 'Dr. Shoe',
				   Type  => 'string');
    _setProperty('PaulA_User', $keyBindings, 'RealName', $newValue,
		 (@_ ? 1 : 0));
}

sub test14 {
    my $keyBindings = { Login => 'hsimpson' };
    my $newValue = CIM::Value->new(Value => "homer\@springfield\n",
				   Type  => 'string');
    _setProperty('PaulA_User', $keyBindings, 'Signature', $newValue,
		 (@_ ? 1 : 0));
}

sub test15 {
    my $keyBindings = { Login => 'hsimpson' };
    my $newValue = CIM::Value->new(Value => [ "admins", "users" ],
				   Type  => 'string');
    _setProperty('PaulA_User', $keyBindings, 'SystemGroups', $newValue,
		 (@_ ? 1 : 0));
}

sub test16 {
    my $keyBindings = { Login => 'hsimpson' };
    my $newValue = CIM::Value->new(Value => [ "paula_admin", "paula_user" ],
				   Type  => 'string');
    _setProperty('PaulA_User', $keyBindings, 'PaulAGroups', $newValue,
		 (@_ ? 1 : 0));
}

sub test17 {
    my $keyBindings = { Login => 'hsimpson' };
    my $newValue = CIM::Value->new(Value => [ ],
				   Type  => "string",
				   );
    _setProperty('PaulA_User', $keyBindings, 'SystemGroups', $newValue,
		 (@_ ? 1 : 0));
}

sub test18 {
    my $keyBindings = { Login => 'hsimpson' };
    my $newValue = CIM::Value->new(Value => [ ],
				   Type  => "string",
				   );
    _setProperty('PaulA_User', $keyBindings, 'PaulAGroups', $newValue,
		 (@_ ? 1 : 0));
}

sub test19 {
    my $keyBindings = { Login => 'lluke' };
    my $newValue = CIM::Value->new(Value => [ 'cowboy@devel-2.bonn.id-pro.net', 'lonesome@cowboy.com'],
				   Type  => "string",
				   );
    _setProperty('PaulA_User', $keyBindings, 'MailAliases', $newValue,
		 (@_ ? 1 : 0));
}

sub test20 {
    my $keyBindings = { Login => 'lluke' };
    my $newValue = CIM::Value->new(Value => [ ],
				   Type  => "string",
				   );
    _setProperty('PaulA_User', $keyBindings, 'MailAliases', $newValue,
		 (@_ ? 1 : 0));
}

sub test21 {
    my $keyBindings = { Login => 'bbunny' };
    my $newValue = CIM::Value->new(Value => [ ],
				   Type  => "string",
				   );
    _setProperty('PaulA_User', $keyBindings, 'DistributionLists', $newValue,
		 (@_ ? 1 : 0));
}

sub test22 {
    my $keyBindings = { Login => 'bbunny' };
#    my $newValue = CIM::Value->new(Value => [ 'niemand@devel-2.bonn.id-pro.net', 'nixgut@devel-2.bonn.id-pro.net'],
    my $newValue = CIM::Value->new(Value => [ 'testliste1@devel-2.bonn.id-pro.net'],
				   Type  => "string",
				   );
    _setProperty('PaulA_User', $keyBindings, 'DistributionLists', $newValue,
		 (@_ ? 1 : 0));
}

sub test23 {
    my $keyBindings = { Login => 'bbunny' };
    my $newValue = CIM::Value->new(Value => "myserver.mydomain.com",
				   Type  => "string",
				   );
    _setProperty('PaulA_User', $keyBindings, 'PrivatePopServer', $newValue,
		 (@_ ? 1 : 0));
}

sub test24 {
    my $keyBindings = { Login => 'bbunny' };
    my $newValue = CIM::Value->new(Value => "bunny",
				   Type  => "string",
				   );
    _setProperty('PaulA_User', $keyBindings, 'PrivatePopLogin', $newValue,
		 (@_ ? 1 : 0));
}

sub test25 {
    my $keyBindings = { Login => 'bbunny' };
    my $newValue = CIM::Value->new(Value => "geheim",
				   Type  => "string",
				   );
    _setProperty('PaulA_User', $keyBindings, 'PrivatePopPassword', $newValue,
		 (@_ ? 1 : 0));
}

sub test26 {
    my $keyBindings = { Login => 'bbunny' };
    my $newValue = CIM::Value->new(Value => 'away@comics.com',
				   Type  => "string",
				   );
    _setProperty('PaulA_User', $keyBindings, 'MailForward', $newValue,
		 (@_ ? 1 : 0));
}

sub test27 {
    my $keyBindings = { Login => 'bbunny' };
    my $newValue = CIM::Value->new(Value => '',
				   Type  => "string",
				   );
    _setProperty('PaulA_User', $keyBindings, 'MailForward', $newValue,
		 (@_ ? 1 : 0));
}

sub test28 {
    my $keyBindings = { Login => 'bbunny' };
    my $newValue = CIM::Value->new(Value => '0',
				   Type  => "boolean",
				   );
    _setProperty('PaulA_User', $keyBindings, 'AutoReply', $newValue,
		 (@_ ? 1 : 0));
}

sub test29 {
    my $keyBindings = { Login => 'bbunny' };
    my $newValue = CIM::Value->new(Value => '1',
				   Type  => "boolean",
				   );
    _setProperty('PaulA_User', $keyBindings, 'AutoReply', $newValue,
		 (@_ ? 1 : 0));
}

sub test30 {
    my $keyBindings = { Login => 'bbunny' };
    my $newValue = CIM::Value->new(Value => '0',
				   Type  => "boolean",
				   );
    _setProperty('PaulA_User', $keyBindings, 'HasLocalHomepage', $newValue,
		 (@_ ? 1 : 0));
}
sub test31 {
    my $keyBindings = { Login => 'bbunny' };
    my $newValue = CIM::Value->new(Value => '1',
				   Type  => "boolean",
				   );
    _setProperty('PaulA_User', $keyBindings, 'HasLocalHomepage', $newValue,
		 (@_ ? 1 : 0));
}
sub test32 {
    my $keyBindings = { Login => 'bbunny' };
    my $newValue = CIM::Value->new(Value => "Subject: some stupid reply\n\n\$SUBJECT",
				   Type  => "string",
				   );
    _setProperty('PaulA_User', $keyBindings, 'ReplyText', $newValue,
		 (@_ ? 1 : 0));
}
sub test33 {
    my $keyBindings = { Login => 'bbunny' };
    my $newValue = CIM::Value->new(Value => "Subject: some other stupid reply\n\n\$SUBJECT",
				   Type  => "string",
				   );
    _setProperty('PaulA_User', $keyBindings, 'ReplyText', $newValue,
		 (@_ ? 1 : 0));
}
# ---------------------------------------------------------------------------

sub test51 {
    my $newValue = CIM::Value->new(Value => [qw(/usr/bin/perl /usr/bin/emacs)],
				   Type  => 'string');
    _setProperty('PaulA_System', undef, 'ValidLoginShells', $newValue,
		 (@_ ? 1 : 0));
}

sub test52 {
    my $newValue = CIM::Value->new(Value => [qw()],
				   Type  => 'string');
    _setProperty('PaulA_System', undef, 'ValidDistributionLists', $newValue,
		 (@_ ? 1 : 0));
}

sub test53 {
    my $newValue = CIM::Value->new(Value => [qw(testliste1 liste@test.de)],
				   Type  => 'string');
    _setProperty('PaulA_System', undef, 'ValidDistributionLists', $newValue,
		 (@_ ? 1 : 0));
}

# ---------------------------------------------------------------------------

sub test96 {
    my $keyBindings = { Login => 'hsimpson' };
    my $newValue = CIM::Value->new(Value => "SomeValue",
				   Type  => 'string');
    _setProperty('PaulA_User', $keyBindings, 'Invalid', $newValue,
		 (@_ ? 1 : 0));
}

sub test97 {
    my $keyBindings = { Login => 'hsimpson' };
    my $newValue = CIM::Value->new(Value => "SomeValue",
				   Type  => 'string');
    _setProperty('Invalid', $keyBindings, 'Signature', $newValue,
		 (@_ ? 1 : 0));
}

sub test98 {
    my $keyBindings = { Invalid => 'hsimpson' };
    my $newValue = CIM::Value->new(Value => "SomeValue",
				   Type  => 'string');
    _setProperty('PaulA_User', $keyBindings, 'Signature', $newValue,
		 (@_ ? 1 : 0));
}

sub test99 {
    my $keyBindings = { Login => 'invalid' };
    my $newValue = CIM::Value->new(Value => "SomeValue",
				   Type  => 'string');
    _setProperty('PaulA_User', $keyBindings, 'Signature', $newValue,
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
