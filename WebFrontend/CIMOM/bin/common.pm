use strict;
use FindBin;
use CIM::Client;


use vars qw($cc $FUNCTIONING);

BEGIN {
    $ENV{CIM_CLIENT_CONFIG} = "$FindBin::Bin/../etc/cimclient.xml" 
	unless defined $ENV{CIM_CLIENT_CONFIG};
    
    $cc = CIM::Client->new(UseConfig => 1);

    # Determines whether a module is currently functioning
    $FUNCTIONING = 1;
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


