use strict;

use CIM::Error;

############################## readProperty_*##############################
# Zum Einlesen der Properties
#    Input:  String (eingelesene Sektion)
#    Output: String (wird ggf. spaeter durch system2paula_* transformiert)
###########################################################################

sub readProperty_ValidLoginShells {
    my ($self, $section, $keyBindings, $readValues, $handle) = @_;

#    $section = $handle->section();
    
    my $login = $$keyBindings{Login};
    
    my $info;
    my $regexp = '(.*?^)(\S+?)\s*?$';
    eval { $info = $handle->search('SECTION',
				   $regexp, 'sm',
				   undef) };
    PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED, "$@") if ($@);
    
    my @list = sort @{$info->{Read}};
    return \@list;
}


############################## writeProperty_* ############################
# Zum Schreiben der Properties
#    Input:  - String (eingelesene Sektion)
#            - Hash-Referenz (KeyBindings), 
#            - Scalar resp. array-reference (read Value)
#            - Scalar resp. array-reference (new Value)
#    Output: - String (wird ggf. spaeter durch system2paula_* transformiert)
###########################################################################

sub writeProperty_ValidLoginShells {
    my ($self, $section, $keyBindings, $readValue, $newValue, $handle, $type) =
	@_;
    
    $section = $handle->section();
    
    my $info;
    my $regexp = '(.*?^)(\S+?)\s*?$';
    eval { $info = $handle->search('SECTION',
				   $regexp, 'sm',
				   undef) };
    PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED, "$@") if ($@);

    my (%oldVirtual, %newVirtual);
    @oldVirtual{@$readValue} = ();
    @newVirtual{@$newValue} = ();

    for (my $pos = 0; $pos < $info->{Count}; $pos++) {
	my $line = $info->{Read}->[$pos];
	my ($listname) = split /\s+/, $line; 
	
	if (!exists $newVirtual{$listname}) {
	    $info->{Write}->[$pos] = '';
	}
	else {
	    $info->{Write}->[$pos] = $line;
	    $newVirtual{$listname} = 1;	# mark as done
	}
    }
    
    foreach (keys %newVirtual){
	next if $newVirtual{$_};
	$info->{Append} .= "$_\n";
    }
    
    return $info;
}


############################## system2paula_* #############################
# Wandelt den angegebenen Wert von "System-Schreibweise" in die
# "PaulA-Repraesentation" um (z.B. "TRUE" -> "1")
#    Input:  ein String
#    Output: entweder ein Skalar oder eine Array-Referenz
###########################################################################



############################## isValid_* ##################################
# Tests, ob der angegebene Wert gueltig ist oder nicht.
# (werden *vor* der paula2system-Transformation durchgefuehrt.)
#    Input:  entweder ein Skalar oder eine Array-Referenz
#    Output: 1 = ok, 0 = Fehler
###########################################################################

sub isValid_ValidLoginShells {
    my ($self, $listref) = @_;
    foreach (@$listref) {
	unless (-x $_) {
	    black("  (Not an executable file: $_)");
	    return 0;
	}
    }
    return 1;
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
