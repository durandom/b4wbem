use strict;

#############################################
package PaulA::Provider::PaulA::PaulA_System;
#############################################
use Carp;

use base qw(PaulA::Provider);

use CIM::Utils;
use CIM::Error;

do "PaulA/Provider/common/shells.pm";

sub new {
    my ($class, %args) = @_;
    
    my $self = $class->SUPER::new(%args);
    
    return $self;
}


###################### objectMethod_*/classMethod_* #######################

sub classMethod_CreateUser {
    my ($self, $paramLogin, $paramRealName, $paramPassword,
	$paramPaulAGroup) = @_;
    
    my $login      = $paramLogin->value->value;
    my $realname   = $paramRealName->value->value || "";
    my $password   = $paramPassword->value->value;
    my $paulagroup = $paramPaulAGroup->value->value;

    unless (defined $login and defined $password and defined $paulagroup) {
	return CIM::Value->new(Type  => 'boolean',
			       Value => 0);
    }
    
    magenta("Creating User: $login ($realname, $password, $paulagroup)");


    my $cimom = $self->{_CIMOMHandle};

    # check if user exists
    {
	my @in;
	my $on = CIM::ObjectName->new(ObjectName => 'PaulA_User',
				      ConvertType => 'CLASSNAME');
	eval { @in = $cimom->invokeIMethod(scalar $self->{_namespacePath},
					   "EnumerateInstanceNames",
					   ClassName => $on,
					  ) };
	if ($@) {
	    PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED,
				   "EnumerateInstanceNames failed: $@");
	}
	my %users;
	foreach (map { $_->valueByKey('Login') } @in) {
	    $users{$_} = 1;
	}
	
	if (exists $users{$login}) {
	    red("CreateUser: User $login already exists.");
	    return CIM::Value->new(Type  => 'boolean', Value => 0);
	}
    }

    system("useradd -p " . crypt($password, "XY") .
	   " $login -c '$realname'  -G $paulagroup");
    
    my $result = (($? >> 8) == 0);
    
    return CIM::Value->new(Type  => 'boolean',
			   Value => $result);
}

sub classMethod_DeleteUser {
    my ($self, $paramLogin) = @_;
    
    my $login = $paramLogin->value->value;
    magenta("Deleting User: $login");
    
    system("userdel -r $login");
    
    my $result = (($? >> 8) == 0);
    
    return CIM::Value->new(Type  => 'boolean',
			   Value => $result);
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
