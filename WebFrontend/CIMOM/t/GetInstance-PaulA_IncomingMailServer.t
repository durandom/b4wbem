use strict;
use lib "t";
use common;

my $className = 'PaulA_IncomingMailServer';
my $keyBindings;

sub test_1 {
    ;
}


callTests();


{
    #####################################################
    $keyBindings = { ServerName => "test1.provider.net",
		     Login      => "bert" };
    #####################################################
    
    my %ServerName = ( ServerName => 'test1.provider.net' );
    my %Login = ( Login => 'bert' );
    my %Password = ( Password => 's e.c,r_e+t1' );
    my %Protocol = ( Protocol => 'POP3' );
    my %Extra_Envelope = ( Extra_Envelope => undef );
    my %Extra_QVirtual = ( Extra_QVirtual => undef );
    my %LocalDomain = ( LocalDomain => 'some.domain.de');
    my %ValidProtocols = ( ValidProtocols => undef);
    
    my $valueHash0 = { %ServerName, %Login, %Password, %Protocol,
		       %Extra_Envelope, %Extra_QVirtual,
		       %LocalDomain, %ValidProtocols,
		     };
    
    _getInstance_ok($className, $keyBindings,
		    undef, $valueHash0);
    
    _getInstance_ok($className, $keyBindings,
		    [ keys %$valueHash0 ], $valueHash0);
    
    _getInstance_ok($className, $keyBindings,
		    [ qw(Foo) ], {});
    
    _getInstance_ok($className, $keyBindings,
  		    [ ], {});
}


{
    #####################################################
    $keyBindings = { ServerName => "test3.provider.net",
		   };
    #####################################################
    
    my %ServerName = ( ServerName => 'test3.provider.net' );
    my %Login = ( Login => undef );
    my %Password = ( Password => undef );
    my %Protocol = ( Protocol => 'ETRN' );
    my %Extra_Envelope = ( Extra_Envelope => undef );
    my %Extra_QVirtual = ( Extra_QVirtual => undef );
    my %LocalDomain = ( LocalDomain => undef);
    my %ValidProtocols = ( ValidProtocols => undef);
    
    my $valueHash0 = { %ServerName, %Login, %Password, %Protocol,
		       %Extra_Envelope, %Extra_QVirtual,
		       %LocalDomain, %ValidProtocols,
		     };
    
    _getInstance_ok($className, $keyBindings,
		    undef, $valueHash0);
    
    _getInstance_ok($className, $keyBindings,
		    [ keys %$valueHash0 ], $valueHash0);
    
    _getInstance_ok($className, $keyBindings,
		    [ qw(Foo) ], {});
    
    _getInstance_ok($className, $keyBindings,
  		    [ ], {});
}


BEGIN { $numOfTests = 40; print "$numOfTests\n"; }


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
