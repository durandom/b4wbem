use strict;
use lib "t";
use common;

use CIM::ObjectName;
use CIM::Utils;
use CIM::Association;
use XML::DOM;
use CIM::Class;
use CIM::Client;
use CIM::Qualifier;
use CIM::Property;
use CIM::NamespacePath;


# preliminaries for testing CIMAssociations:

my $onJon = CIM::ObjectName->new(ObjectName  => 'PaulA_User',
				KeyBindings => {Login => 'jon' },
				ConvertType => 'INSTANCENAME');

my $onGar = CIM::ObjectName->new(ObjectName  => 'PaulA_User',
				KeyBindings => {Login => 'garfield' },
				ConvertType => 'INSTANCENAME');

my $onOdie = CIM::ObjectName->new(ObjectName  => 'PaulA_User',
				KeyBindings => {Login => 'odie' },
				ConvertType => 'INSTANCENAME');

my $valJon = CIM::Value->new(   Type  => CIM::DataType::reference,
				Value => $onJon);

my $valGar = CIM::Value->new(   Type  => CIM::DataType::reference,
				Value => $onGar);

my $valOdie = CIM::Value->new(	Type  => CIM::DataType::reference,
				Value => $onOdie);

my $true = CIM::Value->new( Type  => CIM::DataType::boolean,
			    Value => '1');
my $false = CIM::Value->new(Type  => CIM::DataType::boolean,
			    Value => '0');


my $prop1 = CIM::Property->new( Name    =>      'Antecedent',
                                Type    =>      CIM::DataType::reference,
                                Value   =>      $valJon
                              );

my $prop2 = CIM::Property->new(  Name    =>      'Dependent',
				 Type    =>	CIM::DataType::reference,
				 Value   =>      $valGar );

my $prop3 = CIM::Property->new(  Name    =>      'Dependent',
				 Type    =>	CIM::DataType::reference,
				 Value   =>      $valOdie );
#pprint $prop2;
#pprint $prop2->toXML->toString;
#print "\n\n";


my $asso = CIM::Association->new(   ClassName	=>	'CIM_Dependency',
				    Superclass  =>	'AtestSuperclass',
				    Property	=>	[$prop1, $prop2],
				    );

my $asso2 = CIM::Association->new(  ClassName	=>	'CIM_Dependency',
				    Superclass  =>	'AtestSuperclass',
				    );

# cpprint $asso->toXML->toString;
# cpprint $asso2->toXML->toString;

# test 1

my $compare1 = '<INSTANCE CLASSNAME="CIM_Dependency"><QUALIFIER NAME="Association" TYPE="boolean"><VALUE>TRUE</VALUE></QUALIFIER><PROPERTY.REFERENCE NAME="Antecedent"><VALUE.REFERENCE><INSTANCENAME CLASSNAME="PaulA_User"><KEYBINDING NAME="Login"><KEYVALUE>jon</KEYVALUE></KEYBINDING></INSTANCENAME></VALUE.REFERENCE></PROPERTY.REFERENCE><PROPERTY.REFERENCE NAME="Dependent"><VALUE.REFERENCE><INSTANCENAME CLASSNAME="PaulA_User"><KEYBINDING NAME="Login"><KEYVALUE>garfield</KEYVALUE></KEYBINDING></INSTANCENAME></VALUE.REFERENCE></PROPERTY.REFERENCE></INSTANCE>' . "\n";

assert($compare1 eq $asso->toXML->toString);


# test 2

assert('CIM_Dependency' eq $asso->className());

# test 3

$asso2->properties($prop1, $prop3);

my $properties = $asso2->properties;
my $num = @{$properties};
assert($num == 2); 

# test 4

my $qualifiers = $asso2->qualifiers;
$num = @{$qualifiers};
# association qualifier must be set
assert($num == 1); 
assert($qualifiers->[0]->value->value eq "TRUE" && 
       $qualifiers->[0]->name eq "Association"); 


# test 6

my $asso3 = CIM::Association->new(  XML	=>  $asso->toXML  );
#cpprint $asso3->toXML->toString;

assert($asso3->toXML->toString eq $asso->toXML->toString);



BEGIN { $numOfTests = 6; print "$numOfTests\n"; }


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
