use strict;
use lib "t";
use common;

use XML::DOM;
use CIM::Method;
use CIM::Parameter;
use CIM::Qualifier;


# preliminaries 

my $v1 = CIM::Value->new(    Value   =>      '100',
                             Type    =>      CIM::DataType::string  );

my $v2 = CIM::Value->new(    Value   =>      'TRUE',
                             Type    =>      CIM::DataType::boolean  );

my $quali1 = CIM::Qualifier->new(    Name => 'q1',
                                     Value => $v1	);

my $quali2 = CIM::Qualifier->new(    Name => 'q2',
                                     Value => $v2	);

my $para1 = CIM::Parameter->new(  Name	    =>     'Karl-Heinz',
				  Type	    =>     CIM::DataType::string );

my $para2 = CIM::Parameter->new( Name	    =>  'Hans-Martin',
                                 Type	    =>	CIM::DataType::reference,
				 ReferenceClass => "SomeClass",
                                 Qualifier  =>  $quali2,
                              );

#-----------------------------------------

# toXML test, mit PARAMETER
my $method1 = CIM::Method->new(	Name	=>	'test',
				Type	=>	'string',
				Parameter  =>	[$para1],
				Qualifier  =>	[$quali1] );

my $compare = '<METHOD NAME="test" TYPE="string"><QUALIFIER NAME="q1" TYPE="string"><VALUE>100</VALUE></QUALIFIER><PARAMETER NAME="Karl-Heinz" TYPE="string"/></METHOD>' ."\n";
assert($compare eq $method1->toXML->toString);

# print $method1->toXML->toString;

# toXML test, mit PARAMETER.REFERENCE
my $method = CIM::Method->new(	Name	=>	'test',
				Type	=>	'string',
				Parameter  =>	[$para2],
			     );

$compare = '<METHOD NAME="test" TYPE="string"><PARAMETER.REFERENCE NAME="Hans-Martin" REFERENCECLASS="SomeClass"><QUALIFIER NAME="q2" TYPE="boolean"><VALUE>TRUE</VALUE></QUALIFIER></PARAMETER.REFERENCE></METHOD>' ."\n";
assert($compare eq $method->toXML->toString);

# print $method->toXML->toString;

# does 'name' work?	#3
assert('test' eq $method->name());

# does 'qualifiers' work?   #4
$method->qualifiers($quali2);
my $elem = $method->qualifiers;
my $num = @{$elem};
assert($num == 1);

# does 'addQualifiers' work?	#5
$method->addQualifiers($quali1, $quali2);
$elem = $method->qualifiers;
$num = @{$elem};
assert($num == 3);

#6
my $q = $method->qualifierByName('q1');
assert($q->name() eq 'q1');

#7
$q = $method->qualifierByName('Something Invalid');
assert(not defined $q);

# does 'parameters' work?   #8
$method->parameters($para2);
$elem = $method->parameters;
$num = @{$elem};
assert($num == 1);

# does 'addParameters' work?	#9
$method->addParameters($para1, $para2);
$elem = $method->parameters;
$num = @{$elem};
assert($num == 3);

#10
my $p = $method->parameterByName('Hans-Martin');
assert($p->name() eq 'Hans-Martin');

#11
$p = $method->parameterByName('Something Invalid');
assert(not defined $p);

# does type() work? #12
assert($method1->type() eq CIM::DataType::string);

# does propagated() work? #13 #14
assert($method->propagated() == 0);
$method->propagated('true');
assert($method->propagated() == 1);

# does 'fromXML' work?	    #7
my $xml = $method->toXML;
my $method2 = CIM::Method->new(XML => $xml->getDocumentElement());
assert($method->toXML->toString eq $method2->toXML->toString);

# print $method2->toXML->toString, "\n";


BEGIN { $numOfTests = 15; print "$numOfTests\n"; }


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
