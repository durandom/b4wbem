use strict;

###########################
package CIM::NamespacePath;
###########################
use Carp;

use base qw(CIM::Base);
use CIM::Utils;

sub new {
    my ($class, %args) = @_;
    
    my $self = $class->SUPER::new();
    
    $self->{'CIM::NamespacePath::_namespace'} = [];
    $self->{'CIM::NamespacePath::_host'} = undef;
    
    $self->{_identifier} = 'CIMNamespacePath';
    
    $self->processArgs(%args);
    
    return $self;
}


sub _init {
    my ($self, %args) = @_;
    
    # Set namespace; default: 'root'
    if (defined $args{Namespace}) {
	$self->namespace($args{Namespace});
    }
    else {  # default
	$self->namespace( [ qw(root) ] );
    }
    
    # Set host, not set by default
    $self->{_host} = $args{Host}; 
}




# set and get routine
sub namespace {
    my $self = shift;
    
    if (defined $_[0]) {
	# input is an array reference
	if (ref $_[0]) {
	     $self->{_namespace} = $_[0] if defined $_[0];
	}
	# input is a string
	else {
	    $self->{_namespace} = [ split /\//, $_[0] ];
	}
    }
    
    if (wantarray) {
	return @{$self->{_namespace}};
    }
    else {
	return join '/', @{$self->{_namespace}};   # scalar context
    }
}

# set and get routine
sub host {
    my $self = shift;
    
    $self->{_host} = $_[0] if defined $_[0];
    
    return $self->{_host};
}


sub isLocal {
    my $self = shift;
    
    defined $self->{_host}? return 0 : return 1;
}



sub toXML {
    my $self = shift;

    my $doc = XML::DOM::Document->new();
    my $root = $doc;    

    my $tag = ($self->isLocal)? 'LOCALNAMESPACEPATH' : 'NAMESPACEPATH';
    my $path = $doc->createElement($tag);
    $doc->appendChild($path);
    $root = $path;    
    
    if ($tag eq 'NAMESPACEPATH') {
	my $host = $doc->createElement('HOST');
	my $lnsp = $doc->createElement('LOCALNAMESPACEPATH');
	$root->appendChild($host);	
	$host->addText($self->host);
	$root->appendChild($lnsp);	
	$root = $lnsp;
    }

    foreach my $name ($self->namespace()) {
   	my $ns = $doc->createElement('NAMESPACE');
    	$root->appendChild($ns);
    	$ns->setAttribute('NAME', "$name");
    }

    return $doc;
}


sub fromXML {
    my ($self, $node) = @_;
    
    unless ($node->getNodeName eq 'LOCALNAMESPACEPATH' ||
	    $node->getNodeName eq 'NAMESPACEPATH') {
	$self->error("Invalid Root Element: " . $node->getNodeName);
    }
    
    if ($node->getNodeName eq 'NAMESPACEPATH') {
	my @nodes = $node->getChildNodes();
	foreach my $child (@nodes) {
	    if ($child->getNodeName() eq 'HOST') {
		$self->{_host} = $child->getFirstChild->getData(); # case empty?
	    }
	    else {
		# set LOCALNAMESPACEPATH node to $node
		$node = $child;
	    }
	}     
    }    

    my @ns;
    foreach my $child ($node->getChildNodes()) {
	push @ns, $child->getAttributes->getNamedItem('NAME')->getValue();
    }
    
    $self->{_namespace} = \@ns;
}


sub toString {
    my $self = shift;
    
    return "Namespace: `" . $self->namespace . "', Host: " .
	(defined $self->{_host} ? "`$self->{_host}'" : "[unspecified]");
}



1;


__END__


=head1 NAME

CIM::NamespacePath - Class encapsulating both a LOCALNAMESPACEPATH and a NAMESPACEPATH CIM XML element.



=head1 SYNOPSIS

 use CIM::NamespacePath;

 $nsp =	
    CIM::NamespacePath->new(Namespace => [qw(root my new namespace)]);

 # alternative syntax:
 $nsp = 
    CIM::NamespacePath->new(Namespace => 'root/my/new/namespace'); 
    

 $doc = $nsp->toXML();
 $nsp2 = CIM::NamespacePath->new(XML => $doc);

 $ns = $nsp->namespace();   # scalar context
 @ns = $nsp->namespace();   # list context
 
 $host = $nsp->host();
 
 $bool = $nsp->isLocal();   # is it a LOCALNAMESPACEPATH?
 
 print $nsp->toString(), "\n";



=head1 DESCRIPTION

The CIM::NamespacePath module encapsulates the CIM XML elements NAMESPACEPATH 
and LOCALNAMESPACEPATH. A CIM::NamespacePath consists of a host (optional),
and a namespace.



=head1 CONSTRUCTOR

=over 4

=item new([OPTIONS])

C<OPTIONS> are passed in a hash like fashion, using key and value pairs.

B<XML> - Read the instance from the given XML::DOM element or document. 
Only used as sole option. If additional options are given they
will be ignored.

B<Namespace> - The namespace, optional. 'root' is the default.	
Value may be given as string or array reference. 

B<Host>	- The host, if given you get a NAMESPACEPATH representation,
otherwise a LOCALNAMESPACEPATH.	Default is undef.



=head1 METHODS

=item _init([OPTIONS])

Called only by new(). Initialization of class variables.


=item host(['hostname'])

Get/set function for the host part of a NamespacePath.
Return value: string, name of the host.

=item namespace([$nsp])

Input: optional, array reference or string (internally the 
namespace is stored as an array reference).
When called with an argument ( [qw(root my new namespace)] or 
"root/my/new/namespace"), the new namespace is set.

Return value:
Namespace as a single string when called in scalar context:
"root/my/new/namespace",
array in list context: ("root", "my", "new", "namespace").

=item isLocal()

Returns 1 if it's a LOCALNAMESPACEPATH (no host is defined) and 0
otherwise.

=item toXML()

Returns a XML::DOM document representation of the instance.

=item fromXML($node)

Creates an instance from the XML::DOM::Element $node and returns it.
Not inherited, function from CIM::Base is overloaded.

=item toString()

Returns the whole content as a single string.



=head1 SEE ALSO

L<CIM::Base>, L<CIM::ObjectName>



=head1 AUTHOR

 Axel Miesen <miesen@ID-PRO.de>
 Eva Bolten <bolten@ID-PRO.de>	



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
