use strict;

use common;


#
# DeleteInstance tests
#

sub _deleteInstance {
    my ($className, $keyBindings, $onlyHeader) = @_;
    
    my $on = CIM::ObjectName->new(ObjectName  => $className,
				  ConvertType => 'INSTANCENAME',
				  KeyBindings => $keyBindings,
				 );

    return "DeleteInstance $on"
	if $onlyHeader;
    
    
    eval { $cc->DeleteInstance(InstanceName => $on) };
    
    if ($@) {
	print $@, "\n";
    }
    else {
	print "Instance deleted.\n";
    }
}


# ---------------------------------------------------------------------------


sub test1 {
    my ($args) = @_;
    
    my $keyBindings = { Login => 'hsimpson' };
    _deleteInstance('PaulA_User', $keyBindings,
		    (@_ ? 1 : 0));
}


# ---------------------------------------------------------------------------


sub test97 {
    my ($args) = @_;
    
    my $keyBindings = { Login => 'hsimpson' };
    _deleteInstance('Invalid', $keyBindings,
		    (@_ ? 1 : 0));
}


sub test98 {
    my ($args) = @_;
    
    my $keyBindings = { Invalid => 'hsimpson' };
    _deleteInstance('PaulA_User', $keyBindings,
		    (@_ ? 1 : 0));
}


sub test99 {
    my ($args) = @_;
    
    my $keyBindings = { Login => 'invalid' };
    _deleteInstance('PaulA_User', $keyBindings,
		    (@_ ? 1 : 0));
}


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
