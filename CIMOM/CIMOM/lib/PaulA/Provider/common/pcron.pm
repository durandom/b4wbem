use strict;

use CIM::Error;


############################## writeProperty_* ############################
# Zum Schreiben der Properties
#    Input:  - String (eingelesene Sektion)
#            - Hash-Referenz (KeyBindings), 
#            - Scalar resp. array-reference (read Value)
#            - Scalar resp. array-reference (new Value)
#    Output: - String (wird ggf. spaeter durch system2paula_* transformiert)
###########################################################################

sub writeProperty_MailWeekdaysInterval {
    my ($self, @args) = @_;
    
    my $type = "Wk";
    
    return $self->_writeMail(@args, $type);
}
    
sub writeProperty_MailWeekendInterval {
    my ($self, @args) = @_;
    
    my $type = "Wd";
    
    return $self->_writeMail(@args, $type);
}

sub _writeMail {
    my ($self, $section, $keyBindings, $readValue, $newValue, $handle, $type) =
	@_;
    
    my $prefix = $type eq "Wk" ? "MailWeekdays" : "MailWeekend"; 
    
    my $start = $self->{_valueList}->{$prefix . "Start"};
    my $end = $self->{_valueList}->{$prefix . "End"};
    my $inter = $self->{_valueList}->{$prefix . "Interval"};
    
    unless ((defined $start && defined $end && defined $inter) ||
	    (!defined $start && !defined $end && !defined $inter)) {
	
        PaulA::Provider::error(CIM::Error::CIM_ERR_INVALID_PARAMETER,
			       "Either all or none of the start, end and interval properties have to be defined"); 
    }
    
    my $info;
    # match complete line
    my $regexp = '(.*?^)(fetchmail[^\n]*?;[^\n]*?' . $type . '.*?)$';
    eval { $info = $handle->search('SECTION',
				   $regexp, 'sm',
				   undef) };
    
    if ($info->{Count} == 1) {
	my ($left, $right) = $info->{Read}->[0] =~ m/(.*;)(.*)/;
     
        if (!defined $inter || !defined $start || !defined $end) {
            $info->{Write}->[0] = '';
        } # empty strings needn't be expected as they are not valid
        else {
            $info->{Write}->[0] = $left . "m$inter$type$start-$end"; 
        }

	
    }
    elsif ($info->{Count} == 0)  {
	my $fetchmailrc = $self->definition('fetchmailrc');
        $info->{Append} = "fetchmail -f $fetchmailrc;m$inter$type$start-$end\n";
    }
    else {
        PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED, 
			       "no more than 1 entry for Weekend or " . 
			       "Weekdays is allowed");
    }
    
    return $info;
}

############################## isValid_* ##################################
# Tests, ob der angegebene Wert gueltig ist oder nicht.
# (werden *vor* der paula2system-Transformation durchgefuehrt.)
#    Input:  entweder ein Skalar oder eine Array-Referenz
#    Output: 1 = ok, 0 = Fehler
###########################################################################

sub isValid_MailWeekdaysStart {
    my ($self, $val) = @_;
    return 1 if !defined $val;
    return 0 if $val =~ /^\s*$/;
    return 1;
}
sub isValid_MailWeekdaysEnd {
    my ($self, $val) = @_;
    return 1 if !defined $val;
    return 0 if $val =~ /^\s*$/;
    return 1;
}
sub isValid_MailWeekdaysInterval {
    my ($self, $val) = @_;
    return 1 if !defined $val;
    return 0 if $val =~ /^\s*$/;
    return 1;
}
sub isValid_MailWeekendStart {
    my ($self, $val) = @_;
    return 1 if !defined $val;
    return 0 if $val =~ /^\s*$/;
    return 1;
}
sub isValid_MailWeekendEnd {
    my ($self, $val) = @_;
    return 1 if !defined $val;
    return 0 if $val =~ /^\s*$/;
    return 1;
}
sub isValid_MailWeekendInterval {
    my ($self, $val) = @_;
    return 1 if !defined $val;
    return 0 if $val =~ /^\s*$/;
    return 1;
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
