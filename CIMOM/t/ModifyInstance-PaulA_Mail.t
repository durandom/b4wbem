use strict;
use lib "t";
use common;

my $className = 'PaulA_Mail';
my $keyBindings = {};


sub test_1 {
    my %wkStart0    = ( MailWeekdaysStart => [ '', 'uint16' ] );
    my %wkEnd0	= ( MailWeekdaysEnd => [ '', 'uint16' ] );
    my %wkInterval0 = ( MailWeekdaysInterval => [ '', 'uint16' ] );
    my $valueHash0  = { %wkStart0, %wkEnd0, %wkInterval0};

    
    _modifyInstance_notok($className, $keyBindings,
		       [ keys %$valueHash0 ], $valueHash0, 4);

}
sub test_2 {
    my %wkStart	    = ( MailWeekendStart => [ '0700', 'uint16' ] );
    my %wkEnd	    = ( MailWeekendEnd => [ '2000', 'uint16' ] );
    my %wkInterval  = ( MailWeekendInterval => [ '5', 'uint16' ] );
    my $valueHash   = { %wkStart, %wkEnd, %wkInterval};

    my %wkStart1    = ( MailWeekendStart => [ '0800', 'uint16' ] );
    my %wkEnd1	    = ( MailWeekendEnd => [ undef, 'uint16' ] );
    my %wkInterval1 = ( MailWeekendInterval => [ undef, 'uint16' ] );
    my $valueHash1  = { %wkStart1, %wkEnd1, %wkInterval1};
    
    my %wkStart2    = ( MailWeekendStart => [ undef, 'uint16' ] );
    my %wkEnd2	    = ( MailWeekendEnd => [ '2200', 'uint16' ] );
    my %wkInterval2 = ( MailWeekendInterval => [ undef, 'uint16' ] );
    my $valueHash2  = { %wkStart2, %wkEnd2, %wkInterval2};
    
    my %wkStart3    = ( MailWeekendStart => [ '0900', 'uint16' ] );
    my %wkEnd3	    = ( MailWeekendEnd => [ undef, 'uint16' ] );
    my %wkInterval3 = ( MailWeekendInterval => [ '', 'uint16' ] );
    my $valueHash3  = { %wkStart3, %wkEnd3, %wkInterval3};

    my %wkStartUndef    = ( MailWeekendStart => [ undef, 'uint16' ] );
    my %wkEndUndef	= ( MailWeekendEnd => [ undef, 'uint16' ] );
    my %wkIntervalUndef = ( MailWeekendInterval => [ undef, 'uint16' ] );
    my $valueHashUndef  = { %wkStartUndef, %wkEndUndef, %wkIntervalUndef};
    
    _modifyInstance_ok($className, $keyBindings,
		       [ keys %$valueHashUndef ], $valueHashUndef);
    _modifyInstance_notok($className, $keyBindings,
		       [ keys %$valueHash1 ], $valueHash1, 4);
    _modifyInstance_notok($className, $keyBindings,
		       [ keys %$valueHash2 ], $valueHash2, 4);
    _modifyInstance_notok($className, $keyBindings,
		       [ keys %$valueHash3 ], $valueHash3, 4);

#    _modifyInstance_ok($className, $keyBindings,
#		       [ keys %$valueHash], $valueHash);
#    _modifyInstance_ok($className, $keyBindings,
#		       [ keys %$valueHash1 ], $valueHash1);
#    _modifyInstance_ok($className, $keyBindings,
#		       [ keys %$valueHash2 ], $valueHash2);
#    _modifyInstance_ok($className, $keyBindings,
#		       [ keys %$valueHash3 ], $valueHash3);
}


callTests();

    my %wkStart0    = ( MailWeekendStart => [ '0700', 'uint16' ] );
    my %wkEnd0	    = ( MailWeekendEnd => [ '2000', 'uint16' ] );
    my %wkInterval0 = ( MailWeekendInterval => [ '20', 'uint16' ] );
    my $valueHash0  = { %wkStart0, %wkEnd0, %wkInterval0};

    my %wkStartUndef    = ( MailWeekendStart => [ undef, 'uint16' ] );
    my %wkEndUndef	= ( MailWeekendEnd => [ undef, 'uint16' ] );
    my %wkIntervalUndef = ( MailWeekendInterval => [ undef, 'uint16' ] );
    my $valueHashUndef  = { %wkStartUndef, %wkEndUndef, %wkIntervalUndef};

    my %wkStart1    = ( MailWeekendStart => [ '0800', 'uint16' ] );
    my %wkEnd1	    = ( MailWeekendEnd => [ '2100', 'uint16' ] );
    my %wkInterval1 = ( MailWeekendInterval => [ undef, 'uint16' ] );
    my $valueHash1  = { %wkStart1, %wkEnd1, %wkInterval1};
    
    my %wkStart2    = ( MailWeekendStart => [ undef, 'uint16' ] );
    my %wkEnd2	    = ( MailWeekendEnd => [ '2200', 'uint16' ] );
    my %wkInterval2 = ( MailWeekendInterval => [ undef, 'uint16' ] );
    my $valueHash2  = { %wkStart2, %wkEnd2, %wkInterval2};
    
    my %wkStart3    = ( MailWeekendStart => [ '0900', 'uint16' ] );
    my %wkEnd3	    = ( MailWeekendEnd => [ undef, 'uint16' ] );
    my %wkInterval3 = ( MailWeekendInterval => [ '20', 'uint16' ] );
    my $valueHash3  = { %wkStart3, %wkEnd3, %wkInterval3};

# MailWeekdays properties
{
    _modifyInstance_ok($className, $keyBindings,
		       [ keys %$valueHash0 ], $valueHash0);
    _modifyInstance_ok($className, $keyBindings,
		       [ keys %$valueHashUndef ], $valueHashUndef);
    _modifyInstance_ok($className, $keyBindings,
		       [ keys %$valueHash0 ], $valueHash0);
# error tests
    _modifyInstance_ok($className, $keyBindings,
		       [ keys %$valueHashUndef ], $valueHashUndef);
    _modifyInstance_notok($className, $keyBindings,
		       [ keys %$valueHash1 ], $valueHash1, 4);
    _modifyInstance_notok($className, $keyBindings,
		       [ keys %$valueHash2 ], $valueHash2, 4);
    _modifyInstance_notok($className, $keyBindings,
		       [ keys %$valueHash3 ], $valueHash3, 4);
}   

# MailWeekend properties
{
    my %wkStart0    = ( MailWeekdaysStart => [ '0700', 'uint16' ] );
    my %wkEnd0	    = ( MailWeekdaysEnd => [ '2000', 'uint16' ] );
    my %wkInterval0 = ( MailWeekdaysInterval => [ '20', 'uint16' ] );
    my $valueHash0  = { %wkStart0, %wkEnd0, %wkInterval0};
    

    my %wkStartUndef    = ( MailWeekdaysStart => [ undef, 'uint16' ] );
    my %wkEndUndef	= ( MailWeekdaysEnd => [ undef, 'uint16' ] );
    my %wkIntervalUndef = ( MailWeekdaysInterval => [ undef, 'uint16' ] );
    my $valueHashUndef  = { %wkStartUndef, %wkEndUndef, %wkIntervalUndef};

    _modifyInstance_ok($className, $keyBindings,
		       [ keys %$valueHash0 ], $valueHash0);
    _modifyInstance_ok($className, $keyBindings,
		       [ keys %$valueHashUndef ], $valueHashUndef);
    _modifyInstance_ok($className, $keyBindings,
		       [ keys %$valueHash0 ], $valueHash0);
}
    
BEGIN { $numOfTests = 38; print "$numOfTests\n"; }


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
