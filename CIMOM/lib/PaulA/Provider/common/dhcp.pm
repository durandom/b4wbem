use strict;

use CIM::Error;


############################## readProperty_*##############################
# Zum Einlesen der Properties
#    Input:  String (eingelesene Sektion)
#    Output: String (wird ggf. spaeter durch system2paula_* transformiert)
###########################################################################

sub readProperty_Ranges {
    my ($self, $section, $keyBindings, $readValues, $handle) = @_;

#    $section = $handle->section();
    
    my $info;
    my $regexp = '(.*?^)([^\n\S]*range dynamic-bootp\s+[\d\.]+\s*[\d\.]*;\s*)$';
    eval { $info = $handle->search('SECTION',
				   $regexp, 'sm',
				   undef) };
    PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED, "$@") if ($@);

    return undef if $#{$info->{Read}} == -1;	
    # otherwise an empty array would be returned
    
    my @mappings;
    for (my $pos = 0; $pos < $info->{Count}; $pos++) {
	my $line = $info->{Read}->[$pos];
	my ($ip1, $ip2) =
	    $line =~ m/\s*range dynamic-bootp\s+([\d\.]+)\s*([\d\.]*);\s*$/;
        
            my $range = $ip1 . "-" . $ip2;
            $range =~ s/-$//;       # in case $ip2 doesn't have a real value
            push @mappings, $range;
    }
    
    @mappings = sort @mappings;
    return \@mappings;
}

sub readProperty_DomainNameServers {
    my ($self, $section, $keyBindings, $readValues, $handle) = @_;

#    $section = $handle->section();
    
    my $info;
    my $regexp = '(.*?^)(\s*option domain-name-servers\s+[\d\.]+;\s*?)$';
    eval { $info = $handle->search('SECTION',
				   $regexp, 'sm',
				   undef) };
    PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED, "$@") if ($@);

    return undef if $#{$info->{Read}} == -1;	
    # otherwise an empty array would be returned

    my @mappings;
    for (my $pos = 0; $pos < $info->{Count}; $pos++) {
	my $line = $info->{Read}->[$pos];
	my ($ip) =
	    $line =~ m/\s*option domain-name-servers\s+([\d\.]+);\s*$/;
	push @mappings, $ip;
    }
    
    @mappings = sort @mappings;
    return \@mappings;
}

sub readProperty_HostMappings {
    my ($self, $section, $keyBindings, $readValues, $handle) = @_;

#    $section = $handle->section();
    
    my $info;
    my $regexp =
	'(.*?^)(\s*host\s+[\d\.]+\s+{\s+hardware\sethernet\s+.+?;\s+}\s*)$';
    eval { $info = $handle->search('SECTION',
				   $regexp, 'sm',
				   undef) };
    PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED, "$@") if ($@);

    return undef if $#{$info->{Read}} == -1;	
    # otherwise an empty array would be returned

    my @mappings;
    for (my $pos = 0; $pos < $info->{Count}; $pos++) {
	my $line = $info->{Read}->[$pos];
	my ($ip, $mac) = $line =~ m/\s*host\s+([\d\.]+?)\s+[^\n]+\s([^\n]+?);/;
	push @mappings, $mac . "-" . $ip;
    }
    
    @mappings = sort @mappings;
    return \@mappings;
}

sub readProperty_DHCPEnabled {
    my ($self, $section, $keyBindings, $readValues, $handle) = @_;

    if ($handle->id eq "dhcpd_status") {
        if ($handle->exitCode == 0) {
            return 1;
        }
        elsif ($handle->exitCode == 1) {
            return 0;
        }
    }
}

############################## writeProperty_* ############################
# Zum Schreiben der Properties
#    Input:  - String (eingelesene Sektion)
#            - Hash-Referenz (KeyBindings),
#            - Scalar resp. array-reference (read Value)
#            - Scalar resp. array-reference (new Value)
#    Output: - String (wird ggf. spaeter durch system2paula_* transformiert)
###########################################################################

sub writeProperty_Ranges {
    my ($self, $section, $keyBindings, $readValue, $newValue, $handle, $type) =
	@_;

    my $info;
    # match complete line
    my $regexp = '(.*?^)([^\n\S]*range dynamic-bootp\s+[\d\.]+\s*[\d\.]*;\s*?)$';
    eval { $info = $handle->search('SECTION',
				   $regexp, 'sm',
				   undef) };
    PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED, "$@") if ($@);

    my (%oldValues, %newValues);
    @oldValues{@$readValue} = ();
    @newValues{@$newValue} = ();

    for (my $pos = 0; $pos < $info->{Count}; $pos++) {
	my $line = $info->{Read}->[$pos];
	my ($ip1, $ip2) =
	    $line =~ m/\s*range dynamic-bootp\s+([\d\.]+)\s*([\d\.]*);\s*?$/;
        
	if (!exists $newValues{"$ip1-$ip2"} && !exists $newValues{$ip1}) {
	    $info->{Write}->[$pos] = '';
	}
	$newValues{"$ip1-$ip2"} = 1;	# mark as done
    }

    foreach (sort keys %newValues){
	next if $newValues{$_};
	my ($ip1, $ip2) = split /-/, $_;
        if (defined $ip2) {
	    $info->{Append} .= "   range dynamic-bootp $ip1 $ip2;\n";
        }
        else {
            $info->{Append} .= "   range dynamic-bootp $ip1;\n";
        }
    }

    return $info;
}

sub writeProperty_HostMappings {
    my ($self, $section, $keyBindings, $readValue, $newValue, $handle, $type) =
	@_;
    
    my $info;
    # match complete line
    my $regexp =
	'(.*?^)(\s*host\s+[\d\.]+\s+{\s+hardware\sethernet\s+.+?;\s+}\s*?)$';
    
    eval { $info = $handle->search('SECTION',
				   $regexp, 'sm',
				   undef) };
    PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED, "$@") if ($@);

    my (%oldValues, %newValues);
    $readValue = [] unless defined $readValue;
    $newValue = [] unless defined $newValue;
    # otherwise the next line wouldn't work
    @oldValues{@$readValue} = ();
    @newValues{@$newValue} = ();

    for (my $pos = 0; $pos < $info->{Count}; $pos++) {
	my $line = $info->{Read}->[$pos];
	my ($ip, $mac) = $line =~ m/\s*host\s+([\d\.]+?)\s+[^\n]+\s([^\n]+?);/;

	if (!exists $newValues{"$mac-$ip"}) {
	    $info->{Write}->[$pos] = '';
	}
	$newValues{"$mac-$ip"} = 1;	# mark as done
    }

    foreach (sort keys %newValues){
	next if $newValues{$_};
	my ($mac, $ip) = split /-/, $_;
	$info->{Append} .= "   host $ip { hardware ethernet $mac; }\n";
    }
    
    return $info;
}


sub writeProperty_DomainNameServers {
    my ($self, $section, $keyBindings, $readValue, $newValue, $handle, $type) =
	@_;
    
    my $info;
    # match complete line
    my $regexp = '(.*?^)(\s*option domain-name-servers\s+[\d\.]+;\s*?)$';
    
    eval { $info = $handle->search('SECTION',
				   $regexp, 'sm',
				   undef) };
    PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED, "$@") if ($@);
    
    my (%oldValues, %newValues);
    $readValue = [] unless defined $readValue;
    $newValue = [] unless defined $newValue;
    # otherwise the next lines wouldn't work
    @oldValues{@$readValue} = ();
    @newValues{@$newValue} = ();
    
    for (my $pos = 0; $pos < $info->{Count}; $pos++) {
	my $line = $info->{Read}->[$pos];
	my ($ip) =
	    $line =~ m/\s*option domain-name-servers\s+([\d\.]+);\s*?$/;
	
	if (!exists $newValues{$ip}) {
	    $info->{Write}->[$pos] = '';
	}
	$newValues{$ip} = 1;	# mark as done
    }
    
    foreach (sort keys %newValues){
	next if $newValues{$_};
	$info->{Append} .= "   option domain-name-servers $_;\n";
    }
    
    return $info;
}


############################## addCommandlineOpt_* ########################

sub addCommandlineOpt_DHCPEnabled {
    my ($self, $keyBindings, $readValue, $newValue, $handle) = @_;
    
    red("addCommandlineOpt_DHCPEnabled: $newValue, " . $handle->id . "\n");
    
    if ($handle->id eq 'dhcpd_switch') {
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
	return 'dhcpd ' . ($newValue ? 'on' : 'off');
    }
    else {
	PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED,
			       "Unknown Handle id " . present($handle->id));
    }
}


############################## isValid_* ##################################
# Tests, ob der angegebene Wert gueltig ist oder nicht.
# (werden *vor* der paula2system-Transformation durchgefuehrt.)
#    Input:  entweder ein Skalar oder eine Array-Referenz
#    Output: 1 = ok, 0 = Fehler
###########################################################################

sub isValid_Ranges {
    my ($self, $val) = @_;
    return (($#{$val} == -1)? 0 : 1);
}

sub isValid_DomainNameServers {
    my ($self, $val) = @_;
    return (($#{$val} == -1)? 0 : 1);
}

sub isValid_HostMappings {
    my ($self, $val) = @_;
    return (($#{$val} == -1)? 0 : 1);
}

sub isValid_Routers {
    my ($self, $val) = @_;
    return 0 unless defined $val;
    return (($val =~ /^\s*$/)? 0 : 1);
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
