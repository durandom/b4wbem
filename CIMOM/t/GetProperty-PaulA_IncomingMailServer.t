use strict;
use lib "t";
use common;

my $className = 'PaulA_IncomingMailServer';
my $keyBindings;


sub test_1 {
    my $keyBindings1 = { ServerName => "test1.provider.net",
			 Login	    => "bert" };    
    _getProperty_ok($className, $keyBindings1, 'Password', 
		    's e.c,r_e+t1');
    _getProperty_ok($className, $keyBindings1, 'Login', 
		    'bert');
    _getProperty_ok($className, $keyBindings1, 'Protocol', 
		    'POP3');
    _getProperty_ok($className, $keyBindings1, 'LocalDomain', 
		    'some.domain.de');
}

sub test_2 {
    my $keyBindings2 = { ServerName => "test1.provider.net",
			 Login	    => "ernie" };    
    _getProperty_ok($className, $keyBindings2, 'Password', 
		    's e.c,r_e+tE');
    _getProperty_ok($className, $keyBindings2, 'Protocol', 
		    'POP3');
}

sub test_3 {
    my $keyBindings3 = { ServerName => "test3.provider.net",
			};    
    _getProperty_ok($className, $keyBindings3, 'Password', 
		    undef);
    _getProperty_ok($className, $keyBindings3, 'Protocol', 
		    'ETRN');
    _getProperty_ok($className, $keyBindings3, 'Login', 
		    undef);
    _getProperty_ok($className, $keyBindings3, 'LocalDomain', 
		    undef);
}
    
sub test_4 {
    my $keyBindings4 = { ServerName => "test2.provider.net",
			 Login	    => "multidropname" };    
    _getProperty_ok($className, $keyBindings4, 'Extra_Envelope', 
		    'Delivered-To:');
    _getProperty_ok($className, $keyBindings4, 'Extra_QVirtual', 
		    'xxx-');

    _getProperty_ok($className, $keyBindings4, 'Password', 
		    'secret2');
    _getProperty_ok($className, $keyBindings4, 'Protocol', 
		    'POP3-Multidrop');
    _getProperty_ok($className, $keyBindings4, 'LocalDomain', 
		    'my.domain.de');
}

sub test_5 {
    my $keyBindings4 = { ServerName => "test4.provider.net",
			 Login	    => "multidropname4" };    

    _getProperty_ok($className, $keyBindings4, 'Extra_Envelope', 
		    undef);
    _getProperty_ok($className, $keyBindings4, 'Extra_QVirtual', 
		    undef);
}
    
			 
callTests();


{
    #####################################################
    $keyBindings = { ServerName => "test1.provider.net",
		     Login      => "bert" };
    #####################################################
   
    _getProperty_ok($className, $keyBindings, 'Login', 
		    'bert');
    _getProperty_ok($className, $keyBindings, 'Password', 
		    's e.c,r_e+t1');
    _getProperty_ok($className, $keyBindings, 'Protocol', 
		    'POP3');
    _getProperty_ok($className, $keyBindings, 'Extra_Envelope', 
		    undef);
    _getProperty_ok($className, $keyBindings, 'Extra_QVirtual', 
		    undef);
}

{
    #####################################################
    $keyBindings = { ServerName => "test1.provider.net",
		     Login      => "ernie" };    
    #####################################################
    
    _getProperty_ok($className, $keyBindings, 'Login', 
		    'ernie');
    _getProperty_ok($className, $keyBindings, 'Password', 
		    's e.c,r_e+tE');
    _getProperty_ok($className, $keyBindings, 'Protocol', 
		    'POP3');
    _getProperty_ok($className, $keyBindings, 'Extra_Envelope', 
		    undef);
    _getProperty_ok($className, $keyBindings, 'Extra_QVirtual', 
		    undef);
}

{
    #####################################################
    $keyBindings = { ServerName => "test3.provider.net",
		   };    
    #####################################################
    
    _getProperty_ok($className, $keyBindings, 'Login', 
		    undef);
    _getProperty_ok($className, $keyBindings, 'Password', 
		    undef);
    _getProperty_ok($className, $keyBindings, 'Protocol', 
		    'ETRN');
    _getProperty_ok($className, $keyBindings, 'Extra_Envelope', 
		    undef);
    _getProperty_ok($className, $keyBindings, 'Extra_QVirtual', 
		    undef);
}

{
    #####################################################
    $keyBindings = { ServerName => "test2.provider.net",
		     Login      => "multidropname" };    
    #####################################################
    
    _getProperty_ok($className, $keyBindings, 'Login', 
		    'multidropname');
    _getProperty_ok($className, $keyBindings, 'Password', 
		    'secret2');
    _getProperty_ok($className, $keyBindings, 'Protocol', 
		    'POP3-Multidrop');
    _getProperty_ok($className, $keyBindings, 'Extra_Envelope', 
		    'Delivered-To:');
    _getProperty_ok($className, $keyBindings, 'Extra_QVirtual', 
		    'xxx-');
}

{
    #####################################################
    $keyBindings = { ServerName => "test4.provider.net",
		     Login      => "multidropname4" };    
    #####################################################
    
    _getProperty_ok($className, $keyBindings, 'Login', 
		    'multidropname4');
    _getProperty_ok($className, $keyBindings, 'Password', 
		    'secret4');
    _getProperty_ok($className, $keyBindings, 'Protocol', 
		    'POP3-Multidrop');
    _getProperty_ok($className, $keyBindings, 'Extra_Envelope', 
		    undef);
    _getProperty_ok($className, $keyBindings, 'Extra_QVirtual', 
		    undef);
}


###############
# error tests #
###############
{
    # invalid key
    _getProperty_notok($className, { InvalidKey => 'foo' }, 'Login',
                       6);
    
    # invalid server
    _getProperty_notok($className, { ServerName => 'foo' }, 'Login',
                       6);
    
    # invalid property name
    _getProperty_notok($className, { ServerName => "test3.provider.net" },
		       'InvalidName', 12);
}


BEGIN { $numOfTests = 28; print "$numOfTests\n"; }


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
