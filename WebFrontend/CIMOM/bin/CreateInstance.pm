use strict;

use common;


#
# CreateInstance tests
#

sub _createInstance {
    my ($className, $propertyList, $onlyHeader) = @_;
    
    return "CreateInstance $className"
	if $onlyHeader;
    
    
    my $instance = CIM::Instance->new(ClassName => $className,
				      Property  => $propertyList);
    
    my $in;
    
    eval { $in = $cc->CreateInstance(NewInstance => $instance) };
    
    if ($@) {
	print $@, "\n";
    }
    else {
	cpprint $in->toXML->toString;
    }
}


# ---------------------------------------------------------------------------

my @properties;

push @properties,
    CIM::Property->new(Name  => 'Login',
		       Type  => 'string',
		       Value => CIM::Value->new(Value => 'cbrown',
						Type  => 'string')),
    CIM::Property->new(Name  => 'RealName',
		       Type  => 'string',
		       Value => CIM::Value->new(Value => 'Charly Brown',
						Type  => 'string')),
    CIM::Property->new(Name  => 'Foo',
		       Type  => 'string',
		       Value => CIM::Value->new(Value => 'Bar',
						Type  => 'string')),
    CIM::Property->new(Name  => 'LoginShell',
		       Type  => 'string',
		       Value => CIM::Value->new(Value => 'perl',
						Type  => 'string'))
		       ;


# ---------------------------------------------------------------------------


sub test1 {
    my ($args) = @_;
    
    _createInstance('PaulA_User', \@properties,
		    (@_ ? 1 : 0));
}


# ---------------------------------------------------------------------------


sub test99 {
    my ($args) = @_;
    
    _createInstance('Invalid', [],
		    (@_ ? 1 : 0));
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
