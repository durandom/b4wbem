use strict;

#####################
package PaulA::CIMOM;
#####################
use Carp;
use Carp::Assert;

use File::Basename;
use File::PathConvert;
use XML::DOM;
use XML::Simple;
use Tie::SecureHash;

use CIM::IMethodCall;
use CIM::IMethodResponse;
use CIM::MethodCall;
use CIM::MethodResponse;
use CIM::Utils;
use CIM::Class;
use CIM::ReturnValue;
use CIM::Error;
use CIM::OperationRequestMessage;
use CIM::OperationResponseMessage;

use PaulA::ServerConfig;

use PaulA::Repository;
use PaulA::Provider;

use Apache::Constants ':response';
use Apache::Log;




sub new {
    my ($class, $r) = @_;

    my $self = {};
    $self->{_r} = $r;
    $self->{_opReq} = undef;  # the request...
    $self->{_opResp} = undef; # ...and the response
    
    $self->{_config} = PaulA::ServerConfig->
	new(Path           => $r->dir_config('path'),
	    ValParser      => $r->dir_config('valparser'),
	    RepositoryRoot => $r->dir_config('repository'),
	    Sandbox        => $r->dir_config('sandbox'),
	    User           => $r->dir_config('user'),
	    Password       => $r->dir_config('password'),
	   );
    
    bless $self, $class;
}


sub config {
    my $self = shift;
    
    return $self->{_config};
}

sub log {
    my $self = shift;
    
    return $self->{_r}->log;
}



####################
# Main entry point #
####################
sub handleRequest ($$) {
    my ($self, $r) = @_;

    # create a cimom object:
    unless (ref($self)) {
	$self = $self->new($r);
    }

    $CIM::Utils::verbose = 0 unless $r->server->loglevel == Apache::Log::DEBUG;

    # set PATH to a trusted value:
    $ENV{PATH} = $self->{_config}->path;
    
    # Currently we dont't support M-POST:
    if ($r->method eq 'M-POST') {
	$r->log->warn("client attempted M-POST method invocation");
	return NOT_IMPLEMENTED;
    }

    # It *must* be POST:
    if ($r->method ne 'POST') {
	my $method = $r->method() || "UNKNOWN";
	$r->log->error("client attempted a " . $method . " method invocation");
	
	return SERVER_ERROR;
    }


    my $body;
    $r->read($body, $r->header_in('Content-length'));
	
    
    if ($r->server->loglevel == Apache::Log::DEBUG) {
	print STDERR "----- Request -----\n";

	my %header = $r->headers_in();
	while (my ($key, $value) = each %header) {
	    print STDERR "$key: $value\n";
	}
	
	print STDERR "\n";
	print STDERR prettyXML($body);
    }


    
    # $string now (probably) contains some XML request.
    # Try to parse it:

    my $parser = XML::DOM::Parser->new();
    my $doc;
    
    
    # Error message for ill-formed or invalid documents:
    my $request_not_valid = <<END_OF_request_not_valid;
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<HTML><HEAD>
<TITLE>400 Bad Request</TITLE>
</HEAD><BODY>
<H1>Bad Request</H1>
The entity body defining the CIM Operation request was not well-formed
or not valid respect to the CIM XML DTD.<P>
</BODY></HTML>
END_OF_request_not_valid

    
    
    eval { $doc = $parser->parse($body) };
    
    if ($@) { # not well-formed
	$r->log->error("Request not well-formed");
	$r->err_header_out('CIMError', 'request-not-well-formed');
	$r->custom_response(BAD_REQUEST, $request_not_valid);
	
	return BAD_REQUEST;
    }
    

    # Validation:
    my $status;
    unless ($self->_isValid($body, \$status)) {
	unless ($status == SERVER_ERROR) {
	    $r->log->error("Request is well-formed but invalid");
	    $r->err_header_out('CIMError', 'request-not-valid');
	    $r->custom_response($status, $request_not_valid);
	}
	return $status;
    }

    # Test whether there is a MESSAGE subelement under the CIM root element:
    my $message = $doc->getDocumentElement->getChildNodes->[0];

    if ($message->getNodeName ne 'MESSAGE') {
	$r->log->error("document is valid but not a CIM Operation Request");
	# There is no appropriate CIMError for this case!
	$r->err_header_out('CIMError', 'request-not-valid');
	$r->custom_response($status, $request_not_valid);
	return BAD_REQUEST;
    }

    my $req = $message->getChildNodes->[0]->getNodeName;
    
    # At the moment, we only support SimpleReqs:
    unless ($req eq 'SIMPLEREQ') {
	if ($req eq 'MULTIREQ') {
	    $r->err_header_out('CIMError', 'multiple-requests-unsupported');
	    return NOT_IMPLEMENTED;
	} else {
	    $r->log->
		error("document is valid but not a CIM Operation Request");
	    # There is no appropriate CIMError for this case!
	    $r->err_header_out('CIMError', 'request-not-valid');
	    $r->custom_response($status, $request_not_valid);
	    return BAD_REQUEST;
	}
    }

    #########################################################
    # Now we're absolutely sure that we have to deal with a
    # (simple) CIM Operation Request.
    #########################################################


    
    $self->{_opReq} = CIM::OperationRequestMessage->new(XML => $doc);

    # Create the response object. It must have the same message id
    # as the request:
    $self->{_opResp} = CIM::OperationResponseMessage->
	new(MessageID => $self->{_opReq}->messageID);

    
    my $rv = CIM::ReturnValue->new();
    my $error;

    my $resp; # Will become either a IMethodResponse or a
              # MethodResponse object

    
    if ($self->{_opReq}->isIMethodCall) {
	#################################
	# handle Intrinsic Method Calls #
	#################################
	
	$rv->convertType('IRETURNVALUE');

	my $imc = $self->{_opReq}->call;
	my $methodName = $imc->methodName;

	$resp = CIM::IMethodResponse->new(MethodName => $methodName);

	
	my %args;
	# set given values 
	foreach ($imc->parameters) {
	    $args{$_->name} = $_->value;
	}
	

	my @obj;

	# invokeIMethod:
	eval { @obj = $self->invokeIMethod($imc->namespacePath,
					   $methodName,
					   %args) };
	
	if ($@) {
	    if (ref $@ and $@->isa('CIM::Error')) {
		$error = $@;
	    } else {
		$error = CIM::Error->new(Code => CIM::Error::CIM_ERR_FAILED);
		print STDERR "Some internal error occurred:\n";
		print STDERR "($@)\n";
	    }
	    
	} else {
	    my $info = CIM::IMethodInfo->new;
	    if ($info->returnValueCanBeMissing($methodName)) {
		$rv->values($obj[0]) if defined $obj[0];
	    } elsif ($info->returnValueIsVoid($methodName)) {
		;
	    } elsif ($info->returnValueIsScalar($methodName)) {
		$rv->values($obj[0]);
	    } elsif ($info->returnValueIsArray($methodName)) {
		$rv->values(@obj);
	    } else {
		mark("This message should never appear!");
	    }
	}
    }
    else {
	##################################
	# handle Extrinsic Method Calls: #
	##################################
	
	$rv->convertType('RETURNVALUE');

	my $mc = $self->{_opReq}->call;

	my $objectName = $mc->localPath;
	my $methodName = $mc->methodName;
	
  	$resp = CIM::MethodResponse->new(MethodName => $methodName);
	


	my $invokeMethod;
	if ($mc->localPath->convertType eq 'INSTANCENAME') {
	    $invokeMethod = "invokeObjectMethod";
	} else {
	    $invokeMethod = "invokeClassMethod";
	}
	    
	my $result;
	eval { $result = $self->$invokeMethod(scalar $objectName,
					      $methodName,
					      $mc->parameters) };
	    

	if ($@) {
	    if (ref $@ and $@->isa('CIM::Error')) {
		$error = $@;
	    } else {
		$error = CIM::Error->new(Code => CIM::Error::CIM_ERR_FAILED);
		print STDERR "Some internal error occurred:\n";
		print STDERR "($@)\n";
	    }
	} else {
	    $rv->addValue($result);
	}

    }

	    
    if (defined $error) {
	$resp->error($error);
    } else {
	$resp->returnValue($rv);
    }
    
    $self->{_opResp}->addResponse($resp);
    

    # create HTTP response:
    $r->send_http_header;
    $r->print($self->{_opResp}->toXML->toString);

    if ($r->server->loglevel == Apache::Log::DEBUG) {
	print STDERR "----- Response -----\n";

	print STDERR prettyXML($self->{_opResp}->toXML->toString);
    }
    
    return OK;
}



sub invokeIMethod {
    my ($self, $targetNamespace, $methodName, %args) = @_;

    unless ($self->_authenticate) {
	die CIM::Error->new(Code => CIM::Error::CIM_ERR_ACCESS_DENIED);
    }
    
    $self->{_r}->log->
	info("invoking IMethod `$methodName'; target namespace: " .
	      $targetNamespace->namespace);
    
    my $info = CIM::IMethodInfo->new;
    $info->fillArgsWithDefaultValues(\%args, $methodName);
    
    # The value of this variable has to be calculated below.
    # If it remains undef, we use the repository, otherwise we
    # use a provider.
    my $provider = undef;
    
    
    my $classname;
    if (my $c = $info->extractClass($methodName)) {
	if (defined $c and exists $args{$c->[0]}) {
	    # @$c contains in that order: key of named Argument,
	    # function for retrieving the corresponding value
	    my @elem = @$c;
	    my $obj = $args{shift @elem};
    
	    while (scalar @elem > 1) {
		my $func = shift @elem;
		$obj = $obj->$func;
	    };
	    my ($access) = @elem;	     
	    
	    $classname = $obj->$access;
	}
    }

    # check in repository whether the cim-class of the target object exists
    my $repository =
	PaulA::Repository->new(NamespacePath => $targetNamespace,
			       CIMOMHandle   => $self);

    if (defined $classname) {
	$repository->isValidClass($classname)
	    or die CIM::Error->new(Code => CIM::Error::CIM_ERR_INVALID_CLASS);
    }
	
    my $package;
    if (defined $classname) {
	$provider = $self->_provider($targetNamespace,
				     $classname,
				     $methodName);
    }

    my @obj;
    
    if (defined $provider) {
	$self->{_r}->log->info("Asking provider");

	@obj = $provider->$methodName(%args);

    } else {
	$self->{_r}->log->info("Asking repository");

        @obj = $repository->$methodName(%args);
    }

    return @obj;
}




sub invokeObjectMethod {
    my ($self, $objectName, $methodName, @params) = @_;
    
    unless ($self->_authenticate) {
	die CIM::Error->new(Code => CIM::Error::CIM_ERR_ACCESS_DENIED);
    }
    
    my $provider = $self->_provider($objectName->namespacePath,
				    $objectName->objectName);
	
    die CIM::Error->new(Code => CIM::Error::CIM_ERR_FAILED)
	unless defined $provider; # should never happen
    
    return $provider->invokeObjectMethod($methodName, $objectName, @params);
}


sub invokeClassMethod {
    my ($self, $objectName, $methodName, @params) = @_;
    
    unless ($self->_authenticate) {
	die CIM::Error->new(Code => CIM::Error::CIM_ERR_ACCESS_DENIED);
    }
    
    my $provider = $self->_provider($objectName->namespacePath,
				    $objectName->objectName);
	
    die CIM::Error->new(Code => CIM::Error::CIM_ERR_FAILED)
	unless defined $provider; # should never happen
    
    return $provider->invokeClassMethod($methodName, $objectName, @params);
}



sub _provider {
    my ($self, $namespacePath, $classname, $methodName) = @_;

    # Construct file and package name
    my @n = $namespacePath->namespace;
    shift @n;   # get rid of the "root" part
    
    # Our Providers are located in the PaulA/Provider tree:
    unshift @n, ("PaulA", "Provider");
    
    push @n, $classname;
    # @n is now something like ('PaulA', 'Provider', 'test', 'CIM_Person')
    
    my $package = join('::', @n);
    
    # Ok, let's pull in the stuff:
    eval "require $package";
    
    if ($@) {
	$self->{_r}->log->info("no provider for $classname found");
	return undef;
    }
    else {
	$self->{_r}->log->info("found provider for $classname");

	# for extrinsic methods a 'can' check isn't useful.
	# Just return the provider.
	unless (defined $methodName) {
	    return $package->new(NamespacePath => $namespacePath,
				 CIMOMHandle   => $self);
	}

	# Otherwise we have an intrinsic method.
	if ($package->can($methodName)) {
	    return $package->new(NamespacePath => $namespacePath,
				 CIMOMHandle   => $self);
	}
	else {
	    $self->{_r}->log->
		info("$classname provider cannot handle `$methodName'");
	    return undef;
	}
    }
}


sub _authenticate {
    my $self = shift;
    
    my ($res, $password) = $self->{_r}->get_basic_auth_pw;

    return $res unless ($res == OK);

    my $user = $self->{_r}->connection->user;
    
    return ($password and $user and
	    ($user eq $self->{_config}->user) and
	    ($password eq $self->{_config}->password));
}



#
# Test whether a string is a valid CIM_DTD_V20.dtd XML entity
#
# @returns: A true or false value, and the $status reference is set
#           to an appropriate HTTP status code
#
sub _isValid {
    my ($self, $string, $status) = @_;

    my $nsgmls = $self->{_config}->valParser;
    my $dir = dirname(File::PathConvert::rel2abs(__FILE__));
    my $dtd = "$dir/nsgmls/CIM_DTD_V20.dtd";
    
    $ENV{SP_CHARSET_FIXED} = "YES";
    $ENV{SP_ENCODING} = "XML";
    $ENV{SGML_CATALOG_FILES} = $dir . "/nsgmls/xml.soc";


    # If there is any <!DOCTYPE ...> line: delete it. (why should a client
    # prescribe what DTD we have to use?)
    $string =~ s/<!DOCTYPE.*?>//;
    
    # prepend our <!DOCTYPE ...> line:
    $string = qq/<!DOCTYPE CIM SYSTEM "$dtd">\n$string/;

    # print STDERR $string, "\n";
    if (open(NSGMLS, "| $nsgmls -s -wxml")) {
	#open(NSGMLS, "| $nsgmls -s -wxml >/dev/null 2>&1");
	print NSGMLS $string;
	close NSGMLS;
    } else {
	$self->{_r}->log->error("Cannot open $nsgmls");
	$$status = SERVER_ERROR;
	return 0;
    }
    
    if ($? >> 8) { # Document not valid
	$$status = BAD_REQUEST;
	return 0;
    } else {
	$$status = OK;
	return 1;
    }
}


    
1;


=head1 NAME

PaulA::CIMOM - abstract base class for a CIM Object Manager



=head1 SYNOPSIS

 package MyCIMOM;
 use PaulA::CIMOM;

 use base qw(PaulA::CIMOM);

 sub new {
     my ($class, %args) = @_;

     my $self = $class->SUPER::new(%args);
    
     # ...
     
     return $self;
 }


 sub send() {
     my ($self, $response) = @_;
     
     # ...
 }
 
 sub receive() {
     my $self = shift;
     
     # ...
     
     return $request;
 }

=head1 DESCRIPTION

The CIM Object Manager handles the interaction between management
applications (CIM clients) and providers or repository. 

=head1 CONSTRUCTOR

Not intended for direct use.

=head1 METHODS




=head1 AUTHORS

 Axel Miesen <miesen@ID-PRO.de>
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
