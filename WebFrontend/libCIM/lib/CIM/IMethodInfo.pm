use strict;

#########################
package CIM::IMethodInfo;
#########################


sub new {
    bless {}, $_[0];
}


{
    #
    # Description of the following table:
    #
    # First Level:  The names of the intrinsic methods
    # ------------------------------------------------
    #
    # Second Level (inside an intrinsic method):
    # --------------------------------------------
    #
    #   "Parameters": Description of the parameters. Inside this hashref
    #                 the following keys can/must appear:
    #
    #     "Class": The Perl CIM Class which represents this parameter
    #
    #     "ConvertType": E.g. CIM::ObjectName is used to represent
    #                    class/instance names. (See GetClass/GetInstance.)
    #                    This key determines the conversion.
    #
    #     "Type":  The type of this parameter (not needed for "pseudo types").
    #
    #     "Default": The default value for OPTIONAL parameters. What you
    #                fill in here must be a valid parameter for 'Value'
    #                in the CIM::Value constructor.
    #
    #     "Input": An array ref that can contain the strings
    #              'NULL' (specifies that the param can have *no* value), and
    #              '@'    (param is an array of values) 
    #
    #
    #   "ReturnValue": Description of return value. Inside this hashref
    #                  the following keys can/must appear:
    #
    #     "Type": one of
    #       ''  (void)
    #       '$' (a scalar, i.e. a single object)
    #       '@' (an array of objects)
    #       '?' (no scalar or one scalar)
    #
    #     "Class": The Perl CIM Class which represents this return value
    #              TODO: NOT NEEDED???
    #
    #
    #   "Meta": Some meta informations mainly for the CIMOM. Inside
    #           this hashref the following keys can/must appear:
    #
    #     "ExtractClass": An array ref that contains at position 
    #                     0: The name parameter of the parameter from
    #                        which you can extract the class name
    #                     1..n: a list of methods which must be called to
    #                        obtain this information. If you e.g. have
    #                        ExtractClass => ['ModifiedInstance',
    #                                         'objectName',
    #                                          'objectName' ],
    #                        then you must call
    #                        $o->objectName->objectName
    #                        to extract the class name ($o is the
    #                        ExtactClass parameter)
    
    my $_table =
    {
	 ############################################################
	 ######################## Basic Read ########################
	 ############################################################
	 
	 ########
	 GetClass =>
	 ########
	 {
	     Parameters =>
	     {
		 
		 ClassName =>
		 {
		     Class       => 'CIM::ObjectName',
		     ConvertType => 'CLASSNAME',
		 },
		 
		 LocalOnly =>
		 {
		     Type    => 'boolean',
		     Class   => 'CIM::Value',
		     Default => 1,
		 },
		 
		 IncludeQualifiers =>
		 {
		     Type    => 'boolean',
		     Class   => 'CIM::Value',
		     Default => 1,
		 },
		 
		 IncludeClassOrigin =>
		 {
		     Type    => 'boolean',
		     Class   => 'CIM::Value',
		     Default => 0,
		 },
		 
		 PropertyList =>
		 {
		     Type    => 'string',
		     Class   => 'CIM::Value',
		     Input   => [ 'NULL', '@' ],
		     Default => undef,
		 },
	     },

	     ReturnValue =>
	     {
		 Type  => '$',
		 Class => 'CIM::Class',
	     },
	     
	     Meta =>
	     {
	         ExtractClass => [ 'ClassName', 'objectName' ],
	     },
	 },
	 
	 ################
	 EnumerateClasses =>
	 ################
	 {
	     Parameters =>
	     {
		 
		 ClassName =>
		 {
		     Class       => 'CIM::ObjectName',
		     Default     => undef,
		     ConvertType => 'CLASSNAME',
		 },
		 
		 DeepInheritance =>
		 {
		     Type    => 'boolean',
		     Class   => 'CIM::Value',
		     Default => 0,
		 },
		 
		 LocalOnly =>
		 {
		     Type    => 'boolean',
		     Class   => 'CIM::Value',
		     Default => 1,
		 },
		 
		 IncludeQualifiers =>
		 {
		     Type    => 'boolean',
		     Class   => 'CIM::Value',
		     Default => 1,
		 },
		 
		 IncludeClassOrigin =>
		 {
		     Type    => 'boolean',
		     Class   => 'CIM::Value',
		     Default => 0,
		 },
	     },

	     ReturnValue =>
	     {
		 Type  => '@',
		 Class => 'CIM::Class',
	     },
	     
	     Meta =>
	     {
	         ExtractClass => [ 'ClassName', 'objectName' ],
	     },
	 },
	
	 ###################
	 EnumerateClassNames =>
	 ###################
	 {
	     Parameters =>
	     {
		 ClassName =>
		 {
		     Class       => 'CIM::ObjectName',
		     Default     => undef,
		     ConvertType => 'CLASSNAME',
		 },
		 
		 DeepInheritance =>
		 {
		     Type    => 'boolean',
		     Class   => 'CIM::Value',
		     Default => 0,
		 },
	     },
	     
	     ReturnValue =>
	     {
		 Type  => '@',
		 Class => 'CIM::ObjectName',
	     },
	     
	     Meta =>
	     {
	         ExtractClass => [ 'ClassName', 'objectName' ],
	     },
	 },
	
	 ###########
	 GetInstance =>
	 ###########
	 {
	     Parameters =>
	     {
		 InstanceName =>
		 {
		     Class       => 'CIM::ObjectName',
		     ConvertType => 'INSTANCENAME',
		 },
		 
		 LocalOnly =>
		 {
		     Type    => 'boolean',
		     Class   => 'CIM::Value',
		     Default => 1,
		 },
		 
		 IncludeQualifiers =>
		 {
		     Type    => 'boolean',
		     Class   => 'CIM::Value',
		     Default => 0,
		 },
		 
		 IncludeClassOrigin =>
		 {
		     Type    => 'boolean',
		     Class   => 'CIM::Value',
		     Default => 0,
		 },
		 
		 PropertyList =>
		 {
		     Type    => 'string',
		     Class   => 'CIM::Value',
		     Input   => [ 'NULL', '@' ],
		     Default => undef,
		 },
	     },

	     ReturnValue =>
	     {
		 Type  => '$',
		 Class => 'CIM::Instance',
	     },
	     
	     Meta =>
	     {
	         ExtractClass => [ 'InstanceName', 'objectName' ],
	     },
	 },
	
	 ##################
	 EnumerateInstances =>
	 ##################
	 {
	     Parameters =>
	     {
		 ClassName =>
		 {
		     Class       => 'CIM::ObjectName',
		     ConvertType => 'CLASSNAME',
		 },
		 
		 LocalOnly =>
		 {
		     Type    => 'boolean',
		     Class   => 'CIM::Value',
		     Default => 1,
		 },
		 
		 DeepInheritance =>
		 {
		     Type    => 'boolean',
		     Class   => 'CIM::Value',
		     Default => 1,
		 },
		 
		 IncludeQualifiers =>
		 {
		     Type    => 'boolean',
		     Class   => 'CIM::Value',
		     Default => 0,
		 },
		 
		 IncludeClassOrigin =>
		 {
		     Type    => 'boolean',
		     Class   => 'CIM::Value',
		     Default => 0,
		 },
		 
		 PropertyList =>
		 {
		     Type    => 'string',
		     Class   => 'CIM::Value',
		     Input   => [ 'NULL', '@' ],
		     Default => undef,
		 },
	     },
	     
	     ReturnValue =>
	     {
		 Type  => '@',
		 Class => 'CIM::ValueObject',
	     },
	     
	     Meta =>
	     {
	         ExtractClass => [ 'ClassName', 'objectName' ],
	     },
	 },
	
	 ######################
	 EnumerateInstanceNames =>
	 ######################
	 {
	     Parameters =>
	     {
		 ClassName =>
		 {
		     Class       => 'CIM::ObjectName',
		     ConvertType => 'CLASSNAME',
		 },
	     },

	     ReturnValue =>
	     {
		 Type  => '@',
		 Class => 'CIM::ObjectName',
	     },
	     
	     Meta =>
	     {
	         ExtractClass => [ 'ClassName', 'objectName' ],
             },
	 },
	 
	 ###########
	 GetProperty =>
	 ###########
	 {
	     Parameters =>
	     {
		 InstanceName =>
		 {
		     Class       => 'CIM::ObjectName',
		     ConvertType => 'INSTANCENAME',
		 },
		 
		 PropertyName =>
		 {
		     Type  => 'string',
		     Class => 'CIM::Value',  
		 },
	     },  
	     ReturnValue =>
	     {
		 Type  => '?',
		 Class => 'CIM::Value',
	     },
	     
	     Meta =>
	     {
	         ExtractClass => [ 'InstanceName', 'objectName' ],
	     },
	 },
	 
	 
	 ############################################################
	 ######################## Basic Write #######################
	 ############################################################
        
	 ###########
	 SetProperty =>
	 ###########
	 {
	     Parameters =>
	     {
		 InstanceName =>
		 {
		     Class       => 'CIM::ObjectName',
		     ConvertType => 'INSTANCENAME',
		 },
		 
		 PropertyName =>
		 {
		     Type  => 'string',
		     Class => 'CIM::Value',  
		 },
		 
		 NewValue =>
		 {
		     Class     => 'CIM::Value',
		     Input     => [ 'NULL' ],
		     Default   => undef,
		 }
	     },
	     
	     ReturnValue =>
	     {
		 Type  => '',
	     },

	     Meta =>
	     {
	         ExtractClass => [ 'InstanceName', 'objectName' ],
	     },
	 },
	 
	    
	 ############################################################
	 ################### Instance Manipulation ##################
	 ############################################################
        
	 ##############
	 CreateInstance =>
	 ##############
	 {
	     Parameters =>
	     {
		 NewInstance =>
		 {
		     Class       => 'CIM::Instance',
		 },
	     },
	     
	     ReturnValue =>
	     {
		 Type  => '$',
		 Class => 'CIM::ObjectName',
	     },

	     Meta =>
	     {
	         ExtractClass     => [ 'NewInstance', 'className' ],
	     },
	 },

	 ##############
	 ModifyInstance =>
	 ##############
	 {
	     Parameters =>
	     {
		 ModifiedInstance =>
		 {
		     Class => 'CIM::ValueObject',
		 },			
	     },
	     
	     ReturnValue =>
	     {
		 Type  => '',
	     },

	     Meta =>
	     {
	         ExtractClass     => [
					 'ModifiedInstance',
					 'objectName',
					 'objectName'
				     ],
	     },
	 },
	
	 ##############
	 DeleteInstance =>
	 ##############
	 {
	     Parameters =>
	     {
		 InstanceName =>
		 {
		     Class       => 'CIM::ObjectName',
		     ConvertType => 'INSTANCENAME',
		 },
	     },
	     
	     ReturnValue =>
	     {
		 Type  => '',
	     },

	     Meta =>
	     {
	         ExtractClass => [ 'InstanceName', 'objectName' ],
             },
	 },
	 
	
	 ############################################################
	 #################### Schema Manipulation ###################
	 ############################################################
        
	 ###########
	 CreateClass =>
	 ###########
	 {
	     Parameters =>
	     {
		 NewClass =>
		 {
		     Class => 'CIM::Class',
		 },
	     },
	     
	     ReturnValue =>
	     {
		 Type  => '',
	     },

	     Meta =>
	     {
		 # ?
	     },
	 },
	
	 ###########
	 ModifyClass =>
	 ###########
	 {
	     # TODO
	 },
	
	 ###########
	 DeleteClass =>
	 ###########
	 {
	     Parameters =>
	     {
		 ClassName =>
		 {
		     Class       => 'CIM::ObjectName',
		     ConvertType => 'CLASSNAME',
		 },
	     },
	     ReturnValue =>
	     {
		 Type  => '',
	     },

	     Meta =>
	     {
	         ExtractClass => [ 'ClassName', 'objectName' ],
             },
	 },
	 
	
	 ############################################################
	 ################### Qualifier Declaration ##################
	 ############################################################

	 ###########
	 GetQualifier =>
	 ###########
	 {
	     # TODO
	 },
	
	 ############
	 SetQualifier =>
	 ############
	 {
	     # TODO
	 },
	
	 ###############
	 DeleteQualifier =>
	 ###############
	 {
	     # TODO
	 },
	
	 ###################
	 EnumerateQualifiers =>
	 ###################
	 {
	     # TODO
	 },
	
	
	 ############################################################
	 ###################### Query Execution #####################
	 ############################################################
        
	 #########
	 ExecQuery =>
	 #########
	 {
	     # TODO
	 },
        
	
	 ############################################################
	 ################### Association Traversal ##################
	 ############################################################
        
	 ###########
	 Associators =>
	 ###########
	 {
	     Parameters =>
	     {
		 
		 ObjectName =>
		 {
		     Class       => 'CIM::ObjectName',
		 },
		 
		 AssocClass =>
		 {
		     Class	 => 'CIM::ObjectName',
		     ConvertType => 'CLASSNAME',
		     Default	 => undef,
		 },
		 
		 ResultClass =>
		 {
		     Class	 => 'CIM::ObjectName',
		     ConvertType => 'CLASSNAME',
		     Default	 => undef,
		 },
		 
		 Role	=>
		 {
		     Type    => 'string',
		     Class   => 'CIM::Value',
		     Default => undef,
		 },

		 ResultRole	=>
		 {
		     Type    => 'string',
		     Class   => 'CIM::Value',
		     Default => undef,
		 },

		 IncludeQualifiers =>
		 {
		     Type    => 'boolean',
		     Class   => 'CIM::Value',
		     Default => 0,
		 },
		 
		 IncludeClassOrigin =>
		 {
		     Type    => 'boolean',
		     Class   => 'CIM::Value',
		     Default => 0,
		 },
		 
		 PropertyList =>
		 {
		     Type    => 'string',
		     Class   => 'CIM::Value',
		     Input   => [ 'NULL', '@' ],
		     Default => undef,
		 },
	     },

	     ReturnValue =>
	     {
		 Type  => '@',
		 Class => 'CIM::ValueObject',
	     },
	     
	     Meta =>
	     {
	         ExtractClass => [ 'ObjectName', 'objectName' ],
             },
	 },
	 
	 ###############
	 AssociatorNames =>
	 ###############
	 {
	     Parameters =>
	     {
		 
		 ObjectName =>
		 {
		     Class       => 'CIM::ObjectName',
		 },
		 
		 AssocClass =>
		 {
		     Class	 => 'CIM::ObjectName',
		     ConvertType => 'CLASSNAME',
		     Default	 => undef,
		 },
		 
		 ResultClass =>
		 {
		     Class	 => 'CIM::ObjectName',
		     ConvertType => 'CLASSNAME',
		     Default	 => undef,
		 },
		 
		 Role	=>
		 {
		     Type    => 'string',
		     Class   => 'CIM::Value',
		     Default => undef,
		 },

		 ResultRole	=>
		 {
		     Type    => 'string',
		     Class   => 'CIM::Value',
		     Default => undef,
		 },
	     },
	     
	     ReturnValue =>
	     {
		 Type  => '@',
		 Class => 'CIM::ObjectName',
	     },
	     
	     Meta =>
	     {
	         ExtractClass => [ 'ObjectName', 'objectName' ],
             },
	 },
	
	 ##########
	 References =>
	 ##########
	 {
	     Parameters =>
	     {
		 
		 ObjectName =>
		 {
		     Class       => 'CIM::ObjectName',
		 },
		 
		 ResultClass =>
		 {
		     Class       => 'CIM::ObjectName',
		     ConvertType => 'CLASSNAME',
		     Default	 => undef,
		 },
		 
		 Role	=>
		 {
		     Type    => 'string',
		     Class   => 'CIM::Value',
		     Default => undef,
		 },

		 IncludeQualifiers =>
		 {
		     Type    => 'boolean',
		     Class   => 'CIM::Value',
		     Default => 0,
		 },
		 
		 IncludeClassOrigin =>
		 {
		     Type    => 'boolean',
		     Class   => 'CIM::Value',
		     Default => 0,
		 },
		 
		 PropertyList =>
		 {
		     Type    => 'string',
		     Class   => 'CIM::Value',
		     Input   => [ 'NULL', '@' ],
		     Default => undef,
		 },
	     },

	     ReturnValue =>
	     {
		 Type  => '@',
		 Class => 'CIM::ValueObject',
	     },
	     
	     Meta =>
	     {
	         ExtractClass => [ 'ObjectName', 'objectName' ],
	     },
	 },

	
	 ##############
	 ReferenceNames =>
	 ##############
	 {
	     Parameters =>
	     {
		 
		 ObjectName =>
		 {
		     Class       => 'CIM::ObjectName',
		 },
		 
		 ResultClass =>
		 {
		     Class	 => 'CIM::ObjectName',
		     ConvertType => 'CLASSNAME',
		     Default	 => undef,
		 },
		 
		 Role	=>
		 {
		     Type    => 'string',
		     Class   => 'CIM::Value',
		     Default => undef,
		 },
	     },

	     ReturnValue =>
	     {
		 Type  => '@',
		 Class => 'CIM::ObjectName',
	     },
	     
	     Meta =>
	     {
	         ExtractClass => [ 'ObjectName', 'objectName' ],
	     },
	 },
	 
     };
    
    
    sub isValidIMethodName {
	my ($self, $name) = @_;
	
	return scalar (grep { /^$name$/ } (keys %{$_table}));
    }

    sub class {
	my ($self, $imethod, $parameter) = @_;

	return $_table->{$imethod}->{Parameters}->{$parameter}->{Class};
    }
    
    sub convertType {
	my ($self, $imethod, $parameter) = @_;

	return $_table->{$imethod}->{Parameters}->{$parameter}->{ConvertType};
    }
    
    sub extractClass {
	my ($self, $imethod) = @_;

	return $_table->{$imethod}->{Meta}->{ExtractClass}
    }

    
    sub parameters {
	my ($self, $imethod) = @_;

	return keys %{$_table->{$imethod}->{Parameters}};
    }
    
    sub isValidParameterName {
	my ($self, $imethod, $name) = @_;

	return scalar (grep { /^$name$/ }
		       (keys %{$_table->{$imethod}->{Parameters}}));
    }

    sub type {
	my $self = shift;

	if (scalar @_ == 2) {
	    my ($imethod, $parameter) = @_;
	    
	    return $_table->{$imethod}->{Parameters}->{$parameter}->{Type};
	}
	else {
	    my ($parameter) = @_;

	    foreach (keys %{$_table}) {
		return $_table->{$_}->{Parameters}->{$parameter}->{Type}
		    if exists $_table->{$_}->{Parameters}->{$parameter};
	    }
	}
    }

    sub isOptional {
	my ($self, $imethod, $parameter) = @_;

	exists $_table->{$imethod}->{Parameters}->{$parameter}->{Default};
    }

    sub isMandatory {
	my ($self, $imethod, $parameter) = @_;

	return scalar(not exists $_table->{$imethod}->
		      {Parameters}->{$parameter}->{Default});
    }

    sub default {
	my ($self, $imethod, $parameter) = @_;

	return $_table->{$imethod}->{Parameters}->{$parameter}->{Default};
    }
    
    sub nullAllowed {
	my ($self, $imethod, $parameter) = @_;

	return 0 unless exists $_table->{$imethod}->
	    {Parameters}->{$parameter}->{Input};
	
	return scalar grep { /^NULL$/ }
		(@{$_table->{$imethod}->{Parameters}->{$parameter}->{Input}});
    }

    sub isArray {
	my ($self, $imethod, $parameter) = @_;

	return 0 unless exists $_table->{$imethod}->
	    {Parameters}->{$parameter}->{Input};
	
	return scalar grep { /^\@$/ }
		(@{$_table->{$imethod}->{Parameters}->{$parameter}->{Input}});
    }


    sub returnValueIsVoid {
	my ($self, $imethod) = @_;

	return $_table->{$imethod}->{ReturnValue}->{Type} eq "";
    }
    
    sub returnValueIsScalar {
	my ($self, $imethod) = @_;

	return $_table->{$imethod}->{ReturnValue}->{Type} eq '$';
    }
    
    sub returnValueIsArray {
	my ($self, $imethod) = @_;

	return $_table->{$imethod}->{ReturnValue}->{Type} eq '@';
    }
    
    sub returnValueCanBeMissing {
	my ($self, $imethod) = @_;

	return $_table->{$imethod}->{ReturnValue}->{Type} eq '?';
    }


    sub fillArgsWithDefaultValues {
	my ($self, $args, $imethodname) = @_;

	foreach ($self->parameters($imethodname)) {
	    # set defaults if no values were given 
	    unless (exists $args->{$_}) {
		my $default = $self->default($imethodname, $_);
		# only set parameters which have defined values 
		if (defined $default) {
		    $args->{$_} = 
			CIM::Value->new(Value => $default,
					Type  => $self->type($imethodname, $_),
				       );
		}
	    }
	}
    }
    
}


1;

__END__

=head1 NAME

CIM::IMethodInfo - Informations about Intrinsic Method signatures

=head1 SYNOPSIS

 use CIM::IMethodInfo;

 $info = CIM::IMethodInfo->new;

 $b = $info->isValidIMethodName("GetClass");

 $o = $info->class("GetClass", "LocalOnly");

 $t = $info->type("GetClass", "ClassName");
    
 $b = $info->isOptional("GetClass", "LocalOnly");

 $b = $info->isMandatory("GetClass", "LocalOnly");

 $d = $info->default("GetClass", "LocalOnly");

 $n = $info->nullAllowed("GetClass", "LocalOnly");

 $i = $info->isArray("GetClass", "LocalOnly");
 
 $r = $info->returnValueIsVoid("GetClass");
 
 $r = $info->returnValueIsScalar("GetClass");

 $r = $info->returnValueIsArray("GetClass");

 $r = $info->returnValueCanBeMissing("GetClass");

 $info->fillArgsWithDefaultValues(\%args, "GetClass");


=head1 DESCRIPTION

This module contains informations about the signatures of Intrinsic Methods.
It is used for internal purposes only.



=head1 CONSTRUCTOR

=over 4

=item new()

Currently, IMethodInfo objects have no attributes. Therefore, new() does
nothing except returning an object reference, and all methods could be
used as static methods, too.



=head1 METHODS

=item isValidIMethodName($name)

This method tests whether $name (a string) is a valid Intrinsic Method Name 
(like "GetClass"). Return value is the number of Intrinsic Methods of that 
name (0 or 1).

=item class($imethodname, $parameter)

This method returns the name (string) of the class you need to create for 
an object that represents a parameter (e.g. "LocalOnly") of a imethod (e.g. 
"GetClass").
Return value: a string e.g "CIM::Value" for the above example.

=item convertType($imethodname, $parameter)
    
Return value: convertType (string) of the given parameter of the given class.

=item extractClass($imethodname)

Returns an array reference. The array contains two or more values
(e.g. [ 'ModifiedInstance', 'objectName', 'objectName' ]).
The first value gives the name of the parameter containing the object concerned 
(e.g. ModifiedInstance), the second and following give the 
names of the functions needed to retrive the class name of that object as 
string. 
Thus you can get the class name belonging to the given parameter:
$modifiedInstance->objectName->objectName for the above example.
(needed in PaulA/CIMOM.pm, function invokeIMethod()).

=item parameters($imethodname)

Returns an array representing the names of the parameters of the given imethod.

=item isValidParameterName($imethodname, $parameter)

Returns 1 or 0 depending on wether the parameter name (a string) given is a 
valid parameter name for the given imethod or not.

=item type($imethodname, $parameter)

This method returns the "data type" of the given parameter
(e.g. type("GetClass", "LocalOnly") returns 'boolean'), 
or undef, if $parameter is a "pseudo type" like "ClassName".


=item isOptional($imethodname, $parameter)

This method tests whether $parameter is optional.
Return value: 0 or 1. 

=item isMandatory($imethodname, $parameter)

This method tests whether $parameter is mandatory.
Return value: 0 or 1. 

=item default($imethodname, $parameter)

This method returns the default value for $parameter, or undef, if
$parameter isn't optional.

=item nullAllowed($imethodname, $parameter)

This method tests whether NULL is an allowed value for $parameter.
Return value: 0 or 1. 
    
=item isArray($imethodname, $parameter)

This method tests whether the value of the given parameter has to be 
an array.
Return value: 0 or 1. 
    
=item returnValueIsVoid($imethodname)

This method tests whether the given imethod has an return value.
Return value: 0 or 1. 
    
=item returnValueIsScalar($imethodname)

This method tests whether the return value of the given imethod is a scalar.
Return value: 0 or 1. 

=item returnValueIsArray($imethodname)

This method tests whether the return value of the given imethod is an array.
Return value: 0 or 1. 
    
=item returnValueCanBeMissing($imethodname)

This method tests whether the return value of the given imethod may be missing.
Return value: 0 or 1. 

=item fillArgsWithDefaultValues(\%args, $imethodname)

This method fills the hash %args with the default CIM values of the specified
Intrinsic Method $imethodname.
No return value.


=head1 AUTHOR

 Axel Miesen <miesen@ID-PRO.de>



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
