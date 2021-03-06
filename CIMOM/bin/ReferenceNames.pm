use strict;

use CIM::Utils;
use PaulA::Repository;
use common;

$FUNCTIONING = 1;

sub test1 {
    my $objectName = 'CIM_AlarmDevice';
    return "ReferenceNames with a CIM::Class as query ($objectName)\n    and with default settings"
	if @_;


    my $on = CIM::ObjectName->new(
				ObjectName => $objectName,
				ConvertType => "CLASSNAME",
				);

    my @asso;
    eval { 
	@asso = $cc->ReferenceNames(
				ObjectName => $on,
				);
    };
    
    if ($@) {
	print $@, "\n";
    } 
    else {
	foreach (@asso) {
	    cpprint $_->toXML->toString;
	}
    }
    
}

sub test2 {
    my $objectName = 'CIM_Invalid';
    return "ReferenceNames with a non existent CIM::Class as query ($objectName)"
	if @_;


    my $on = CIM::ObjectName->new(
				ObjectName => $objectName,
				ConvertType => "CLASSNAME",
				);

    my @asso;
    eval { 
	@asso = $cc->ReferenceNames(
				ObjectName => $on,
				);
    };
    
    if ($@) {
	print $@, "\n";
    } 
    else {
	foreach (@asso) {
	    cpprint $_->toXML->toString;
	}
    }
    
}

sub test3 {
    my $on = CIM::ObjectName->new(  ObjectName  => 'PaulA_User',
				    KeyBindings => { Login => 'hsimpson' },
				    ConvertType => 'INSTANCENAME',
				);
    
    return "ReferenceNames with a CIM::Instance as query ($on)\n    and with default settings"
	if @_;

    my @asso;
    eval { 
	@asso = $cc->ReferenceNames(ObjectName => $on,
				   );
    };
    
    if ($@) {
	print $@, "\n";
    } 
    else {
	foreach (@asso) {
	    $_->namespacePath();
	    cpprint $_->toXML->toString;
	}
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
