use strict;

###########################################
package PaulA::Provider::PaulA::PaulA_Mail;
###########################################
use Carp;

use base qw(PaulA::Provider);

use CIM::Utils;
use CIM::Error;

do "PaulA/Provider/common/pcron.pm";

sub new {
    my ($class, %args) = @_;
    
    my $self = $class->SUPER::new(%args);
    
    return $self;
}

sub classMethod_FetchMails {
    my ($self) = @_;

    my $sandbox = $self->{_CIMOMHandle}->config->sandbox;
    my $file = $self->definition('fetchmailrc');
    my $status = system("fetchmail -f $sandbox/$file");

    if ($status == 0) {
	return CIM::Value->new(Type  => 'boolean', Value => 1);
    }
    else {
	return CIM::Value->new(Type  => 'boolean', Value => 0);
    }
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
