use strict;

use CIM::Utils;
use common;


#
# GetClass tests
#

sub test1 {
    my $classname = 'PaulA_User';
    return "GetClass($classname) with default settings"
	if @_;
    
    
    my $on = CIM::ObjectName->new(ObjectName => $classname);
    my $class;
    
    eval { $class = $cc->GetClass(ClassName => $on) };

    if ($@) {
	print $@, "\n";
    } else {
	cpprint $class->toXML->toString;
    }
}


sub test2 {
    my $classname = 'CIM_CollectedCollections';
    return "GetClass($classname) with default settings, class is an Association"
	if @_;

    
    my $on = CIM::ObjectName->new(ObjectName => $classname);
    my $class;
    
    eval { $class = $cc->GetClass(ClassName => $on) };

    if ($@) {
	print $@, "\n";
    } else {
	cpprint $class->toXML->toString;
	print "\nThe class \"$classname\" is an association!\n" 
	    if $class->isAssociation();
    }
}


sub test3 {
    my $classname = 'CIM_ManagedSystemElement';
    return "GetClass($classname) with no qualifiers included in response"
	if @_;
    
    
    my $on = CIM::ObjectName->new(ObjectName => $classname);
    my $class;
    
    eval { $class = $cc->GetClass(ClassName         => $on,
				  IncludeQualifiers => 0,
				 ) };

    if ($@) {
	print $@, "\n";
    } else {
	cpprint $class->toXML->toString;
    }
}



sub test4 {
    my $classname = 'CIM_ManagedSystemElement';
    return "GetClass($classname) with no properties included in response"
	if @_;
    
    
    my $on = CIM::ObjectName->new(ObjectName => $classname);
    my $class;
    
    eval { $class = $cc->GetClass(ClassName    => $on,
				  PropertyList => [ ],
				 ) };

    if ($@) {
	print $@, "\n";
    } else {
	cpprint $class->toXML->toString;
    }
}


sub test5 {
    my $classname = 'CIM_ManagedSystemElement';
    return "GetClass($classname) with PropertyList ['Status', 'Name']"
	if @_;
    
    
    my $on = CIM::ObjectName->new(ObjectName => $classname);
    my $class;
    eval { $class = $cc->GetClass(ClassName    => $on,
				  PropertyList => [ 'Status', 'Name' ],
				 ) };

    if ($@) {
	print $@, "\n";
    } else {
	cpprint $class->toXML->toString;
    }
}


sub test6 {
    my $classname = 'CIM_ManagedSystemElement';
    return "GetClass($classname) with unknown Property in PropertyList"
	if @_;
    
    
    my $on = CIM::ObjectName->new(ObjectName => $classname);
    my $class;
    
    eval { $class = $cc->GetClass(ClassName    => $on,
				  PropertyList => [ 'Foo' ],
				 ) };

    if ($@) {
	print $@, "\n";
    } else {
	cpprint $class->toXML->toString;
    }
}


sub test7 {
    my $classname = 'CIM_ManagedSystemElement';
    return "GetClass($classname) return Property 'Name' only/no Qualifiers"
	if @_;
    
    
    my $on = CIM::ObjectName->new(ObjectName => $classname);
    my $class;
    
    eval { $class = $cc->GetClass(ClassName         => $on,
				  IncludeQualifiers => 0,
				  PropertyList      => [ 'Name' ],
				 ) };

    if ($@) {
	print $@, "\n";
    } else {
	cpprint $class->toXML->toString;
    }
}

sub test8 {
    return "GetClass(Foo_Bar), unknown class"
	if @_;
    
    my $on = CIM::ObjectName->new(ObjectName => 'Foo_Bar');
    my $class;
    
    eval { $class = $cc->GetClass(ClassName => $on); };

    if ($@) {
	print $@, "\n";
    } else {
	print "*** This message should not appear! ***\n";
    }
}


1;

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
