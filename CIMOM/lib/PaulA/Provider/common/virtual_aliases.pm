use strict;

use CIM::Error;

############################## readProperty_* #############################
# Zum Einlesen der Properties
#    Input:  - String (eingelesene Sektion)
#            - Hash-Reference (KeyBindings)
#            - Hash-Reference (so far read values)
#    Output: - String (wird ggf. spaeter durch system2paula_* transformiert)
###########################################################################


sub readProperty_VirtualDomains {
    # returns all domains for which mappings exist to mydomain
    my ($self, $section, $keyBindings, $readValues) = @_;

    # all domains on the left side (including domains from user mappings)
    my %domains = $section =~  m/^\S*\@(\S+)(.*)/gm;
    
    my @domains = sort keys %domains;
    return \@domains;
}


sub readProperty_FaxExtensions {
    my ($self, @args) = @_;
    
    my $type = "FAX";
    
    $self->_readMappings(@args, $type);
}

sub readProperty_MailAliases {
    my ($self, $section, $keyBindings, $readValues, $handle) = @_;

    my $type = "ALIASES";
    $self->_readMappings($section, $keyBindings, $readValues, $handle, $type);
}

sub readProperty_DistributionLists {	  
    my ($self, $section, $keyBindings, $readValues, $handle) = @_;

    my $type = "LISTS";
    $self->_readMappings($section, $keyBindings, $readValues, $handle, $type);
}

sub readProperty_ValidDistributionLists {
    my ($self, $section, $keyBindings, $readValues, $handle) = @_;
    
    my $login = $$keyBindings{Login};
    
    my $info;
    my $regexp = '(.*?^)(\S+)[^\n]*?$';
    eval { $info = $handle->search('SECTION',
				   $regexp, 'sm',
				   undef) };
    PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED, "$@") if ($@);
    
    return undef if $#{$info->{Read}} == -1;	
    # otherwise an empty array would be returned

    my @lists = sort @{$info->{Read}};
    return \@lists;
}

############################## writeProperty_* ############################
# Zum Schreiben der Properties
#    Input:  - String (eingelesene Sektion)
#            - Hash-Referenz (KeyBindings), 
#            - Scalar resp. array-reference (read Value)
#            - Scalar resp. array-reference (new Value)
#    Output: - String (wird ggf. spaeter durch system2paula_* transformiert)
###########################################################################



sub writeProperty_FaxNumber {
    # beware: domain has to be "mydomain" 
    my ($self, $section, $keyBindings, $readValue, $newValue, $handle,
	$type) = @_;
    
    my $user = $$keyBindings{Login};
    
    my $info;
    # maybe the regexpshould be extended by "mydomain"
    my $regexp = '(.*?^)(\d+-gif-many\@fax\.\S+.*?)\s*$';

    eval { $info = $handle->search('SECTION',
				   $regexp, 'sm',
				   undef) };
    PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED, "$@") if ($@);

    my $done = 0;
    for (my $pos = 0; $pos < $info->{Count}; $pos++) {
	my $line = $info->{Read}->[$pos];

	if ($line =~ /(\S+\s+)(.*)\b$user\b(.*)/) {
	    # change line if there's more than one right hand address   
		$line =~ s/$user//;
		$line =~ s/\s,/ /;
		$line =~ s/,,/,/;
		$info->{Write}->[$pos] = $line;
	    # delete line if $user was the only right hand entry
	    if ($line =~ /^\S+\s+$/) {
		$line = "";
		$info->{Write}->[$pos] = $line;
	    }
	}
	    
	if ($newValue) {
	    if ($line =~ /^$newValue\b/) {
		$line .= ", $user";
		$info->{Write}->[$pos] = $line;
		$done = 1;
		last;
	    }
	}
    }

    unless ($done) {
	if ($newValue) { 
	    my $mydom = $self->_readDomainName;
	    $info->{Append} = "$newValue-gif-many\@fax.$mydom $user\n";
	}
    }

    return $info;
}

sub writeProperty_FaxExtensions {
    my ($self, $section, $keyBindings, $readValue, $newValue, $handle) = @_;
    my $type = "FAX";
    $self->_writeMappings($section, $keyBindings, $readValue, 
                          $newValue, $handle, $type);
}

sub writeProperty_MailAliases {
    my ($self, $section, $keyBindings, $readValue, $newValue, $handle) = @_;
    my $type = "ALIASES";
    $self->_writeMappings($section, $keyBindings, $readValue, $newValue,
			  $handle, $type);
}

sub writeProperty_DistributionLists {  
    my ($self, $section, $keyBindings, $readValue, $newValue, $handle) = @_;
    my $type = "LISTS";
    $self->_writeMappings($section, $keyBindings, $readValue, $newValue,
			  $handle, $type);
}

sub writeProperty_ValidDistributionLists {
    my ($self, $section, $keyBindings, $readValue, $newValue, $handle, $type) =
	@_;
    
    my $mydomain = $self->_readDomainName();
    foreach (@$newValue) {  
	unless (/@/) {	# add "@mydomain"
	    next if /^$/;
	    $_ .= "@" . $mydomain unless $_ =~ /^\s*$/;	
	}
	# catch illegal aliases
	# like ones already used as MailAliases?
    }

    my $info;
    # match complete line
    my $regexp = '(.*?^)(\S+\s+?[^\n]*?)\s*?$';

    eval { $info = $handle->search('SECTION',
				   $regexp, 'sm',
				   undef) };
    PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED, "$@") if ($@);


    my (%oldVirtual, %newVirtual);
    $readValue = [] unless defined $readValue;
    $newValue = [] unless defined $newValue;
    # otherwise the next lines wouldn't work
    @oldVirtual{@$readValue} = ();
    @newVirtual{@$newValue} = ();

    for (my $pos = 0; $pos < $info->{Count}; $pos++) {
	my $line = $info->{Read}->[$pos];
	my ($listname) = split /\s+/, $line; 
	
	if (!exists $newVirtual{$listname}) {
	    $info->{Write}->[$pos] = '';
	}
	else {
	    $info->{Write}->[$pos] = $line;
	    $newVirtual{$listname} = 1;	# mark as done
	}
    }
    
    foreach (keys %newVirtual){
	next if $newVirtual{$_};
	$info->{Append} .= "$_	\n";
    }
    
    return $info;
}

######################## additionalOutStuff_ #########################

sub addCommandlineOpt_MyDomain {
    my ($self, $keyBindings, $readValue, $newValue, $handle) = @_;
    
    red("addCommandlineOpt_MyDomain: $newValue, " . $handle->id . "\n");

    if ($handle->id eq 'perl') {
        my $old = $self->{_readValues}->{MyDomain};
        my $new = $self->{_valueList}->{MyDomain};
        my $file = $self->sandbox . "/" . $self->definition('virtual');
	return "-n -i -e \"s/(\\\S+\@)$old/\\\$1$new/; print\" $file";
    }
    elsif ($handle->id eq 'postmap_virtual') {
        return undef; 
    }
    elsif ($handle->id eq 'postfix_reload') {
        return undef; 
    }
    else {
	PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED,
			       "Unknown Handle id " . present($handle->id));
    }

}
    

#########################################################################
# private functions
#########################################################################

sub _readMappings {
    my ($self, $section, $keyBindings, $readValues, $handle, $type) = @_;

#    $section = $handle->section();
    
    my $login = $$keyBindings{Login};
    
    my $info;
    my $regexp = '(.*?^)(\S+?@?\S*?)\s+[^\n]*?\b' . $login . '\b[^\n]*?\s*$';
    eval { $info = $handle->search('SECTION',
				   $regexp, 'sm',
				   undef) };
    PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED, "$@") if ($@);

    my @aliases;
    foreach (sort @{$info->{Read}}) {
        if ($type eq "FAX" ){
            if ($_ =~ /\@fax\./)  {
                my ($no) = split /-/; 
	        push @aliases, $no;
            }
        }
        else {
            # remove all fax aliases
	    push @aliases, $_ unless $_ =~ /\@fax\./;
        }
    }
    @aliases = sort @aliases;
    return \@aliases;
}

sub _writeMappings {
#   doesn't work when addresses without domain part are already in the file
#   doesn't work when a left hand entry isn't followed by a whitespace 
#   (excluding \n), even when there is no right hand entry
#   attempts to add a user to a nonexistent list are quietly ignored, no error 
#   message, it's just nothing written
    my ($self, $section, $keyBindings, $readValue, $newValue, $handle,
	$type) = @_;
    
    my $login = $$keyBindings{Login};
    my $mydomain = $self->_readDomainName();

    # change the contents of $newValue to the form required in the file
    foreach (@$newValue) {  
	unless (/@/) {	# add "@mydomain"
	    next if /^\s*$/;
            if ($type eq "FAX") {
                $_ .= "-gif-many\@fax.$mydomain";
            } 
            else {
	        $_ .= "@" . $mydomain;
            }
	}
	# catch illegal aliases
	PaulA::Provider::error(CIM::Error::CIM_ERR_INVALID_PARAMETER,
			       "can't create this alias, it's identical " .
			       "with the main mail address") 
	    if (/^$login\@$mydomain$/);    
	# it's the main mail address of the user
    }
    
    my $info;
    # match complete line
    # read lines even when there's only a left hand entry 
    # -> add users to empty lists
    my $regexp = '(.*?^)([^\@\s]+?@?[^\@\s]*?\s+?[^\n]*?(\b' . $login .
	'\b)?[^\n]*?)\s*$';

    eval { $info = $handle->search('SECTION',
				   $regexp, 'sm',
				   undef) };
    PaulA::Provider::error(CIM::Error::CIM_ERR_FAILED, "$@") if ($@);


    my (%oldVirtual, %newVirtual);
    $readValue = [] unless defined $readValue;
    $newValue = [] unless defined $newValue;
    # otherwise the next lines wouldn't work
    @oldVirtual{@$readValue} = ();
    @newVirtual{@$newValue} = ();

    for (my $pos = 0; $pos < $info->{Count}; $pos++) {
	my $line = $info->{Read}->[$pos];
	my ($alias) = split /\s+/, $line; 
	
	if (exists $oldVirtual{$alias}   # may not exist for mailing lists
	    && exists $newVirtual{$alias}) { 
	# do ~nothing
	    $info->{Write}->[$pos] = $line;
	    $newVirtual{$alias} = 1;    # mark as done
	    next;
	}
    	elsif (exists $newVirtual{$alias}) {
	    if ($type eq "LISTS") {
	        # append new entry
		if ($line =~ /^\S+\s+$/) { 
		   $line .= $login;
		}
		else { 
		   $line .= ", $login";
		}
		$info->{Write}->[$pos] = $line;
		next;
	    }
	    elsif ($type eq "ALIASES") {
		PaulA::Provider::error(CIM::Error::CIM_ERR_INVALID_PARAMETER, 
			"can't create this alias, it already exists");
		# if a line with the new alias exists, it is already 
		# given to somebody else and can't be created
	    }
            elsif ($type eq "FAX") {
                # append new entry
                $line .= ", $login";
		$info->{Write}->[$pos] = $line;
	        $newVirtual{$alias} = 1;    # mark as done
		next;
            }
	}
	else {
	# remove line / part of line if there is no newValue 
	    if ($type eq "ALIASES") {
		unless ($line =~ /\b$login\b/) {
		# keep line if there isn't $login in it anyway
		    $info->{Write}->[$pos] = $line if $line !~ /\b$login\b/;
		}
		else {
		# remove the line if $login was the right hand entry 
		# (only one entry allowed)
		    $info->{Write}->[$pos] = "";
		}
	    }
	    elsif ($type eq "LISTS") {
	    # remove $login from the line
		$line =~ s/(\S+?\s+.*?)\b$login\b(,\s+)*(.*)/$1$3/;
		$line =~ s/,\s*$//;
		$info->{Write}->[$pos] = $line;
	    }
            elsif ($type eq "FAX") {
                if ($line =~ /^\S+\@fax\.$mydomain/) {  # mark
		    $line =~ s/(\S+?\s+.*?)\b$login\b(,\s+)*(.*)/$1$3/;
		    $line =~ s/,,/,/;       # ",," -> ","
		    $line =~ s/,\s*$//;     # remove "," at end of line
		    $line =~ s/(\s),/$1/;   # " ," -> " "
                    if ($line =~ /^\S+\s*$/) {
                        $info->{Write}->[$pos] = "";
                    }
                    else {
                        $info->{Write}->[$pos] = $line;
                    }
                    
                }
            }
	}        
    }
    
    if ($type eq "ALIASES" || $type eq "FAX") {	# add new (fax)aliases
	foreach (keys %newVirtual){
	    next if $newVirtual{$_};
	    
	    $info->{Append} .= "$_ $login\n";
	}
    }

    return $info;  # should be a %info hash in future...
}


############################## isValid_* ##################################
# Tests, ob der angegebene Wert gueltig ist oder nicht.
# (werden *vor* der paula2system-Transformation durchgefuehrt.)
#    Input:  entweder ein Skalar oder eine Array-Referenz
#    Output: 1 = ok, 0 = Fehler
###########################################################################

sub isValid_MailAliasRoot {
    my ($self, $val) = @_;
    return 1 unless defined $val;
    return 0 if $val =~ /^\s*$/;
    return 1;
}

sub isValid_MailAliasPostmaster {
    my ($self, $val) = @_;
    return 0 unless defined $val;
    return 0 if $val =~ /^\s*$/;
    return 1;
}

sub isValid_DefaultMailForward {
    my ($self, $val) = @_;
    return 1 unless defined $val;
    return 0 if $val =~ /^\s*$/;
    return 1;
}

sub isValid_ValidDistributionLists {
    my ($self, $val) = @_;
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
