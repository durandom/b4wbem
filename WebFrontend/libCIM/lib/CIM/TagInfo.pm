use strict;

#####################
package CIM::TagInfo;
#####################

use CIM::NamespacePath;
use CIM::ParamValue;
use CIM::ReturnValue;
use CIM::ObjectName;
use CIM::Qualifier;
use CIM::Class;
use CIM::Instance;
use CIM::ValueObject;
use CIM::Value;
use CIM::Property;
use CIM::Error;


sub new {
    bless {}, $_[0];
}


{
    my $_table =
    {
	CLASS =>
	{
	    Class => 'CIM::Class',
	},
	
	CLASSNAME =>
	{
	    Class => 'CIM::ObjectName',
	},

	CLASSPATH =>
	{
	    Class => 'CIM::ObjectName',
	},

	ERROR =>
	{
	    Class => 'CIM::Error',
	},
	
	INSTANCE =>
	{
	    Class => 'CIM::Instance',
	},

	INSTANCENAME =>
	{
	    Class => 'CIM::ObjectName',
	},
	
	INSTANCEPATH =>
	{
	    Class => 'CIM::ObjectName',
	},
	
	PARAMVALUE =>
	{
	    Class => 'CIM::ParamValue',
	},
	
	IPARAMVALUE =>
	{
	    Class => 'CIM::ParamValue',
	},
	
	IRETURNVALUE =>
	{
	    Class => 'CIM::ReturnValue',
	},
	
	RETURNVALUE =>
	{
	    Class => 'CIM::ReturnValue',
	},
	
	LOCALCLASSPATH =>
	{
	    Class => 'CIM::ObjectName',
	},

	LOCALINSTANCEPATH =>
	{
	    Class => 'CIM::ObjectName',
	},

	LOCALNAMESPACEPATH =>
	{
	    Class => 'CIM::NamespacePath',
	},

	METHOD =>
	{
	    Class => 'CIM::Method',
	},

	NAMESPACEPATH =>
	{
	    Class => 'CIM::NamespacePath',
	},
	
	OBJECTPATH =>
	{
	    Class => 'CIM::ObjectName',
	},
	
	PARAMETER =>
	{
	    Class => 'CIM::Parameter',
	},
	
	'PARAMETER.ARRAY' =>
	{
	    Class => 'CIM::Parameter',
	},
	
	'PARAMETER.REFARRAY' =>
	{
	    Class => 'CIM::Parameter',
	},
	
	'PARAMETER.REFERENCE' =>
	{
	    Class => 'CIM::Parameter',
	},
	
	PROPERTY =>
	{
	    Class => 'CIM::Property',
	},
	
	'PROPERTY.ARRAY' =>
	{
	    Class => 'CIM::Property',
	},
	
	'PROPERTY.REFERENCE' =>
	{
	    Class => 'CIM::Property',
	},
	
	QUALIFIER =>
	{
	    Class => 'CIM::Qualifier',
	},
	
	VALUE =>
	{
	    Class => 'CIM::Value',
	},
	
	'VALUE.ARRAY' =>
	{
	    Class => 'CIM::Value',
	},
	
	'VALUE.NAMEDINSTANCE' =>
	{
	    Class => 'CIM::ValueObject',
	},
	
	'VALUE.NAMEDOBJECT' =>
	{
	    Class => 'CIM::ValueObject',
	},
	
	'VALUE.OBJECT' =>
	{
	    Class => 'CIM::ValueObject',
	},
	
	'VALUE.OBJECTWITHLOCALPATH' =>
	{
	    Class => 'CIM::ValueObject',
	},
	
	'VALUE.OBJECTWITHPATH' =>
	{
	    Class => 'CIM::ValueObject',
	},
	
	'VALUE.REFARRAY' =>
	{
	    Class => 'CIM::Value',
	},
	
	'VALUE.REFERENCE' =>
	{
	    Class => 'CIM::Value',
	},
	
    };
    
    
    sub class {
	my ($self, $tag) = @_;
	
	return $_table->{$tag}->{Class};
    }
}

1;




__END__

=head1 NAME

CIM::TagInfo - mapping of XML tags to Perl classes.


=head1 SYNOPSIS

 use CIM::TagInfo;

 $xmltag = 'PROPERTY.ARRAY';

 $class = CIM::TagInfo->class($xmltag);



=head1 DESCRIPTION

This module contains informations for mapping XML tags to Perl Classes.
Currently this class is only used in CIM::Base when doing the full
automatical fromXML() of a XML request.
It is used for internal purposes only.



=head1 CONSTRUCTOR

=over 4   

=item new()

Currently, TagInfo objects have no attributes. Therefore, new() does
nothing except returning an object reference, and all methods could be
used as static methods, too.



=head1 METHODS

=item class()

Returns the name of the CIM class which is competent for the given XML tag.


=head1 SEE ALSO

L<CIM::Base>



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
