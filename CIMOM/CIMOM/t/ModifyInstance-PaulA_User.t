use strict;
use lib "t";
use common;

my $className = 'PaulA_User';
my $keyBindings;

sub test_1 {
    $keyBindings = { Login => 'hsimpson' };
    my %PrivatePopLogin = ( PrivatePopLogin => [ 'homer', 'string' ] );
    my %PrivatePopPassword = ( PrivatePopPassword => [ 'marge', 'string' ] );
    my %PrivatePopServer = ( PrivatePopServer => [ 'pop.springfield.net', 'string' ] );
    
    my %PrivatePopLogin1 = ( PrivatePopLogin => [ 'test1', 'string' ] );
    my %PrivatePopPassword1 = ( PrivatePopPassword => [ 'pass1', 'string' ] );
    my %PrivatePopServer1 = ( PrivatePopServer => [ 'pop.test1.net', 'string' ] );
    
    my $valueHash1 = { %PrivatePopLogin1, %PrivatePopPassword1,
		       %PrivatePopServer1};
    my $valueHash2 = { %PrivatePopLogin, %PrivatePopPassword,
		       %PrivatePopServer};
    
    _modifyInstance_ok('PaulA_User', $keyBindings,
		       [ keys %$valueHash2 ], $valueHash2);
    _modifyInstance_ok('PaulA_User', $keyBindings,
		       [ keys %$valueHash1 ], $valueHash1);
}

sub test_3 {
    $keyBindings = { Login => 'bbunny' };
    my %PrivatePopLogin = ( PrivatePopLogin => [ undef, 'string' ] );
    my %PrivatePopPassword = ( PrivatePopPassword => [ undef, 'string' ] );
    my %PrivatePopServer = ( PrivatePopServer => [ undef, 'string' ] );
    
    my $valueHash2 = { %PrivatePopLogin, %PrivatePopPassword,
		       %PrivatePopServer};
    my $valueHash3 = { %PrivatePopPassword,
		       %PrivatePopServer};
    my $valueHash4 = { %PrivatePopLogin,
		       %PrivatePopServer};
    
    _modifyInstance_ok('PaulA_User', $keyBindings,
		       [ keys %$valueHash2 ], $valueHash2);
    _modifyInstance_ok('PaulA_User', $keyBindings,
		       [ keys %$valueHash3 ], $valueHash3);
    _modifyInstance_ok('PaulA_User', $keyBindings,
		       [ keys %$valueHash3 ], $valueHash3);
}



callTests();


{
    #######################################
    $keyBindings = { Login => 'hsimpson' };
    #######################################
    my %Password = ( Password => [ 'k3wLpAssWd', 'string' ] );
    my %RealName = ( RealName => [ 'Dr. Simpson', 'string' ] );
    
    my %PrivatePopLogin = ( PrivatePopLogin => [ 'homer', 'string' ] );
    my %PrivatePopPassword = ( PrivatePopPassword => [ 'marge', 'string' ] );
    my %PrivatePopServer = ( PrivatePopServer => [ 'pop.springfield.net', 'string' ] );
    
    my $valueHash1 = { %Password, %RealName};
    my $valueHash2 = { %PrivatePopLogin, %PrivatePopPassword,
		       %PrivatePopServer};
    
#      _modifyInstance_ok('PaulA_User', $keyBindings,
#  		       [ keys %$valueHash1 ], $valueHash1);
    
    _modifyInstance_ok('PaulA_User', $keyBindings,
		       [ keys %$valueHash2 ], $valueHash2);
}


{
    #####################################
    $keyBindings = { Login => 'bbunny' };
    #####################################
    $keyBindings = { Login => 'bbunny' };
    my %PrivatePopLogin = ( PrivatePopLogin => [ undef, 'string' ] );
    my %PrivatePopPassword = ( PrivatePopPassword => [ undef, 'string' ] );
    my %PrivatePopServer = ( PrivatePopServer => [ undef, 'string' ] );
    
    my $valueHash2 = { %PrivatePopLogin, %PrivatePopPassword,
		       %PrivatePopServer};
    
      _modifyInstance_ok('PaulA_User', $keyBindings,
  		       [ keys %$valueHash2 ], $valueHash2);
}


{
    #####################################
    $keyBindings = { Login => 'mmouse' };
    #####################################
#    my %PrivatePopLogin = ( PrivatePopLogin => [ '', 'string' ] );
#    my %PrivatePopPassword = ( PrivatePopPassword => [ 'cheese', 'string' ] );
#    my %PrivatePopServer = ( PrivatePopServer => [ 'pop.disney.com', 'string' ] );
#    
#    my $valueHash3 = { %PrivatePopLogin, %PrivatePopPassword,
#		       %PrivatePopServer};
#    
#    _modifyInstance_ok('PaulA_User', $keyBindings,
#		       [ keys %$valueHash3 ], $valueHash3);
#    # doesn't work because PrivatePopLogin is $login if not given
#
    
}


###############
# error tests #
###############
{
    $keyBindings = { Login => 'bbunny' };
    
    my %PrivatePopLogin = ( PrivatePopLogin => [ 'login', 'string' ] );
    my %PrivatePopPassword = ( PrivatePopPassword => [ 'passwd', 'string' ] );
    my %PrivatePopServer = ( PrivatePopServer => [ 'pop', 'string' ] );
    
    my $valueHash1 = { %PrivatePopLogin };
    my $valueHash2 = { %PrivatePopLogin, %PrivatePopPassword };
    my $valueHash3 = { %PrivatePopLogin, %PrivatePopServer};
    
    _modifyInstance_notok('PaulA_User', $keyBindings,
			  [ keys %$valueHash1 ], $valueHash1, 4);
    _modifyInstance_notok('PaulA_User', $keyBindings,
			  [ keys %$valueHash2 ], $valueHash2, 4);
    _modifyInstance_notok('PaulA_User', $keyBindings,
			  [ keys %$valueHash3 ], $valueHash3, 4);
}


BEGIN { $numOfTests = 13; print "$numOfTests\n"; }


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
