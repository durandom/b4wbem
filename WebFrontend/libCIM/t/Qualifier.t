use strict;
use lib "t";
use common;

use CIM::Qualifier;


# preliminaries for testing the CIMQualifier class:

my $v1 = CIM::Value->new(    Value   =>      '100',
			     Type    =>      CIM::DataType::string  );

my $v2 = CIM::Value->new(    Value   =>      'TRUE',
			     Type    =>      CIM::DataType::boolean  );

my $f1 = {  OVERRIDABLE     =>	'true',
	    TOSUBCLASS	    =>  'false',
	    TOINSTANCE	    =>  'true'};  

my $f2 =  { OVERRIDABLE    =>	'false'};

my $f3 =  { TOINSTANCE	    =>	'true'};

#--------------------------------------------------------

my $quali1 = CIM::Qualifier->new(	Name => 'test',
					Value => $v1,
					Flavors => $f1);

# is the name set correctly?
assert($quali1->name() eq 'test');

my %hash = %{$quali1->flavors()};

# is a default flavor set correctly?
assert($hash{TRANSLATABLE} eq 'false');
# is a given flavor set correctly?
assert($hash{TOSUBCLASS} eq 'false');

# are flavors added correctly?
$quali1->addFlavors($f2); 
%hash = %{$quali1->flavors()};
assert($hash{TOSUBCLASS} eq 'false' &&
       $hash{OVERRIDABLE} eq 'false');

# are flavors changed correctly?
%hash = %{$quali1->flavors($f3)};
assert($hash{TOSUBCLASS} eq 'true' &&
       $hash{TOINSTANCE} eq 'true'); 

$quali1->value($v2);
assert($quali1->value->value eq 'TRUE');

# does propagated work?
assert($quali1->propagated() == 0);


# does toXML work?
my $toString1 = $quali1->toXML->toString;
chomp $toString1;
my $compare = '<QUALIFIER NAME="test" TYPE="boolean" TOINSTANCE="true"><VALUE>TRUE</VALUE></QUALIFIER>';
assert($toString1 eq $compare); 

# does fromXML work?
my $bsp = $quali1->toXML;
my $quali2 = CIM::Qualifier->new(XML => $bsp->getDocumentElement());

my $toString2 = $quali2->toXML->toString;
chomp $toString2;
assert($toString2 eq $compare);


# comparison tests:
{
    my $q1 = CIM::Qualifier->new(Name    => 'test',
				 Value   => $v1,
				 Flavors => $f1);
    my $q2 = CIM::Qualifier->new(Name    => 'aName',
				 Value   => $v1,
				 Flavors => $f1);
    my $q3 = CIM::Qualifier->new(Name    => 'test',
				 Value   => $v2,
				 Flavors => $f1);
    my $q4 = CIM::Qualifier->new(Name    => 'test',
				 Value   => $v1,
				 Flavors => $f2);
    
    assert($q1 == $q1);
    
    assert($q1 != $q2);
    assert($q1 != $q3);
    assert($q1 != $q4);
    
    assert($q2 != $q3);
    assert($q2 != $q4);
    
    assert($q3 != $q4);
    
    assert($q1 != $v1);
}


BEGIN { $numOfTests = 17; print "$numOfTests\n"; }


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
