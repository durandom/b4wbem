use strict;

use CIM::Error;


############################## readProperty_*##############################

sub readProperty_ValidFaxExtensions {
    my ($self, $section, $keyBindings, $readValues, $handle) = @_;

#    $section = $handle->section();
    
    my $info;
    my $regexp = '(.*?^=)(\d+)(\nmode\s+fax.*?)';
    eval { $info = $handle->search('SECTION',
				   $regexp, 'sm',
				   undef) };
    PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED, "$@") if ($@);

    return undef if $#{$info->{Read}} == -1;	
    # otherwise an empty array would be returned
    
    # remove the prefix:
    my @numbers;
    my $prefix = defined($self->{_readValues}->{Prefix}->[0]) ?
		 $self->{_readValues}->{Prefix}->[0] : "";
    for (my $pos = 0; $pos < $info->{Count}; $pos++) {
	my $line = $info->{Read}->[$pos];
	
	$line =~ s/$prefix//;
	push @numbers, $line;
    }

    return \@numbers;
}

sub readProperty_BaseNumber {
    my ($self, $section, $keyBindings, $readValues, $handle) = @_;

#    $section = $handle->section();
    
    my $info;
    my $regexp = '(.*^prefix\s+)(\d+)(.*)';
    eval { $info = $handle->search('SECTION',
				   $regexp, 'sm',
				   undef) };
    PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED, "$@") if ($@);

    PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED, 
	"found more than one match for this property") 
	if $info->{Count} > 1;
    
    my $ccode = defined($self->{_readValues}->{CountryCode}->[0]) ?
		$self->{_readValues}->{CountryCode}->[0] : "";
    my $acode = defined($self->{_readValues}->{AreaCode}->[0]) ?
		$self->{_readValues}->{AreaCode}->[0] : "";
    
    # remove country and area code 
    $info->{Read}->[0] =~ s/^$ccode// if defined $info->{Read}->[0];
    $info->{Read}->[0] =~ s/^$acode// if defined $info->{Read}->[0];
    
    # dismiss empty value
    return undef unless defined $info->{Read}->[0];
    return undef if $info->{Read}->[0] =~ /^\s*$/;
    
    return $info->{Read}->[0];
}
	
############################## writeProperty_* ############################

sub writeProperty_ValidFaxExtensions {
    my ($self, $section, $keyBindings, $readValue, $newValue, $handle, $type) =
	@_;

    my $info;
    # match complete line
    my $regexp = '(.*?^)(=\d+\nmode\s+fax.+?mailformat.*?\n\n?)(.*)';

    eval { $info = $handle->search('SECTION',
				   $regexp, 'sm',
				   undef) };
    PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED, "$@") if ($@);
    
    $newValue = [] unless defined $newValue; 
    my %newValues;
    @newValues{@$newValue} = ();
    # otherwise the next lines wouldn't work 

    # remove all read values
    for (my $pos = 0; $pos < $info->{Count}; $pos++) {
	    $info->{Write}->[$pos] = '';
    }

    my $prefix = $self->{_valueList}->{Prefix};
    $prefix = $self->{_readValues}->{Prefix} unless defined $prefix;

    my $len = defined $newValue->[0] ? length $newValue->[0] : 0;
    foreach (sort keys %newValues){
	PaulA::Provider::error(CIM::Error::CIM_ERR_INVALID_PARAMETER, 
		"All Fax Extensions must have the same length") 
		if length $_ != $len;
	$info->{Append} .= "\n=$prefix$_\nmode\t\tfax\n" .
			    "delay\t\t1\n" .
			    "handler\t\t/usr/local/bin/capi.faxrcvd.pl\n" .
			    "recipient\tdummy\@localhost\n" .
			    "mailformat\tinline_jpeg\n";
    }

    # set new NumLength value 
    $len += length $prefix;
    $self->{_valueList}->{NumLength} = $len;
    
    return $info;
}

 
######################## additionalOutStuff_ #########################

sub additionalOutStuff_CountryCode {
    my $self = shift;

    # get the up to date values of the other required properties 
    my $areaCode = defined $self->{_valueList}->{AreaCode} ? 
			$self->{_valueList}->{AreaCode} 
			: $self->{_readValues}->{AreaCode};

    my $baseNumber = exists $self->{_valueList}->{BaseNumber} ? 
			$self->{_valueList}->{BaseNumber} 
			: $self->{_readValues}->{BaseNumber};

    my $countryCode = defined $self->{_valueList}->{CountryCode} ?
			$self->{_valueList}->{CountryCode} 
			: "";
    
    # set new Prefix value (will be written in Prefix Regexp)
    $self->{_valueList}->{Prefix} = $countryCode .
				    $areaCode .
				    $baseNumber;
}

sub additionalOutStuff_AreaCode {
    my $self = shift;

    # get the up to date values of the other required properties 
    my $countryCode = defined $self->{_valueList}->{CountryCode} ? 
			$self->{_valueList}->{CountryCode} 
			: $self->{_readValues}->{CountryCode};
			
    my $baseNumber = exists $self->{_valueList}->{BaseNumber} ? 
			$self->{_valueList}->{BaseNumber} 
			: $self->{_readValues}->{BaseNumber};

    my $areaCode = defined $self->{_valueList}->{AreaCode} ?
			$self->{_valueList}->{AreaCode} 
			: "";

    # set new Prefix value (will be written in Prefix Regexp)
    $self->{_valueList}->{Prefix} = $countryCode .
				    $areaCode .
				    $baseNumber;
}

sub additionalOutStuff_BaseNumber {
    my $self = shift;

    # get the up to date values of the other required properties 
    my $countryCode = defined $self->{_valueList}->{CountryCode} ? 
			$self->{_valueList}->{CountryCode} 
			: $self->{_readValues}->{CountryCode};
    my $areaCode = defined $self->{_valueList}->{AreaCode} ? 
			$self->{_valueList}->{AreaCode} 
			: $self->{_readValues}->{AreaCode};

    my $baseNumber = defined $self->{_valueList}->{BaseNumber} ?
			$self->{_valueList}->{BaseNumber} 
			: "";
			
    # set new Prefix value (will be written in Prefix Regexp)
    $self->{_valueList}->{Prefix} = $countryCode .
				    $areaCode .
				    $baseNumber;

}


############################## isValid_* ############################

sub isValid_HeaderIDString {
    my ($self, $val) = @_;
    return 1 unless defined $val;
    return 0 if $val =~ /^\s*$/;
    return 1;
}
sub isValid_HeaderFaxNumber {
    my ($self, $val) = @_;
    return 1 unless defined $val;
    return 0 if $val =~ /^\s*$/;
    return 1;
}
sub isValid_CountryCode {
    my ($self, $val) = @_;
    return 1 unless defined $val;
    return 0 if $val =~ /^\s*$/;
    return 1;
}
sub isValid_AreaCode {
    my ($self, $val) = @_;
    return 1 unless defined $val;
    return 0 if $val =~ /^\s*$/;
    return 1;
}
sub isValid_Prefix {
    my ($self, $val) = @_;
    return 1 unless defined $val;
    return 0 if $val =~ /^\s*$/;
    return 1;
}
sub isValid_NumLength {
    my ($self, $val) = @_;
    return 1 unless defined $val;
    return 0 if $val =~ /^\s*$/;
    return 1;
}
sub isValid_BaseNumber {
    my ($self, $val) = @_;
    return 1 unless defined $val;
    return 0 if $val =~ /^\s*$/;
    return 1;
}
sub isValid_ValidFaxExtensions {
    my ($self, $val) = @_;
    return 1 unless defined $val;
    return (($#{$val} == -1)? 0 : 1);
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
