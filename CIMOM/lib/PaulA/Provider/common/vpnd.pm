use strict;

use CIM::Error;


sub readProperty_IsServer {
    my ($self, $section, $keyBindings, $readValues, $handle) = @_;

    my $info;
    my $regexp = '(.*?^mode\s)(.+?)$';
    eval { $info = $handle->search('SECTION',
				   $regexp, 'sm',
				   undef) };
    PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED, "$@") if ($@);
    
    PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED,
			   "no more than 1 mode entry is allowed")
	  if $info->{Count} > 1;
    
    if ($info->{Read}->[0] eq "client") {
        return 0;
    }
    elsif ($info->{Read}->[0] eq "server") {
        return 1;
    }
    else {
         PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED,
				"wrong entry in mode line of vpnd.conf");
    }
}


#######################################################################

sub writeProperty_IsServer {
    my ($self, $section, $keyBindings, $readValue, $newValue, $handle,
        $type) = @_;
  
    my $info;
    my $regexp = '(^)(.*?\n)()';

    eval { $info = $handle->search('SECTION',
				   $regexp, 'm',
				   undef) };
    PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED, "$@") if ($@);

    for (my $pos = 0; $pos < $info->{Count}; $pos++) {
	my $line = $info->{Read}->[$pos];

        if ($line =~ /^mode\s/) {
            if ($newValue == 0) {
                $info->{Write}->[$pos] = "mode client\n";
            }
            elsif ($newValue == 1) {
                $info->{Write}->[$pos] = "mode server\n";
            }
        }
        elsif ($line =~ /^keyfile\s/) {
            if ($newValue == 0) {
                $info->{Write}->[$pos] =
                    "keyfile /etc/vpnd/keys/keys/vpnd.rmt.key\n";
            }
            elsif ($newValue == 1) {
                $info->{Write}->[$pos] =
                  "keyfile /etc/vpnd/keys/keys/vpnd.lcl.key\n";
            }
        }
    }

    return $info;
}

sub writeProperty_Remote {
    my ($self, $section, $keyBindings, $readValue, $newValue, $handle,
        $type) = @_;
    
    #
    # VM: I really don's know, if this is a good idea to call another
    #     writeProperty_*() function...
    #     Maybe it only works because it's the same handle.
    #     And maybe there is an error in the return value.
    #
    
    # write RouteLocalNetwork if it is on, with $newValue = 1
    if ($self->{_readValues}->{RouteLocalNetwork} == 1) {
	return $self->writeProperty_RouteLocalNetwork($section, $keyBindings,
						      $readValue, "1",
						      $handle, $type);
    }
    
    return undef;
}

sub writeProperty_RouteLocalNetwork {
    my ($self, $section, $keyBindings, $readValue, $newValue, $handle,
        $type) = @_;
    
    my $info;
    my $regexp = '(.*)^(route1\s.*?\n)(.*)';

    eval { $info = $handle->search('SECTION',
				   $regexp, 'sm',
				   undef) };
    PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED, "$@") if ($@);
    PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED,
			   "no more than 1 RouteLocalNetwork entry is allowed")
	  if $info->{Count} > 1;
    
    my $initAddr = $self->{_readValues}->{InetAddr};
    my $mask = $self->{_readValues}->{Mask};
    my $remote = (defined $self->{_valueList}->{Remote}
		  ? $self->{_valueList}->{Remote}
		  : $self->{_readValues}->{Remote});
    
    my $ip = $self->_ipcalc($initAddr, $mask);
    
    if ($info->{Count} == 1) {
	if ($newValue == 1) {
	    $info->{Write}->[0] = "route1 $ip $mask $remote\n";
	}
	else {
	    $info->{Write}->[0] = "";
	}
    }
    else {
	if ($newValue == 1) {
	    $info->{Append} = "route1 $ip $mask $remote\n";
	}
    }
    
    return $info;
}

sub _ipcalc {
    my ($self, $initAddr, $mask) = @_;
    
    my $string = `ipcalc --network $initAddr $mask`;
    $string =~ /NETWORK=(.*)/;
    
    return $1;
}


############################## addCommandlineOpt_* ########################

sub addCommandlineOpt_VPNEnabled {
    my ($self, $keyBindings, $readValue, $newValue, $handle) = @_;
    
    red("addCommandlineOpt_VPNEnabled: $newValue, " . $handle->id . "\n");
    
    if ($handle->id eq 'vpnd_switch') {
	# server is already running
	if ($readValue) {
	    return $newValue ? 'restart' : 'stop';
	}
	# server is already stopped
	else {
	    return $newValue ? 'start' : undef;
	}
    }
    elsif ($handle->id eq 'chkconfig_switch') {
	return 'vpnd ' . ($newValue ? 'on' : 'off');
    }
    else {
	PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED,
			       "Unknown Handle id " . present($handle->id));
    }
}

######################## additionalOutStuff_ #########################

sub additionalOutStuff_ServerIP {
    my $self = shift;

    if ($self->{_valueList}->{ServerIP} eq "") { 
        $self->{_valueList}->{ServerPort} = "";
    }
    green(present(scalar $self->{_valueList}));
}
    
############################## isValid_* ##################################
# Tests, ob der angegebene Wert gueltig ist oder nicht.
# (werden *vor* der paula2system-Transformation durchgefuehrt.)
#    Input:  entweder ein Skalar oder eine Array-Referenz
#    Output: 1 = ok, 0 = Fehler
###########################################################################



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
