use strict;

use CIM::Error;

############################## readProperty_*##############################
# Zum Einlesen der Properties
#    Input:  String (eingelesene Sektion)
#    Output: String (wird ggf. spaeter durch system2paula_* transformiert)
###########################################################################

sub readProperty_Permissions {
    my ($self, $section, $keyBindings, $readValues, $handle) = @_;

    my @permissions;
    my @lines = split "\n", $section;
    foreach my $line (@lines) {
	my ($name, $perm) =
	    $line =~ m/\s*(\w+)\s+"(.)"\s*$/;
	next unless defined $name;
	push @permissions, $name . "_" . $perm;
    }
    
    @permissions = sort @permissions;
    return \@permissions;
}

sub readProperty_KEYBINDINGS {
    my ($self, $section) = @_;
    
    return [] unless defined $section;
    
    my @groups = $section =~ /^Group "(.*?)".*$/gm;
    
    my @keybindings = ();
    foreach my $group (sort @groups) {
	push @keybindings, { Name => $group };
    }
    
    return \@keybindings;
}



############################## writeProperty_* ############################
# Zum Schreiben der Properties
#    Input:  - String (eingelesene Sektion)
#            - Hash-Referenz (KeyBindings), 
#            - Scalar resp. array-reference (read Value)
#            - Scalar resp. array-reference (new Value)
#    Output: - String (wird ggf. spaeter durch system2paula_* transformiert)
###########################################################################

sub writeProperty_Permissions {
    my ($self, $section, $keyBindings, $readValue, $newValue, $handle, $type)
	= @_;
    
    my $info;
    # match complete line
    my $regexp = '()(.+)()';
    eval { $info = $handle->search('SECTION',
				   $regexp, 'sm',
				   undef) };
    PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED, "$@") if ($@);
    
    my @read = @{$readValue};
    my @new = @{$newValue};
    if ($#read != $#new) {
	PaulA::Provider::error(CIM::Error::CIM_ERR_INVALID_PARAMETER, 
			       "wrong number of permissions for property " .
			       "Permissions of class PaulA_Groups: " .
			       ($#read+1) . " instead of expected " .($#new+1));
    }
    
    my $new;
    foreach (@{$newValue}) {
	my ($name, $perm) = $_ =~ /(\w+)_(\w)$/;
	$new .= $name . " " .  '"' . $perm . '"' . "\n";
    }
    
    $info->{Write}->[0] = "$new";
    
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
