use strict;
use lib "t";
use common;

use CIM::Value;


#### Tests 1+3:
my $v1 = CIM::Value->new(Value => "This is a simple test string",
			 Type  => CIM::DataType::string);
my $doc1 = $v1->toXML;
my $toString1 = $doc1->toString();
chomp $toString1;
my $compare = "<VALUE>This is a simple test string</VALUE>";
assert($toString1 eq $compare);
assert(!$v1->isArray);
assert(!$v1->isReference);


#### Tests 4-6:
my $v2 = CIM::Value->new(Value => [],
			 Type  => 'uint32');
my $toString2 = $v2->toXML->toString();
chomp $toString2;
$compare = "<VALUE.ARRAY/>";
assert($toString2 eq $compare);
assert($v2->isArray);
assert(!$v2->isReference);


#### Tests 7-8:
my $v3 = CIM::Value->new(Value => [1, 0],
			 Type  => 'boolean');
my $doc3 = $v3->toXML;
my $toString3 = $doc3->toString();
chomp $toString3;
$compare = "<VALUE.ARRAY><VALUE>TRUE</VALUE><VALUE>FALSE</VALUE></VALUE.ARRAY>";
assert($toString3 eq $compare);
assert($v3->isArray);


#### Test 9:
my $v4 = CIM::Value->new(XML => $doc3);
$v4->type('boolean');
my $toString4 = $v4->toXML->toString();
chomp $toString4;
assert($toString4 eq $toString3);


#### Tests 10-14
assert($v1 == $v1);
assert($v3 == $v4);

assert($v1 != $v2);
assert($v1 != $v3);
assert($v2 != $v3);


#### Tests 15-22
{
    my $o1 = CIM::ObjectName->new(ObjectName  => 'huhu',
				  KeyBindings => {key0 => 'val0',
						  key1 => 'val1'},
				  ConvertType => 'CLASSNAME');
    my $o2 = CIM::ObjectName->new(ObjectName  => 'duda',
				  KeyBindings => {key => 'val'},
				  ConvertType => 'INSTANCENAME');

    my ($v0, $v1, $compare);
    {
	$v0 = CIM::Value->new(Type  => CIM::DataType::reference,
			      Value => $o1);
	$compare = '<VALUE.REFERENCE><CLASSNAME NAME="huhu"><KEYBINDING NAME="key0"><KEYVALUE>val0</KEYVALUE></KEYBINDING><KEYBINDING NAME="key1"><KEYVALUE>val1</KEYVALUE></KEYBINDING></CLASSNAME></VALUE.REFERENCE>';
	my $toString0 = $v0->toXML->toString();
	chomp $toString0;
	assert($toString0 eq $compare);
	
	my $v1 = CIM::Value->new(XML => $v0->toXML);
	my $toString1 = $v1->toXML->toString();
	chomp $toString1;
	assert($toString1 eq $compare);

	assert(!$v0->isArray);
	assert($v0->isReference);
    }
    {
	$v0 = CIM::Value->new(Type  => CIM::DataType::reference,
			      Value => [ $o1, $o2 ]);
	$compare = '<VALUE.REFARRAY><VALUE.REFERENCE><CLASSNAME NAME="huhu"><KEYBINDING NAME="key0"><KEYVALUE>val0</KEYVALUE></KEYBINDING><KEYBINDING NAME="key1"><KEYVALUE>val1</KEYVALUE></KEYBINDING></CLASSNAME></VALUE.REFERENCE><VALUE.REFERENCE><INSTANCENAME CLASSNAME="duda"><KEYBINDING NAME="key"><KEYVALUE>val</KEYVALUE></KEYBINDING></INSTANCENAME></VALUE.REFERENCE></VALUE.REFARRAY>';
	my $toString0 = $v0->toXML->toString();
	chomp $toString0;
	assert($toString0 eq $compare);
	
	my $v1 = CIM::Value->new(XML => $v0->toXML);
	my $toString1 = $v1->toXML->toString();
	chomp $toString1;
	assert($toString1 eq $compare);
	
	assert($v0->isArray);
	assert($v0->isReference);
    }
    
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
