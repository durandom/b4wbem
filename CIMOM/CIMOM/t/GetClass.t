use strict;
use lib "t";
use common;


# Defaults:
# ---------
# LocalOnly => 1
# IncludeQualifiers => 1
# IncludeClassOrigin => 0

my $classname = 'CIM_Collection';

# test 1
# defaults 
{
     my $compare = '<CLASS NAME="CIM_Collection" SUPERCLASS="CIM_ManagedElement"><QUALIFIER NAME="Abstract" TYPE="boolean" TOSUBCLASS="false"><VALUE>TRUE</VALUE></QUALIFIER><QUALIFIER NAME="Description" TYPE="string" TOSUBCLASS="false"><VALUE>Collection is an abstract class that provides a commonsuperclass for data elements that represent collections of ManagedElements and its subclasses.</VALUE></QUALIFIER><PROPERTY NAME="Caption" PROPAGATED="true" TYPE="string"/><PROPERTY NAME="Description" PROPAGATED="true" TYPE="string"/></CLASS>' . "\n";
    
    my $on = CIM::ObjectName->new(ObjectName => $classname);

    my $class;
    eval { $class = $cc->GetClass(ClassName         => $on,
				  ) };

    print STDERR $@;
    assert(!$@ && $class->toXML->toString eq $compare);
    
}

# test2
# don't return qualifiers in the response
{

    my $compare = '<CLASS NAME="CIM_Collection" SUPERCLASS="CIM_ManagedElement"><PROPERTY NAME="Caption" PROPAGATED="true" TYPE="string"/><PROPERTY NAME="Description" PROPAGATED="true" TYPE="string"/></CLASS>' . "\n";

    my $on = CIM::ObjectName->new(ObjectName => $classname);
    my $class;

    eval { $class = $cc->GetClass(ClassName         => $on,
                                  IncludeQualifiers => 0,
                                 ) };

    print STDERR $@;
    assert(!$@ && $class->toXML->toString eq $compare);
}

# test3
# return a class with empty propertyList
{
    my $compare = '<CLASS NAME="CIM_Collection" SUPERCLASS="CIM_ManagedElement"><QUALIFIER NAME="Abstract" TYPE="boolean" TOSUBCLASS="false"><VALUE>TRUE</VALUE></QUALIFIER><QUALIFIER NAME="Description" TYPE="string" TOSUBCLASS="false"><VALUE>Collection is an abstract class that provides a commonsuperclass for data elements that represent collections of ManagedElements and its subclasses.</VALUE></QUALIFIER></CLASS>' . "\n";

    my $on = CIM::ObjectName->new(ObjectName => $classname);
    my $class;

    eval { $class = $cc->GetClass(ClassName    => $on,
                                  PropertyList => [ ],
                                 ) };
    print STDERR $@;
    assert(!$@ && $class->toXML->toString eq $compare);

}

# test4
# return a class with PropertyList ['Caption']"
{
    my $compare = '<CLASS NAME="CIM_Collection" SUPERCLASS="CIM_ManagedElement"><QUALIFIER NAME="Abstract" TYPE="boolean" TOSUBCLASS="false"><VALUE>TRUE</VALUE></QUALIFIER><QUALIFIER NAME="Description" TYPE="string" TOSUBCLASS="false"><VALUE>Collection is an abstract class that provides a commonsuperclass for data elements that represent collections of ManagedElements and its subclasses.</VALUE></QUALIFIER><PROPERTY NAME="Caption" PROPAGATED="true" TYPE="string"/></CLASS>' ."\n";

    my $on = CIM::ObjectName->new(ObjectName => $classname);
    my $class;
    eval { $class = $cc->GetClass(ClassName    => $on,
                                  PropertyList => [ 'Caption' ],
                                 ) };

    print STDERR $@;
    assert(!$@ && $class->toXML->toString eq $compare);

}

# test5
# with an unknown property in PropertyList
{
    my $compare = '<CLASS NAME="CIM_Collection" SUPERCLASS="CIM_ManagedElement"><QUALIFIER NAME="Abstract" TYPE="boolean" TOSUBCLASS="false"><VALUE>TRUE</VALUE></QUALIFIER><QUALIFIER NAME="Description" TYPE="string" TOSUBCLASS="false"><VALUE>Collection is an abstract class that provides a commonsuperclass for data elements that represent collections of ManagedElements and its subclasses.</VALUE></QUALIFIER></CLASS>' . "\n";

    my $on = CIM::ObjectName->new(ObjectName => $classname);
    my $class;

    eval { $class = $cc->GetClass(ClassName    => $on,
                                  PropertyList => [ 'Foo' ],
                                 ) };

    print STDERR $@;
    assert(!$@ && $class->toXML->toString eq $compare);
}

# test6
# with no properties and no qualifiers
{
    my $compare = '<CLASS NAME="CIM_Collection" SUPERCLASS="CIM_ManagedElement"/>' . "\n";

    my $on = CIM::ObjectName->new(ObjectName => $classname);
    my $class;

    eval { $class = $cc->GetClass(ClassName         => $on,
                                  IncludeQualifiers => 0,
                                  PropertyList      => [ ],
                                 ) };

    print STDERR $@;
    assert(!$@ && $class->toXML->toString eq $compare);
}

# test7 
# trying to get a nonexistent class
{
    my $on = CIM::ObjectName->new(ObjectName => 'Foo_Bar');
    my $class;

    eval { $class = $cc->GetClass(ClassName => $on); };

    assert($@->code == 5);
}

# test 8
# Association class, defaults
{
    $classname = 'CIM_CollectedCollections';

    my $on = CIM::ObjectName->new(ObjectName => $classname);
    my $class;

    eval { $class = $cc->GetClass(ClassName => $on) };

    print STDERR $@;
    assert(!$@ && $class->isAssociation);
}

# test 9
# class with Methods, defaults
{
    $classname = 'CIM_TapeDrive';

    my $on = CIM::ObjectName->new(ObjectName => $classname);
    my $class;
    eval { $class = $cc->GetClass(ClassName => $on) };

    print STDERR $@;
    assert(!$@ && defined $class);
}


# test 10
# PaulA_* class
{
    $classname = 'PaulA_User';

    my $on = CIM::ObjectName->new(ObjectName => $classname);
    my $class;
    eval { $class = $cc->GetClass(ClassName => $on) };

    print STDERR $@;
    assert(!$@ && defined $class);
}



BEGIN { $numOfTests = 10; print "$numOfTests\n"; }


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
