use strict;
use lib "t";
use common;

use CIM::ObjectName;


my $on = CIM::ObjectName->new(ObjectName  => 'foo',
			      KeyBindings => { key1 => 'val1' });

# Test 1:

$on->objectName('CIM_Obj');

assert($on->objectName eq 'CIM_Obj');

# Test 2:

$on->addKeyBinding("key0", "val0");

assert($on->keyBindings()->{key0} eq "val0" &&
       $on->keyBindings()->{key1} eq "val1");

# Test 3:

my $ns = CIM::NamespacePath->new(Namespace => [ 'root', 'Some', 'Ns' ]);
$on->namespacePath($ns);

assert($on->toString() eq 'root/Some/Ns:CIM_Obj.key0=val0,key1=val1');


# Test 4:

$on->convertType('OBJECTPATH-INSTANCENAME');
$ns->host("someHost");

my $compare1 = '<OBJECTPATH><INSTANCEPATH><NAMESPACEPATH><HOST>someHost</HOST><LOCALNAMESPACEPATH><NAMESPACE NAME="root"/><NAMESPACE NAME="Some"/><NAMESPACE NAME="Ns"/></LOCALNAMESPACEPATH></NAMESPACEPATH><INSTANCENAME CLASSNAME="CIM_Obj"><KEYBINDING NAME="key0"><KEYVALUE>val0</KEYVALUE></KEYBINDING><KEYBINDING NAME="key1"><KEYVALUE>val1</KEYVALUE></KEYBINDING></INSTANCENAME></INSTANCEPATH></OBJECTPATH>' . "\n";

assert($on->toXML->toString eq $compare1);


# Test 5

$on->convertType('INSTANCENAME');
$on->namespacePath('');
my $compare2 = '<INSTANCENAME CLASSNAME="CIM_Obj"><KEYBINDING NAME="key0"><KEYVALUE>val0</KEYVALUE></KEYBINDING><KEYBINDING NAME="key1"><KEYVALUE>val1</KEYVALUE></KEYBINDING></INSTANCENAME>' . "\n";

assert($on->toXML->toString eq $compare2);


# Test 6
$on->convertType('CLASSNAME');
$on->deleteKeyBindings;
my $compare3 = '<CLASSNAME NAME="CIM_Obj"/>' . "\n";

assert($on->toXML->toString eq $compare3);


# Test 7
$on->namespacePath($ns);
my $compare4 = '<CLASSPATH><NAMESPACEPATH><HOST>someHost</HOST><LOCALNAMESPACEPATH><NAMESPACE NAME="root"/><NAMESPACE NAME="Some"/><NAMESPACE NAME="Ns"/></LOCALNAMESPACEPATH></NAMESPACEPATH><CLASSNAME NAME="CIM_Obj"/></CLASSPATH>' . "\n";

assert($on->toXML->toString eq $compare4);


# Test 8
my $ns2 = CIM::NamespacePath->new(Namespace   => [ 'root', 'Some', 'Ns' ]);
$on->namespacePath($ns2);
my $compare5 = '<LOCALCLASSPATH><LOCALNAMESPACEPATH><NAMESPACE NAME="root"/><NAMESPACE NAME="Some"/><NAMESPACE NAME="Ns"/></LOCALNAMESPACEPATH><CLASSNAME NAME="CIM_Obj"/></LOCALCLASSPATH>' . "\n";

assert($on->toXML->toString eq $compare5);

#print $on->toXML->toString;
# print $on->toString(), "\n";

# Test 9

my $bla= $on->toXML;
my $test = CIM::ObjectName->new(XML => $bla);

assert($on->toXML->toString eq $test->toXML->toString);

#print $test->toXML->toString;


#-----------------------------------------
# Tests for fromXML: handling of KeyBindings:

# Test 10

my $parser = XML::DOM::Parser->new();
my $doc = $parser->parse('<INSTANCENAME CLASSNAME="CIM_Obj"><KEYBINDING NAME="key0"><KEYVALUE>val0</KEYVALUE></KEYBINDING><KEYBINDING NAME="key1"><KEYVALUE>val1</KEYVALUE></KEYBINDING></INSTANCENAME>');

my $on10 = CIM::ObjectName->new( XML => $doc);

assert($doc->toString eq $on10->toXML->toString);

#cpprint $on10->toXML->toString;


# Test 11

$doc = $parser->parse('<INSTANCENAME CLASSNAME="CIM_Dependency"><KEYBINDING NAME="Dependent"><VALUE.REFERENCE><INSTANCENAME CLASSNAME="PaulA_User"><KEYBINDING NAME="Login"><KEYVALUE>pan</KEYVALUE></KEYBINDING></INSTANCENAME></VALUE.REFERENCE></KEYBINDING></INSTANCENAME>');

my $on11 = CIM::ObjectName->new( XML => $doc);

assert($doc->toString eq $on11->toXML->toString);

#cpprint $on11->toXML->toString;


# Test 12 

$doc = $parser->parse('<INSTANCENAME CLASSNAME="CIM_Obj"><KEYVALUE>pan</KEYVALUE></INSTANCENAME>');

my $on12 = CIM::ObjectName->new( XML => $doc);

assert($doc->toString eq $on12->toXML->toString);

# cpprint $on12->toXML->toString;
# print $on12->toString(), "\n";


# Test 13

$doc = $parser->parse('<INSTANCENAME CLASSNAME="CIM_Dependency"><VALUE.REFERENCE><INSTANCENAME CLASSNAME="PaulA_User"><KEYBINDING NAME="Login"><KEYVALUE>pan</KEYVALUE></KEYBINDING></INSTANCENAME></VALUE.REFERENCE></INSTANCENAME>');

my $on13 = CIM::ObjectName->new( XML => $doc);

assert($doc->toString eq $on13->toXML->toString);

# cpprint $on13->toXML->toString;

#-------------------------------------------

# Test 14

my $on14 = CIM::ObjectName->new(    ObjectName  => 'CIM_Obj',
				    ConvertType => 'INSTANCENAME',
				    SingleKeyValue => 'pan');

assert($on14->toXML->toString eq $on12->toXML->toString);
#cpprint $on14->toXML->toString;


# Test 15

my $on15 = CIM::ObjectName->new(    ObjectName  => 'CIM_Obj',
				    ConvertType => 'INSTANCENAME',
				    SingleKeyValue => $on12);

my $compare15 = '<INSTANCENAME CLASSNAME="CIM_Obj"><VALUE.REFERENCE><INSTANCENAME CLASSNAME="CIM_Obj"><KEYVALUE>pan</KEYVALUE></INSTANCENAME></VALUE.REFERENCE></INSTANCENAME>' . "\n";

assert($on15->toXML->toString eq $compare15);
#cpprint $on15->toXML->toString;

# print $on15->toString(), "\n";
# print $on15->valueByKey(), "\n";

#---------------------------------------------


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
