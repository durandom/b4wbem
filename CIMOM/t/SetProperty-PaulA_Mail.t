use strict;
use lib "t";
use common;

my $className = 'PaulA_Mail';
my $keyBindings = {};		# (i.e. keyless class)


sub test_1 {
    _setProperty_notok($className, $keyBindings, 'MailWeekdaysStart', 
		       'string', '', 4 );
    _setProperty_notok($className, $keyBindings, 'MailWeekdaysStart', 
		       'string', undef, 4 );
    _setProperty_notok($className, $keyBindings, 'MailWeekdaysEnd', 
		       'string', undef, 4 );
    _setProperty_notok($className, $keyBindings, 'MailWeekendInterval', 
		       'string', '', 4 );
    _setProperty_notok($className, $keyBindings, 'MailWeekendInterval', 
		       'string', undef, 4 );
}
sub test_2 {
    _setProperty_ok($className, $keyBindings, 'MailWeekendStart', 
		       'string', '0600' );
    _setProperty_ok($className, $keyBindings, 'MailWeekendEnd', 
		       'string', '1600' );
    _setProperty_ok($className, $keyBindings, 'MailWeekendInterval', 
		       'string', '5' );
}
    
callTests();

# FetchMailsOnDialUp
{
    _setProperty_altok($className, $keyBindings, 'FetchMailsOnDialUp', 
		       'boolean', '1', 'TRUE' );
    _setProperty_altok($className, $keyBindings, 'FetchMailsOnDialUp', 
		       'boolean', '0', 'FALSE' );
    _setProperty_altok($className, $keyBindings, 'FetchMailsOnDialUp', 
		       'boolean', '1', 'TRUE' );
}
# MailWeekdays
{
    _setProperty_ok($className, $keyBindings, 'MailWeekdaysStart', 
		       'string', '0600' );
    _setProperty_ok($className, $keyBindings, 'MailWeekdaysEnd', 
		       'string', '1600' );
    _setProperty_ok($className, $keyBindings, 'MailWeekdaysInterval', 
		       'string', '5' );
}
# MailWeekend
{
    _setProperty_ok($className, $keyBindings, 'MailWeekendStart', 
		       'string', '0600' );
    _setProperty_ok($className, $keyBindings, 'MailWeekendEnd', 
		       'string', '1600' );
    _setProperty_ok($className, $keyBindings, 'MailWeekendInterval', 
		       'string', '5' );
}
# error tests
{
    _setProperty_notok($className, $keyBindings, 'MailWeekdaysStart', 
		       'string', '', 4 );
    _setProperty_notok($className, $keyBindings, 'MailWeekdaysStart', 
		       'string', undef, 4 );
    _setProperty_notok($className, $keyBindings, 'MailWeekdaysEnd', 
		       'string', undef, 4 );
    _setProperty_notok($className, $keyBindings, 'MailWeekendInterval', 
		       'string', '', 4 );
    _setProperty_notok($className, $keyBindings, 'MailWeekendInterval', 
		       'string', undef, 4 );
}
    
BEGIN { $numOfTests = 23; print "$numOfTests\n"; }


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
