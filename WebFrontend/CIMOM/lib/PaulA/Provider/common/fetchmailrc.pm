use strict;

use CIM::Error;

sub readProperty_PrivatePopServer {
    my ($self, $section, $keyBindings, $readValues) = @_;
    
    return undef unless defined $section;  # i.e. no ~/.fetchmailrc found
    
    my ($p) = $section =~ m/poll\s+(\S+)/gm;
    
    return $p;
}

sub readProperty_PrivatePopLogin {
    my ($self, @args) = @_;
    return $self->_readLogin(@args);
}

sub readProperty_PrivatePopPassword {
    my ($self, @args) = @_;
    return $self->_readPassword(@args);
}


sub _readPassword {
    my ($self, $section, $keyBindings, $readValues) = @_;
    
    return undef unless defined $section;  # i.e. no ~/.fetchmailrc found
    
    my ($p) = $section =~ m/pass(?:word)?\s+("(?:.+?)"|(?:\w+))/gm;
    
    $p =~ s/"//g if defined $p;    # remove doublequotes
    return $p;
}

sub _readLogin {
    my ($self, $section, $keyBindings, $readValues) = @_;
    
    return undef unless defined $section;  # i.e. no ~/.fetchmailrc found
    
    my ($p) = $section =~ m/user(?:name)?\s+("(?:.+?)"|(?:\w+))/gm;  
    
    $p =~ s/"//g if defined $p;    # remove doublequotes
    return $p;
}

sub _readProtocol {
    my ($self, $section, $keyBindings, $readValues) = @_;
    
    return undef unless defined $section;  # i.e. no fetchmailrc found
    
    my ($p) = $section =~ m/proto(?:col)?\s+("(?:.+)"|(?:\w+))/gmi;
    
    $p =~ s/"//g;    # remove doublequotes
    $p =~ tr/a-z/A-Z/;
    if ($p eq "POP3") {
        if ($section =~ /\s+to\s+\*\s+here/) {
            $p .= "-Multidrop";
        }
    }
        
    return $p;
}

sub readProperty_LocalDomain {
    my ($self, $section, $keyBindings, $readValues) = @_;
    
    return undef unless defined $section;  # i.e. no fetchmailrc found
    
    my ($p) = $section =~ m/localdomains\s+("(?:.+?)"|(?:\S+))/gm;
    
    $p =~ s/"//g if defined $p;    # remove doublequotes
        
    return $p;
}

sub readProperty_Extra_Envelope {
    my ($self, $section, $keyBindings, $readValues) = @_;
    
    return undef unless defined $section;  # i.e. no fetchmailrc found
    
    my ($p) = $section =~ m/envelope\s+("(?:.+?)"|(?:\S+))/gm;
    
    $p =~ s/"//g if defined $p;    # remove doublequotes
        
    return $p;
}

sub readProperty_Extra_QVirtual {
    my ($self, $section, $keyBindings, $readValues) = @_;
    
    return undef unless defined $section;  # i.e. no fetchmailrc found
    
    my ($p) = $section =~ m/qvirtual\s+("(?:.+?)"|(?:\S+))/gm;
    
    $p =~ s/"//g if defined $p;    # remove doublequotes
        
    return $p;
}

sub readProperty_Login {
     my ($self, @args) = @_;
     return $self->_readLogin(@args);
}
sub readProperty_Password {
    my ($self, @args) = @_;
    return $self->_readPassword(@args);
}
sub readProperty_Protocol {
    my ($self, @args) = @_;
    return $self->_readProtocol(@args);
}

########################################################################
#
#   wirteProperty
#
########################################################################


sub writeProperty_PrivatePopServer {
    my ($self, @args) = @_;

    $self->_writePop(@args);
}
sub writeProperty_PrivatePopPassword {
    my ($self, @args) = @_;

    $self->_writePop(@args);
}
sub writeProperty_PrivatePopLogin {
    my ($self, @args) = @_;

    $self->_writePop(@args);
}

sub _writePop {
    my ($self, $SECTIONREMOVE, $keyBindings, $readValue, $newValue, $handle,
	$type) = @_;

    my $user = $$keyBindings{Login};

    # delete .fetchmailrc if no PrivatePop properties are defined
    if (!defined $self->{_valueList}->{PrivatePopServer} &&
	!defined $self->{_valueList}->{PrivatePopPassword} &&
	!defined $self->{_valueList}->{PrivatePopLogin}) {
	
	$handle->removeAtWriting();
	$self->_fetchmailrc_removeCrontab($user);
	return '';
    }
    
    my $server = $self->{_valueList}->{PrivatePopServer};
    my $password = $self->{_valueList}->{PrivatePopPassword};
    my $login = $self->{_valueList}->{PrivatePopLogin};

    # error if the mandatory PrivatePop properties are not defined
    unless (defined $server && defined $password) {
	die PaulA::Provider::error(CIM::Error::CIM_ERR_INVALID_PARAMETER,
			       "mandatory PrivatePop properties are undefined")
    }
	
    # set default PrivatePopLogin if necessary 
    $login = defined $login ? $login : $user;
    
    # create new line to write
    my $line =	"poll " . $server . 
		" proto pop3" . 
		" user " .  $login .
		" pass " . '"' . $password . '"' .
		" to $user here;\n";

    # read lines from fetchmailrc
    my $info;
    my $regexp = '()(.+)$';    # argh!
    eval { $info = $handle->search('SECTION',
				   $regexp, 'sm',
				   undef) };
    PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED, "$@") if ($@);
    
    # modify file contents
    if ($info->{Count} == 0) {
	$info->{Append} = $line;
    }
    elsif ($info->{Count} == 1) {
	$info->{Write}->[0] = $line;
    }
    else {
	PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED,
			       "We don't support multiple entries in fetchmailrc");
    }
    
    # write crontab
    $self->_fetchmailrc_writeCrontab($user);
    
    return $info;
}

#######################################################################

sub isValid_PrivatePopLogin {
    my ($self, $val) = @_;

    return 0 if !defined $val;
    return 0 if $val =~ /^\s*$/;
    return 1;
}
sub isValid_PrivatePopPassword {
    my ($self, $val) = @_;

    return 0 if !defined $val;
    return 0 if $val =~ /^\s*$/;
    return 1;
}
sub isValid_PrivatePopServer {
    my ($self, $val) = @_;

    return 0 if !defined $val;
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
