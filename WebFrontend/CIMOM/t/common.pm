use strict;
use vars qw($test $numOfTests);

use FindBin;
use lib "$FindBin::Bin/../../libCIM/lib";
use Term::ANSIColor qw(:constants);
use Getopt::Long;
use vars qw($progname $VERSION $cc $sandbox $verbose);

use vars qw(@ISA @EXPORT);
use Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(restoreSandbox $cc $sandbox $verbose);


use CIM::Client;
use CIM::Utils;

($progname = $0) =~ s|.*/||;
$VERSION = '0.3';

my $assertCounter = 0;
my @failedAsserts;
my $func;           # call this test function, if specified


####################
sub restoreSandbox {
    # ... alle "System-Dateien" und Repository auf den Ursprungszustand bringen
    system("cd $FindBin::Bin/.. ; make sandbox > /dev/null");
}


#######
BEGIN {
    restoreSandbox();
    print "1.."; $| = 1;
}

#####
END {
    if ($verbose and not $func) {
	if ($#failedAsserts == -1) {
	    print "\nAll $assertCounter Tests are ok.  :-)\n";
	    print "WARNING: Got $assertCounter Tests, but expected $numOfTests.\n"
		if ($assertCounter != $numOfTests);
	}
	else {
	    print "\nFailed Tests: ", join(', ', @failedAsserts), "\n";
	}
    }
}


$cc = undef;
$cc = CIM::Client->new(UseConfig => "$FindBin::Bin/cimclient.xml")
    if -e "$FindBin::Bin/cimclient.xml";

$sandbox = "$FindBin::Bin/sandbox";


my $help;
$verbose = undef;   # for interactive and verbose testing
my $asserts;        # quit after specified number of asserts


GetOptions("help"      => \$help,   # unused?
	   "verbose:i" => \$verbose,
	   "assert=i"  => \$asserts,
	   "func=s"    => \$func,
	  ) || usage();

$verbose = 1 if (defined $verbose and $verbose == 0);  # called with "-v"
$verbose = 0 unless defined $verbose;                  # called without -v


###########
sub usage {
    print <<"END_USAGE";
$progname version $VERSION
Usage: $progname [OPTIONS]

Options:
    --help        : list available command line options (this page)
    --verbose:i   : Increases verbosity (with optional verbose level)
    --assert=i    : quit after specified number of asserts
    --func=s      : just call test function test_*()

Options can be used with a single '-' and can be abbreviated.
END_USAGE
    exit(0);
}


###############
sub callTests {
    if (defined $func) {
	my $functionCall = "test_$func";
	print BLUE . "Calling test function $func:" . RESET . "\n";
	
	if (main->can($functionCall)) {
	    eval "$functionCall()";
	}
	else {
	    print RED . "Invalid function: `$functionCall'" . RESET . "\n";
	}
	
	exit 1;
    }
}


############
sub assert {
    my $expr = shift;
    print "  " . ($expr ? GREEN : BOLD . RED) if $verbose;
    ++$test;
    unless ($expr) {
	print "not ";
	push @failedAsserts, $test;
    }
    print "ok $test";
    print RESET if $verbose;
    print " (of $numOfTests)" if $verbose > 2 and not defined $func;
    print "\n";
    $assertCounter++;
    exit if (defined $asserts and $assertCounter == $asserts);
}


#####################
sub _getReturnValue {
    my ($e, $result) = @_;
    
    if ($e) {
	if (ref $e and $e->isa('CIM::Error')) {
	    cpprint $e->toXML->toString if $verbose >= 2;
	    return $e;
	}
	else {
	    die "Return value is no CIM::Error:\n$e";
	}
    }
    else {
	if ($verbose >= 2) {
	    print "Return Value:";
	    if (defined $result) {
		print "\n";
		if (ref($result) eq 'ARRAY') {
		    foreach (@$result) {
			cpprint $_->toXML->toString;
		    }
		}
		else {
		    cpprint $result->toXML->toString;
		}
	    }
	    else {
		print " (void)\n";
	    }
	}
	return $result;
    }
}


#################
sub _checkError {
    my ($result, $errorCode) = @_;
    assert(ref $result eq 'CIM::Error' and $result->code == $errorCode);
}

#################
sub _checkValue {
    my ($result, $cmpvalue) = @_;
    
    # maxbe a CIM::Error?
    if (defined $result and ref $result ne 'CIM::Value') {
	assert(0);
	return;
    }
    
    $result = $result->valueAsRef
	if defined $result;
    
    my $areEqual = areEqual($result, $cmpvalue);
    if (not $areEqual and $verbose >= 3) {
	print STDERR "  value: ", present($result), "\n";
	print STDERR "  expected: ", present($cmpvalue), "\n";
    }
    assert($areEqual);
}


#################
sub _checkCIMOM {
    my ($result, $errorCode) = @_;
    unless (defined $cc) {
	print STDERR "\n" . BOLD . RED . 
	    "    ****************************************************\n" .
	    "    *** The CIM client is undefined.                 ***\n" .
	    "    *** Maybe you should call 'perl -w cimomstart.t' ***\n" .
	    "    ****************************************************\n\n" .
	    RESET;
	$verbose = 0;
	exit 1;
    }
}



############################## GetProperty ##################################

##################
sub _getProperty {
    my ($className, $keyBindings, $propertyName) = @_;
    
    _checkCIMOM();
    
    my $on = CIM::ObjectName->new(ObjectName  => $className,
				  KeyBindings => $keyBindings);
    
    my $result;
    eval { $result = $cc->GetProperty(InstanceName => $on,
				      PropertyName => $propertyName) };

    return _getReturnValue($@, $result);
}

#####################
sub _getProperty_ok {
    my ($className, $keyBindings, $propertyName, $cmpvalue) = @_;
    
    blue("GetProperty: ", present(\@_)) if $verbose;
    
    my $result = _getProperty($className, $keyBindings, $propertyName);
    
    _checkValue($result, $cmpvalue);
}

########################
sub _getProperty_notok {
    my ($className, $keyBindings, $propertyName, $errorCode) = @_;
    
    blue("GetProperty: ", present(\@_)) if $verbose;

    my $result = _getProperty($className, $keyBindings, $propertyName);
    _checkError($result, $errorCode);
}


############################## GetInstance ##################################


##################
sub _getInstance {
    my ($className, $keyBindings, $propertyList) = @_;
    
    _checkCIMOM();
    
    my $on = CIM::ObjectName->new(ObjectName  => $className,
				  KeyBindings => $keyBindings);
    
#      my $proptext = "All Properties";
#      if (defined $propertyList) {
#  	$proptext = "[ " . join(', ', @$propertyList) . " ]";
#      }
    
    my $result;
    if (defined $propertyList) {
	eval { $result = $cc->GetInstance(InstanceName => $on,
					  PropertyList => $propertyList,
					 ) };
    }
    else {
	eval { $result = $cc->GetInstance(InstanceName => $on,
					 ) };
    }
    
    return _getReturnValue($@, $result);
}


#####################
sub _getInstance_ok {
    my ($className, $keyBindings, $propertyList, $valueHash) = @_;
    
    blue("GetInstance: ", present(\@_)) if $verbose;
    
    my $result = _getInstance($className, $keyBindings, $propertyList);
    #print STDERR "ref=" . ref($result) . "\n" if $verbose;
    
    # compare property list:
    {
	my @pids = sort map { $_->name } @{$result->properties};
	my @cmppids = sort keys %$valueHash;
	
	my $areEqual = areEqual(\@pids, \@cmppids);
	
	if (not $areEqual and $verbose >= 3) {
	    print STDERR "  values are: ", present(\@pids), "\n";
	    print STDERR "  expected  : ", present(\@cmppids), "\n";
	}
	assert(areEqual(\@pids, \@cmppids));
    }
    
    # compare each value:
    foreach my $p (@{$result->properties}) {
	my $name = $p->name;
	my $cmpvalue = $valueHash->{$name};
	_checkValue($p->value, $cmpvalue);
    }
}

########################
sub _getInstance_notok {
    my ($className, $keyBindings, $propertyList, $errorCode) = @_;
    
    blue("GetInstance: ", present(\@_)) if $verbose;
    
    my $result = _getInstance($className, $keyBindings, $propertyList);
    #print STDERR "ref=`" . ref($result) . "'\n" if $verbose;
    
    _checkError($result, $errorCode);
}


############################## SetProperty ##################################


##################
sub _setProperty {
    my ($className, $keyBindings, $propertyName, $type, $newValue) = @_;
    
    _checkCIMOM();
    
    my $on = CIM::ObjectName->new(ObjectName  => $className,
				  KeyBindings => $keyBindings);
    
    my %params = ();
    $params{InstanceName} = $on;
    $params{PropertyName} = $propertyName;
    $params{NewValue} = CIM::Value->new(Value => $newValue, Type => $type)
	if defined $newValue;
    
    my $result;
    eval { $result = $cc->SetProperty(%params) };
    
    return _getReturnValue($@, $result);
}

#####################
sub _setProperty_ok {
    my ($className, $keyBindings, $propertyName, $type, $newValue) = @_;
    
    blue("SetProperty: ", present(\@_)) if $verbose;
    
    my $result = _setProperty($className, $keyBindings,
			      $propertyName, $type, $newValue);
    assert(not defined $result);
    
    _getProperty_ok($className, $keyBindings, $propertyName, $newValue);
}

########################
sub _setProperty_altok {
    my ($className, $keyBindings, $propertyName, $type, $newValue, $readValue)
	= @_;
    
    blue("SetProperty: ", present(\@_)) if $verbose;
    
    my $result = _setProperty($className, $keyBindings,
			      $propertyName, $type, $newValue);
    assert(not defined $result);
    
    _getProperty_ok($className, $keyBindings, $propertyName, $readValue);
}

########################
sub _setProperty_notok {
    my ($className, $keyBindings, $propertyName, $type, $newValue, $errorCode)
	= @_;
    
    blue("SetProperty: ", present(\@_)) if $verbose;
    
    my $result = _setProperty($className, $keyBindings,
			      $propertyName, $type, $newValue);
    
    _checkError($result, $errorCode);
}




############################## ModifyInstance ###############################


#####################
sub _modifyInstance {
    my ($className, $keyBindings, $propertyList, $valueHash) = @_;
    
    _checkCIMOM();
    
    my $on = CIM::ObjectName->new(ObjectName  => $className,
                                  ConvertType => 'INSTANCENAME',
				  KeyBindings => $keyBindings);

    my @properties;
    foreach my $name (@$propertyList) {
	my $value = $valueHash->{$name}->[0];
	my $type = $valueHash->{$name}->[1];
	my $p;
	if (defined $value) {
	    $p = CIM::Property->new(Name  => $name,
				    Type  => $type,
				    Value => CIM::Value->new(Value => $value,
							     Type  => $type));
	}
	else {
	    $p = CIM::Property->new(Name  => $name,
				    Type  => $type);
	}
	push @properties, $p;
    }
    
    my $instance = CIM::Instance->new(ClassName => $className,
				      Property  => \@properties,
				     );
    
    my $vo = CIM::ValueObject->new(ObjectName => $on,
                                   Object     => $instance);
    
    my $result;
    eval { $result = $cc->ModifyInstance(ModifiedInstance => $vo) };
    
    return _getReturnValue($@, $result);
}

########################
sub _modifyInstance_ok {
    my ($className, $keyBindings, $propertyList, $valueHash) = @_;
    
    blue("ModifyInstance: ", present(\@_)) if $verbose;
    
    my $result = _modifyInstance($className, $keyBindings,
				 $propertyList, $valueHash);
    assert(not defined $result);
    
    my $shortValueHash;
    foreach my $key (keys %$valueHash) {
	$shortValueHash->{$key} = $valueHash->{$key}->[0];
    }
    _getInstance_ok($className, $keyBindings, $propertyList, $shortValueHash);
}


###########################
sub _modifyInstance_notok {
    my ($className, $keyBindings, $propertyList, $valueHash, $errorCode) = @_;
    
    blue("ModifyInstance: ", present(\@_)) if $verbose;
    
    my $result = _modifyInstance($className, $keyBindings,
				 $propertyList, $valueHash);
    _checkError($result, $errorCode);
}


############################## EnumerateInstanceNames #######################


#############################
sub _enumerateInstanceNames {
    my ($className) = @_;
    
    _checkCIMOM();
    
    my $on = CIM::ObjectName->new(ObjectName  => $className,
                                  ConvertType => 'INSTANCENAME');
    
    my @result;
    
    eval { @result = $cc->EnumerateInstanceNames(ClassName => $on) };
    
    return _getReturnValue($@, \@result);
}

################################
sub _enumerateInstanceNames_ok {
    my ($className, $cmpvalue) = @_;
    
    blue("EnumerateInstanceNames: ", present(\@_)) if $verbose;
    
    my $result = _enumerateInstanceNames($className);
    
    my @keyBindings;
    foreach (@$result) {
	push @keyBindings, $_->keyBindings;
    }
    
    my $areEqual = areEqual(\@keyBindings, $cmpvalue);
    if (not $areEqual and $verbose >= 3) {
	print STDERR "  value is: ", present(\@keyBindings), "\n";
	print STDERR "  expected: ", present($cmpvalue), "\n";
    }
    assert($areEqual);
}

###################################
sub _enumerateInstanceNames_notok {
    my ($className, $errorCode) = @_;
    
    blue("EnumerateInstanceNames: ", present(\@_)) if $verbose;
    
    my $result = _enumerateInstanceNames($className);
    
    _checkError($result, $errorCode);
}




############################## Extrinsic Methods ############################


######################
sub _extrinsicMethod {
    my ($className, $keyBindings, $type, $name, $params) = @_;
    
    _checkCIMOM();
    
    my $on = CIM::ObjectName->new(ObjectName  => $className,
				  KeyBindings => $keyBindings);
    
    my $result;
    my $func = "invoke" . $type . "Method";
    
    eval { $result = $cc->$func($on, $name, @$params) };
    
    return _getReturnValue($@, $result);
}

#########################
sub _extrinsicMethod_ok {
    my ($className, $keyBindings, $type, $name, $params, $cmpvalue) = @_;
    
    my $result = _extrinsicMethod($className, $keyBindings, $type,
				  $name, $params);
    
    _checkValue($result, $cmpvalue);
}

############################
sub _extrinsicMethod_notok {
    my ($className, $keyBindings, $type, $name, $params, $errorCode) = @_;
    
    my $result = _extrinsicMethod($className, $keyBindings, $type,
				  $name, $params);
    
    _checkError($result, $errorCode);
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
