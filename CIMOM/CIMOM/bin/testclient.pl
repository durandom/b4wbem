#!/usr/bin/perl -w
use strict;

use Term::ANSIColor qw(:constants);
use Getopt::Long;

use FindBin;
use lib "$FindBin::Bin";
use lib "$FindBin::Bin/../../libCIM/lib";
use lib "$FindBin::Bin/../lib";

use CIM::Utils;
use common;


use vars qw($progname $VERSION);
($progname = $0) =~ s|.*/||;
$VERSION = 1.2;

sub usage() {
    print<<END_USAGE;
$progname version $VERSION
Usage: $progname [OPTIONS] <MODULE>
    --func N            : set test function N as default
    --quit              : quit after the first test
    --help              : list available command line options (this page)

END_USAGE
    exit(0);
}


my $help;
my $func;
my $quit;

GetOptions("func=i" => \$func,
	   "help"   => \$help,
	   "quit"   => \$quit,
          ) || usage();



usage() if (defined $help || !$ARGV[0]);

my $module = $ARGV[0]; 

require $module;

$FUNCTIONING or
    die "$progname: Sorry, the requested module is currently out of service\n";



#
# Construct a list of numbers corresponding to the testN functions: 
#
my @funcs = ();

foreach my $symname (sort keys %main::) {
    local *sym = $main::{$symname};

    if (defined &sym) {
	push(@funcs, $1) if $main::{$symname} =~ /main::test(\d+)/;
    }
}


my $startup = (defined $func);

$func = $funcs[0] unless defined $func;

# determine length of largest number:
my $columns = 0;
foreach (@funcs) {
    my $len = length "$_";
    $columns = $len if $len > $columns;
}

sub numericalsort { $a <=> $b };
@funcs = sort numericalsort @funcs;


my $end = 0;
until ($end) {
    print RESET;

    unless ($startup) {
	print "\n", BLUE;
	foreach (@funcs) {
	    my $s  = sprintf "%${columns}s", $_;
	    no strict 'refs';
	    print "(", BOLD, $s, RESET, BLUE, ") " .
		&{"test$_"}("some arg") . "\n";
	}
	print BOLD, "Your choice: [$func] ", RESET;
    }
    else {
	no strict 'refs';
	print BLUE . &{"test$func"}("some arg") . RESET . ":\n";
    }
    
    my $line;
    if ($startup) {
	$line = "$func\n";
	$startup = 0;
    } else {
	$line = <STDIN>;
    }

    chomp $line if defined $line;
    
    unless (defined $line) {
	$end = 1;
	print "\n";
	next;
    }

    $line = $func unless $line;

    unless (scalar grep { /^$line$/ } @funcs) {
	print STDERR BOLD, RED, "No such test function: test$line", RESET,"\n";
	next;
    }

    no strict 'refs';
    eval { &{"test$line"} };
    if (my $execption = $@) {
	print BOLD, RED, $execption, RESET;
    }
    
    $func = $line if $line;
    $end = 1 if defined $quit;
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


