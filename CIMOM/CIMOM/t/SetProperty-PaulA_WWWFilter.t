use strict;
use lib "t";
use common;

my $className = 'PaulA_WWWFilter';
my $keyBindings = {};		# (i.e. keyless class)

sub test_1 {
    ;
}

sub test_2 {
    _setProperty_ok($className, $keyBindings, 'BlockList', 'string',
    		    undef);
    _setProperty_notok($className, $keyBindings, 'BlockList', 'string',
    		    [], 4);
    _setProperty_ok($className, $keyBindings, 'BlockList', 'string',
		    [
		     '*.admaximize.com',
		     '*.imgis.com', 
		     '/*.*/*preferences.com*',
		     '1ad.prolinks.de',
		     'adwisdom.com',
		     'akamaitech.net/.*/Banners/',
		     'altavista.telia.com/av/pix/sponsors/',
		     'amazon.com/g/associates/logos/',
		     'annonce.insite.dk',
		     'banner*.*.*.*',
		    ]);
    _setProperty_ok($className, $keyBindings, 'BlockList', 'string',
		    [
		     '*.admaximize.com',
		     '*.imgis.com', 
		     '/*.*/*preferences.com*',
		     '1ad.prolinks.de',
		     'adwisdom.com',
		     'akamaitech.net/.*/Banners/',
		     'altavista.telia.com/av/pix/sponsors/',
		     'amazon.com/g/associates/logos/',
		     'annonce.insite.dk',
		     'banner*.*.*.*',
		    ]);
}
    

callTests();


#######################
# FilterEnabled tests #
#######################
{
    _setProperty_altok($className, $keyBindings, 'FilterEnabled', 'boolean',
		       '0', 'FALSE');
    _setProperty_altok($className, $keyBindings, 'FilterEnabled', 'boolean',
		       '1', 'TRUE');
    _setProperty_altok($className, $keyBindings, 'FilterEnabled', 'boolean',
		       '0', 'FALSE');
}

###################
# BlockList tests #
###################
{
    _setProperty_ok($className, $keyBindings, 'BlockList', 'string',
    		    undef);
    _setProperty_notok($className, $keyBindings, 'BlockList', 'string',
    		    [], 4);
    _setProperty_ok($className, $keyBindings, 'BlockList', 'string',
		    [ qw(
			 *.adds.com
			 banners*
			)]);
}

BEGIN { $numOfTests = 11; print "$numOfTests\n"; }


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
