use strict;
use lib "t";
use common;

use CIM::Utils;
use CIM::Value;


##
## bool2string(), string2bool()
##
{
    assert(bool2string(1) eq 'true');
    assert(bool2string(0) eq 'false');
    
    assert(string2bool('true') == 1);
    assert(string2bool('false') == 0);
}



##
## areEqual()
##
{
    my ($s1, $s2, $s3) = (undef, 'foo', 'bar');
    my $v1 = CIM::Value->new(Type => 'boolean', Value => 1);
    my $v2 = CIM::Value->new(Type => 'boolean', Value => 0);
    
    assert(    areEqual($s1, $s1));
    assert(    areEqual($s2, $s2));
    assert(    areEqual($v1, $v1));
    
    assert(not areEqual($s1, $s2));
    assert(not areEqual($s2, $s3));
    assert(not areEqual($v1, $v2));
    
    assert(not areEqual($s2, $v1));
}



##
## areEqual()
##
{
    my @a1 = undef;
    my @a2 = ();
    my @a3 = ('foo', 'bar');
    my @a4 = ('foo', 'bar', 42);
    my @a5 = ('foo', undef, 43);
    
    assert(    areEqual(\@a1, \@a1));
    assert(    areEqual(\@a2, \@a2));
    assert(    areEqual(\@a3, \@a3));
    
    assert(not areEqual(\@a1, \@a2));
    assert(not areEqual(\@a1, \@a3));
    assert(not areEqual(\@a1, \@a4));
    assert(not areEqual(\@a1, \@a5));
    
    assert(not areEqual(\@a2, \@a3));
    assert(not areEqual(\@a2, \@a4));
    assert(not areEqual(\@a2, \@a5));
    
    assert(not areEqual(\@a3, \@a4));
    assert(not areEqual(\@a3, \@a5));
    
    assert(not areEqual(\@a4, \@a5));
}



##
## areEqual()
##
{
    my %h1;
    my %h2 = ();
    my %h3 = (
	      FOO => 'foo',
	      BAR => 'bar',
	     );
    my %h4 = (
	      foo => 'foo',
	      BAR => 'bar',
	     );
    my %h5 = (
	      FOO => undef,
	      BAR => 'bar',
	     );
    
    assert(    areEqual(\%h1, \%h1));
    assert(    areEqual(\%h2, \%h2));
    assert(    areEqual(\%h3, \%h3));
    
    assert(    areEqual(\%h1, \%h2));
    assert(not areEqual(\%h1, \%h3));
    assert(not areEqual(\%h1, \%h4));
    assert(not areEqual(\%h1, \%h5));
    
    assert(not areEqual(\%h2, \%h3));
    assert(not areEqual(\%h2, \%h4));
    assert(not areEqual(\%h2, \%h5));
    
    assert(not areEqual(\%h3, \%h4));
    assert(not areEqual(\%h3, \%h5));
    
    assert(not areEqual(\%h4, \%h5));
}



BEGIN { $numOfTests = 37; print "$numOfTests\n"; }


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
