use strict;

##############################
package PaulA::ProviderConfig;
##############################
use Carp;

use Tie::SecureHash;
use XML::Simple;
use CIM::Utils;

use PaulA::ProviderHandle;


my $verbose = 1;

sub new {
    my ($class, %args) = @_;
    
    my $self = Tie::SecureHash->new($class);
    
    $self->{'PaulA::ProviderConfig::_filename'} = undef;
    $self->{'PaulA::ProviderConfig::_config'} = undef;
    
    $self->{'PaulA::ProviderConfig::_handles'} = undef;
    
    $self->{'PaulA::ProviderConfig::_CIMOMHandle'} = $args{CIMOMHandle};
    $self->{'PaulA::ProviderConfig::_namespacePath'} = $args{NamespacePath};
    
    $self->{'PaulA::ProviderConfig::_definitions'} = {};
    
    $self->init($args{Filename})
	if defined $args{Filename};
    
    return $self;
}


sub init {
    my ($self, $filename) = @_;
    
    croak("no filename specified")
	unless defined $filename;
    
    $self->{_filename} = $filename;
    eval { $self->{_config} =
	       XMLin($filename,
		     forcearray => [
				    qw(DEFINE
				       PROPERTY
				       SECTION HANDLE
				       IN OUT INOUT
				       IN_DEP OUT_DEP INOUT_DEP)
				   ],
		     keyattr    => [ qw(ID NAME) ]) };
    die "Error in reading $filename: $@" if ($@);

    # handles
    $self->{_handles} = undef;
    foreach my $id (keys %{$self->{_config}->{HANDLE}}) {
	my $h = $self->{_config}->{HANDLE}->{$id};
	$self->{_handles}->{$id} = PaulA::ProviderHandle->
	    new(ID            => $id,
		Config        => $h,
		CIMOMHandle   => scalar $self->{_CIMOMHandle},
		NamespacePath => scalar $self->{_namespacePath},
	       );
    }
    
    # definitions
    $self->{_definitions} = {};
    my $definitions = $self->{_config}->{DEFINITIONS};
    if (defined $definitions and defined $definitions->{DEFINE}) {
	
	#black(present($definitions->{DEFINE}));
	foreach my $name (keys %{$definitions->{DEFINE}}) {
	    #black("  name = " . present($name));
	    $self->{_definitions}->{$name} =
		$definitions->{DEFINE}->{$name}->{content};
	}
	#black(present(scalar $self->{_definitions}));
    }
}


###############################################################################
# Input:  - InOut             'IN' or 'OUT'
#         - PropertyList      Array reference with all Properties asked for
# Output: - RequestedProperties  Hash of all requested Properties
#                                (Property-ID => Property-Confighash)
#  #         - DependentProperties  Hash of all dependend Properties
#  #                                (Property-ID => Property-Confighash)
#         - HandlesByNumber   Hash of all requested handle numbers
#                             (Handle number => Handle-ID)
#                             (TODO: maybe better to return the handle *object*)
#
sub getPropertyInfos {
    my ($self, %args) = @_;
    
    my $inout = $args{InOut};
    
    my (%requested_properties, %dependend_properties, %handle_no);
    
    if (defined $args{PropertyList}[0] &&
	$args{PropertyList}[0] eq 'KEYBINDINGS') {
	
	# pseudo property 'KEYBINDINGS'
	my $p = $self->{_config}->{KEYBINDINGS};
	%requested_properties = ( KEYBINDINGS => $p );
	%handle_no = $self->_getHandleInfos($inout, $p);
    }
    else {
	my @propertyList = [];
	@propertyList = @{$args{PropertyList}};
	
	# get primary properties
	foreach my $p_id (keys %{$self->{_config}->{PROPERTY}}) {
	    # ignore if not specified in "PropertyList"
	    next unless (scalar grep /^$p_id$/, @propertyList);
	    
	    my $p = $self->{_config}->{PROPERTY}->{$p_id};
	    $requested_properties{$p_id} = $p;
	}
	
	# resolve dependencies
	foreach (1..4) {  # argh! (i.e. do it better)
	    foreach my $p_id (sort keys %requested_properties) {
		my $p = $self->{_config}->{PROPERTY}->{$p_id};
		#magenta($p_id);
		foreach my $d (@{$p->{DEPENDENCIES}->{$inout . "_DEP"}},
			       @{$p->{DEPENDENCIES}->{"INOUT_DEP"}}) {
		    my $newpid = $d->{PROPERTY};
		    my $newp = $self->{_config}->{PROPERTY}->{$newpid};
		    $requested_properties{$newpid} = $newp;
		}
	    }
	}
	
	# get handle infos
	foreach my $p (values %requested_properties) {
	    %handle_no = (%handle_no, $self->_getHandleInfos($inout, $p));
	}
    }
    
    ####################################################
    if ($verbose) {
	black("  /-------------- $inout ---------------\\");
	black("    Requested Properties:");
	foreach my $p_id (keys %requested_properties) {
	    black("      $p_id");
	}
	black("    Requested Handles (No's):");
	foreach my $h_no (keys %handle_no) {
	    black("      $h_no -> $handle_no{$h_no}");
	}
	black("  \\------------------------------------/");
    }
    ####################################################
    
    return ( RequestedProperties => \%requested_properties,
	     DependendProperties => \%dependend_properties,
	     HandlesByNumber     => \%handle_no );
}


#############################################################################
# Input:  - PROPERTY/KEYBINDINGS-Confighash
# Output: - Hash of all handle numbers (Handle number => Handle-ID)
sub _getHandleInfos {
    my ($self, $inout, $property) = @_;

    my %handle_no;
    
    my %io_hash = ( IN => 'R', OUT => 'W' );
    my $access = $io_hash{$inout};
    
    foreach my $io (@{$property->{$inout}},
		    @{$property->{INOUT}}) {
	
	# SECTION and HANDLES
	foreach my $target (qw(SECTION HANDLE)) {
	    
	    my $id = $io->{$target};
	    unless (defined $id) {
		#black("WARNING: no $target ID specified.");
		next;
	    }
	    
	    my $t = $self->{_config}->{$target}->{$id};
	    unless (defined $t) {
		die("$target '$id' does not exist");
		next;
	    }
	    
	    # no errors found:
	    #black("   ######## $target=$id");
	    if ($target eq 'SECTION') {
		# ... obsolet?
	    }
	    elsif ($target eq 'HANDLE') {
		unless (defined $t->{ACCESS}) {
		    die("$target ID '$id' has no ACCESS tag");
		    next;
		}
		
		unless ($t->{ACCESS} =~ /$access/) {
		    die("$target '$id' is not usable for $inout");
		    next;
		}
		
		my $no = $t->{NO};
		$handle_no{$no} = $id;
	    }
	}
    }
    
    return %handle_no;
}




sub property {
    my ($self, $id) = @_;
    return $self->{_config}->{PROPERTY}->{$id};
}

sub keyBindings {
    my ($self, $id) = @_;
    return $self->{_config}->{KEYBINDINGS};
}

sub section {
    my ($self, $id) = @_;
    return $self->{_config}->{SECTION}->{$id};
}

sub handle {
    my ($self, $id) = @_;
    return $self->{_handles}->{$id};
}

sub definition {
    my ($self, $name) = @_;
    return $self->{_definitions}->{$name};
}



1;


__END__

=head1 NAME

PaulA::ProviderConfig - Represents a provider configuration



=head1 SYNOPSIS

 (only for internal use in Provider.pm)


=head1 DESCRIPTION

This module represents a provider configuration.



=head1 CONSTRUCTOR

=over 4

=item new([OPTIONS])

C<OPTIONS> are passed in a hash like fashion, using key and value pairs.
The possible options are:

B<Filename> - Specifies the name of the XML config file.
This Option is optional. 



=head1 METHODS

=item init($filename)

Reads the specified XML config file. You must use this function unless you
specified the B<Filename> option in new().

=item getPropertyInfos()

This function returns handle and property concerning informations from
the config file.

The possible options are:

B<InOut> - Valid values are 'IN' or 'OUT' to specify if you want the
relevant input or output informations.

B<PropertyList> - Array reference of all property names to search for.

The function returns a hash with the following key and value pairs:

B<RequestedProperties> - An hash with all requested properties mapping the
property name (=key) to the property hash like read from the XML config file
(=value).

B<HandlesByNumber> - An hash of all requested handles mapping the handle number
(=key) to the the handle hash like read from the XML config file (=value).



=item property()

Returns the property hash like read from the XML config file.

=item section()

Returns the section hash like read from the XML config file.

=item handle()

Returns the handle hash like read from the XML config file.



=head1 SEE ALSO

L<PaulA::Provider>, L<PaulA::ProviderHandle>



=head1 AUTHOR

 Volker Moell <moell@gmx.de>



=head1 COPYRIGHT

Copyright (c) 2000 ID-PRO Deutschland GmbH. All rights reserved.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307,
USA.

=cut
