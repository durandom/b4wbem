use strict;

####################
package CIM::Client;
####################
use Carp;
use Carp::Assert;

use Tie::SecureHash;
use XML::Simple;

use CIM::NamespacePath;
use CIM::ObjectName;
use CIM::ParamValue;
use CIM::Value;
use CIM::DataType;
use CIM::IMethodCall;
use CIM::MethodCall;
use CIM::IMethodInfo;
use CIM::IDGenerator;
use CIM::OperationRequestMessage;
use CIM::OperationResponseMessage;
use CIM::Transport::HTTP;
use CIM::Utils;


my $nameOfConfigEnvVar = 'CIM_CLIENT_CONFIG';


#
# Constructor of CIM::Client.
# 
sub new {
    my ($class, %args) = @_;
    
    my $self = Tie::SecureHash->new($class);
    
    $self->{'CIM::Client::_useConfig'} = 0;
    

    $self->{'CIM::Client::_host'} = undef;
    $self->{'CIM::Client::_port'} = undef;
    $self->{'CIM::Client::_name'} = undef;
    $self->{'CIM::Client::_user'} = undef;
    $self->{'CIM::Client::_password'} = undef;
    $self->{'CIM::Client::_namespacePath'} = undef;
    
    $self->{_useConfig} = $args{UseConfig} if defined($args{UseConfig});

    my $config = {};
    
    if ($self->{_useConfig}) {
	# $self->{_useConfig} can be a filename or just a true value like '1'.

	
	my $configfile = ($self->{_useConfig} eq '1'
			  ? $ENV{$nameOfConfigEnvVar}
			  : $self->{_useConfig} );

	defined $configfile or
	    fatal("UseConfig wanted, but $nameOfConfigEnvVar " .
		  "environment variable is not set");
	
	-r $configfile or
	    fatal("Cannot obtain configuration data from `$configfile'");

	eval { $config = XMLin($configfile) };
	if ($@) {
	    fatal("An error ocurred while parsing $configfile.\n" .
		  "XML parser error message:" . $@);
	}
    }

    $self->{_host} = defined($args{Host}) ?
	$args{Host} : $config->{cimom}->{host};
	
    $self->{_port} = defined($args{Port}) ?
	$args{Port} : $config->{cimom}->{port};
	
    $self->{_name} = defined($args{Name}) ?
	$args{Name} : $config->{cimom}->{name};
	
    $self->{_namespacePath} = defined($args{NamespacePath}) ?
	$args{NamespacePath} :
	    CIM::NamespacePath->
		  new(Namespace => $config->{namespace}->{default});
	
    $self->{_user} = defined($args{User}) ?
	$args{User} : $config->{secrets}->{user};
    
    $self->{_password} = defined($args{Password}) ?
	$args{Password} : $config->{secrets}->{password};
	

    # Now we MUST have values for all the variables:
    foreach my $var (qw(_host _port _name _user _password _namespacePath)) {
	unless (defined $self->{$var}) {
	    $_ = $var;
	    s/_(.)/\U$1/;
	    fatal("Neither constructor call nor config file " .
		  "contains value for $_");
	}
    }
	    
    return $self;
}



# set and get routine
sub namespacePath {
    my $self = shift;
    
    $self->{_namespacePath} = $_[0] if defined $_[0];
    
    return $self->{_namespacePath};
}



use vars '$AUTOLOAD';


#
# This is the place where all intrinsic method calls (like GetClass,...)
# lead to.
#
sub AUTOLOAD {
    my ($self, %args) = @_;
    
    return if $AUTOLOAD =~ /::DESTROY$/; # see Conway, p. 112

    
    # get name of the intrinsic method:
    my $method;
    ($method = $AUTOLOAD) =~ s/.*:://;

    my $info = CIM::IMethodInfo->new;

    $info->isValidIMethodName($method) or
	fatal("`$method' is not a valid intrinsic method name\n");
    
    # $method now is e.g. "GetClass".

    # test whether all parameters are valid:
    foreach my $param (keys %args) {
	fatal("$param is not a valid parameter name\n")
	    unless $info->isValidParameterName($method, $param);
    }
    
    my $imc = CIM::IMethodCall->
	new(MethodName    => $method,
	    NamespacePath => scalar $self->{_namespacePath});
    
    my @params = ();  # becomes an array of CIM::ParamValue's


    
    foreach my $param ($info->parameters($method)) {
	
	my $obj;
	my $class = $info->class($method, $param);
	
	# if parameter specified:
	if (exists $args{$param}) {
	    if (ref $args{$param}) {

		my $requiredType =
		    $info->isArray($method, $param) ? 'ARRAY' : $class;
		ref($args{$param}) eq $requiredType or
		    fatal "Wrong type for parameter $param " .
			"(must be $requiredType)\n";
	    } else {
		fatal("Parameter $param must be array")
		    if $info->isArray($method, $param);
		
		$class eq 'CIM::Value' or
		    fatal "Wrong type for parameter $param (must be $class)\n";
	    }
	    
	    $obj = ($info->isArray($method, $param) or not ref($args{$param}))
		    ? CIM::Value->new(Value => $args{$param},
				      Type  => $info->type($method, $param))
		    : $args{$param};
	}
	# if parameter is *not* specified:
	else {
	    fatal "Parameter $param is mandatory\n"
		if ($info->isMandatory($method, $param));
	    
	    next;
	}

	my $c = $info->extractClass($method)->[0];
	
	if (defined $c and $param eq $c) { # TODO: Better...
	    
	    my $ctype = $info->convertType($method, $param);
	    $obj->convertType($ctype) if defined $ctype;
	    
	    # determine whether we have a namespace path in the given object.
	    # If so, change the NamespacePath into it:
	    #
	    # Not yet implemented!!!
	    #
	}
	else {
	    # We can continue with the next foreach, except in the case
	    # that the parameter is mandatory, or:
	    # ...
	    
	    my $nullAllowed = $info->nullAllowed($method, $param);
	    
	    fatal "undef not allowed for parameter $param\n"
		if ((exists $args{$param} and not defined $args{$param})
		    and not $nullAllowed);
	}

	if (not defined $obj) {
	    fatal "undef for parameter $param not allowed\n"
		unless $info->nullAllowed($method, $param);
	}
	
	push @params, CIM::ParamValue->new(Name        => $param,
					   Value       => $obj,
					   ConvertType => 'IPARAMVALUE');
    }

    $imc->parameters(@params);

    my $opResp = $self->_request($imc);
    

    # No error, let's return...
    if ($info->returnValueCanBeMissing($method)) {
	return ($opResp->response->returnValue->values)[0];
    } elsif ($info->returnValueIsVoid($method)) {
	return;
    } elsif ($info->returnValueIsScalar($method)) {
	return ($opResp->response->returnValue->values)[0];
    } elsif ($info->returnValueIsArray($method)) {
	return $opResp->response->returnValue->values;
    } else {
	fatal("This message should not appear");
    }
}


sub _request {
    my ($self, $call) = @_;

    my $opReq = CIM::OperationRequestMessage->
	new(MessageID => scalar CIM::IDGenerator->new->id());

    $opReq->addCall($call);

    my $t = CIM::Transport::HTTP->new();

    my $opResp;
    eval { $opResp = $t->request($opReq,
				 scalar $self->{_host},
				 scalar $self->{_port},
				 scalar $self->{_name},
				 scalar $self->{_user},
				 scalar $self->{_password}) };
    if ($@) {
	# This *must* be some internal error; a CIM error would
	# be encoded in $opResp and wouldn't have caused this
	# exception.
	
	# Just propagate it:
	die "unknown internal error: $@";
    }
    
    # $opResp now is an instance of CIM::OperationResponseMessage.
    
    # Is that correct?
    die $opResp->response->error
	if (defined $opResp->response->error);
    
    return $opResp;
}




#
# Invocation of Extrinsic Methods
#


sub invokeClassMethod {
    my ($self, $objectName, $methodName, @params) = @_;

    $objectName->convertType('CLASSNAME');
    
    # Safe is safe...
    $objectName->deleteKeyBindings();

    $self->_invokeMethod($objectName, $methodName, @params);
}


sub invokeObjectMethod {
    my ($self, $objectName, $methodName, @params) = @_;

    $objectName->convertType('INSTANCENAME');

    $self->_invokeMethod($objectName, $methodName, @params);
}



sub _invokeMethod {    
    my ($self, $objectName, $methodName, @params) = @_;
    
    $objectName->namespacePath(scalar $self->{_namespacePath})
	unless (defined $objectName->namespacePath);

    
    my $mc = CIM::MethodCall->
	new(MethodName => $methodName,
	    LocalPath  => scalar $objectName);

    foreach (@params) { $_->convertType('PARAMVALUE'); }
    $mc->addParameter(@params);

    my $opResp = $self->_request($mc);
    
    return ($opResp->response->returnValue->values)[0];
}
    
    
    
    


1;



__END__

=head1 NAME

CIM::Client - essential class for building CIM Clients



=head1 SYNOPSIS

 use CIM::Client;

 my $cc = CIM::Client->new(UseConfig => 1,
                           Port      => 24666,
                           ...);

 [my $result =] $cc->[IntrinsicMethod](Arg1 => Value1,
                                       Arg2 => Value2,
                                       ...);



=head1 DESCRIPTION

The CIM::Client class enables you to translate the Intrinsic Methods described
in [1] to Perl. It offers a "high level" interface for communication
with a CIM Object Manager. Internally, it transforms your request to XML
(see the examples at the end of [1]), and sends it via HTTP to the cimom
you specified in the constructor. It waits for the response (which of
course is XML, too), and transforms it back to some "high level" Perl object.
(E.g. the result of a GetClass() is a CIM::Class object.)

Please see L<CIM> for a more detailed explanation of the API.


=head1 CONSTRUCTOR

=over 4   

=item new([OPTIONS])

C<OPTIONS> are passed in a hash like fashion, using key and value pairs.
Recognized options are:

=item B<UseConfig>

Takes a filename or just a boolean value to determine whether an
external configuration shall
be read. See L<"CONFIGURATION FILE"> for defaults.

=item B<Host>

The name of the host where the cimom of your interest resides (e.g.
"localhost").

=item B<Port>

The port number this cimom listens to.

=item B<Name>

The name of this cimom (probably something like "cimom" ;-))

Example: If we haves values "localhost", "24666" and "cimom" for the 'Host',
'Port' and 'Name' options resp., then the requests go to the URL

F<http://localhost:24666/cimom>.

=item B<NamespacePath>

A CIM::NamespacePath object that determines to which CIM namespace your
requests will go.

=item B<User>, B<Password>

Used for authentication/authorization.

=back

In any case, values for B<all> options must be given (otherwise, an exception
will be thrown). You can mix external configuration and "hardcoded" values
in the constructor call. In this case the latter are stronger.

=head1 CONFIGURATION FILE

If you specify a "UseConfig => 1" in the CIM::Client constructor call,
it tries to obtain configuration data from an external file.
There is no default for the name of this file; it is determined by the
value of the environment variable I<CIM_CLIENT_CONFIG>. (Remark for
mod_perl programmers: With the C<SetEnv> directive (mod_env) you can
set and pass environment variables to your modules.)

If you specify a "UseConfig => FILENAME", 
it tries to obtain configuration data from FILENAME.

CIM::Client uses XML as configuration file syntax.
The I<config> root element must contain I<cimom>, I<namespace> and I<secrets>
subelements.

The I<cimom> element takes three arguments 'host', 'port' and 'name' with
obvious meanings.

The I<namespace> element takes an argument 'default' that describes
the name of the default namespace (something like "root" or "root/cimv2").

The I<secrets> element must contain a I<user> and a I<password> element;
their content is needed for CIM authentication. Since those informations
are given in clear text, we suggest to source out the I<secrets>
hierarchy into another file with stricter read permissions, and to include
it in the main configuration via the XML entity mechanism.

=head2 Configuration file example

 <config>

   <cimom host="localhost"
          port="24666"
          name="cimom" />

   <namespace default="root/PaulA" />

   <secrets>
     <user>cimmaster</user>
     <password>LetMeIn</password>
   </secrets>

 </config>


=head1 METHODS

The CIM client can handle many Intrinsic Methods. The exceptions are
labeled in to following list:


=head2 Basic Read

=item GetClass()

=item EnumerateClasses()

=item EnumerateClassNames()

=item GetInstance()

=item EnumerateInstances()

=item EnumerateInstanceNames()

=item GetProperty()



=head2 Basic Write

=item SetProperty()

=item CreateInstance()

=item ModifyInstance()

=item DeleteInstance()



=head2 Schema Manipulation

=item CreateClass()

=item ModifyClass() B<currently not supported> 

=item DeleteClass()



=head2 Qualifier Declaration 

=item GetQualifier() B<currently not supported> 

=item SetQualifier() B<currently not supported> 

=item DeleteQualifier() B<currently not supported> 

=item EnumerateQualifiers() B<currently not supported> 



=head2 Query Execution

=item ExecQuery() B<currently not supported> 



=head2 Association Traversal

=item Associators()

=item AssociatorNames()

=item References()

=item ReferenceNames()



=head1 REFERENCES

 1. "Specification for CIM Operations over HTTP",
     Version 1.0, DMTF, August  11th, 1999,
     (http://www.dmtf.org/download/spec/xmls/CIM_HTTP_Mapping10.htm)


=head1 AUTHORS

 Axel Miesen  <miesen@ID-PRO.de>
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
