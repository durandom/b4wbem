use strict;

######################################
package CIM::OperationResponseMessage;
######################################
use Carp;
use Carp::Assert;

use base qw(CIM::OperationMessage);

use CIM::IMethodResponse;
use CIM::MethodResponse;
use CIM::Utils;


sub new {
    my ($class, %args) = @_;
    
    my $self = $class->SUPER::new(%args);
    
    $self->{'CIM::OperationResponseMessage::_responses'} = [];
    
    $self->{_identifier} = 'OperationResponseMessage';
    
    $self->processArgs(%args);
    
    return $self;
}

sub addResponse {
    my ($self, $c) = @_;
    
    push @{$self->{_responses}}, $c;
}


sub _init {
    my ($self, %args) = @_;
}


sub isIMethodResponse {
    my $self = shift;

    return ($self->{_responses}->[0]->id eq 'IMethodResponse');
}

sub isMethodResponse {
    my $self = shift;

    return ($self->{_responses}->[0]->id eq 'MethodResponse');
}

sub response {
    my $self = shift;

    # Currently only SIMPLE (= single) responses:
    return ($self->{_responses}->[0]);
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

    # Currently, we only support SIMPLERSP's:
    assert(scalar(@{$self->{_responses}} == 1));

    my $simplersp = $doc->createElement("SIMPLERSP");
    $message->appendChild($simplersp);

    my $rsp = $self->{_responses}->[0]->toXML;
    $rsp->getDocumentElement()->setOwnerDocument($doc);
    $simplersp->appendChild($rsp->getDocumentElement());
    
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

    my $multi = $root->getElementsByTagName('MULTIRSP')->[0];
    assert(not defined $multi);

    # If we support multireqs one day, here must be done something
    # like "foreach child of $multi..."
    
    # Ok, do we have an IMethodResponse or an MethodResponse?
    my $resp;

    if ($root->getElementsByTagName('IMETHODRESPONSE')->[0]) {
	$resp = $root->getElementsByTagName('IMETHODRESPONSE')->[0];
	$self->addResponse(CIM::IMethodResponse->new(XML => $resp));
    } else {
	$resp = $root->getElementsByTagName('METHODRESPONSE')->[0];
	$self->addResponse(CIM::MethodResponse->new(XML => $resp));
    }
}


sub toString {
    my ($self) = @_;

    return "CIMVERSION: " . $self->CIMVersion . "\n" .
	"DTDVERSION: " . $self->DTDVersion . "\n" .
	    "MESSAGEID: " . $self->messageID . "\n" .
		"PROTOCOLVERSION: " . $self->protocolVersion . "\n" .
		    $self->response->toString;
}



1;


__END__

=head1 NAME

CIM::OperationResponseMessage - represents a CIM Operation Response Message



=head1 SYNOPSIS

    use CIM::OperationResponseMessage;
    
    $response = $opResp->response;


=head1 DESCRIPTION

CIM::OperationResponseMessage - represents a CIM Operation Response Message


=head1 CONSTRUCTOR

=over 4

=item new([OPTIONS])

C<OPTIONS> are passed in a hash like fashion, using key and value pairs.
The possible options are:

B<XML> - Read the instance from the given XML::DOM element or document. 
Only used as sole option. If additional options are given they
will be ignored.

B<MessageID> - mandatory unless B<XML> is given. The unique ID number of
the message.


=head1 METHODS

=item addResponse($r)

Input: CIM::IMethodResponse or CIM::MethodResponse object.
No return value.
    
=item isIMethodResponse()

Return value: 1 or 0, depending on wether the request is an IMethodResponse 
or not.
    
=item isMethodResponse()

Return value: 1 or 0, depending on wether the request is a MethodResponse 
or not.
    
=item response()

Get function. Works only for single responses.
Return value: CIM::IMethodResponse or CIM::MethodResponse object.

=item toXML()

Returns a XML::DOM document representation of the instance.

=item fromXML()

Creates an instance from the XML::DOM::Element $node and returns it.
Not inherited, function from CIM::Base is overloaded.

=item toString()

Returns the instance as a string (for debugging purposes only).


=head1 SEE ALSO

L<CIM::Base>, L<OperationMessage.pm>, L<IMethodResponse.pm>, 
L<MethodResponse.pm>


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
