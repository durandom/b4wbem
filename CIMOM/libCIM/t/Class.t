use strict;
use lib "t";
use common;

use CIM::Class;
use CIM::Qualifier;
use CIM::Property;


# preliminaries for testing CIMClass:

my $v1 = CIM::Value->new(    Value   =>      '100',
			     Type    =>      CIM::DataType::string  );

my $true = CIM::Value->new(    Value   =>      'TRUE',
			     Type    =>      CIM::DataType::boolean  );

my $quali1 = CIM::Qualifier->new(    Name => 'q1',
				     Value => $v1	);

my $quali2 = CIM::Qualifier->new(    Name => 'q2',
				     Value => $true	);

my $assocQualifier = CIM::Qualifier->new(   Name => "Association",
					    Value => $true     );

my $prop1 = CIM::Property->new(  Name    =>      'Karl-Heinz',
				 Type    =>      CIM::DataType::string );

my $prop2 = CIM::Property->new( Name    =>      'Hans-Martin',
                                Type    =>      CIM::DataType::string,
                                Qualifier   =>  $quali2,
                                Value   =>      $true
                              );

#-----------------------------------------

# does the constructor work? + does 'toXML' work?   #1
my $class = CIM::Class->new(	Name	    =>	'test',
                                Superclass  =>	'testSuperclass',
                                Property  =>	[$prop1],
				Qualifier  =>	[$quali1] );

my $compare = '<CLASS NAME="test" SUPERCLASS="testSuperclass"><QUALIFIER NAME="q1" TYPE="string"><VALUE>100</VALUE></QUALIFIER><PROPERTY NAME="Karl-Heinz" TYPE="string"/></CLASS>' . "\n";
my $toString1 = $class->toXML->toString;
assert($toString1 eq $compare);

# does 'name' work?	#2
assert('test' eq $class->name());

# does 'qualifiers' work?   #3
$class->qualifiers($quali2);
my $elem = $class->qualifiers;
my $num = @{$elem};
assert($num == 1);
assert($toString1 ne $class->toXML->toString);

# does 'addQualifiers' work?	#5
$class->addQualifiers($quali1, $quali2);
$elem = $class->qualifiers;
$num = @{$elem};
assert($num == 3);

# does 'properties' work?   #6
$class->properties($prop2);
$elem = $class->properties;
$num = @{$elem};
assert($num == 1);

# does 'addProperties' work?	#7
$class->addProperties($prop1, $prop2);
$elem = $class->properties;
$num = @{$elem};
assert($num == 3);

# does propertyByName work? #8
assert ($class->propertyByName("Karl-Heinz") == $prop1);


# does 'fromXML' work?	    #9
my $xml = $class->toXML;
my $class2 = CIM::Class->new(XML => $xml->getDocumentElement());
assert($class2->toXML->toString eq $class->toXML->toString);

#@{$class->properties}[0]->addQualifiers($quali1);
#pprint $class->toXML->toString, "\n";
#print $class->toString, "\n";

# does isAssociation work?
assert(!$class2->isAssociation);    #10
my $classA = CIM::Class->new(	Name	    =>	'test',
                                Superclass  =>	'testSuperclass',
				Qualifier  =>	[$assocQualifier] );

assert($classA->isAssociation);	    #11

# does toXML work for a class containing methods?
use CIM::Method;
my $method = CIM::Method->new(	Name	=> 'myMethod'	);

my $classM = CIM::Class->new(	Name	    =>	'test',
                                Superclass  =>	'testSuperclass',
				Qualifier   =>	[$assocQualifier],
				Method	    =>	[$method] );

$compare = '<CLASS NAME="test" SUPERCLASS="testSuperclass"><QUALIFIER NAME="Association" TYPE="boolean"><VALUE>TRUE</VALUE></QUALIFIER><METHOD NAME="myMethod"/></CLASS>' ."\n";

assert($classM->toXML->toString eq $compare);	#12
# print $classM->toXML->toString;

# does fromXML work for a class containing methods?
$xml = $compare;
my $classM2 = CIM::Class->new(	XML => $xml );
assert($classM2->toXML->toString eq $compare);	#13

# does addMethod work?
$classM->addMethods($method);
$elem = $classM->methods;
$num = @{$elem};
assert($num = 2);   #14

# does methods work?
$classM->methods($method);
$elem = $classM->methods;
$num = @{$elem};
assert($num = 1);   #15

# does methodByName work?
my $method2 = $classM->methodByName("myMethod");
assert($method == $method2);	#16


BEGIN { $numOfTests = 16; print "$numOfTests\n"; }


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
