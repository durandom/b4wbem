use strict;
use lib "t";
use common;

use CIM::Client;
use CIM::Utils;


my @properties;

push @properties,
    CIM::Property->new(Name  => 'RealName',
		       Type  => 'string',
		       Value => CIM::Value->new(Value => 'Harry Hirsch',
						Type  => 'string')),
    ;

my $realName = $properties[0]->value;



# Test 1

my $class = CIM::Class->new(Name => 'SomeClass');
my $vo = CIM::ValueObject->new(
			       Object	=> $class,
			      );

my $compare1 = '<VALUE.OBJECT><CLASS NAME="SomeClass"/></VALUE.OBJECT>' . "\n";
    
assert($vo->toXML->toString eq $compare1);


# Test 2
    
$vo->isNamedObject(1);
my $compare2 = '<VALUE.NAMEDOBJECT><CLASS NAME="SomeClass"/></VALUE.NAMEDOBJECT>' .  "\n"; 
    
assert($vo->toXML->toString eq $compare2);

# Test 3

my $nsp = CIM::NamespacePath->new(Namespace => [ 'root', 'Some', 'Ns' ],
				 );

my $on = CIM::ObjectName->new(  ObjectName    => 'PaulA_User',
				ConvertType   => 'CLASSNAME',
				NamespacePath => $nsp,
			     );
$vo->objectName($on);

my $compare3 = '<VALUE.OBJECTWITHLOCALPATH><LOCALCLASSPATH><LOCALNAMESPACEPATH><NAMESPACE NAME="root"/><NAMESPACE NAME="Some"/><NAMESPACE NAME="Ns"/></LOCALNAMESPACEPATH><CLASSNAME NAME="PaulA_User"/></LOCALCLASSPATH><CLASS NAME="SomeClass"/></VALUE.OBJECTWITHLOCALPATH>' . "\n";

assert($vo->toXML->toString eq $compare3);

    
# Test 4
$nsp->host('someHost');

my $compare4 = '<VALUE.OBJECTWITHPATH><CLASSPATH><NAMESPACEPATH><HOST>someHost</HOST><LOCALNAMESPACEPATH><NAMESPACE NAME="root"/><NAMESPACE NAME="Some"/><NAMESPACE NAME="Ns"/></LOCALNAMESPACEPATH></NAMESPACEPATH><CLASSNAME NAME="PaulA_User"/></CLASSPATH><CLASS NAME="SomeClass"/></VALUE.OBJECTWITHPATH>' . "\n";

assert($vo->toXML->toString eq $compare4);
    

# Test 5
my $on2 = CIM::ObjectName->new(  ObjectName    => 'PaulA_User',
				 ConvertType   => 'INSTANCENAME',
				 KeyBindings =>
				 {
				  Login => 'harry'
				 },
			      );
my $instance = CIM::Instance->new(ClassName => 'PaulA_User',
				  Property  => \@properties);
$vo->object($instance);
$vo->objectName($on2);

my $compare5 = '<VALUE.NAMEDOBJECT><INSTANCENAME CLASSNAME="PaulA_User"><KEYBINDING NAME="Login"><KEYVALUE>harry</KEYVALUE></KEYBINDING></INSTANCENAME><INSTANCE CLASSNAME="PaulA_User"><PROPERTY NAME="RealName" TYPE="string"><VALUE>Harry Hirsch</VALUE></PROPERTY></INSTANCE></VALUE.NAMEDOBJECT>' . "\n";

assert($vo->toXML->toString eq $compare5);
    

# Test 6
$vo->isNamedObject(0);
    
my $compare6 = '<VALUE.NAMEDINSTANCE><INSTANCENAME CLASSNAME="PaulA_User"><KEYBINDING NAME="Login"><KEYVALUE>harry</KEYVALUE></KEYBINDING></INSTANCENAME><INSTANCE CLASSNAME="PaulA_User"><PROPERTY NAME="RealName" TYPE="string"><VALUE>Harry Hirsch</VALUE></PROPERTY></INSTANCE></VALUE.NAMEDINSTANCE>' . "\n";
    
assert($vo->toXML->toString eq $compare6);
    

# Test 7
$on2->namespacePath($nsp);
    
my $compare7 = '<VALUE.OBJECTWITHPATH><INSTANCEPATH><NAMESPACEPATH><HOST>someHost</HOST><LOCALNAMESPACEPATH><NAMESPACE NAME="root"/><NAMESPACE NAME="Some"/><NAMESPACE NAME="Ns"/></LOCALNAMESPACEPATH></NAMESPACEPATH><INSTANCENAME CLASSNAME="PaulA_User"><KEYBINDING NAME="Login"><KEYVALUE>harry</KEYVALUE></KEYBINDING></INSTANCENAME></INSTANCEPATH><INSTANCE CLASSNAME="PaulA_User"><PROPERTY NAME="RealName" TYPE="string"><VALUE>Harry Hirsch</VALUE></PROPERTY></INSTANCE></VALUE.OBJECTWITHPATH>' . "\n";
    
assert($vo->toXML->toString eq $compare7);
    
    

# Test 8
my $nsp2 = CIM::NamespacePath->new(Namespace   => [ 'root', 'Some', 'Ns' ],
				  );
    
$on2->namespacePath($nsp2);

my $compare8 = '<VALUE.OBJECTWITHLOCALPATH><LOCALINSTANCEPATH><LOCALNAMESPACEPATH><NAMESPACE NAME="root"/><NAMESPACE NAME="Some"/><NAMESPACE NAME="Ns"/></LOCALNAMESPACEPATH><INSTANCENAME CLASSNAME="PaulA_User"><KEYBINDING NAME="Login"><KEYVALUE>harry</KEYVALUE></KEYBINDING></INSTANCENAME></LOCALINSTANCEPATH><INSTANCE CLASSNAME="PaulA_User"><PROPERTY NAME="RealName" TYPE="string"><VALUE>Harry Hirsch</VALUE></PROPERTY></INSTANCE></VALUE.OBJECTWITHLOCALPATH>' . "\n";
    
assert($vo->toXML->toString eq $compare8);
    
#print $vo->toXML->toString;

    
# Test 9
my $vo2 = CIM::ValueObject->new(
				Object	=> $instance,
			       );
my $compare9 = '<VALUE.OBJECT><INSTANCE CLASSNAME="PaulA_User"><PROPERTY NAME="RealName" TYPE="string"><VALUE>Harry Hirsch</VALUE></PROPERTY></INSTANCE></VALUE.OBJECT>' . "\n";
    
assert($vo2->toXML->toString eq $compare9);
    
#print $vo2->toXML->toString;


# Test 10 
# className returns undef as there is no object name defined for $vo2
assert(!$vo2->className);;

# Test 11
my $voFromXML1 = CIM::ValueObject->new( XML => $vo->toXML);
    
assert($vo->toXML->toString eq $compare8);

#print $voFromXML1->toXML->toString;


    
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
