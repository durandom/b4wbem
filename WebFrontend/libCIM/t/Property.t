use strict;
use lib "t";
use common;

use CIM::Property;
use CIM::Qualifier;


# preliminaries for testing the CIM::Property class:

my $o1 = CIM::ObjectName->new(ObjectName  => 'huhu',
			      KeyBindings => {key0 => 'val0',
					      key1 => 'val1'},
			      ConvertType => 'CLASSNAME');

my $v1 = CIM::Value->new(	Value   =>	'100',
				Type    =>	CIM::DataType::string  );
my $v2 = CIM::Value->new(	Value   =>	'TRUE',
				Type    =>	CIM::DataType::boolean  );
my $v3 = CIM::Value->new(	Value   =>	$o1,
				Type    =>	CIM::DataType::reference  );

my $q1 = CIM::Qualifier->new(    Name => 'testQ',
				 Value => $v1	);
my $q2 = CIM::Qualifier->new(    Name => 'testQQ',
				 Value => $v2	);


# initializing CIM::Properties
my $p1 = CIM::Property->new(	Name	=>	'Karl-Heinz',
				Type	=>	CIM::DataType::string );

my $p2 = CIM::Property->new(	Name	=>	'Hans-Martin',
				Type	=>	CIM::DataType::boolean,
				Qualifier   =>	$q2,
				Value	=>	$v2,
			      );	
my $p2a = CIM::Property->new(	Name	=>	'Hans-Martin',
				Type	=>	CIM::DataType::reference,
				Qualifier   =>	$q2,
				Value	=>	$v3,
			      );	

# does constructor work? + does toXML work?
my $compare = '<PROPERTY NAME="Karl-Heinz" TYPE="string"/>';
my $toString1 = $p1->toXML->toString;
chomp $toString1;
assert($toString1 eq $compare);

# does isArray work? 
assert($p1->isArray == 0);
assert($p2->isArray == 0);
assert($p2a->isArray == 0);

# does isReference work? 
assert($p1->isReference == 0);
assert($p2->isReference == 0);
assert($p2a->isReference == 1);

# does name work? 
assert($p1->name() eq 'Karl-Heinz');

# does type work? 
assert($p1->type() eq CIM::DataType::string);
assert($p2a->type() eq CIM::DataType::reference);

# does value work?
$p1->value($v1);
assert($p1->value() == $v1);

# does propagated work?
$p1->propagated('true');
assert($p1->propagated() == 1);

# does qualifiers work?
$p1->qualifiers($q1);
assert(${$p1->qualifiers()}[0] == $q1);

# does addQualifiers work?
$p1->addQualifiers($q2, $q1);
assert(${$p1->qualifiers()}[2] == $q1 &&
       ${$p1->qualifiers()}[1] == $q2);

# does fromXML work?
my $xml = $p2->toXML;
$compare = '<PROPERTY NAME="Hans-Martin" TYPE="boolean"><VALUE>TRUE</VALUE><QUALIFIER NAME="testQQ" TYPE="boolean"><VALUE>TRUE</VALUE></QUALIFIER></PROPERTY>';
my $p3 = CIM::Property->new(XML => $xml);
my $toString2 = $p3->toXML->toString;
chomp $toString2;
#print $toString2, "\n";
assert($toString2 eq $compare);

# does fromXML work? (another try for PROPERTY.REFERENCE)
$xml = $p2a->toXML;
$compare = '<PROPERTY.REFERENCE NAME="Hans-Martin"><VALUE.REFERENCE><CLASSNAME NAME="huhu"><KEYBINDING NAME="key0"><KEYVALUE>val0</KEYVALUE></KEYBINDING><KEYBINDING NAME="key1"><KEYVALUE>val1</KEYVALUE></KEYBINDING></CLASSNAME></VALUE.REFERENCE><QUALIFIER NAME="testQQ" TYPE="boolean"><VALUE>TRUE</VALUE></QUALIFIER></PROPERTY.REFERENCE>';
$p3 = CIM::Property->new(XML =>	$xml);
$toString2 = $p3->toXML->toString;
chomp $toString2;
#print $toString2, "\n";
assert($toString2 eq $compare);

# is a PROPERTY.ARRAY recognized?
my $parser = new XML::DOM::Parser;
my $testString = '<PROPERTY.ARRAY NAME="Roles" TYPE="string"><QUALIFIER NAME="CIMTYPE" TYPE="string" TOINSTANCE="true"><VALUE>string</VALUE></QUALIFIER></PROPERTY.ARRAY>';
my $doc = $parser->parse($testString);

my $p4 =  CIM::Property->new(XML =>  $doc->getDocumentElement());
#print $p4->toXML->toString;
assert($p4->toXML->toString eq $doc->toString);

#pprint $p4->toXML->toString;
#pprint $doc->toString;

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
