use strict;

use common;


#
# GetInstance tests
#

sub _getInstance {
    my ($className, $keyBindings, $propertyList, $onlyHeader) = @_;

    my $on = CIM::ObjectName->new(ObjectName  => $className,
				  KeyBindings => $keyBindings);

    my $proptext = "All Properties";
    if (defined $propertyList) {
	$proptext = "[ " . join(', ', @$propertyList) . " ]";
    }
    
    return "GetInstance $on, $proptext"
	if $onlyHeader;
    
    my $instance;
    
    if (defined $propertyList) {
	eval { $instance = $cc->GetInstance(InstanceName => $on,
					    PropertyList => $propertyList,
					   ) };
    }
    else {
	eval { $instance = $cc->GetInstance(InstanceName => $on,
					   ) };
    }
    
    if ($@) {
        print $@, "\n";
    } else {
        if (defined $instance) {
            cpprint $instance->toXML->toString;
        } else {
            print "No instance returned\n";
        }
    }
}

# ---------------------------------------------------------------------------

sub test1 {
    my ($args) = @_;
    
    my $keyBindings = { Login => 'hsimpson' };
    my $propertyList = [ qw(Password LoginShell) ];
    _getInstance('PaulA_User', $keyBindings, $propertyList,
		 (@_ ? 1 : 0));
}

sub test2 {
    my ($args) = @_;
    
    my $keyBindings = { Login => 'hsimpson' };
    my $propertyList = [ qw(RealName Foo) ];
    _getInstance('PaulA_User', $keyBindings, $propertyList,
		 (@_ ? 1 : 0));
}

sub test3 {
    my ($args) = @_;
    
    my $keyBindings = { Login => 'hsimpson' };
    my $propertyList = [ qw(Foo) ];
    _getInstance('PaulA_User', $keyBindings, $propertyList,
		 (@_ ? 1 : 0));
}

sub test4 {
    my ($args) = @_;
    
    my $keyBindings = { Login => 'hsimpson' };
    my $propertyList = [ ];
    _getInstance('PaulA_User', $keyBindings, $propertyList,
		 (@_ ? 1 : 0));
}

sub test5 {
    my ($args) = @_;
    
    my $keyBindings = { Login => 'mmouse' };
    my $propertyList = [ qw(PaulAGroups) ];
    _getInstance('PaulA_User', $keyBindings, $propertyList,
		 (@_ ? 1 : 0));
}

sub test6 {
    my ($args) = @_;
    
    my $keyBindings = { Login => 'mmouse' };
    my $propertyList = [ qw(PaulAGroups PaulAPermissions) ];
    _getInstance('PaulA_User', $keyBindings, $propertyList,
		 (@_ ? 1 : 0));
}

sub test7 {
    my ($args) = @_;
    
    my $keyBindings = { Login => 'lluke' };
    my $propertyList = [ qw(Signature) ];
    _getInstance('PaulA_User', $keyBindings, $propertyList,
		 (@_ ? 1 : 0));
}

sub test11 {
    my ($args) = @_;
    
    my $keyBindings = { Login => 'hsimpson' };
    _getInstance('PaulA_User', $keyBindings, undef,
		 (@_ ? 1 : 0));
}

sub test12 {
    my ($args) = @_;
    
    my $keyBindings = { Login => 'mmouse' };
    _getInstance('PaulA_User', $keyBindings, undef,
		 (@_ ? 1 : 0));
}

sub test13 {
    my ($args) = @_;
    
    my $keyBindings = { Login => 'lluke' };
    _getInstance('PaulA_User', $keyBindings, undef,
		 (@_ ? 1 : 0));
}

sub test14 {
    my ($args) = @_;
    
    my $keyBindings = { Login => 'bbunny' };
    _getInstance('PaulA_User', $keyBindings, undef,
		 (@_ ? 1 : 0));
}


sub test15 {
    my ($args) = @_;
    
    my $keyBindings;
    my $propertyList = [ qw(DomainName) ];
    _getInstance('PaulA_System', $keyBindings, $propertyList,
		 (@_ ? 1 : 0));
}
# ---------------------------------------------------------------------------

sub test99 {
    my ($args) = @_;
    
    my $keyBindings = { Login => 'invalid' };
    my $propertyList = [ qw(Signature) ];
    _getInstance('PaulA_User', $keyBindings, $propertyList,
		 (@_ ? 1 : 0));
}

sub test98 {
    my ($args) = @_;
    
    my $keyBindings = { Invalid => 'hsimpson' };
    my $propertyList = [ qw(Signature) ];
    _getInstance('PaulA_User', $keyBindings, $propertyList,
		 (@_ ? 1 : 0));
}

sub test97 {
    my ($args) = @_;
    
    my $keyBindings = { Login => 'hsimpson' };
    my $propertyList = [ qw(Signature) ];
    _getInstance('Invalid', $keyBindings, $propertyList,
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
