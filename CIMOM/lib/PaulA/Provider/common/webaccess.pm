use strict;

use CIM::Error;


############################## readProperty_* #############################
# Zum Einlesen der Properties
#    Input:  - String (eingelesene Sektion)
#            - Hash-Reference (KeyBindings)
#            - Hash-Reference (so far read values)
#    Output: - String (wird ggf. spaeter durch system2paula_* transformiert)
###########################################################################

sub readProperty_WebAccess {
    my ($self, $section, $keyBindings, $readValues, $handle) = @_;

    my $login = $$keyBindings{Login};

    my $info;
    my $regexp = '(.*?^)(' . $login . ')\s*$';
    eval { $info = $handle->search('SECTION',
                                   $regexp, 'sm',
                                   undef) };
    
    PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED, "$@") if ($@);
    
    PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED, 
	"no more than 1 WebAccess entry is allowed") if $info->{Count} > 1;

    return defined $info->{Read}->[0] ? 1 : 0;
}


############################## writeProperty_* ############################
# Zum Schreiben der Properties
#    Input:  - String (eingelesene Sektion)
#            - Hash-Referenz (KeyBindings), 
#            - Scalar resp. array-reference (read Value)
#            - Scalar resp. array-reference (new Value)
#    Output: - String (wird ggf. spaeter durch system2paula_* transformiert)
###########################################################################

sub writeProperty_WebAccess {
    my ($self, $section, $keyBindings, $readValue, $newValue, $handle) = @_;

    my $login = $$keyBindings{Login};

    my $info;
    my $regexp = '(.*?^)(' . $login . ')\s*$';
    eval { $info = $handle->search('SECTION',
                                   $regexp, 'sm',
                                   undef) };
    
    PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED, "$@") if ($@);
    
    PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED, 
	"no more than 1 WebAccess entry is allowed") if $info->{Count} > 1;

    if ($newValue == 1 && $readValue == 0) {
	$info->{Append} = 
	    "$login\n";
    }
    elsif ($newValue == 0 && $readValue == 1) {
	$info->{Write}->[0] = "";
    }	

    return $info;
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
