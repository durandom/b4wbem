use strict;

#########################################
package PaulA::Provider::test::Test_User;
#########################################
use Carp;
use Carp::Assert;


use base qw(PaulA::Provider);

use CIM::Utils;
use CIM::Error;

do "PaulA/Provider/common/group.pm";
do "PaulA/Provider/common/misc.pm";
do "PaulA/Provider/common/passwd.pm";


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

sub readProperty_MailAddress {
    my ($self, $section, $keyBindings, $readValues) = @_;
    
    my $login = $$keyBindings{Login};
    
    my $a = $self->_readDomainName(@_);
    $a =~s/(.+)/$login\@$1/;
    
    return $a;
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


sub writeProperty_Signature {
    my ($self, $section, $keyBindings, $readValue, $newValue, $handle) = @_;
    
    unless (defined $newValue) {
	$handle->removeAtWriting();
	return '';
    }
    
    return $newValue;
}




############################## isValid_* ##################################
# Tests, ob der angegebene Wert gueltig ist oder nicht.
# (werden *vor* der paula2system-Transformation durchgefuehrt.)
#    Input:  entweder ein Skalar oder eine Array-Referenz
#    Output: 1 = ok, 0 = Fehler
###########################################################################




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

sub handleName_signature {
    my ($self, $keyBindings, $readValues) = @_;
    
    # TODO: hier ggf. noch eine CIM-Abfrage reinbauen!
    my $login = $keyBindings->{Login};
    
    return "files/home/$login/signature";
}



###################### handlePermissions_* ################################

#  sub handlePermissions_signature {
#      my ($self, $keyBindings) = @_;
    
#      #my $uid = $keyBindings->{Login};  # not for testing in sandbox!
    
#      my $uid = undef;
#      my $gid = undef;
#      my $umask = '0600';   # i.e. "-rw-------"
    
#      return ($uid, $gid, $umask);
#  }




###################### objectMethod_*/classMethod_* #######################



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
