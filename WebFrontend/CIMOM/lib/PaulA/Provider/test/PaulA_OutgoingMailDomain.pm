use strict;

########################################################
package PaulA::Provider::test::PaulA_OutgoingMailDomain;
########################################################
use Carp;

use base qw(PaulA::Provider);

use CIM::Utils;
use CIM::Error;

do "PaulA/Provider/common/transport.pm";

sub new {
    my ($class, %args) = @_;
    
    my $self = $class->SUPER::new(%args);
    
    return $self;
}

sub readProperty_KEYBINDINGS { 
    my ($self, $section) = @_;
    
    return [] unless defined $section;
    
    my @users = $section =~ /.*?^(\w\S+)\s*:.*?$/gsm;
    
    my @keybindings = ();
    foreach my $user (sort @users) {
	push @keybindings, { Domain => $user };
    }
    
    return \@keybindings;
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
