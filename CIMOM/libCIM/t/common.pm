use strict;
use vars qw($test $numOfTests);

use FindBin;
use lib "$FindBin::Bin/../../libCIM/lib";
use Term::ANSIColor qw(:constants);
use Getopt::Long;
use vars qw($progname $VERSION $verbose);

use vars qw(@ISA @EXPORT);
use Exporter;
@ISA = qw(Exporter);
@EXPORT = qw($verbose);


use CIM::Utils;

($progname = $0) =~ s|.*/||;
$VERSION = '0.1';

my $assertCounter = 0;
my @failedAsserts;


BEGIN {
    print "1.."; $| = 1;
}

#####
END {
    if ($verbose) {
	if ($#failedAsserts == -1) {
	    print "\nAll $assertCounter Tests are ok.  :-)\n";
	    print "WARNING: Got $assertCounter Tests, but expected $numOfTests.\n"
		if ($assertCounter != $numOfTests);
	}
	else {
	    print "\nFailed Tests: ", join(', ', @failedAsserts), "\n";
	}
    }
}


my $help;
$verbose = undef;   # for interactive and verbose testing
my $asserts;        # quit after specified number of asserts


GetOptions("help"      => \$help,   # unused?
	   "verbose:i" => \$verbose,
	   "assert=i"  => \$asserts,
	  ) || usage();

$verbose = 1 if (defined $verbose and $verbose == 0);  # called with "-v"
$verbose = 0 unless defined $verbose;                  # called without -v


###########
sub usage {
    print <<"END_USAGE";
$progname version $VERSION
Usage: $progname [OPTIONS]

Options:
    --help        : list available command line options (this page)
    --verbose:i   : Increases verbosity (with optional verbose level)
    --assert=i    : quit after specified number of asserts

Options can be used with a single '-' and can be abbreviated.
END_USAGE
    exit(0);
}


############
sub assert {
    my $expr = shift;
    print "  " . ($expr ? GREEN : BOLD . RED) if $verbose;
    ++$test;
    unless ($expr) {
	print "not ";
	push @failedAsserts, $test;
    }
    print "ok $test";
    print RESET if $verbose;
    print " (of $numOfTests)" if $verbose > 2;
    print "\n";
    $assertCounter++;
    exit if (defined $asserts and $assertCounter == $asserts);
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
