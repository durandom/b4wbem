use strict;
use lib "t";
use common;


# test 1
# CIM::Class, defaults
{
    my $objectName = 'CIM_SAPStatisticalInformation';
    my $on = CIM::ObjectName->new(ObjectName => $objectName,
				  ConvertType => "CLASSNAME",
				 );

    my @asso;
    eval { 
	@asso = $cc->AssociatorNames(ObjectName => $on,
				    );
    };
    
    print STDERR $@;

    my $count = @asso;
    assert(!$@ && $count == 1 && 
	    $asso[0]->convertType eq "OBJECTPATH-CLASSNAME");
}    

# test 2
# input: invalid CIM::Class
{
    my $objectName = 'Invalid';
    my $on = CIM::ObjectName->new(ObjectName => $objectName,
				  ConvertType => "CLASSNAME",
				 );

    my @asso;
    eval { 
	@asso = $cc->AssociatorNames(ObjectName => $on,
				    );
    };
    
    assert($@->code == 5);
}    

# test 3
# CIM::Instance, defaults
{
    my $on = CIM::ObjectName->
		new(ObjectName  => 'PaulA_User',
		    KeyBindings => { Login => 'hsimpson' },
		    ConvertType => 'INSTANCENAME',
		    );

    my @asso;
    eval { 
	@asso = $cc->AssociatorNames(ObjectName => $on,
				);
    };
    
    print STDERR $@;

    my $count = @asso;
    assert(!$@ && $count == 1 && 
	    $asso[0]->convertType eq "OBJECTPATH-INSTANCENAME");
}    


BEGIN { $numOfTests = 3; print "$numOfTests\n"; }


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
