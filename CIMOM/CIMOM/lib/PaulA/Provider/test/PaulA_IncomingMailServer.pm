use strict;

########################################################
package PaulA::Provider::test::PaulA_IncomingMailServer;
########################################################
use Carp;

use base qw(PaulA::Provider);

use CIM::Utils;
use CIM::Error;

do "PaulA/Provider/common/fetchmailrc.pm";

sub new {
    my ($class, %args) = @_;
    
    my $self = $class->SUPER::new(%args);
    
    return $self;
}


sub readProperty_KEYBINDINGS {  # mark
#    my ($self, $section) = @_;
    my ($self, $section, $keyBindings, $readValues, $handle) = @_;
    
    return [] unless defined $section;
    
    my $info;
    my $regexp = '(.*?^)(poll\s+\S+.*?(?:user\s+\S+)?.*?;$)$';
    eval { $info = $handle->search('SECTION',
				   $regexp, 'sm',
				   undef) };
    PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED, "$@") if ($@);
    
    my @keys;
    for (my $pos = 0; $pos < $info->{Count}; $pos++) {
	my $line = $info->{Read}->[$pos];
	my ($server, $login);
	if ($line =~ m/^poll (\S+)/) {
            $server = $1;
        }
	if ($line =~ m/user (\S+)/) {
            $login = $1;
        }
            
	push @keys, ($server, $login);
    }

    my @keybindings = ();
    # no simple sort possible
    for (my $i = 0; $i <= $#keys; $i+=2) {
        if (defined $keys[$i+1]) {
            push @keybindings, { ServerName => $keys[$i],
                                 Login	=> $keys[$i+1]  };
        }
        else {
            push @keybindings, { ServerName => $keys[$i] };
        }
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
