use strict;

###########################################
package PaulA::Provider::PaulA::PaulA_User;
###########################################
use Carp;
use POSIX;
use Authen::PAM;

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

    # Fallback for "$HOME":
    $self->{'PaulA::Provider::PaulA::PaulA_User::_defaultHome'} = '/home';
    
    # Determine default home:
    # works only if useradd is set correctly 
    if (open(USERADD, "/etc/default/useradd")) {
	while (<USERADD>) {
	    last if ($self->{_defaultHome}) = /^HOME=(.*)/;
	}
	close USERADD;
    }
    
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
    
    my $basedir = $readValues->{HomeDirectory}->[0];
    return -d "$basedir/www" ? 1 : 0;
}

sub readProperty_MailAddress {
    my ($self, $section, $keyBindings, $readValues) = @_;

    my $key = $$keyBindings{Login};

    my $a = $self->_readDomainName(@_);
    $a =~s/(.+)/$key\@$1/;

    return $a;
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


sub readProperty_Password {
    # Dummy...
    return "";
}

sub readProperty_KEYBINDINGS {
    my ($self, $section) = @_;
    
    return [] unless defined $section;

    # Extracting user names: 
    # Valid PaulA users are the ones contained at least in on group
    # named "paula_*".
    
    my @a = $section =~ /^paula_.*:(.*?)$/gm;
    my @users = split ',', (join ',', @a);
    my %users;
    foreach (@users) {
	$users{$_} = 1;
    }
    
    my @keybindings = ();
    foreach my $user (sort keys %users) {
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
    my $crontab = `crontab -u $user -l`;    # current contents
    # change if fetchmail isn't called as shown
    unless ($crontab =~ m/^[^#]+\* \* \* \* \* fetchmail/m) {  # TODO!
	$crontab =~ s/^#.*$//m;
	# delete old fetchmail line:
	$crontab =~ s/(.*)^.+?\bfetchmail\b.*?\$(.*)/$1$2/;;
	# add new fetchmail line, do fetchmail once an hour
	$crontab .= "* * * * * fetchmail\n"; 
	# the following line is needed to bypass taint
	my ($newcrontab) = $crontab =~ /(.*)/s;
	system("echo '$newcrontab' | crontab -u $user -")  == 0 or
	    die "Error creating a crontab for $user";
    }
}

sub _fetchmailrc_removeCrontab {
    my ($self, $user) = @_;

    if ( system("crontab -u $user -l") == 0) {
	system("crontab -u $user -r") == 0 or
	    die "Error in removing the crontab of $user";
    }
}

sub _autoReply_createFiles {
    my ($self, $login, $homedir) = @_;

    my $umask = "0644";
    my $uid = $login; 
    my $gid = $login; 
    my $own = $uid . "." . $gid;
    my $base = $homedir;  
    
    my $file = "$base/.vacation.dir";
    open FILE, ">$file" or die "Error opening file $file";;
    close FILE;
    system("chmod $umask $file") == 0 or
	die "Error in chmod-ing file `$file' to `$umask'";
    system("chown $own $file") == 0 or
	die "Error in chown-ing file `$file' to `$own'";
    

    $file = "$base/.vacation.pag";
    open FILE, ">$file" or die "Error opening file $file";;
    close FILE;
    system("chmod $umask $file") == 0 or
	die "Error in chmod-ing file `$file' to `$umask'";
    system("chown $own $file") == 0 or
	die "Error in chown-ing file `$file' to `$own'";

    # file must not be overwritten if it already exists:
    $file = "$base/.vacation.msg";
    unless (-e $file) {
	open FILE, ">$file" or die "Error opening file $file";;
	print FILE "Subject: I'm on holiday\n";	# mark! -> reading of template file
	close FILE;
	system("chmod $umask $file") == 0 or
	    die "Error in chmod-ing file `$file' to `$umask'";
	}
	system("chown $own $file") == 0 or
	    die "Error in chown-ing file `$file' to `$own'";
}
 

sub writeProperty_HasLocalHomepage {
    my ($self, $section, $keyBindings, $readValue, $newValue, $handle) = @_;
    
    $section = $handle->section();  # argh!
    my $login = $keyBindings->{Login};
    
    my $umask = "0750";
    my $uid = $login; 
    my $gid = $login; 
    my $own = $uid . "." . $gid;

    my $basedir = $self->{_readValues}->{HomeDirectory};
    my $dir = "$basedir/www";
    
    # create dir
    if ($newValue == 1 && $readValue == 0) {
        mkdir $dir or die "could not create directory $dir";
        system("chmod $umask $dir") == 0
            or die "Error in chmod-ing directory `$dir' to `$umask'";
        system("chown $own $dir") == 0 
            or die "Error in chown-ing directory `$dir' to `$own'";
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


    
sub writeProperty_Password {
    my ($self, $section, $keyBindings, $readValue, $newValue) = @_;

    my ($username, $newpassword) = ($keyBindings->{Login}, $newValue);

    # Since we are running as root, pam doesn't ask for the old password.
    #
    # TODO: perform an authentication before changing the password!
    
    my $my_conv_func = sub {
	my @res;
	while ( @_ ) {
	    my $code = shift;
	    my $msg = shift;
	    my $ans = $newpassword;
	    
	    push @res, PAM_SUCCESS();
	    push @res, $ans;
	}
	push @res, PAM_SUCCESS();
	return @res;
    };
    
    my $retval;
    
    my $pamh = new Authen::PAM('passwd', $username, $my_conv_func);
    unless (defined $pamh) {
	black("Error code $pamh during PAM init!");
	return undef;
    }

    $retval = $pamh->pam_set_item(PAM_TTY, '/dev/console');
    unless ($retval == PAM_SUCCESS) {
	black("Error during am_set_item");
	return undef;
    }

    $retval = $pamh->pam_chauthtok;
    
    if ($retval != PAM_SUCCESS) {
	black($pamh->pam_strerror($retval));
	return undef;
    }

    return undef;
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

sub isValid_LoginShell {
    my ($self, $val) = @_;
    
    return $val if -x $val;
    
    PaulA::Provider::error(CIM::Error::CIM_ERR_INVALID_PARAMETER, 
        "file is not executable");
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
    
    return $readValues->{HomeDirectory}->[0] . "/.forward"; 
}

sub handleName_replytext {
    my ($self, $keyBindings, $readValues) = @_;
    
    my $login = $keyBindings->{Login};
    
    return $$readValues{HomeDirectory}->[0] . "/.vacation.msg"; 
}

sub handleName_fetchmailrc {
    my ($self, $keyBindings, $readValues) = @_;
    
    my $login = $keyBindings->{Login};
    
    return $$readValues{HomeDirectory}->[0] . "/.fetchmailrc";
}


###################### handlePermissions_* ################################

sub handlePermissions_fetchmailrc {
    my ($self, $keyBindings) = @_;
    
    my $uid = $keyBindings->{Login};  # not for testing in sandbox!
    my $gid = $keyBindings->{Login};
    my $umask = '0600';   # i.e. "-rw-------"
    
    return ($uid, $gid, $umask);
}


sub handlePermissions_forward {
    my ($self, $keyBindings) = @_;
    
    my $uid = $keyBindings->{Login};  # not for testing in sandbox!
    my $gid = $keyBindings->{Login};
    my $umask = '0644';   # i.e. "-rw-r--r--"
    
    return ($uid, $gid, $umask);
}

sub handlePermissions_replytext {
    my ($self, $keyBindings) = @_;

    my $uid = $keyBindings->{Login};  # not for testing in sandbox!
    my $gid = $keyBindings->{Login};
    my $umask = '0644';   # i.e. "-rw-r--r--"
    
    return ($uid, $gid, $umask);
} 

#####################
# Extrinsic Methods #
#####################


sub _pam_authenticate {
    my ($self, $username, $password) = @_;
    my $pamh;
    my $retval;

    my $my_conv_func = sub {
	my @res;
	while ( @_ ) {
	    my $code = shift;
	    my $msg = shift;
	    my $ans = "";
	    
	    $ans = $username if ($code == PAM_PROMPT_ECHO_ON() );
	    $ans = $password if ($code == PAM_PROMPT_ECHO_OFF() );
	    
	    push @res, PAM_SUCCESS();
	    push @res, $ans;
	}
	push @res, PAM_SUCCESS();
	return @res;
    };
	
    $pamh = new Authen::PAM('login', $username, $my_conv_func);
    unless (defined $pamh) {
	black("Error code $pamh during PAM init!");
	return 0;
    }

    $retval = $pamh->pam_set_item(PAM_TTY, '/dev/console');
    unless ($retval == PAM_SUCCESS) {
	black("Error during am_set_item");
	return 0;
    }

    $retval = $pamh->pam_authenticate;
    
    if ($retval != PAM_SUCCESS) {
	black($pamh->pam_strerror($retval));
	return 0;
    }
    
    return 1;
}


sub objectMethod_Authenticate {
    my ($self, $keyBindings, $password) = @_;

    $password->name eq 'Password' or
	error(CIM::Error::CIM_ERR_INVALID_PARAMETER,
	      "Parameter was not Password");
    
    $password = $password->value; # Forget the ParamValue wrapper
    
    black("*********** authenticating user `" . $keyBindings->{Login} . "'");
    
    my $result = $self->_pam_authenticate($keyBindings->{Login},
					  scalar $password->value);
    
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
