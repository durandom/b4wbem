use strict;

use CIM::Error;


sub readProperty_LoginShell {
    my ($self, $section, $keyBindings, $readValues) = @_;
    my @a = split ':', $section;
    return (defined $a[6] ? $a[6] : "");
}



sub mapValue_RealName {
    my ($self, $val) = @_;
    return (defined $val ? $val : '');
}

sub mapValue_HomeDirectory {
    my ($self, $val) = @_;
    return (defined $val ? $val : '');
}



sub isValid_RealName {
    my ($self, $val) = @_;
    return ($val =~ m/:/) ? 0 : 1;
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
