#
# splitschema.PL -- automatically executed when doing 'make'
#
use strict;

# create the C-*.xml files

my $dir = "repository/xmlRoot/PaulA";
my $schema = "S-CIM_Schema23.xml";

chdir("$dir") or die "Cannot read $dir: $!";
opendir DIR, ".";

print "creating XML files (may take a while)...";

my @files = grep /C-[CP][IR][MS]_.*xml/, readdir DIR;
if ($#files + 1 != 665) {
    system ("../../../bin/splitCIMSchema.pl $schema");
}
closedir DIR;

print "\n";


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
