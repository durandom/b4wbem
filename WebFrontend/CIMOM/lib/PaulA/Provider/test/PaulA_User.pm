use strict;

##########################################
package PaulA::Provider::test::PaulA_User;
##########################################
use Carp;
use Carp::Assert;


use base qw(PaulA::Provider);

use CIM::Utils;
use CIM::Error;

do "PaulA/Provider/common/fetchmailrc.pm";
do "PaulA/Provider/common/forward.pm";
do "PaulA/Provider/common/group.pm";
do "PaulA/Provider/common/misc.pm";
do "PaulA/Provider/common/passwd.pm";
do "PaulA/Provider/common/virtual_aliases.pm";
do "PaulA/Provider/common/webaccess.pm";


sub new {
    my ($class, %args) = @_;
    
    my $self = $class->SUPER::new(%args);
    
    return $self;
}



############################## readProperty_* #############################
# Zum Einlesen der Properties
#    Input:  - String (eingelesene Sektion)
#            - Hash-Reference (KeyBindings)
#            - Hash-Reference (so far read values)
#    Output: - String (wird ggf. spaeter durch system2paula_* transformiert)
###########################################################################

sub readProperty_HasLocalHomepage {
    my ($self, $section, $keyBindings, $readValues) = @_;
    
    # to be improved; working with basedir no good,
    # there should be directory handles
    
    my $login = $keyBindings->{Login};
    my $basedir = $self->sandbox() . "/files/home/$login";
    return -d "$basedir/www" ? 1 : 0;
}


sub readProperty_PaulAPermissions {
    my ($self, $section, $keyBindings, $readValues, $handle) = @_;
    
    my @a = $section =~ m/^Group\s+"(\w+)"\s*(.+?)EndGroup\s*$/gms;
    my %entries = (@a);
    
    # $$readValues{PaulAGroups} is an arrayref pointing to an array 
    # (containing possible difffrent versions of the property array to be 
    # represented) of arrayrefs (pointing to a single property array). 
    # Here we take only the first property array and dismiss the rest.
    # To be changed.
    my @groups = @{@{$$readValues{PaulAGroups}}[0]};
    
    my %rights;
    foreach my $elem (@groups) {
	$entries{$elem} =~ s/"//g;
	my %tmp = split /\s+/, $entries{$elem};
	
	foreach my $key (keys %tmp) {
	    if (!defined $rights{$key} || $tmp{$key} eq "w") {
		$rights{$key} = $tmp{$key};
	    black("1 $elem, $key, $tmp{$key}");
	    }
	    elsif ($tmp{$key} eq "r" && $rights{$key} ne "w") {
		$rights{$key} = $tmp{$key};
	    }
	}
    }
    
    my @tmp;
    foreach (sort keys %rights) {
	push @tmp, $_ . "_" . $rights{$_};
    }
    
    return \@tmp;
}


sub readProperty_KEYBINDINGS {
    my ($self, $section) = @_;
    
    return [] unless defined $section;
    
    my @users = $section =~ /^(.*?):.*$/gm;
    
    my @keybindings = ();
    foreach my $user (sort @users) {
	push @keybindings, { Login => $user };
    }
    
    return \@keybindings;
}



############################## writeProperty_* ############################
# Zum Schreiben der Properties
#    Input:  - String (eingelesene Sektion)
#            - Hash-Referenz (KeyBindings), 
#            - Scalar resp. array-reference (read Value)
#            - Scalar resp. array-reference (new Value)
#    Output: - String (wird ggf. spaeter durch system2paula_* transformiert)
###########################################################################


sub _fetchmailrc_writeCrontab {
    my ($self, $user) = @_;
    
    # change crontab if necessary
    my $file = $self->sandbox() . "/files/crontab.$user";
    open FILE, "> $file";
    print FILE "* * * * * fetchmail\n";
    close FILE;
}

sub _fetchmailrc_removeCrontab {
    my ($self, $user) = @_;
    # dummy
}


sub _autoReply_createFiles {
    my ($self, $login) = @_;

    my $umask = "0660";
    my $base = $self->sandbox();
    
    my $file = "$base/files/home/$login/vacation.dir";
    open FILE, ">$file" or die "Error opening file $file";;
    close FILE;
    system("chmod $umask $file") == 0 or
	die "Error in chmod-ing file `$file' to `$umask'";
    
    $file = "$base/files/home/$login/vacation.pag";
    open FILE, ">$file" or die "Error opening file $file";;
    close FILE;
    system("chmod $umask $file") == 0 or
	die "Error in chmod-ing file `$file' to `$umask'";

    $file = "$base/files/home/$login/vacation.msg";
    open FILE, ">$file" or die "Error opening file $file";;
    print FILE "Subject: I'm on holiday\n";	# mark -> reading of template file
    close FILE;
    system("chmod $umask $file") == 0 or
	die "Error in chmod-ing file `$file' to `$umask'";
}

sub writeProperty_HasLocalHomepage {
    my ($self, $section, $keyBindings, $readValue, $newValue, $handle) = @_;
    
    my $umask = "0750";
    $section = $handle->section();  # argh!
    my $login = $keyBindings->{Login};
    
    my $basedir = $self->sandbox() . "/files/home/$login/";
    my $dir = "$basedir/www";
    
    # create dir
    if ($newValue == 1 && $readValue == 0) {
        mkdir $dir or die "could not create directory $dir";
        system("chmod $umask $dir") == 0
            or die "Error in chmod-ing directory `$dir' to `$umask'";
    }
    # remove dir
    elsif ($newValue == 0 && $readValue == 1) {
        if (-e "$dir.bak") {
            system("rm -rf $dir.bak") == 0 
                or die "could not remove $dir.bak";
        }
        system("mv -f $dir $dir.bak") == 0
            or die "could not move $dir to $dir.bak";
    }

    return $newValue;   
}
  


############################## isValid_* ##################################
# Tests, ob der angegebene Wert gueltig ist oder nicht.
# (werden *vor* der paula2system-Transformation durchgefuehrt.)
#    Input:  entweder ein Skalar oder eine Array-Referenz
#    Output: 1 = ok, 0 = Fehler
###########################################################################

sub isValid_Password {
    my ($self, $val) = @_;
    return ($val =~ m/:/) ? 0 : 1;
}




############################## system2paula_* #############################
# Wandelt den angegebenen Wert von "System-Schreibweise" in die
# "PaulA-Repraesentation" um (z.B. "TRUE" -> "1")
#    Input:  ein String
#    Output: entweder ein Skalar oder eine Array-Referenz
###########################################################################



############################## paula2system_* #############################
# Wandelt den angegebenen Wert von "Paula-Repraesentation" in die
# "System-Schreibweise" um (z.B. "1" -> "TRUE")
#    Input:  entweder ein Skalar oder eine Array-Referenz
#    Output: ein String
###########################################################################



############################## handleName_* ###############################
# Liefert den Handle-Namen, wenn dynamisch erzeugt werden muss. 
# Ansonsten ist dafuer ja das NAME-Attribut von HANDLE da.
#    Input:  - Hash-Referenz auf die Key-Bindings
#            - Hash-Referenz auf alle bisher schon eingelesenen Werte
#              (damit erspart man sich evtl. eine erneute CIM-Anfrage)
#    Output: ein String
#            (kann auch richtig schoen kompliziert sein mit Kommandozeilen-
#             Optionen bei einem Programmaufruf u.s.w.)
###########################################################################

sub handleName_forward {
    my ($self, $keyBindings, $readValues) = @_;
    
    my $login = $keyBindings->{Login};
    
    return "files/home/$login/forward";
}

sub handleName_replytext {
    my ($self, $keyBindings, $readValues) = @_;
    
    my $login = $keyBindings->{Login};
    
    return "files/home/$login/vacation.msg";
}

sub handleName_fetchmailrc {
    my ($self, $keyBindings, $readValues) = @_;
    
    my $login = $keyBindings->{Login};
    
    return "files/home/$login/fetchmailrc";
}



###################### handlePermissions_* ################################



###################### objectMethod_*/classMethod_* #######################

sub objectMethod_Authenticate {
    my ($self, $keyBindings, $password) = @_;

    assert($password->name eq 'Password');
    $password = $password->value; # Forget the ParamValue wrapper

    black("*********** authenticating user `" . $keyBindings->{Login} . "'");

    open(PASSWD, $self->sandbox . "/files/passwd") or
	die "cannot open files/passwd: $!";

    my $cryptedPasswd;
    
    while (<PASSWD>) {
	last if (($cryptedPasswd) = /^$keyBindings->{Login}:(.*?):/);
    }

    close PASSWD;

    my $result;
    if (defined $cryptedPasswd) {
	$result = (crypt($password->value, $cryptedPasswd) eq $cryptedPasswd) ?
	    1 : 0;
    } else {
	# The login was not found in the passwd file
	$result = 0;
    }
    
    return CIM::Value->new(Type  => 'boolean',
			   Value => $result);
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
