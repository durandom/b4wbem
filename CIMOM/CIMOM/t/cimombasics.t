use strict;
use lib "t";
use common;

use XML::Simple;



# The intentention of this script is to test basic cimom functionalities
# without use of CIM::Client. 
# Therefore we use LWP::UserAgent for "low level" communication.

use LWP;

my $config = XMLin("$FindBin::Bin/cimclient.xml");

my $url = 'http://';
$url .= $config->{cimom}->{host};
$url .= ":";
$url .= $config->{cimom}->{port};
$url .= "/";
$url .= $config->{cimom}->{name};

my $ua = LWP::UserAgent->new;
my ($request, $response);



# Query status
print STDERR "Query status...\n" if $verbose; 
my $pid = `$FindBin::Bin/cimomtest status`; chomp $pid;
assert($? == 0);
print STDERR "cimom (PID $pid) is running.\n" if $verbose;




# Try M-POST
print STDERR "Try M-POST invocation (must fail)...\n" if $verbose; 
$request = HTTP::Request->new('M-POST' => $url);
$response = $ua->request($request);

assert($response->is_error and
       $response->status_line() eq '501 Method Not Implemented');



# Send some trash
print STDERR "Send some trash...\n" if $verbose; 
$request = HTTP::Request->new('POST' => $url);
$request->content("*@##!?\n");

$response = $ua->request($request);

assert($response->is_error and
       $response->status_line() eq '400 Bad Request' and
       $response->header('CIMError') eq 'request-not-well-formed');



# Send something that is well-formed but invalid:
print STDERR "Send a well-formed but invalid request...\n" if $verbose; 
$request = HTTP::Request->new('POST' => $url);
$request->content("<hello name='cimom'>How are you?</hello>");

$response = $ua->request($request);

assert($response->is_error and
       $response->status_line() eq '400 Bad Request' and
       $response->header('CIMError') eq 'request-not-valid');



# Send something valid that is no Operation Request:
$request = HTTP::Request->new('POST' => $url);
$request->content("<CIM><DECLARATION /></CIM>");

$response = $ua->request($request);

assert($response->is_error and
       $response->status_line() eq '400 Bad Request' and
       $response->header('CIMError') eq 'request-not-valid');



# Send a MULTIREQ:
$request = HTTP::Request->new('POST' => $url);
$request->content(<<EOF_REQUEST);
<CIM CIMVERSION="2.0" DTDVERSION="2.0"><MESSAGE ID="42" PROTOCOLVERSION="1.0"><MULTIREQ><SIMPLEREQ><IMETHODCALL NAME="x"><LOCALNAMESPACEPATH><NAMESPACE NAME="root" /></LOCALNAMESPACEPATH></IMETHODCALL></SIMPLEREQ><SIMPLEREQ><IMETHODCALL NAME="y"><LOCALNAMESPACEPATH><NAMESPACE NAME="root" /></LOCALNAMESPACEPATH></IMETHODCALL></SIMPLEREQ></MULTIREQ></MESSAGE></CIM>
EOF_REQUEST
$response = $ua->request($request);

assert($response->is_error and
       $response->status_line() eq '501 Method Not Implemented' and
       $response->header('CIMError') eq 'multiple-requests-unsupported');


#
# Insert number of tests here:
#
BEGIN { $numOfTests = 6; print "$numOfTests\n"; }

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
