use strict;
use lib "t";
use common;

use CIM::Parameter;
use CIM::Qualifier;


# preliminaries 

my $v1 = CIM::Value->new(	Value   =>	'100',
				Type    =>	CIM::DataType::string  );
my $v2 = CIM::Value->new(	Value   =>	'TRUE',
				Type    =>	CIM::DataType::boolean  );

my $q1 = CIM::Qualifier->new(    Name => 'testQ',
				 Value => $v1	);
my $q2 = CIM::Qualifier->new(    Name => 'testQQ',
				 Value => $v2	);


# initializing CIM::Properties
my $p1 = CIM::Parameter->new(	Name	=>	'Karl-Heinz',
				Type	=>	CIM::DataType::string,
			     );

my $p1array = CIM::Parameter->new(  Name	=>  'Karl-Heinz',
				    isArray	=>  1,
				    Type	=>  CIM::DataType::string );

my $p2 = CIM::Parameter->new(	Name	=>	'Hans-Martin',
				Type	=>	CIM::DataType::boolean,
				Qualifier   =>	$q2,
			      );	
my $p2ref = CIM::Parameter->new(    Name	=>  'Hans-Martin',
				    Type	=>  CIM::DataType::reference,
				    ReferenceClass => 'SomeClass',
			      );	

my $p2refarray = CIM::Parameter->new(   Name	=>  'Hans-Martin',
					Type	=>  CIM::DataType::reference,
					ReferenceClass => 'SomeClass',
					isArray     =>  1,
			      );	

# toXML for PARAMETER
my $compare = '<PARAMETER NAME="Karl-Heinz" TYPE="string"/>' . "\n";
assert($p1->toXML->toString eq $compare);

# qualifiers
$p1->qualifiers( ($q1, $q2) ); 
my $count = @{$p1->qualifiers()};
assert($count == 2);


# toXML for PARAMETER.REFERENCE
$compare = '<PARAMETER.REFERENCE NAME="Hans-Martin" REFERENCECLASS="SomeClass"/>' . "\n";
assert($p2ref->toXML->toString eq $compare);

# addQualifiers
$p2ref->addQualifiers($q1);
$count = @{$p2ref->qualifiers()};

assert($count == 1);

# cpprint $p2ref->toXML->toString;

# toXML for PARAMETER.REFARRAY
$compare = '<PARAMETER.REFARRAY NAME="Hans-Martin" REFERENCECLASS="SomeClass"/>' . "\n";
assert($p2refarray->toXML->toString eq $compare);


# toXML for PARAMETER.ARRAY
$compare = '<PARAMETER.ARRAY NAME="Karl-Heinz" TYPE="string"/>' . "\n";
assert($p1array->toXML->toString eq $compare);

# qualifiers
$p2->qualifiers($q2); 
$count = @{$p2->qualifiers()};
assert($count == 1);


# does isArray work? 
assert($p1array->isArray    == 1);
assert($p1->isArray	    == 0);
assert($p2ref->isArray	    == 0);
assert($p2refarray->isArray == 1);

# does isReference work? 
assert($p1->isReference == 0);
assert($p2ref->isReference == 1);
assert($p2refarray->isReference == 1);

# does name work? 
assert($p1->name() eq 'Karl-Heinz');

# does type work? 
assert($p1->type() eq CIM::DataType::string);
assert($p2ref->type() eq CIM::DataType::reference);

# does qualifiers work?
assert(${$p1->qualifiers()}[0] == $q1);

# does addQualifiers work?
$p1->qualifiers("");
$p1->addQualifiers($q2, $q1);
assert(${$p1->qualifiers()}[2] == $q1 &&
       ${$p1->qualifiers()}[1] == $q2);



# fromXML for PARAMETER
my $xml = $p2->toXML;
$compare = '<PARAMETER NAME="Hans-Martin" TYPE="boolean"><QUALIFIER NAME="testQQ" TYPE="boolean"><VALUE>TRUE</VALUE></QUALIFIER></PARAMETER>' . "\n";
my $p3 = CIM::Parameter->new(XML => $xml);

assert($p3->toXML->toString eq $compare);
# print $p3->toXML->toString, "\n";


# fromXML for PARAMETER.REFERENCE
$xml = $p2ref->toXML;
$compare = '<PARAMETER.REFERENCE NAME="Hans-Martin" REFERENCECLASS="SomeClass"><QUALIFIER NAME="testQ" TYPE="string"><VALUE>100</VALUE></QUALIFIER></PARAMETER.REFERENCE>' . "\n";
my $p4 = CIM::Parameter->new(XML => $xml);

assert($p4->toXML->toString eq $compare);
# print $p4->toXML->toString;


# fromXML for PARAMETER.REFARRAY
$xml = $p2refarray->toXML;
$compare = '<PARAMETER.REFARRAY NAME="Hans-Martin" REFERENCECLASS="SomeClass"/>' . "\n";
my $p5 = CIM::Parameter->new(XML => $xml);

assert($p5->toXML->toString eq $compare);
# print $p5->toXML->toString, "\n";


# fromXML for PARAMETER.ARRAY
$xml = $p1array->toXML;
$compare = '<PARAMETER.ARRAY NAME="Karl-Heinz" TYPE="string"/>' . "\n";
my $p6 = CIM::Parameter->new(XML => $xml);

assert($p6->toXML->toString eq $compare);
# print $p6->toXML->toString, "\n";


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
