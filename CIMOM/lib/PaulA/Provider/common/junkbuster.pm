use strict;

use CIM::Error;

sub readProperty_BlockList {
    my ($self, $section, $keyBindings, $readValues, $handle) = @_;

#    $section = $handle->section();
    
    my $info;
    my $regexp = '(.*?^)(\S+[^\n]+)($.*)';
    eval { $info = $handle->search('SECTION',
				   $regexp, 'sm',
				   undef) };
    PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED, "$@") if ($@);

    return undef if $#{$info->{Read}} == -1;	
    # otherwise an empty array would be returned

    return $info->{Read};
}
    
############################## writeProperty_* ############################
# Zum Schreiben der Properties
#    Input:  - String (eingelesene Sektion)
#            - Hash-Referenz (KeyBindings), 
#            - Scalar resp. array-reference (read Value)
#            - Scalar resp. array-reference (new Value)
#    Output: - String (wird ggf. spaeter durch system2paula_* transformiert)
###########################################################################

sub writeProperty_BlockList {
    my ($self, $section, $keyBindings, $readValue, $newValue, $handle,
	$type) = @_;
    
    my $info;
    # match complete line
    my $regexp = '()(.*)()';
    
    eval { $info = $handle->search('SECTION',
				   $regexp, 'sm',
				   undef) };
    PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED, "$@") if ($@);

    $newValue = [] unless defined $newValue;
    $info->{Write}->[0] = join("\n", @$newValue) . "\n"; 
    
    return $info;
}


############################## addCommandlineOpt_* ########################

sub addCommandlineOpt_FilterEnabled {
    my ($self, $keyBindings, $readValue, $newValue, $handle) = @_;
    
    red("addCommandlineOpt_FilterEnabled: $newValue, " . $handle->id . "\n");
    
    if ($handle->id eq 'junkbuster_switch') {
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
	return 'junkbuster ' . ($newValue ? 'on' : 'off');
    }
    elsif ($handle->id eq 'squid_restart') {
	return undef;
    }
    else {
	PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED,
			       "Unknown Handle id " . present($handle->id));
    }
}



############################## isValid_* ##################################

sub isValid_BlockList {
    my ($self, $val) = @_;
    return (($#{$val} == -1)? 0 : 1);
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
