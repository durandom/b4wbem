use strict;

############################################
package PaulA::Provider::test::PaulA_System;
############################################
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
    my ($self, $pLogin, $pRealName, $pPassword, $pPaulAGroup) = @_;

    my ($login, $realname, $password, $paulagroup);
    
    $login = $pLogin->value->value
	if defined $pLogin->value;
    
    $realname = defined $pRealName->value ? $pRealName->value->value : "";
    
    $password = $pPassword->value->value
	if defined $pPassword->value;
    
    $paulagroup = $pPaulAGroup->value->value
	if defined $pPaulAGroup->value;
    
    # Error on invalid or insufficient parameters
    unless (defined $login and defined $password and defined $paulagroup) {
	return CIM::Value->new(Type  => 'boolean',
			       Value => 0);
    }
    
    magenta("Creating User: $login ($realname, $password, $paulagroup)");
    
    my $homedir = "/home/$login";
    
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
    
    # /etc/passwd
    {
	my $crypt = crypt($password, "XY");
	
	my $file = $self->sandbox() . "/files/passwd";
	open FILE, ">> $file";
	print FILE "$login:$crypt:666:100::x:/bin/false\n";
	close FILE;
    }
    
    # add group
    {
	my $className = 'PaulA_User';
	my $keyBindings = { Login => $login };
	my $on = CIM::ObjectName->new(ObjectName  => $className,
				      KeyBindings => $keyBindings,
				      ConvertType => 'CLASSNAME');
	my $propertyList =
	    [
	     CIM::Property->new(Name  => 'PaulAGroups',
				Type  => 'string',
				Value =>
				CIM::Value->new(Value => [ $paulagroup ],
						Type  => 'string')),
	     CIM::Property->new(Name  => 'RealName',
				Type  => 'string',
				Value => CIM::Value->new(Value => $realname,
							 Type  => 'string')),
	     CIM::Property->new(Name  => 'HomeDirectory',
				Type  => 'string',
				Value => CIM::Value->new(Value => $homedir,
							 Type  => 'string')),
	    ];
	my $instance = CIM::Instance->new(ClassName => $className,
					  Property  => $propertyList);
	my $vo = CIM::ValueObject->new(ObjectName => $on,
				       Object     => $instance);
	eval { $cimom->invokeIMethod(scalar $self->{_namespacePath},
				     "ModifyInstance",
				     ModifiedInstance => $vo,
				    ) };
	if ($@) {
	    PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED,
				   "ModifyInstance failed: $@");
	}
    }
    # create homedir
    my $homedir = $self->sandbox . "/files/home/$login";
    my $status = system("mkdir $homedir"); 
    PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED,
	    "creation of homedir failed, exit code $status")
	    if $status;
    
    return CIM::Value->new(Type  => 'boolean', Value => 1);
}

sub classMethod_DeleteUser {
    my ($self, $pLogin) = @_;
    
    my $login = $pLogin->value->value;
    magenta("Deleting User: $login");

    # remove user from paula groups
    my $className = 'PaulA_User';
    my $keyBindings = { Login => $login };
    my $on = CIM::ObjectName->new(ObjectName  => $className,
				  KeyBindings => $keyBindings,
				  ConvertType => 'INSTANCENAME');
    
    my $newVal = CIM::Value->new(Value => [ ],
				 Type  => 'string');

    my $propName =  CIM::Value->new(Value => 'PaulAGroups',
				    Type  => 'string');

    my $obj;
    my $cimom = $self->{_CIMOMHandle};
    eval { $cimom->invokeIMethod(scalar $self->{_namespacePath},
				 "SetProperty",
				 InstanceName  => $on,
				 PropertyName => $propName,
				 NewValue => $newVal,
				) };
    if ($@) {
	PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED,
			       "SetProperty failed: $@");
    }
    
    # delete home dir 
    my $homedir = $self->sandbox . "/files/home/$login";
    
    my $status1 = system("rm -rf $homedir");
    
    PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED,
			   "removal of homedir failed, exit code $status1")
	  if $status1;
    
    # delete line in passwd 
    my $passwd = $self->sandbox . "/files/passwd";
    
    my $status2 = system("perl -n -i -e \"print unless /^$login:/;\" $passwd");
    PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED,
			   "deleting line in passwd failed, exit code $status2")
	  if $status2;
    
    
    my $result = 1;
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
