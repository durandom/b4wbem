#!/usr/bin/perl -w
use strict;

use Carp;

use FindBin;
use lib "$FindBin::Bin/../../libCIM/lib";

use XML::DOM;
use CIM::Utils;


# save everything between '<CLASS NAME="' and the
# corresponding '<\/CLASS>' in $class

my $nesting = 0;
my $name;
my $class;

$| = 1;
while (<>) {
    if (/^\s*<CLASS\s+NAME="(\w+)"/) {
	$nesting++;
	$name = $1;
    }
    if ($nesting > 0) {
	s/^\s+//;
	s/\s+$//;
	$class .= $_;
    }
    if (/<\/CLASS>/ && $nesting > 0) {
	$nesting--;
	if ($nesting == 0) {
	    my $file = "C-$name.xml";
	    
	    #print "$file\n";
	    
	    open OUT, "> $file";
	    select OUT;
	    pprint ($class);
	    select STDOUT;
	    
	    close OUT;  
	    undef $class;
	    undef $name;
	}
    }
}

1;


__END__

=head1 NAME

splitCIMSchema.pl

=head1 SYNOPSIS

splitCIMSchema.pl <filename>

=head1 DESCRIPTION

This script splits the contents of CIM_Schema23.xml or a similar file into 
files containing one class schema each. The files are named C-<ClassName>.xml.
The input file is given as the only argument. The output files were placed
into the current working directory.

=head1 AUTHOR

 Eva Bolten <bolten@ID-PRO.de>

=head1 COPYRIGHT

Copyright (c) 2000 ID-PRO Deutschland GmbH. All rights reserved.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307,
USA.

=cut
