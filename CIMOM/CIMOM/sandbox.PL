#
# config.PL -- automatically executed when doing 'make'
#
use strict;

use FindBin;
use File::Path;
use File::Find;



my $root = "$FindBin::Bin";
my $origdir   = "$root/t/skel";
my $targetdir = "$root/t/sandbox";
my $repository = "$root/repository";
    

# Delete Sandbox
system("rm -rf $targetdir");
($? >> 8) == 0 or
    die "Cannot delete $targetdir: $!";


# Copy files from t/skel to t/sandbox
system("cp -a $origdir $targetdir");
($? >> 8) == 0 or
    die "Copying of files from $origdir to $targetdir was unsuccessful: $!";
system("find $targetdir -name CVS |xargs rm -rf");
($? >> 8) == 0 or
    die "Error while removing CVS directories: $!";


# make links to files from the repository, 
# needed for tests in the test repository
my $linkDir = "$targetdir/xmlRoot/test/";
my @links = qw (
		S-CIM_Schema23.xml
		
		C-CIM_AlarmDevice.xml
		C-CIM_CollectedCollections.xml
		C-CIM_Collection.xml
		C-CIM_Dependency.xml
		C-CIM_ManagedSystemElement.xml
		C-CIM_SAPStatisticalInformation.xml
		C-CIM_ServiceAccessPoint.xml
		C-CIM_TapeDrive.xml
	       );

# Create links for all PaulA classes
find(sub { push(@links, $_) if /^C-PaulA/ }, $repository);



#  (-d $linkDir or mkdir($linkDir)) or
#      die "Cannot mkdir $linkDir: $!";
    
foreach (@links) {
    unless (-l "$linkDir/$_") {
	symlink("$repository/xmlRoot/PaulA/$_", "$linkDir/$_") or
	    die "Cannot create $_ symlink: $!";
    }
}


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
