use strict;

use CIM::Error;




sub _getHashOfPaulAGroups {
    my ($self) = @_;
    my %paula;   # hash of PaulA groups
    {
	# in the future: EnumerateInstanceNames(PaulA_Groups)
	# for now: quick grep in paula group.conf
	my $file = $self->sandbox . "/files/groups.paula"; # ARGH!
	open FILE, "$file" or die "couldn't open $file\n";
	
	# get the PaulA groups
	while (<FILE>) {
	    /^Group\s+"(.+?)"/;
	    $paula{$1} = 1 if defined $1;
	}
	close FILE;
    }
    return %paula;
}


sub readProperty_SystemGroups {
    return _read_Groups(@_, 'SYSTEM');
}

sub readProperty_PaulAGroups {
    return _read_Groups(@_, 'PAULA');
}

sub _read_Groups {
    my ($self, $section, $keyBindings, $readValues, $handle, $type) = @_;
    
    my %paula = $self->_getHashOfPaulAGroups();
    
    my $login = $keyBindings->{Login};
    my $info;
    my $regexp = '(.*?^)(.+?:.*?)\s*$';
    eval { $info = $handle->search('SECTION',
				   $regexp, 'sm',
				   undef) };
    PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED, "$@") if ($@);
    
    my @groups;
    for (my $pos = 0; $pos < $info->{Count}; $pos++) {
	my $line = $info->{Read}->[$pos];
	$line .= ',';   # so the username must be followed by a ","
	
	$line =~ /^(.+?):.+[,:]$login,/m;
	
	my $groupname = $1;
	next unless defined $groupname;
	if ($type eq 'PAULA') {
	    push @groups, $groupname if exists $paula{$groupname};
	}
	else {
	    push @groups, $groupname unless exists $paula{$groupname};
	}
    }
    @groups = sort @groups;
    return \@groups;
}



sub writeProperty_SystemGroups {
     _write_Groups(@_, 'SYSTEM');
}

sub writeProperty_PaulAGroups {
    _write_Groups(@_, 'PAULA');
}

sub _write_Groups {
    my ($self, $section, $keyBindings, $readValue, $newValue, $handle,
	$type) = @_;
    
    my %paula = $self->_getHashOfPaulAGroups();
    
    my (%old, %new);
    @old{@$readValue} = ();
    @new{@$newValue} = ();

    my $user = $keyBindings->{Login};
    my $info;
    my $regexp = '(.*?^)(.+?:.*?)\s*$';
    eval { $info = $handle->search('SECTION',
				   $regexp, 'sm',
				   undef) };
    PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED, "$@") if ($@);

#      # just for testing
#      magenta(present($info));
#      for (my $pos = 0; $pos < $info->{Count}; $pos++) {
#  	magenta("     $pos: ", $info->{Read}->[$pos]);
#      }
#      mark(present($readValue));
#      mark(present($newValue));
#      mark(present(\%old));
#      mark(present(\%new));
    
    # modify lines
    my @groups;
    for (my $pos = 0; $pos < $info->{Count}; $pos++) {
	my $line = $info->{Read}->[$pos];
	$line =~ /^(.+?):.*$/m;
	my $groupname = $1;
	
	# skip group if wrong $type
	if ($type eq 'PAULA') {
	    next unless exists $paula{$groupname};
	}
	else {
	    next if exists $paula{$groupname};
	}
	
	# delete user $user in group $groupname
	if (!exists $old{$groupname}) {
	    $line =~ s/(.+)/$1,$user/;
	    $line =~ s/([:,])([:,])/$1/;
	    $info->{Write}->[$pos] = $line;
	}
	# insert user $user into group $groupname
	if (!exists $new{$groupname}) {
	    $line =~ s/(.+[:,])$user(,?.*)/$1$2/;
	    $line =~ s/([:,])([:,])/$1/;
	    $line =~ s/,$//;
	    $info->{Write}->[$pos] = $line;
	}
    }
    
#      # just for testing
#      for (my $pos = 0; $pos < $info->{Count}; $pos++) {
#  	magenta("     $pos: ", $info->{Write}->[$pos])
#  	    if defined $info->{Write}->[$pos];
#      }
#      magenta(present($info));
    
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
