use strict;

#####################################
package CIM::OperationRequestMessage;
#####################################
use Carp;

use base qw(CIM::OperationMessage);

use CIM::IMethodCall;
use CIM::MethodCall;
use Carp::Assert;


sub new {
    my ($class, %args) = @_;
    
    my $self = $class->SUPER::new(%args);

    $self->{'CIM::OperationRequestMessage::_calls'} = [];

    $self->{_identifier} = 'OperationRequestMessage';
    
    $self->processArgs(%args);
    
    return $self;
}


sub _init {
    my ($self, %args) = @_;
}



sub addCall {
    my ($self, $c) = @_;
    
    push @{$self->{_calls}}, $c;
}


sub isIMethodCall {
    my $self = shift;

    return ($self->{_calls}->[0]->id eq 'IMethodCall');
}


sub isMethodCall {
    my $self = shift;

    return ($self->{_calls}->[0]->id eq 'MethodCall');
}



sub call {
    my $self = shift;

    # Currently only SIMPLE (= single) calls:
    return ($self->{_calls}->[0]);
}


sub toXML {
    my $self = shift;
    
    my $doc = XML::DOM::Document->new();
    
    my $decl = XML::DOM::XMLDecl->new();
    $decl->setVersion("1.0");
    $decl->setEncoding("utf-8");
    $doc->setXMLDecl($decl);


    my $cim = $doc->createElement("CIM");
    $cim->setAttribute("CIMVERSION", scalar $self->{_CIMVersion});
    $cim->setAttribute("DTDVERSION", scalar $self->{_DTDVersion});
    $doc->appendChild($cim);
    
    my $message = $doc->createElement("MESSAGE");
    $message->setAttribute("ID", scalar $self->{_messageID});
    $message->setAttribute("PROTOCOLVERSION",
			   scalar $self->{_protocolVersion});
    $cim->appendChild($message);

    # Currently, we only support SIMPLEREQ's:
    assert(scalar(@{$self->{_calls}} == 1));

    my $simplereq = $doc->createElement("SIMPLEREQ");
    $message->appendChild($simplereq);
	    
    my $call = $self->{_calls}->[0]->toXML;
    $call->getDocumentElement()->setOwnerDocument($doc);
    $simplereq->appendChild($call->getDocumentElement());
    
    return $doc;
}


sub fromXML {
    my ($self, $root) = @_;

    $root = $root->getDocumentElement()
	if ($root->getNodeName() eq '#document');

    $self->CIMVersion($root->getAttributes->
		      getNamedItem('CIMVERSION')->getValue());
    $self->DTDVersion($root->getAttributes->
		      getNamedItem('DTDVERSION')->getValue());
		      
    my $message = $root->getElementsByTagName('MESSAGE')->[0];
    $self->messageID($message->getAttributes->getNamedItem('ID')->getValue());
    $self->protocolVersion($message->getAttributes->
			   getNamedItem('PROTOCOLVERSION')->getValue());

    my @multi = $root->getElementsByTagName('MULTIREQ');

    assert(not scalar @multi);

    # If we support multireqs one day, here must be done something
    # like "foreach child of $multi..."

    
    # Ok, do we have an IMethodCall or an MethodCall?
    my $call;
    
    if ($root->getElementsByTagName('IMETHODCALL')->[0]) {
	$call = $root->getElementsByTagName('IMETHODCALL')->[0];
	$self->addCall(CIM::IMethodCall->new(XML => $call));
    } else {
	$call = $root->getElementsByTagName('METHODCALL')->[0];
	$self->addCall(CIM::MethodCall->new(XML => $call));
    }
}


sub toString {
    my ($self) = @_;

    return "CIMVERSION: " . $self->CIMVersion . "\n" .
	"DTDVERSION: " . $self->DTDVersion . "\n" .
	    "MESSAGEID: " . $self->messageID . "\n" .
		"PROTOCOLVERSION: " . $self->protocolVersion . "\n" .
		    $self->iMethodCall->toString;
}



1;


__END__

=head1 NAME

CIM::OperationRequestMessage - represents a CIM Operation Request Message



=head1 SYNOPSIS

    use CIM::OperationRequestMessage;

    $opReq = 
	CIM::OperationRequestMessage->new( MessageID => 
					    scalar CIM::IDGenerator->new->id());
	


=head1 DESCRIPTION

CIM::OperationRequestMessage - represents a CIM Operation Request Message


=head1 CONSTRUCTOR

=over 4

=item new([OPTIONS])

C<OPTIONS> are passed in a hash like fashion, using key and value pairs.
The possible options are:

B<XML> - Read the instance from the given XML::DOM element or document. 
Only used as sole option. If additional options are given they
will be ignored.

B<MessageID> - mandatory unless B<XML> is given. A unique number, 
which should be generated via CIM::IDGenerator->new->id().


=head1 METHODS

=item addCall($c)

Input: CIM::IMethodCall or CIM::MethodCall object.
No return value.
    
=item isIMethodCall()

Return value: 1 or 0, depending on wether the request is an IMethodCall or not.
    
=item isMethodCall()

Return value: 1 or 0, depending on wether the request is a MethodCall or not.
    
=item call()

Get function. Works only for single calls in a request.
Return value: CIM::IMethodCall or CIM::MethodCall object.

=item toXML()

Returns a XML::DOM document representation of the instance.

=item fromXML()

Creates an instance from the XML::DOM::Element $node and returns it.
Not inherited, function from CIM::Base is overloaded.

=item toString()

Returns the instance as a string (for debugging purposes only).


=head1 SEE ALSO

L<CIM::Base>, L<OperationMessage.pm>, L<IMethodCall.pm>, L<MethodCall.pm>


=head1 AUTHOR

 Axel Miesen <miesen@ID-PRO.de>



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
