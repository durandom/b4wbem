use strict;

use CIM::Error;

####################################################################
# PaulA_OutgoingMailDomain
####################################################################

# read

sub readProperty_Create_OutgoingMailDomain {
    my ($self, $section, $keyBindings, $readValues, $handle) = @_;

    # dummy
    return []; 
}
sub readProperty_Delete_OutgoingMailDomain {
    my ($self, $section, $keyBindings, $readValues, $handle) = @_;

    # dummy
    return 1; 
}
  
#--------------------------------------------------------------------
# write

sub writeProperty_Create_OutgoingMailDomain {
    my ($self, $section, $keyBindings, $readValue, $newValue, $handle, $type) =
	@_;

    my @in = $self->_enumerateInstanceNames("PaulA_OutgoingMailDomain");
    
    foreach (@in) {
	if ($_->valueByKey("Domain") eq $newValue->[0]) {
	    PaulA::Provider::error(CIM::Error::CIM_ERR_ALREADY_EXISTS, 
		"Instance already exists");
	}
    }

    my $info;
    my $regexp = '()(.*)()$';
    eval { $info = $handle->search('SECTION',
				   $regexp, 'sm',
				   undef) };
    PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED, "$@") if ($@);

    $info->{Append} = $newValue->[0] . "  :\[" . $newValue->[1] . "\]\n"
		    . '.' . $newValue->[0] . " :\[" . $newValue->[1] . "\]\n"; 
    
    return $info;
}

sub writeProperty_Delete_OutgoingMailDomain {
    my ($self, $section, $keyBindings, $readValue, $newValue, $handle, $type) =
	@_;

    my @in = $self->_enumerateInstanceNames("PaulA_OutgoingMailDomain");
    
    my $check = 0;
    foreach (@in) {
	if ($_->valueByKey("Domain") eq $newValue) {
            black("deleting PaulA_OutgoingMailDomain=$newValue");
            $check = 1;
            last;
	}
    }
    PaulA::Provider::error(CIM::Error::CIM_ERR_NOT_FOUND, 
        "Instance doesn't exist") unless $check;

    my $info;
    my $regexp = '(.*^)(' . $newValue . '\s.*?^\.' . $newValue . '.*?\n)(.*)$';
    eval { $info = $handle->search('SECTION',
				   $regexp, 'sm',
				   undef) };
    PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED, "$@") if ($@);

    PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED, 
	"to many entries") if $info->{Count} > 1;

    $info->{Write}->[0] = "";
    
    return $info;
}

####################################################################
# PaulA_Group
####################################################################

# read

sub readProperty_Create_Group {
    my ($self, $section, $keyBindings, $readValues, $handle) = @_;

    # dummy
    return []; 
}
sub readProperty_Delete_Group {
    my ($self, $section, $keyBindings, $readValues, $handle) = @_;

    # dummy
    return []; 
}

#--------------------------------------------------------------------
# write

sub writeProperty_Create_Group {
    my ($self, $section, $keyBindings, $readValue, $newValue, $handle, $type) =
	@_;

    my $info;
    my $name = shift @$newValue;
    if ($handle->id eq "groups.paula") {
        my @in = $self->_enumerateInstanceNames("PaulA_Group");
        
        foreach (@in) {
            if ($_->valueByKey("Name") eq $newValue->[0]) {
                PaulA::Provider::error(CIM::Error::CIM_ERR_ALREADY_EXISTS, 
                    "Instance already exists");
            }
        }
        my $regexp = '()(.*)()$';
        eval { $info = $handle->search('SECTION',
                                       $regexp, 'sm',
                                       undef) };
        PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED, "$@") if ($@);

        my @perms = @$newValue;
        $info->{Append} = 'Group "' . $name . '"' . "\n";
        foreach (@perms) {
            my ($a, $b) = $_ =~ /(\w+)_(\w)$/;
            $info->{Append} .= " $a " . '"' . $b . '"' . "\n";
        }
        $info->{Append} .= "EndGroup\n";;

        unshift @$newValue, $name;
    }
    elsif ($handle->id eq "group") {
        my $regexp = '()(.*)()';
        eval { $info = $handle->search('SECTION',
                                       $regexp, 'sm',
                                       undef) };
        PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED, "$@") if ($@);

        $info->{Append} .= "$name:x:555:\n"     
        # Aargh! The number has to be generated to be unique
         
    }
    else {
	PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED,
			       "Unknown Handle id " . present($handle->id));
    }
      
    return $info;
}

sub writeProperty_Delete_Group {
    my ($self, $section, $keyBindings, $readValue, $newValue, $handle, $type) =
	@_;

    my $info;
    if ($handle->id eq "groups.paula") {
        my @in = $self->_enumerateInstanceNames("PaulA_Group");
        
        my $check = 0;
        foreach (@in) {
            if ($_->valueByKey("Name") eq $newValue) {
                black("deleting PaulA_Group=$newValue");
                $check = 1;
                last;
            }
        }
        PaulA::Provider::error(CIM::Error::CIM_ERR_NOT_FOUND, 
            "Instance doesn't exist") unless $check;

        my $regexp = '(.*^)(Group\s"' . "$newValue.+?^EndGroup\n)(.*)\$";
        eval { $info = $handle->search('SECTION',
                                       $regexp, 'sm',
                                       undef) };
        PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED, "$@") if ($@);

        PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED, 
            "to many entries") if $info->{Count} > 1;

        $info->{Write}->[0] = "";
    }
    elsif ($handle->id eq "group") {
        my $regexp = "(.*)(^$newValue:.*?\n)(.*)";
        eval { $info = $handle->search('SECTION',
                                       $regexp, 'sm',
                                       undef) };
        PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED, "$@") if ($@);

        $info->{Write}->[0] = "";     
    }
    else {
	PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED,
			       "Unknown Handle id " . present($handle->id));
    }
    
    return $info;
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
