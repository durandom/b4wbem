use strict;
use lib "t";
use common;

my $className = 'PaulA_Fax';
my $keyBindings = {};


sub test_1 {
    my $valueHash = { 
			( AreaCode => [ '221', 'string' ] ),
			( CountryCode =>  [ '444', 'string' ] ),
			( BaseNumber =>  [ '12345', 'string' ] ),
			( ValidFaxExtensions =>  [ ['999'], 'string' ] ),
		    };
    
    _modifyInstance_ok($className, $keyBindings,
		       [ keys %$valueHash ], $valueHash);
    _getProperty_ok($className, $keyBindings, 'AreaCode', '221' );
    _getProperty_ok($className, $keyBindings, 'CountryCode', '444' );
    _getProperty_ok($className, $keyBindings, 'BaseNumber', '12345' );
    _getProperty_ok($className, $keyBindings, 'NumLength', '14' );
    _getProperty_ok($className, $keyBindings, 'Prefix', '44422112345' );
    _getProperty_ok($className, $keyBindings, 'ValidFaxExtensions', 
		    [ '999' ] );

}
sub test_2 {
    my $valueHash = { 
			( AreaCode => [ '221', 'string' ] ),
			( CountryCode =>  [ '444', 'string' ] ),
			( BaseNumber =>  [ undef, 'string' ] ),
			( ValidFaxExtensions =>  [ undef, 'string' ] ),
		    };
    
    _modifyInstance_ok($className, $keyBindings,
		       [ keys %$valueHash ], $valueHash);
    _getProperty_ok($className, $keyBindings, 'AreaCode', '221' );
    _getProperty_ok($className, $keyBindings, 'CountryCode', '444' );
    _getProperty_ok($className, $keyBindings, 'BaseNumber', undef );
    _getProperty_ok($className, $keyBindings, 'NumLength', '6' );
    _getProperty_ok($className, $keyBindings, 'Prefix', '444221' );
    _getProperty_ok($className, $keyBindings, 'ValidFaxExtensions', 
		    undef );
}


callTests();

{
    my $valueHash = { 
			( AreaCode => [ '221', 'string' ] ),
			( CountryCode =>  [ '444', 'string' ] ),
			( BaseNumber =>  [ '12345', 'string' ] ),
			( ValidFaxExtensions =>  [ ['999'], 'string' ] ),
		    };
    
    _modifyInstance_ok($className, $keyBindings,
		       [ keys %$valueHash ], $valueHash);
    _getProperty_ok($className, $keyBindings, 'AreaCode', '221' );
    _getProperty_ok($className, $keyBindings, 'CountryCode', '444' );
    _getProperty_ok($className, $keyBindings, 'BaseNumber', '12345' );
    _getProperty_ok($className, $keyBindings, 'NumLength', '14' );
    _getProperty_ok($className, $keyBindings, 'Prefix', '44422112345' );
    _getProperty_ok($className, $keyBindings, 'ValidFaxExtensions', 
		    [ '999' ] );

}
restoreSandbox();
{
    my $valueHash = { 
			( AreaCode => [ '221', 'string' ] ),
			( ValidFaxExtensions =>  [ undef, 'string' ] ),
		    };
    
    _modifyInstance_ok($className, $keyBindings,
		       [ keys %$valueHash ], $valueHash);
    _getProperty_ok($className, $keyBindings, 'AreaCode', '221' );
    _getProperty_ok($className, $keyBindings, 'CountryCode', '49' );
    _getProperty_ok($className, $keyBindings, 'BaseNumber', '42154' );
    _getProperty_ok($className, $keyBindings, 'NumLength', '10' );
    _getProperty_ok($className, $keyBindings, 'Prefix', '4922142154' );
    _getProperty_ok($className, $keyBindings, 'ValidFaxExtensions', 
		    undef );
}
    
BEGIN { $numOfTests = 22; print "$numOfTests\n"; }


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
