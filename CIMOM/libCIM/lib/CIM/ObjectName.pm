use strict;

########################
package CIM::ObjectName;
########################
use Carp;

use base qw(CIM::Base);

use CIM::NamespacePath;
use CIM::Utils;


sub new {
    my ($class, %args) = @_;
    
    my $self = $class->SUPER::new();

    $self->{'CIM::ObjectName::_objectName'} = undef;
    $self->{'CIM::ObjectName::_namespacePath'} = undef;
    $self->{'CIM::ObjectName::_keyBindings'} = {};
    
    $self->{_identifier} = 'CIMObjectName';
    
    $self->{_childAccessors} = {
				CLASSNAME    => 'objectName',
				INSTANCENAME => 'objectName',
			       };

    $self->{_validConvertTypes} = [
				   'CLASSNAME',
				   'INSTANCENAME',
				   'OBJECTPATH-CLASSNAME',
				   'OBJECTPATH-INSTANCENAME'
				  ];
    
    $self->processArgs(%args);

    return $self;
}


sub _init {
    my ($self, %args) = @_;
    
    $self->{_objectName} =
	exists $args{ObjectName} ? $args{ObjectName} : '';
    
    $self->{_namespacePath} =
	exists $args{NamespacePath} ? $args{NamespacePath} : undef;
    
    $self->singleKeyValue($args{SingleKeyValue}) 
	if defined $args{SingleKeyValue};

    # KeyBindings overwrites SingleKeyValue
    # using them together is wrong anyway
    $self->keyBindings($args{KeyBindings}) 
	if defined $args{KeyBindings};
    
    $self->convertType($args{ConvertType})
	if defined $args{ConvertType};
}    



# set and get routine
sub objectName {
    my $self = shift;
    
    $self->{_objectName} = $_[0] if defined $_[0];
    
    return $self->{_objectName};
}

# set and get routine
sub namespacePath {
    my $self = shift;

    $self->{_namespacePath} = $_[0] if defined $_[0];
    
    return $self->{_namespacePath};
}


sub addKeyBinding {
    my ($self, $key, $value) = @_;
    
    $self->{_keyBindings}->{$key} = $value;
}

# set and get routine
sub keyBindings {
    my $self = shift;
    
    $self->{_keyBindings} = $_[0] if defined $_[0];
    
    return $self->{_keyBindings};
}

sub singleKeyValue {
    my $self = shift;
    
    $self->{_keyBindings} = { '' => $_[0] } if defined $_[0];
    
    return $self->{_keyBindings}->{''};
}

sub deleteKeyBindings {
    my $self = shift;

     $self->{_keyBindings} = {};
}

sub valueByKey {
    my ($self, $key) = @_;

    if (defined $key && defined $self->{_keyBindings}->{$key}) {
	return $self->{_keyBindings}->{$key};
    }
    
    return $self->{_keyBindings}->{''};
}



sub toXML {
    my $self = shift;
    my $doc = XML::DOM::Document->new();
    my $root = $doc;
    
    my $type = $self->convertType();

    # get rid of OBJECTPATH
    if ($type =~ /^OBJECTPATH/) {
	my $op = $doc->createElement('OBJECTPATH');
	$doc->appendChild($op);
	
	# set the objectpath element to $root
	# -> step one level deeper in the XML hierarchy
	$root = $op;
	
	# remove the OBJECTPATH part of the type
	$type =~ s/^OBJECTPATH-//;
    }
    
    # if a path is given, we've got a (LOCAL)CLASS- or INSTANCEPATH element
    if ($self->{_namespacePath}) {
	
	my $tag = ($type eq 'CLASSNAME' ? 'CLASSPATH' : 'INSTANCEPATH');
	$tag = 'LOCAL' . $tag if $self->{_namespacePath}->isLocal;
	
	my $e = $doc->createElement($tag);
	$root->appendChild($e);

	# set the XY path element to $root
	$root = $e;

	# call toXML of NamespacePath
	my $nsp = $self->{_namespacePath}->toXML;
	$nsp->getDocumentElement()->setOwnerDocument($doc);
	$root->appendChild($nsp->getDocumentElement);
    }

    # process the CLASS- or  INSTANCENAME parts
    my $attr = ($type eq 'CLASSNAME' ? 'NAME' : 'CLASSNAME');
    
    my $e = $doc->createElement($type);
    $e->setAttribute($attr, scalar $self->{_objectName});
    
    $root->appendChild($e);
    
    # process the KEYBINDING part(s) of an INSTANCENAME
    foreach my $key (sort keys %{$self->{_keyBindings}}) {
	my $value = $self->{_keyBindings}->{$key};
	my $kb;
	# create KEYBINDING element only when there's a not empty key
	unless ($key eq '') {
	    $kb = $doc->createElement('KEYBINDING');
	    $kb->setAttribute('NAME', $key);
	    $e->appendChild($kb);
	}
	# we have a KEYVALUE if the value of the keyBindings hash is 
	#no object but text
	if (ref $value eq '') {
	    my $kv = $doc->createElement('KEYVALUE');
	    
	    $kv->addText($value);
	    
	    # append to the appropriate parent, KEYBINDING if that is defined,
	    # otherwise INSTANCENAME 
	    if (defined $kb) {
		$kb->appendChild($kv);
	    }
	    else {
		$e->appendChild($kv);
	    }
	}
	# we have a VALUE.REFERENCE if the value of the keyBindings hash is 
	#an object
	else {
  	    my $vr = $doc->createElement('VALUE.REFERENCE');
	    
	    # fill in the contents of the VALUE.REFERENCE
	    my $vrc = $value->toXML;
	    $vrc->getDocumentElement()->setOwnerDocument($doc);
	    $vr->appendChild($vrc->getDocumentElement);
	    
	    if (defined $kb) {
		$kb->appendChild($vr);
	    }
	    else {
		$e->appendChild($vr);
	    }
	}
    }
    
    return $doc;
}


sub fromXML {
    my ($self, $node) = @_;

    # print "CIMObj. -> fromXML: ", $node->toString, "\n";
    my $nodeName = $node->getNodeName();
    
    my ($child, $convTypePart1);
    if ($nodeName eq 'OBJECTPATH') {
	$node = $child = $node->getFirstChild;
	$convTypePart1 = $nodeName;
    
	$nodeName = $node->getNodeName();
    }
        
    # handling of 4 different XML elements:
    if ($nodeName =~ /PATH$/) {
	foreach $child ($node->getChildNodes()) {
	    if ($child->getNodeName() =~ /NAMESPACEPATH$/) {
		my $class = CIM::TagInfo->class($child->getNodeName);
		$self->{_namespacePath} = $class->new(XML => $child);
	    }
	    else {
		$nodeName = $child->getNodeName();
		$node = $child;

		$self->_fromXMLObjectName($node, $nodeName);
	    }
	}
	# set convert types, needed for later conversions to XML
	if (defined $convTypePart1) {
	    $self->convertType($convTypePart1 . "-" . $nodeName);
	}
	else {
	    $self->convertType($nodeName);
	}
    }

    # in case of simple INSTANCENAME or CLASSNAME as input to fromXML
    else {
	$self->convertType($nodeName);
	$self->_fromXMLObjectName($node, $nodeName);
    }    
    
    sub _fromXMLObjectName {
        my ($self, $node, $nodeName) = @_;
	
        my %hash = ( CLASSNAME => 'NAME', INSTANCENAME => 'CLASSNAME' );
        
        $self->{_objectName} =
	    $self->getXMLAttribute($node, $hash{$nodeName});
        
	$self->_fromXMLKeyBindings($node);
    }
    
    
    sub _fromXMLKeyBindings {
	my ($self, $node, $key) = @_;
	my $val;

	foreach my $child ($node->getChildNodes) {
	    
	    if ($child->getNodeName eq "KEYBINDING") {
		$key =
		    $child->getAttributes->getNamedItem('NAME')->getValue();
		$self->_fromXMLKeyBindings($child, $key);
	    }
	    else {
		if ($child->getNodeName eq "KEYVALUE") {
		    $val = $child->getFirstChild->getData();
		}
		elsif ($child->getNodeName eq "VALUE.REFERENCE") {
		    my $class = 
			CIM::TagInfo->class($child->getFirstChild->getNodeName);
		    $val = $class->new(XML => $child->getFirstChild);
		}
		
		# save key binding,
		if (defined $key) {
		    $self->addKeyBinding($key, $val);
		} 
		# save single key value or value reference
		else {
		    $self->singleKeyValue($val);
		}
	    }
	}
    }
}


sub toString {
    my $self = shift;
    
    my $s = '';
    
    $s .= $self->{_namespacePath}->namespace() . ":"
	if defined $self->{_namespacePath};
    
    $s .= $self->{_objectName};
    
    my @keyValuePairs = ();
    fatal("Unknown error: _keyBindings is not a HASH, but a " .
	  ref($self->{_keyBindings}))
	unless ref($self->{_keyBindings}) eq 'HASH';
    
    foreach my $key (sort keys %{$self->{_keyBindings}}) {
	my $value = $self->{_keyBindings}->{$key};
	$key = "[unspecified]" if $key eq '';
	push @keyValuePairs, "$key=$value";
    }
    
    $s .= '.' if scalar @keyValuePairs;
    
    $s .= join ',', @keyValuePairs;
    
    return $s;
}


1;


__END__

=head1 NAME

CIM::ObjectName - Class representing several CIM XML "object naming and locating" elements.


=head1 SYNOPSIS

 use CIM::ObjectName;

 $on = CIM::ObjectName->new( ObjectName  => 'CIM_Obj',
                             KeyBindings => 
				{ 
				key1 => 'value1',
				key2 => 'value2',
			       	},
			     ConvertType => 'INSTANCENAME', 
			    );

 $on = CIM::ObjectName->new( XML => $node );

 print $on->toString(), "\n";



=head1 DESCRIPTION

CIM::ObjectName encapsulates seven different CIM XML elements: 

 CLASSNAME 
 CLASSPATH 
 INSTANCENAME
 INSTANCEPATH 
 LOCALCLASSPATH 
 LOCALINSTANCEPATH 
 OBJETCPATH

An instance of a CIM::objectName may consists of:

  - object name, 
  - (local) namespace path, and
  - key bindings (or key value resp. value reference).

The presence or absence of those elements in combination with the convert 
type determines the XML element represented: 

 CLASSNAME:	    ObjectName (class name)
 INSTANCENAME:	    ObjectName (class name), KeyBindings
 CLASSPATH:	    ObjectName, NamespacePath
 INSTANCEPATH:	    ObjectName, KeyBindings, NamespacePath
 LOCALCLASSPATH:    ObjectName, local NamespacePath
 LOCALINSTANCEPATH: ObjectName, KeyBindings, local NamespacePath
 OBJETCPATH:	    CLASSPATH | INSTANCEPATH

E.g. the object name "HTTP://cimom/root/cimv2:CIM_Obj.key1=value1"
represents an INSTANCEPATH XML element (or an OBJECTPATH element) 
and has
 
  HTTP://cimom/root/cimv2      as namespace path,
  CIM_Obj                      as object name, and
  key1=value1                  as key binding and key value.


The correct convert types to be set for the elements are:

 CLASSNAME:	    CLASSNAME
 INSTANCENAME:	    INSTANCENAME
 CLASSPATH:	    CLASSNAME
 INSTANCEPATH:	    INSTANCENAME
 LOCALCLASSPATH:    CLASSNAME
 LOCALINSTANCEPATH: INSTANCENAME
 OBJETCPATH:	    OBJECTPATH-CLASSNAME or OBJECTPATH-INSTANCENAME
 

=head1 CONSTRUCTOR

=over 4

=item new([OPTIONS])

C<OPTIONS> are passed in a hash like fashion, using key and value pairs.
The possible options are:

B<XML> - Read the instance from the given XML::DOM element or document. 
Only used as sole option. If additional options are given they
will be ignored.

B<ObjectName> - Mandatory unless B<XML> is given;
the value is the name (a string) of the CIM::Class you're dealing with 
or the name of the CIM::Class the CIM::Instance you're handling belongs to.

B<NamespacePath> - Optional, the value is a CIM::NamespacePath instance.
If given, the objectname instance is a Object-, (Local)Class-, or 
(Local)Instance Path, depending on it's convert type.
If not given, the objectname is a Class- or Instance Name.

B<KeyBindings> - Optional, value is a hash reference pointing to a hash
of one or more key bindings.
Only one of the options KeyBindings and SingleKeyValue may be given.

B<SingleKeyValue> - Optional, value is either a string (-> KEYVALUE) or 
a CIM::ObjectName (-> VALUE.REFERENCE).
Only one of the options KeyBindings and SingleKeyValue may be given.

B<ConvertType> - The XML convert type. Optional, but should be given anyway
or toXML() won't work.
If not set directly, you can do it later using the convertType function 
(before you call toXML()).
Valid convert types are B<CLASSNAME>, B<INSTANCENAME>, B<OBJECTPATH-CLASSNAME>,
B<OBJECTPATH-INSTANCENAME>. 



=head1 METHODS

=item _init([OPTIONS])

Called only by new(). Initialization of class variables.

=item objectName(['someName'])

Get/set accessor for the object name.
Input: optional, string.
Return value: string, name of the object name instance.

=item namespacePath([$namespacePath_Obj])

Get/set accessor for the namespace path.
Input: optional, CIM::NamespacePath object.
Return value: CIM::NamespacePath object.

=item keyBindings([$hashRef])

Get/set accessor for the keyBindings.
Input: optional, hash reference with the names of the keyproperties as keys 
and their values (string or reference to a CIM value object) as values of 
the hash (e.g. { Login => 'jdoe' }).
Return value: hash reference 

=item addKeybinding($key, $value)

Adds a new key binding to the keyBindings hash.
Called with two arguments, a key and a value.
No return value.

=item singleKeyValue([$value])

Get/set accessor for a single key value or value reference.
Return value: string or reference to a CIM value object.

=item deleteKeyBindings()

Deletes all key bindings (or key values resp. value references).
No return value.

=item valueByKey($key)

Returns the value from the given name of the keyproperty (string) if such 
a keybinding exists, else the value from an empty key if that exists, 
undef else.
(Single key values and value references are stored with an empty key.)

=item convertType([ { CLASSNAME | INSTANCENAME | OBJECTPATH-CLASSNAME |
OBJECTPATH-INSTANCENAME} ])

Get/set accessor for the convertType.  Valid convert types are
B<CLASSNAME>, B<INSTANCENAME>, B<OBJECTPATH-CLASSNAME>, 
B<OBJECTPATH-INSTANCENAME>. To call the toXML() function a valid 
XML convert type is mandatory.

=item toXML()

Returns a XML::DOM document representation of the instance.

=item fromXML($node)

Creates an instance from the XML::DOM::Element $node and returns it.
Not inherited, function from CIM::Base is overloaded.

=item toString()

Returns an ObjectName instance as a single string of the format:
Path:ObjectName.keyBinding=keyValue



=head1 SEE ALSO

L<CIM::Base>, L<CIM::NamespacePath>, L<CIM::Class>, L<CIM::Instance>



=head1 AUTHORS

 Axel Miesen <miesen@ID-PRO.de>
 Volker Moell <moell@gmx.de>
 Eva Bolten <bolten@ID-PRO.de>


=head1 COPYRIGHT

Copyright (c) 2000 ID-PRO Deutschland GmbH. All rights reserved.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307,
USA.

=cut
