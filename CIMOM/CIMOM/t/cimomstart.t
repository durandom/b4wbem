use strict;
use lib "t";
use common;


# Start cimom
print STDERR "Starting cimom...\n" if $verbose;
system("$FindBin::Bin/cimomtest stop");
system("$FindBin::Bin/cimomtest start");
my $rc = ($? >> 8);
assert($rc == 0);

if ($rc != 0) {
    print STDERR "Could not start cimom.\n" if $verbose;
    exit 1;
}

if ($verbose) {
    print "detecting CIMOM's PID: ";
    system("$FindBin::Bin/cimomtest status");
}


BEGIN { $numOfTests = 1; print "$numOfTests\n"; }


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
