use strict;

###########################################
package PaulA::Provider::test::Test_System;
###########################################
use Carp;

use base qw(PaulA::Provider);

use CIM::Utils;
use CIM::Error;

do "PaulA/Provider/common/virtual_aliases.pm";

sub new {
    my ($class, %args) = @_;
    
    my $self = $class->SUPER::new(%args);
    
    return $self;
}


############################## readProperty_*##############################
# Zum Einlesen der Properties
#    Input:  String (eingelesene Sektion)
#    Output: String (wird ggf. spaeter durch system2paula_* transformiert)
###########################################################################



############################## writeProperty_* ############################
# Zum Schreiben der Properties
#    Input:  - String (eingelesene Sektion)
#            - Hash-Referenz (KeyBindings), 
#            - Scalar resp. array-reference (read Value)
#            - Scalar resp. array-reference (new Value)
#    Output: - String (wird ggf. spaeter durch system2paula_* transformiert)
###########################################################################


    
############################## isValid_* ##################################
# Tests, ob der angegebene Wert gueltig ist oder nicht.
# (werden *vor* der paula2system-Transformation durchgefuehrt.)
#    Input:  entweder ein Skalar oder eine Array-Referenz
#    Output: 1 = ok, 0 = Fehler
###########################################################################

sub isValid_MouseDevice {
    my ($self, $val) = @_;
    return ($val =~ m|/|) ? 1 : 0;
}



############################## system2paula_* #############################
# Wandelt den angegebenen Wert von "System-Schreibweise" in die
# "PaulA-Repraesentation" um (z.B. "TRUE" -> "1")
#    Input:  ein String
#    Output: entweder ein Skalar oder eine Array-Referenz
###########################################################################

sub system2paula_KeyboardProtocol {
    my ($self, $val) = @_;
    #$val = uc $val;  # Test: Uppercase
    return $val;
}



############################## paula2system_* #############################
# Wandelt den angegebenen Wert von "PaulA-Repraesentation" in die
# "System-Schreibweise" um (z.B. "1" -> "TRUE")
#    Input:  entweder ein Skalar oder eine Array-Referenz
#    Output: ein String
###########################################################################

sub paula2system_KeyboardProtocol {
    my ($self, $val) = @_;
    #$val = lc $val;  # Test: Lowercase
    return $val;
}


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
