use strict;
use CIM::Error;


############################## Get ###########################################


#################
sub GetProperty {
    my ($self, %args) = @_;
    
    my $on = $args{InstanceName};
    
    # check for errors
    die CIM::Error->new(Code => CIM::Error::CIM_ERR_INVALID_PARAMETER)
	unless defined $args{InstanceName};
    die CIM::Error->new(Code => CIM::Error::CIM_ERR_INVALID_PARAMETER)
	unless defined $args{PropertyName};
    die CIM::Error->new(Code => CIM::Error::CIM_ERR_NOT_FOUND)
	unless $self->objectExists($on->keyBindings);
    
    # ok from here
    my $classname = $on->objectName;
    $self->_analyzeObjectName($on);
    
    # create and check _propertyList
    my $propertyName = $args{PropertyName}->value;
    $self->{_propertyList} = [ $propertyName ];
    die CIM::Error->new(Code => CIM::Error::CIM_ERR_NO_SUCH_PROPERTY)
	unless defined $self->{_classInfo}->{$propertyName};
    
    # read properties
    $self->_processProperties(InOutMode => 'IN');
    
    # if exists: create return value and return it
    if (defined $self->{_readValues}->{$propertyName}) {
	my $value = $self->{_readValues}->{$propertyName};
	my $type = $self->{_classInfo}->{$propertyName}{CIMTYPE};
	return CIM::Value->new(Value => $value,
			       Type  => $type);
    }
    
    # else: return nothing
    return;
}


#################
sub GetInstance {
    my ($self, %args) = @_;
    
    my $on = $args{InstanceName};
    
    # check for errors
    die CIM::Error->new(Code => CIM::Error::CIM_ERR_INVALID_PARAMETER)
	unless defined $args{InstanceName};
    die CIM::Error->new(Code => CIM::Error::CIM_ERR_NOT_FOUND)
  	unless $self->objectExists($on->keyBindings);
    
#      my @xx = keys %{$self->{_classInfo}};
#      magenta(present(\@xx));
#      die CIM::Error->new(Code => 13);
    
    # ok from here
    my $classname = $on->objectName;
    $self->_analyzeObjectName($on);
    
    # create and check _propertyList
    if (defined $args{PropertyList}) {
	$self->{_propertyList} = [];
	foreach my $value ($args{PropertyList}->value) {
	    push @{$self->{_propertyList}}, $value
		if defined $self->{_classInfo}{$value};
	}
    }
    else {
	@{$self->{_propertyList}} = keys %{$self->{_classInfo}};
    }
    my @propertyList = sort @{$self->{_propertyList}};
    
    # read properties
    $self->_processProperties(InOutMode => 'IN');
    
    # create return value and return it
    my @properties;
    foreach my $p_id (@propertyList) {
	my $value = $self->{_readValues}->{$p_id};
	my $type = $self->{_classInfo}->{$p_id}{CIMTYPE};
	
	if (defined $value) {
	    my $cv = CIM::Value->new(Value => $value,
				     Type  => $type);
	    push @properties, CIM::Property->new(Name  => $p_id,
						 Value => $cv);
	}
	else {
	    push @properties, CIM::Property->new(Name => $p_id,
						 Type => $type);
	}
    }
    my $instance =
	CIM::Instance->new(ClassName => scalar $self->{_className});
    
    if (@properties) {
	$instance->addProperties(@properties);
    }
    
    return $instance;
}


############################## Set/Modify ####################################


#################
sub SetProperty {
    my ($self, %args) = @_;
    
    my $on = $args{InstanceName};
    
    # check for errors
    die CIM::Error->new(Code => CIM::Error::CIM_ERR_INVALID_PARAMETER)
	unless defined $args{PropertyName};
    die CIM::Error->new(Code => CIM::Error::CIM_ERR_INVALID_PARAMETER)
	unless defined $args{InstanceName};
    die CIM::Error->new(Code => CIM::Error::CIM_ERR_NOT_FOUND)
	unless $self->objectExists($on->keyBindings);
    
    # ok from here
    my $classname = $on->objectName;
    $self->_analyzeObjectName($on);
    
    # create and check _propertyList
    my $propertyName = $args{PropertyName}->value;
    $self->{_propertyList} = [ $propertyName ];
    die CIM::Error->new(Code => CIM::Error::CIM_ERR_NO_SUCH_PROPERTY)
	  unless defined $self->{_classInfo}{$propertyName};
    
    # create _valueList
    $self->{_valueList} = { "$propertyName" => $args{NewValue} };
    
    # read properties
    $self->_processProperties(InOutMode => 'IN');
    
    # just for testing
    my $newValue =
	(defined $args{NewValue} ? $args{NewValue}->valueAsRef : undef);
    black("  Old: " . present($self->{_readValues}->{$propertyName}));
    black("  New: " . present($newValue));
    
    # write properties
    $self->_processProperties(InOutMode => 'OUT');
    
    # (no return value)
}


####################
sub ModifyInstance {
    my ($self, %args) = @_;
    
    my $ni = $args{ModifiedInstance};
    my $on = $ni->objectName;
    
    # check for errors
    die CIM::Error->new(Code => CIM::Error::CIM_ERR_INVALID_PARAMETER)
	unless defined $args{ModifiedInstance};
    die CIM::Error->new(Code => CIM::Error::CIM_ERR_NOT_FOUND)
	unless $self->objectExists($on->keyBindings);
    
    # ok from here
    my $classname = $on->objectName;
    $self->_analyzeObjectName($on);
    
    # create _valueList and _propertyList
    undef $self->{_valueList};
    undef $self->{_propertyList};
    foreach my $prop (@{$ni->object->properties}) {
	my $p_id = $prop->name;
	next unless exists $self->{_classInfo}->{$p_id};
	
	push @{$self->{_propertyList}}, $p_id;
	$self->{_valueList}->{$p_id} = $prop->value;
    }
    
    # read properties
    $self->_processProperties(InOutMode => 'IN');
    
    # just for testing...
    foreach my $p_id (keys %{$self->{_readValues}}) {
	black("  Old: " . present($self->{_readValues}->{$p_id}));
	black("  New: " . present($self->{_valueList}->{$p_id}));
    }
    
    # write properties
    $self->_processProperties(InOutMode => 'OUT');
    
    # (no return value)
}


############################## Enumerate #####################################


########################
sub EnumerateInstances {
    my ($self, %args) = @_;
    
    # ok from here
    my $on = $args{ClassName};
    my $classname = $on->objectName;
    
    # read instance names
    my @in = $self->EnumerateInstanceNames(ClassName => $on);
    
    # create return value and return it
    my @instances;
    for my $in (@in) {
	my $keyBindings = $in->keyBindings;
	
        my $on = CIM::ObjectName->new(ObjectName  => $classname,
				      ConvertType => 'INSTANCENAME',
				      KeyBindings => $keyBindings);
        my $i = $self->GetInstance(InstanceName => $on,
                                   %args);                      # hmmm...(?)
        my $ni = CIM::ValueObject->new(ObjectName => $on,
                                       Object     => $i);
        push @instances, $ni;
    }
    return @instances;
}


############################
sub EnumerateInstanceNames {
    my ($self, %args) = @_;
    
    # ok from here
    my $on = $args{ClassName};
    my $classname = $on->objectName;
    $self->_setClassInfo($on);
    
    # create _propertyList
    $self->{_propertyList} = [ 'KEYBINDINGS' ];
    
    # read instance names
    $self->_processProperties(InOutMode => 'IN');
    
    # create return value and return it
    my @in;
    foreach my $keyBindings (@{$self->{_readValues}->{KEYBINDINGS}}) {
	my $in = CIM::ObjectName->new(ObjectName  => $classname,
				      KeyBindings => $keyBindings,
				      ConvertType => 'INSTANCENAME');
	push @in, $in;
    }
    return @in;
}

    
############################## Create/Delete #################################


####################
sub CreateInstance {
    my ($self, %args) = @_;
    
    # ok from here
    my $instance = $args{NewInstance};
    my $classname = $instance->className;
    
    # set ObjectName, _keyBindings, _valueList, _propertyList
    my $on = CIM::ObjectName->new(ObjectName  => $classname,
				  ConvertType => 'CLASSNAME');
    $self->_setClassInfo($on);
    
    my $keyBindings;
    foreach my $prop (@{$instance->properties}) {
	my $p_id = $prop->name;
	next unless exists $self->{_classInfo}->{$p_id};
	
	my $value = $prop->value;
	$keyBindings->{$p_id} = $value->valueAsRef;
	push @{$self->{_propertyList}}, $p_id;
	$self->{_valueList}->{$p_id} = $value;
    }
    $self->_setKeyBindings($keyBindings);
    $keyBindings = $self->{_keyBindings};
    #$self->_checkValueList(); #?!
    
    #mark(present(scalar $self->{_valueList}));
    
    $on->keyBindings($keyBindings);   # VM: mglw. unnoetig
    mark($on);
    
    # read properties
#      $self->_processProperties(InOutMode => 'OUT',
#  			      Flag      => 'CREATE');
    
    error(CIM::Error::CIM_ERR_NOT_SUPPORTED,
	  "CreateInstance not yet supported");
}


####################
sub DeleteInstance {
    my ($self, %args) = @_;
    
    error(CIM::Error::CIM_ERR_NOT_SUPPORTED,
	  "DeleteInstance not yet supported");
}


1;


__END__

=head1 NAME

PaulA::ProviderIMethods - Part of PaulA::Provider



=head1 SYNOPSIS

 (...)


=head1 DESCRIPTION

 (...)


=head1 METHODS

Internal functions will be described later.

The following Intrinsic-Method functions are supported so far:

=item GetProperty()

=item GetInstance()

=item SetProperty()

=item ModifyInstance()

=item EnumerateInstances()

=item EnumerateInstanceNames()



=head1 SEE ALSO

L<PaulA::Provider>



=head1 AUTHOR

 Volker Moell <moell@gmx.de>



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
