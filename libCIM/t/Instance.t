use strict;
use lib "t";
use common;

use XML::DOM;
use CIM::Instance;
use CIM::Class;
use CIM::Qualifier;
use CIM::Property;


# preliminaries 

my $v1 = CIM::Value->new(    Value   =>      '100',
                             Type    =>      CIM::DataType::string  );

my $v2 = CIM::Value->new(    Value   =>      'TRUE',
                             Type    =>      CIM::DataType::boolean  );

my $quali1 = CIM::Qualifier->new(    Name => 'q1',
                                     Value => $v1	);

my $quali2 = CIM::Qualifier->new(    Name => 'q2',
                                     Value => $v2	);

my $prop1 = CIM::Property->new(  Name    =>      'Karl-Heinz',
				 Type    =>      CIM::DataType::string );

my $prop2 = CIM::Property->new( Name    =>      'Hans-Martin',
                                Type    =>      CIM::DataType::string,
                                Qualifier   =>  $quali2,
                                Value   =>      $v2
                              );

#-----------------------------------------

# does the constructor work? + does 'toXML' work?   #1
my $instance = CIM::Instance->new(	ClassName   =>	'test',
					Property  =>	[$prop1],
					Qualifier  =>	[$quali1] );

my $compare = '<INSTANCE CLASSNAME="test"><QUALIFIER NAME="q1" TYPE="string"><VALUE>100</VALUE></QUALIFIER><PROPERTY NAME="Karl-Heinz" TYPE="string"/></INSTANCE>';
my $toString1 = $instance->toXML->toString;
chomp $toString1;
assert($compare eq $toString1);

# does 'className' work?	#2
assert('test' eq $instance->className());

# does 'qualifiers' work?   #3
$instance->qualifiers($quali2);
my $elem = $instance->qualifiers;
my $num = @{$elem};
assert($num == 1);

# does 'addQualifiers' work?	#4
$instance->addQualifiers($quali1, $quali2);
$elem = $instance->qualifiers;
$num = @{$elem};
assert($num == 3);

my $q = $instance->qualifierByName('q1');
assert($q->name() eq 'q1');

$q = $instance->qualifierByName('Something Invalid');
assert(not defined $q);

# does 'properties' work?   #5
$instance->properties($prop2);
$elem = $instance->properties;
$num = @{$elem};
assert($num == 1);

# does 'addProperties' work?	#6
$instance->addProperties($prop1, $prop2);
$elem = $instance->properties;
$num = @{$elem};
assert($num == 3);

my $p = $instance->propertyByName('Hans-Martin');
assert($p->name() eq 'Hans-Martin');

$p = $instance->propertyByName('Something Invalid');
assert(not defined $p);

# does 'fromXML' work?	    #7
my $xml = $instance->toXML;
my $instance2 = CIM::Instance->new(XML => $xml->getDocumentElement());
assert($instance->toXML->toString eq $instance2->toXML->toString);

#@{$instance->properties}[0]->addQualifiers($quali1);
#pprint $instance->toXML->toString, "\n";
#print $instance->toString, "\n";


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
