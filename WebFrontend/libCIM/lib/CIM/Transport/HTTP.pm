use strict;

#############################
package CIM::Transport::HTTP;
#############################
use Carp;
use LWP::UserAgent;
use MIME::Base64;

use CIM::Utils;
use CIM::OperationResponseMessage;


use base qw(CIM::Transport);


sub new {
    my ($class, %args) = @_;
    
    bless {}, $class;
}


sub request {
    my ($self, $opReq, $host, $port, $name, $user, $password) = @_;
    $name =~ m|^/| or $name = "/$name";
    
    my $ua = LWP::UserAgent->new;
    my $url = 'http://' . $host . ':' . $port . $name;
    
    my $request = HTTP::Request->new(POST => $url);
    
    my $auth = encode_base64($user . ':' . $password);
    $request->header(Authorization => "Basic $auth");
    
    $request->content($opReq->toXML->toString);
    
    my $response = $ua->request($request);
    
    if ($response->is_error) {
	die "Error in CIM::Transport::HTTP: `" . $response->as_string . "'";
    }
    #mark($response->content);
    
    return CIM::OperationResponseMessage->new(XML => $response->content);
}

1;

=head1 NAME

 CIM::HTTP - Class for HTTP requasts


=head1 SYNOPSIS

 use CIM::Transport::HTTP;


=head1 DESCRIPTION

Class for HTTP requests, used by CIM::Client.

=head1 NOTES

Base class Transport.pm doesn't exist anymore.
A reorganization would be desirable.

=head1 CONSTRUCTOR

=over 4

=item new()


=head1 METHODS
 
=item request($opReq, $host, $port, $name, $user, $password)

Input: A CIM::OperationRequestMessage and the class variables 
_host, _port, _name, _user and _password from CIM::Client.

Return value: A CIM::OperationResponseMessage object.

=head1 SEE ALSO

L<CIM::Client>

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


