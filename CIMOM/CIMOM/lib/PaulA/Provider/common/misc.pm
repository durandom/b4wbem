use strict;

use CIM::Error;

sub _readDomainName {
    my ($self) = @_;
    
    my $cimom = $self->{_CIMOMHandle};

    my $on = CIM::ObjectName->new(ObjectName  => "PaulA_MTA",
				  ConvertType => "INSTANCENAME");

    my $val = CIM::Value->new(Value => "MyDomain",
			      Type  => "string");
    
    my $obj; 
    eval { ($obj) = $cimom->invokeIMethod(scalar $self->{_namespacePath},
					  "GetProperty",
					  InstanceName => $on,
					  PropertyName => $val, 
					 ) };
    
    if ($@) {
        PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED,
			       "GetProperty failed: $@");
    }
    
    return $obj->value;
}

sub _enumerateInstanceNames {
    my ($self, $className) = @_;
    
    my $cimom = $self->{_CIMOMHandle};

    my $on = CIM::ObjectName->new(ObjectName  => $className,
                                  ConvertType => 'INSTANCENAME');

    my @in;
    eval { @in = $cimom->invokeIMethod(scalar $self->{_namespacePath},
                                           "EnumerateInstanceNames",
                                           ClassName => $on,
                                          ) };
    if ($@) {
	PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED,
			       "EnumerateInstanceNames failed: $@");
    }
    return  @in;
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
