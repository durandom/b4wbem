use strict;

###########################
package CIM::ValueObject;
###########################
use Carp;

use base qw(CIM::Base);


sub new {
    my ($class, %args) = @_;
    
    my $self = $class->SUPER::new();

    $self->{'CIM::ValueObject::_objectName'} = undef;
    $self->{'CIM::ValueObject::_object'} = undef;
    $self->{'CIM::ValueObject::_isNamedObject'} = undef;
   
    $self->{_identifier} = 'CIMValueObject';

    $self->{_childAccessors} = {
				INSTANCE	    => 'object',
				CLASS               => 'object',
				INSTANCENAME	    => 'objectName',
				INSTANCEPATH	    => 'objectName',
				CLASSPATH	    => 'objectName',
				LOCALINSTANCEPATH   => 'objectName',
				LOCALCLASSPATH	    => 'objectName',
			       };
    
    $self->processArgs(%args);
    
    return $self;
}


sub _init {
    my ($self, %args) = @_;

    fatal("No Object") unless exists $args{Object};
    
    $self->{_objectName} = $args{ObjectName} 
	    if defined $args{ObjectName};
    
    $self->{_object}   = $args{Object};
    
    $self->{_isNamedObject} = 
	(defined $args{IsNamedObject})? $args{IsNamedObject} : 0;
}


sub objectName {
    my $self = shift;

    $self->{_objectName} = $_[0] if defined $_[0];
    return $self->{_objectName};
}

sub object {
    my $self = shift;

    $self->{_object} = $_[0] if defined $_[0];
    return $self->{_object};
}

sub className {
    my $self = shift;
    
    return $self->{_objectName}->objectName() if defined $self->{_objectName};

    return undef;
}

sub isNamedObject {
    my $self = shift;

    $self->{_isNamedObject} = $_[0] if defined $_[0];
    return $self->{_isNamedObject};
}	 

sub toXML {
    my $self = shift;
    
    my $doc = XML::DOM::Document->new();
    
    my $tag;
    if (defined $self->{_objectName}) {
	if (defined $self->{_objectName}->namespacePath) {
	    if (defined $self->{_objectName}->namespacePath->host) {
		$tag = 'VALUE.OBJECTWITHPATH';
	    }
	    else {
		$tag = 'VALUE.OBJECTWITHLOCALPATH';
	    }
	}
	# VALUE.NAMEDINSTANCE or VALUE.NAMEDOBJECT, both with an Instance
	elsif ($self->{_isNamedObject}) {
	    $tag = 'VALUE.NAMEDOBJECT';
	}
	else {
	    $tag = 'VALUE.NAMEDINSTANCE';	    
	}
    }

    elsif (ref $self->{_object} eq 'CIM::Instance') {
	$tag = 'VALUE.OBJECT';	# VALUE.OBJECT with Instance
    }
    # VALUE.NAMEDOBJECT or VALUE.OBJECT, both with a Class
    elsif ($self->{_isNamedObject}) {
	$tag = 'VALUE.NAMEDOBJECT';
    }
    else {
	$tag = 'VALUE.OBJECT';	# VALUE.OBJECT with Class
    }


    my $vni = $doc->createElement($tag);
    
    if (defined $self->{_objectName}) {
	my $on = $self->{_objectName}->toXML;
	$on->getDocumentElement()->setOwnerDocument($doc);
	$vni->appendChild($on->getDocumentElement());
    }

    my $i = $self->{_object}->toXML;
    $i->getDocumentElement()->setOwnerDocument($doc);
    $vni->appendChild($i->getDocumentElement());
    
    $doc->appendChild($vni);
    
    return $doc;
}


# fromXML() completely inherited from CIM::Base


sub toString {
    my $self = shift;
    my $text =  "CIMValueObject:\n " 
		. "CIMObjectName: "   
		. $self->{_objectName}->toString() . "\n " 
		. $self->{_object}->toString() . "\n";
    
    return $text;
}

1;


__END__

=head1 NAME

CIM::ValueObject - a represents several CIM XML value elements. 


=head1 SYNOPSIS

 use CIM::ValueObject;

 $vo = CIM::ValueObject->new( ObjectName    => $on,
                              Object	    => $i,
			      );

 $doc = $vo->toXML();
 $vo2 = CIM::ValueObject->new( XML => $doc);


=head1 DESCRIPTION

CIM::ValueObject - a representation of the following CIM XML elements: 

 VALUE.NAMEDINSTANCE
 VALUE.NAMEDOBJECT
 VALUE.OBJECT
 VALUE.OBJECTWITHLOCALPATH
 VALUE.OBJECTWITHPATH

A CIM::ValueObject just a container for a CIM ObjectName (optional) 
and a CIM Object (CIM Class or Instance).
Which kind of XML element is represented by a CIM::ValueObject instance
depends on the elements provided (or not provided) as object name and 
object. Only in the case you want a VALUE.NAMEDOBJECT a flag has to be 
set. 


=head1 CONSTRUCTOR

=over 4

=item new([OPTIONS])

C<OPTIONS> are passed in a hash like fashion, using key and value pairs.
The possible options are:

B<XML> - Read the instance from the given XML::DOM element or document. 
Only used as sole option. If additional options are given they
will be ignored.

B<Object> - A CIM::Instance or CIM::Class.
Mandatory unless B<XML> is given.

B<ObjectName> - A CIM::ObjectName instance, the name or path part of the 
CIM query. Optional.

B<IsNamedObject> - Flag needed for the distinction between VALUE.NAMEDOBJECT 
and VALUE.OBJECT or VALUE.NAMEDINSTANCE, respectively. Optional, boolean, 
default is 0.


=head1 METHODS

=item _init([OPTIONS])

Called only by new(). Initialization of class variables.

=item objectName([$on])

Get/set accessor for the object name part of the ValueObject.
Input: optional, CIM::ObjectName object.
Return value: CIM::ObjectName object.

=item object([$obj])

Sets and/or returns the object part of the ValueObject.

=item className()

If the ObjectName part is a CIM instance name or path, this function returns 
the class name of the class the instance belongs to, else undef.

=item isNamedObject([{ 0 | 1 }])

Get/set accessor for the isNamedObject flag.
Return value: boolean.
    
=item toXML()

Returns a XML::DOM document representation of the instance.

=item fromXML($node)

Creates an instance from the XML::DOM::Element $node and returns it.
Completely inherited from CIM::Base.

=item toString()

Returns the instance as a string (for debugging purposes only).


=head1 SEE ALSO

L<CIM::Base>, L<CIM::ObjectName>, L<CIM::Instance>, L<CIM::Class>




=head1 AUTHOR

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
