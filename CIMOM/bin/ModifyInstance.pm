use strict;

use common;


#
# ModifyInstance tests
#

sub _modifyInstance {
    my ($className, $keyBindings, $propertyList, $onlyHeader) = @_;
    
    my $on = CIM::ObjectName->new(ObjectName  => $className,
				  ConvertType => 'INSTANCENAME',
				  KeyBindings => $keyBindings,
				 );

    return "ModifyInstance $on"
	if $onlyHeader;
    
    
    my $instance = CIM::Instance->new(ClassName => $className,
				      Property  => $propertyList);
    my $vo = CIM::ValueObject->new(ObjectName => $on,
				   Object     => $instance);
    
    eval { $cc->ModifyInstance(ModifiedInstance => $vo) };
    
    if ($@) {
	print $@, "\n";
    }
    else {
	print "Instance modified.\n";
    }
}


# ---------------------------------------------------------------------------

my @properties;

push @properties,
    CIM::Property->new(Name  => 'RealName',
		       Type  => 'string',
		       Value => CIM::Value->new(Value => 'Dr. Dr. Simpson',
						Type  => 'string')),
    CIM::Property->new(Name  => 'LoginShell',
		       Type  => 'string',
		       Value => CIM::Value->new(Value => 'perl',
						Type  => 'string')),
    CIM::Property->new(Name  => 'Signature',
		       Type  => 'string',
		       Value => CIM::Value->new(Value =>
						"This signature is false.\n",
						Type  => 'string'))
		       ;

my $privatePopServer = 
	CIM::Property->new( Name  => 'PrivatePopServer',
			    Type  => 'string',
			    Value => CIM::Value->new(Value => 'some.server.com',
						     Type  => 'string'));

my $privatePopLogin = 
	CIM::Property->new( Name  => 'PrivatePopLogin',
			    Type  => 'string',
			    Value => CIM::Value->new(Value => 'bunny',
						     Type  => 'string'));

my $privatePopPassword = 
	CIM::Property->new( Name  => 'PrivatePopPassword',
			    Type  => 'string',
			    Value => CIM::Value->new(Value => 'geheim',
						     Type  => 'string'));

		       
my $privatePopServerUndef = 
	CIM::Property->new( Name  => 'PrivatePopServer',
			    Type  => 'string',
			    Value => undef );

my $privatePopLoginUndef = 
	CIM::Property->new( Name  => 'PrivatePopLogin',
			    Type  => 'string',
			    Value => undef );

my $privatePopPasswordUndef = 
	CIM::Property->new( Name  => 'PrivatePopPassword',
			    Type  => 'string',
			    Value => undef );

# ---------------------------------------------------------------------------


sub test1 {
    my ($args) = @_;
    
    my $keyBindings = { Login => 'hsimpson' };
    _modifyInstance('PaulA_User', $keyBindings, \@properties,
		    (@_ ? 1 : 0));
}

sub test2 {
    my ($args) = @_;
    
    my $keyBindings = { Login => 'bbunny' };
    _modifyInstance('PaulA_User', $keyBindings, [$privatePopServer, $privatePopPassword, $privatePopLogin],
		    (@_ ? 1 : 0));
}

sub test3 {
    my ($args) = @_;
    
    my $keyBindings = { Login => 'bbunny' };
    _modifyInstance('PaulA_User', $keyBindings, [$privatePopServer, $privatePopPassword],
		    (@_ ? 1 : 0));
}

sub test4 {
    my ($args) = @_;
    
    my $keyBindings = { Login => 'bbunny' };
    _modifyInstance('PaulA_User', $keyBindings, [$privatePopServerUndef, $privatePopPasswordUndef, $privatePopLoginUndef],
		    (@_ ? 1 : 0));
}
sub test5 {
    my ($args) = @_;
    
    my $keyBindings = { Login => 'bbunny' };
    _modifyInstance('PaulA_User', $keyBindings, [$privatePopServerUndef, $privatePopPasswordUndef],
		    (@_ ? 1 : 0));
}
#------------------------------------------------------------------
sub test11 {
    my ($args) = @_;
    
    my $keyBindings = { Login => 'bbunny' };
    _modifyInstance('PaulA_User', $keyBindings, [$privatePopServer, $privatePopLogin],
		    (@_ ? 1 : 0));
}
# ---------------------------------------------------------------------------

sub test97 {
    my ($args) = @_;
    
    my $keyBindings = { Login => 'hsimpson' };
    _modifyInstance('Invalid', $keyBindings, \@properties,
		    (@_ ? 1 : 0));
}


sub test98 {
    my ($args) = @_;
    
    my $keyBindings = { Invalid => 'hsimpson' };
    _modifyInstance('PaulA_User', $keyBindings, \@properties,
		    (@_ ? 1 : 0));
}


sub test99 {
    my ($args) = @_;
    
    my $keyBindings = { Login => 'invalid' };
    _modifyInstance('PaulA_User', $keyBindings, \@properties,
		    (@_ ? 1 : 0));
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
