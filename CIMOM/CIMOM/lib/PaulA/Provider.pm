use strict;

########################
package PaulA::Provider;
########################
use Carp;

use XML::Simple;
use Term::ANSIColor qw(:constants);;
use File::Basename;

use PaulA::ProviderConfig;

use CIM::Error;
use CIM::Utils;


my $verbose = 1;

# Function prefixes
my $prefix_readproperty       = "readProperty_";
my $prefix_writeproperty      = "writeProperty_";
my $prefix_additionaloutstuff = "additionalOutStuff_";
my $prefix_mapvalue           = "mapValue_";
my $prefix_isvalid            = "isValid_";
my $prefix_system2paula       = "system2paula_";
my $prefix_paula2system       = "paula2system_";
my $prefix_handlename         = "handleName_";
my $prefix_handlepermissions  = "handlePermissions_";
my $prefix_createinstance     = "createInstance_";
my $prefix_classmethod        = "classMethod_";
my $prefix_objectmethod       = "objectMethod_";
my $prefix_addcommandlineopt  = "addCommandlineOpt_";


my @validInputMappingTypes = ( qw(REGEXP FUNCTION INTERNAL) );
my @validOutputMappingTypes = ( qw(REGEXP FUNCTION) );
my @validInoutTypes = ( qw(REQUIRED_ASSIGNMENT OPTIONAL_ASSIGNMENT FLAG) );


sub IN     { 'IN'  }
sub OUT    { 'OUT' }
sub CREATE { 'CREATE' }
sub DELETE { 'DELETE' }

sub KEYBINDINGS { 'KEYBINDINGS' }

sub FUNC_REQUIRED { 1 }
sub FUNC_OPTIONAL { 0 }


use PaulA::ProviderIMethods;



sub new {
    my ($class, %args) = @_;
    
    my $self = Tie::SecureHash->new($class);
    
    my ($module) = (caller)[1];

    my $xml = $module;
    $xml =~ s/\.pm$/.xml/;
    $self->{'PaulA::Provider::_config'} =
	PaulA::ProviderConfig->new(Filename      => $xml,
				   CIMOMHandle   => $args{CIMOMHandle},
				   NamespacePath => $args{NamespacePath},
				  );
    
    $self->{'PaulA::Provider::_className'} = basename($module, '.pm');
    
    $self->{'PaulA::Provider::_CIMOMHandle'} = $args{CIMOMHandle};
    $self->{'PaulA::Provider::_namespacePath'} = $args{NamespacePath};
    
    $self->{'PaulA::Provider::_propertyList'} = undef;
    $self->{'PaulA::Provider::_keyBindings'} = undef;
    $self->{'PaulA::Provider::_keyProperties'} = [];
    
    $self->{'PaulA::Provider::_classInfo'} = undef;
    $self->{'PaulA::Provider::_classInfoM'} = undef;
    
    $self->{'PaulA::Provider::_readValues'} = undef;
    $self->{'PaulA::Provider::_valueList'} = undef;
    
    # add $sandbox/bin to the PATH
    if ($self->{_namespacePath}->namespace eq 'root/test') {
	my $sandbox = $self->{_CIMOMHandle}->config->sandbox;
	
	unless ($ENV{PATH} =~ /^$sandbox/) {
	    $ENV{PATH} = "$sandbox/bin/:$ENV{PATH}";
	}
    }
    
    return $self;
}




#############
sub sandbox {
    my ($self) = @_;
    
    error(CIM::Error::CIM_ERR_FAILED, "Call of sandbox() in a non-test-CIMOM")
	unless $self->{_namespacePath}->namespace eq 'root/test';
    
    return $self->{_CIMOMHandle}->{_r}->dir_config('sandbox');
}


###########
sub error {
    my ($code, $msg) = @_;
    
    chomp($msg);
    
    #black("[Provider-Error] $msg");
    black(RED.BOLD. "[Provider-Error] " . RESET.RED . $msg);
    
    die CIM::Error->new(Code => $code);
}



################
sub definition {
    my ($self, $name) = @_;
    return $self->{_config}->definition($name);
}





########################
sub _processProperties {
    my ($self, %args) = @_;
    
    # set and check $inoutMode
    my $inoutMode = $args{InOutMode};
    error(CIM::Error::CIM_ERR_FAILED, "No InOutMode defined")
	unless defined $inoutMode;
    error(CIM::Error::CIM_ERR_FAILED, "Invalid InOutMode: `$inoutMode'")
	unless ($inoutMode eq IN || $inoutMode eq OUT);
    
    my $flag = defined $args{Flag} ? $args{Flag} : '';
    
    my $enumerateInstance =
	((defined $self->{_propertyList}[0] &&
	  $self->{_propertyList}[0] eq 'KEYBINDINGS') ? 1 : 0);

    #black("/===================== $inoutMode =====================\\");
    
    ##
    ## Create List of requested Properties and Handles
    ##
    my (%requested_properties, %handles_by_number);
    {
	my %tmp = $self->{_config}->
	    getPropertyInfos(InOut        => $inoutMode,
			     PropertyList => scalar $self->{_propertyList});
	
        %requested_properties = %{$tmp{RequestedProperties}};
	%handles_by_number    = %{$tmp{HandlesByNumber}};
    }

    #########
    # INPUT #
    #########
    if ($inoutMode eq IN) {
	$self->{_readValues} = {};
	
	# Initialize _readValues with the key properties
	foreach my $p_id (keys %{$self->{_keyBindings}}) {
	    $self->{_readValues}->{$p_id} = [ $self->{_keyBindings}->{$p_id} ];
	}
	
	# At EnumerateInstance* introduce a pseudo property called 'KEYBINDINGS'
	if ($enumerateInstance and (@{$self->{_keyProperties}} == 0)) {
	    $self->{_readValues}->{KEYBINDINGS} = [ {} ];
	    return;
	}
    }
    ##########
    # OUTPUT #
    ##########
    elsif ($inoutMode eq OUT) {
	
	#magenta("_valueList: " . present(scalar $self->{_valueList}));
	
	# check for each requested property if a value is given
	# (incl. dependencies!)
	foreach my $p_id (keys %requested_properties) {
	    #mark("  Property: $p_id");
	    
	    unless (exists $self->{_valueList}->{$p_id}) {
		if (exists $self->{_readValues}->{$p_id}) {
		    my $readValue = $self->{_readValues}->{$p_id};
		    $self->{_valueList}->{$p_id} = $readValue;
		    black("using read value as value for `$p_id': " .
			  present($readValue));
		}
		else {
		    error(CIM::Error::CIM_ERR_INVALID_PARAMETER,
			  "Value of Property '$p_id' is not specified.")
		}
	    }
	}
	
	# Transform property values for writing to system representation
	foreach my $p_id (@{$self->{_propertyList}}) {
	    my $val = $self->{_valueList}->{$p_id};
 	    my $trans = $self->_callFunction("$prefix_paula2system$p_id",
					     FUNC_OPTIONAL,
					     $val);
	    $self->{_valueList}->{$p_id} = defined $trans ? $trans : $val;
	}
	$self->_checkValueList();
	
	#magenta("_valueList: " . present(scalar $self->{_valueList}));
    }
    
    ##
    ## preparatory work for handles
    ##
    foreach my $h_no (sort keys %handles_by_number) { # bei Create alle Handles?
	
	my $h_id = $handles_by_number{$h_no};
	my $handle = $self->{_config}->handle($h_id);
	#black("HANDLE-ID: $h_id");
	
	##
	## Get handle name (if not already specified)
	##
	unless (defined $handle->name or $handle->isDummy) {
	    my $name = $self->_callFunction("$prefix_handlename$h_id",
					    FUNC_OPTIONAL,
					    $self->{_keyBindings},
					    $self->{_readValues});
	    error(CIM::Error::CIM_ERR_FAILED,
		  "Error in calling $prefix_handlename$h_id")
		unless defined $name;
	    
	    $handle->name($name);
	}
	
	##
	## Get handle permissions
	##
	{
	    my ($uid, $gid, $umask) =
		$self->_callFunction("$prefix_handlepermissions$h_id",
				     FUNC_OPTIONAL,
				     $self->{_keyBindings});
	    $handle->setPermissions($uid, $gid, $umask);
	}
	
	##
	## ggf. CreateInstance()
	##
#  	if ($flag eq CREATE) {
	    
#  	    if ($handle->isReadable) {   # not: if ($inoutMode eq IN)
#  	    #if ($inoutMode eq IN) {
		
#  		# read handle
#  		eval { $handle->read };
#  		error(CIM::Error::CIM_ERR_FAILED, "$@") if ($@);
		
#  		# create new instance
#  		my $name = $self->_callFunction("$prefix_createinstance$h_id",
#						FUNC_OPTIONAL,
#  						scalar $handle->complete,
#  						scalar $handle->nocomments,
#  						$self->{_keyBindings},
#  						$self->{_valueList});
#  		error(CIM::Error::CIM_ERR_FAILED, "creating: $h_id");
		
#  		# write handle
#  		eval { $handle->write };
#  		error(CIM::Error::CIM_ERR_FAILED, $@) if ($@);
#  	    }
#  	}
#      }
	
	##
	## Read file or call command
	##
	#if ($inoutMode eq IN) {
	if ($handle->isReadable) {  # on both IN and OUT!
	    eval { $handle->read };
	    error(CIM::Error::CIM_ERR_FAILED, "$@") if ($@);
	}
	
	##
	## Sub Loop - Iterate over all PROPERTY's
	##
	foreach my $p_id (keys %requested_properties) {
	    
	    #mark("-------------- $p_id -------------------");
	    
	    ##
	    ## 2nd Sub Loop - Iterate over all IN's resp. OUT's of each PROPERTY
	    ##
	    my $property = $requested_properties{$p_id};
	    #black("  PROPERTY: ", RED, $p_id);
	    
	    my $mightBeNull = (defined $property->{MIGHT_BE_NULL} &&
			       $property->{MIGHT_BE_NULL} eq 'true') ? 1 : 0;
	    
	    foreach my $inout (@{$property->{$inoutMode}},
			       @{$property->{INOUT}}) {
		
		next unless ($inout->{HANDLE} eq $h_id);
		
		my $force_write = (defined $inout->{FORCE_WRITE} &&
				   $inout->{FORCE_WRITE} eq 'true') ? 1 : 0;
		
		# Get mapping informations
		my ($mapping_type, $regexp, $mods);
		{
		    foreach my $type (@validInputMappingTypes) {
			my $mapping = $inout->{"$type"};
			if (defined $mapping) {
			    
			    # with arguments
			    if (ref $mapping eq 'HASH') {
				$regexp = $mapping->{content};
				$mods = $mapping->{MODIFIERS};
			    }
			    # without arguments
			    else {
				$regexp = $mapping;
			    }
			    
			    $mods = "s" unless defined $mods;
			    $mapping_type = $type;
			}
		    }
		    $mapping_type = 'FUNCTION'
			if $p_id eq 'KEYBINDINGS';
		    unless (defined $mapping_type) {
			#black("Using default mapping for '$p_id'");
			if ($handle->isFile) {
			    $mapping_type = 'REGEXP';
			    $regexp = '()(.*)()';   # i.e. the whole output
			    $mods = "s";
			}
			else {
			    $mapping_type = 'NO_MAPPING';
			}
		    }
		}
		
		##
		## Find Meta Information
		##
		my ($inout_meta, $inout_meta_type);
		{
		    foreach (@validInoutTypes) {
			if (defined $inout->{$_}) {
			    $inout_meta_type = $_;
			    $inout_meta = $inout->{$_};
			    last;
			}
		    }
		    unless (defined $inout_meta) {
			#black("Using default meta infos for '$p_id'");
			$inout_meta_type = 'REQUIRED_ASSIGNMENT'; # hmmm...
		    }
		}
		
		my ($default, $value, $text);
		my $delete_if_default    = 0;
		if ($inout_meta_type eq 'FLAG') {
		    $default = $inout_meta->{DEFAULT};
		    $value   = $inout_meta->{VALUE};
		    $text    = $inout_meta->{TEXT};
		    $delete_if_default = 1;
		}
		elsif ($inout_meta_type eq 'REQUIRED_ASSIGNMENT') {
		}
		elsif ($inout_meta_type eq 'OPTIONAL_ASSIGNMENT') {
		    $default = $inout_meta->{DEFAULT}
			if defined $inout_meta->{DEFAULT};
		    
		    $text = $inout_meta->{TEXT};
		    
		    $delete_if_default = 0;
		    if (defined $inout_meta->{DELETE_IF_DEFAULT} and
			$inout_meta->{DELETE_IF_DEFAULT} =~ /^true$/i) {
			$delete_if_default = 1;
		    }
		}
		$text = '$VAR' unless defined $text;  # fallback
		

		# search in section
		my $s_id = $inout->{SECTION};
		if ($handle->isReadable and
		    ($inoutMode ne IN or defined $handle->complete)) {
		    
		    if (defined $s_id) {
			#black("    SECTION: $s_id");
			
			my $section = $self->{_config}->section($s_id);
			my $mapping = $section->{REGEXP};
			my ($regexp, $mods);
			
			# with arguments
			if (ref $mapping eq 'HASH') {
			    $regexp = $mapping->{content};
			    $mods = $mapping->{MODIFIERS};
			}
			# without arguments
			else {
			    $regexp = $mapping;
			}
			
			# replace pseudo variables
			foreach my $key (@{$self->{_keyProperties}}) {
			    my $v = $self->{_keyBindings}->{$key};
			    $v = "" unless defined $v;
			    $regexp =~ s/\$KEY_$key/$v/g;
			}
			
			# search section in handle
			eval { $handle->search('HANDLE', $regexp, $mods) };
			
			# in case of need error
			if ($@) {
			    my $code = $section->{ERROR_NOT_FOUND}->{CODE};
			    my $errorCode = (defined $code
					     ? $code
					     : CIM::Error::CIM_ERR_FAILED);
			    error($errorCode, "$@");
			}
		    }
		    else {
			# no SECTION specified
			# => so use the complete output
			$handle->search('HANDLE');
		    }
		}
		
		
		#########
		# INPUT #
		#########
		if ($inoutMode eq IN) {
		    red("/----------------- begin INPUT -----------------\\");
		    my $readValue;  # gelesener Wert

		    ########## REGEXP ##########
		    if ($mapping_type eq 'REGEXP') {
			if (defined $handle->complete) {
			    my $info;
			    eval { $info = $handle->search('SECTION',
							   $regexp, $mods,
							   $inout_meta_type) };
			    error(CIM::Error::CIM_ERR_FAILED, "$@") if ($@);
			    
			    my $count = $info->{COUNT};
			    $readValue = $info->{Value}->[0];
			}
			else {
			    red("Warning: \$handle->complete is undefined " .
				"on REGEXP in IN");
			}
		    }
		    ########## FUNCTION ##########
		    elsif ($mapping_type eq 'FUNCTION') {
			$readValue =
			    $self->_callFunction("$prefix_readproperty$p_id",
						 FUNC_OPTIONAL,
						 $handle->section(),
						 $self->{_keyBindings},
						 $self->{_readValues},
						 $handle);
			#mark("readProperty FUNCTION: ", present($readValue));
		    }
		    ########## NO_MAPPING ##########
		    elsif ($mapping_type eq 'NO_MAPPING') {
			; # do nothing
		    }
		    ########## INTERNAL ##########
		    elsif ($mapping_type eq 'INTERNAL') {
			if (defined $handle->complete) {
			    $_ = $handle->section;
			    # this is default input for specified call. ARGH!
			    $readValue = eval $regexp;
			    
			    error(CIM::Error::CIM_ERR_FAILED,
				  "Invalid Perl code: `$regexp'") if ($@);
			}
			else {
			    red("Warning: handle->complete undefined " .
				"on INTERNAL in IN");
			}
		    }
		    ########## (else) ##########
		    else {
			error(CIM::Error::CIM_ERR_FAILED,
			      "Invalid input mappingtype: `$mapping_type'");
		    }
		    
		    red("readValue: " . present($readValue));
		    
		    # PROPERTY's value found
		    if (defined $readValue) {
			# set value if specified
			$readValue = $value if defined $value;
		    }
		    # PROPERTY's value not found
		    else {
			# set default value if specified
			$readValue = (defined $default ? $default : $value);
		    }
		    
		    # transform to PaulA representation
		    {
			my $funcname = "$prefix_system2paula$p_id";
			my $val = $self->_callFunction($funcname,
						       FUNC_OPTIONAL,
						       $readValue);
			$readValue = $val if defined $val;
		    }
		    
		    # in case of need error, when not found
		    unless (defined $readValue or $mightBeNull) {
			my $code = $inout->{ERROR_NOT_FOUND}->{CODE};
			my $errorCode = (defined $code
					 ? $code
					 : CIM::Error::CIM_ERR_FAILED);
			my $stext = (defined $s_id
				     ? "Section '$s_id'"
				     : 'default Section');
			error($errorCode,
			      "Mapping for '$p_id' (Handle '$h_id', $stext) " .
			      "not found");
		    }
		    
		    magenta("_readValues($p_id): " .
			    present($self->{_readValues}->{$p_id}));
		    push @{$self->{_readValues}->{$p_id}}, $readValue
			if defined $readValue;
		    red("\\------------------ end INPUT ------------------/");
		}
		
		##########
		# OUTPUT #
		##########
		elsif ($inoutMode eq OUT) {
		    red("/----------------- begin OUTPUT -----------------\\");
		    
		    my $readValue = $self->{_readValues}->{$p_id};
		    my $newValue = $self->{_valueList}->{$p_id};
		    
		    black("  readValue = " . present($readValue));
		    black("  newValue  = " . present($newValue));
		    
		    # force write if wished
		    if ($force_write) {
			$handle->forceWrite();
		    }
		    # evtl. skip writing (when old and new value are the same)
		    elsif (areEqual($newValue, $readValue)) {
			black("  => retaining Value " . present($readValue));
			next;
		    }
		    
		    if ($handle->isFile or
			$handle->isCommand or
			$handle->isDummy) {
			##
			## Write new instruction to $handle->complete
			##
			########## REGEXP ##########
			if ($mapping_type eq 'REGEXP') {
			    my $info;
			    mark();
			    eval { $info = $handle->search('SECTION',
							   $regexp, $mods,
							   $inout_meta_type) };
			    error(CIM::Error::CIM_ERR_FAILED, "$@") if ($@);
			    mark(present($info, RED)) if $verbose;
			    my $count = $info->{Count};
			    mark(present($count, RED));
			    error(CIM::Error::CIM_ERR_FAILED,
				  "multiple matches found")
				if $count > 1;
			    
			    mark(present($info)) if $verbose;
			    #$readValue = $info->{Value}->[0];
			    
			    # mapping found
			    if ($count == 1) {
				if ($delete_if_default and
				    areEqual($newValue, $default)) {
				    # replace the complete mapping
				    $info->{Write} = [ '' ];
				}
				else {
				    # just replace the submapping
				    $info->{Write} = [ $newValue ];
				    $info->{ReplaceSubmapping} =
					$delete_if_default;
				}
			    }
			    # mapping not found
			    else {
				unless ($delete_if_default and
					areEqual($newValue, $default)) {
				    my $append = $text;
				    my $VAR = $newValue;
				    eval "\$append = qq($append)";
				    $info->{Append} = $append;
				}
			    }
			    
			    if (defined $info) {
				eval { $handle->replace('SECTION', $info) };
				error(CIM::Error::CIM_ERR_FAILED, "$@") if ($@);
			    }
			}
			########## FUNCTION ##########
			elsif ($mapping_type eq 'FUNCTION') {
			    #mark("$mapping_type: $p_id");
			    magenta("newValue: ", present($newValue));
			    my $funcname = "$prefix_writeproperty$p_id";
			    my $info = 
				$self->_callFunction($funcname,
						     FUNC_OPTIONAL,
						     $handle->section,
						     $self->{_keyBindings},
						     $readValue,
						     $newValue,
						     $handle);
			    
			    if (defined $info) {
				eval { $handle->replace('SECTION', $info) };
				error(CIM::Error::CIM_ERR_FAILED, "$@") if ($@);
			    }
			}
			########## NO_MAPPING ##########
			elsif ($mapping_type eq 'NO_MAPPING') {
			    ; # do nothing
			}
			########## (else) ##########
			else {
			    error(CIM::Error::CIM_ERR_FAILED,
				  "Invalid output mapping type: " .
				  present($mapping_type));
			}
			
			if ($handle->isCommand) {
			    # command line from XML
			    my $option = $inout->{CALL}->{OPTION};
			    if (defined $option) {
				my $VAR = $newValue;
				eval "\$handle->addCommandlineOpt($option)"
				    if defined $option;
				error(CIM::Error::CIM_ERR_FAILED, "$@") if ($@);
			    }
			    
			    # command line from provider function
			    my $funcname = "$prefix_addcommandlineopt$p_id";
			    $option = 
				$self->_callFunction($funcname,
						     FUNC_OPTIONAL,
						     $self->{_keyBindings},
						     $readValue,
						     $newValue,
						     $handle);
			    
			    $handle->addCommandlineOpt($option)
				if defined $option;
			    
			    # every command handle should be written
			    $handle->forceWrite();
			}
		    }
		    else {
			error(CIM::Error::CIM_ERR_FAILED,
			      "Invalid output handle type (".$handle->type.")");
		    }
		    
		    $self->_callFunction("$prefix_additionaloutstuff$p_id",
					 FUNC_OPTIONAL);
		    
		    red("\\------------------ end OUTPUT ------------------//");
		}
	    }
	    # (end of iteration over all IN/OUT/OUT's for this property)
	}
	# (end of iteration over all PROPERTY's for this handle)
	
	if ($inoutMode eq OUT) {
	    # (for each handle) write modified file or call command
	    eval { $handle->write };
	    error(CIM::Error::CIM_ERR_FAILED, $@) if ($@);
	}
    }
    # (end of iteration over all HANDLE's)

    if ($inoutMode eq IN) {
	blue("_readValues before compare".present(scalar $self->{_readValues}));
	$self->compareReadValues()  # compare all read values
    }
    #black("\\=================== end $inoutMode ===================/");
}



#######################
sub compareReadValues {
    my ($self) = @_;
    
    foreach my $p_id (keys %{$self->{_readValues}}) {
	
	my @values = @{$self->{_readValues}->{$p_id}};
	
	my $different;
	if ($p_id eq 'KEYBINDINGS' or $self->{_classInfo}->{$p_id}{ISARRAY}) {
	    my $compare;
	    $different = 0;
	    foreach my $va (@values) {
		if (defined $compare) {
		    $different = 1 unless areEqual($compare, $va);
		}
		else {
		    $compare = $va;
		}
	    }
	}
	else {
	    my %seen = ();
	    my @distinct = grep { ! $seen{$_}++ } (@values);
	    $different = ($#distinct > 0);
	}
	
	error(CIM::Error::CIM_ERR_FAILED, "Read different values for $p_id")
	    if $different;
	
	$self->{_readValues}->{$p_id} = $values[0];  # W.L.O.G. the first
    }
}




###################
sub _callFunction {
    my ($self, $func, $required, @args) = @_;
    
    if ($self->can($func)) {
	return $self->$func(@args);
    }
    else {
	error(CIM::Error::CIM_ERR_FAILED,
	      "Function $func isn't defined in " . ref($self))
	    if $required;
    }
    return undef;
}


# checks the value of each property (*before* the paula2system-transformation!)
# Depends on: _valueList, _classInfo
#####################
sub _checkValueList {
    my ($self) = @_;
    
    error(CIM::Error::CIM_ERR_FAILED, "_valueList not defined")
	unless defined $self->{_valueList};
    error(CIM::Error::CIM_ERR_FAILED, "_classInfo not defined")
	unless defined $self->{_classInfo};
    
    foreach my $p_id (keys %{$self->{_valueList}}) {

	#green("Property: $p_id");
	#magenta("_valueList: " . present(scalar $self->{_valueList}));
	
	##
	## check invalid key/value pairs
	## (it's a client error, so we can ignore (i.e. delete) them)
	##
	unless (exists $self->{_classInfo}->{$p_id}) {
	    delete $self->{_valueList}->{$p_id};
	}
	
	##
	## set correct CIM type and get newValue
	##
	my $newValue;
	if (defined $self->{_valueList}->{$p_id}) {
	    
	    if (ref $self->{_valueList}->{$p_id} eq 'CIM::Value') {
		my $type = $self->{_classInfo}->{$p_id}{CIMTYPE};
		$self->{_valueList}->{$p_id}->type($type);
		#magenta(present($type));
		
		$newValue = $self->{_valueList}->{$p_id}->valueAsRef;
	    }
	    else {
		$newValue = $self->{_valueList}->{$p_id};
	    }
	    #magenta(present($newValue));
	}
	
	##
	## call map function, if it exists
	##
	{
	    my $mappedValue;
	    eval { $mappedValue = $self->_callFunction("$prefix_mapvalue$p_id",
						       FUNC_REQUIRED,
						       $newValue) };
	    # no error, so mapped value exists
	    unless ($@ or areEqual($newValue, $mappedValue)) {
		black("Now using mapped value " . present($mappedValue) .
		      " instead of " . present($newValue) .
		      " for property `$p_id'.");
		$newValue = $mappedValue;
	    }
	}
	
	# overwrite CIM::Value in _valueList with a Perl value
	$self->{_valueList}->{$p_id} = $newValue;
	
	if (defined $newValue) {
	    
	    ##
	    ## array check
	    ##
	    if ($self->{_classInfo}->{$p_id}{ISARRAY}) {
		if (ref $newValue ne 'ARRAY') {
		    error(CIM::Error::CIM_ERR_INVALID_PARAMETER,
			  "Value of Property '$p_id' is not an array: " .
			  present($newValue));
		}
	    }
	    elsif (ref $newValue eq 'ARRAY') {
		error(CIM::Error::CIM_ERR_INVALID_PARAMETER,
		      "Value of Property '$p_id' must be an array: " .
		      present($newValue));
	    }
	}
	
	##
	## might_be_null check
	##
	{
	    my $property = $self->{_config}->property($p_id);
	    my $mightBeNull = (defined $property->{MIGHT_BE_NULL} &&
			       $property->{MIGHT_BE_NULL} eq 'true') ? 1 : 0;
	    
	    unless (defined $newValue or $mightBeNull) {
		error(CIM::Error::CIM_ERR_INVALID_PARAMETER,
		      "Invalid Value of Property '$p_id': ".present($newValue));
	    }
	}
	
	##
	## call "is valid" test, if it exists
	##
	my $isvalid = $self->_callFunction("$prefix_isvalid$p_id",
					   FUNC_OPTIONAL,
					   $newValue);
	red("Warning: Maybe invalid return value of function " .
	    "$prefix_isvalid$p_id(): " . present($isvalid))
	    unless (defined $isvalid and ($isvalid == 1 or $isvalid == 0));
	
	if (defined $newValue and defined $isvalid and not $isvalid) {
	    error(CIM::Error::CIM_ERR_INVALID_PARAMETER,
		  "Invalid Value of Property '$p_id': " . present($newValue));
	}
    }
    #magenta("_valueList: " . present(scalar $self->{_valueList}));
}


###################
sub _setClassInfo {
    my ($self, $on) = @_;
    
    my ($class);
    my $cimom = $self->{_CIMOMHandle};
    my $className = $on->objectName;
    
    # if already read a class skip for better performance
    return if defined $self->{_classInfo};
    
    magenta("----> retrieving class `$className' <----");
    eval { ($class) = $cimom->invokeIMethod(scalar $self->{_namespacePath},
					    "GetClass",
					    ClassName => $on) };
    
    if ($@) {
	#black($@);
	error(CIM::Error::CIM_ERR_FAILED, "Error in loading `$className': $@");
    }
    
    # properties
    $self->{_keyProperties} = [];
    foreach my $prop (@{$class->properties}) {
 	$self->{_classInfo}->{$prop->name} = {
					      CIMTYPE => $prop->type,
					      ISARRAY => $prop->isArray,
					      ISKEY   => $prop->isKeyProperty,
					     };
	push @{$self->{_keyProperties}}, $prop->name
	    if $prop->isKeyProperty;
    }

    # methods
    $self->{_classInfoM} = {};
    foreach my $method (@{$class->methods}) {
	$self->{_classInfoM}->{$method->name} = $method;
    }
}

#####################
sub _setKeyBindings {
    my ($self, $keyBindings) = @_;
    
    # look for missing key properties
#      foreach my $prop (keys %{$self->{_classInfo}}) {
#  	error(CIM::Error::CIM_ERR_INVALID_PARAMETER,
#  	      "Missing key value for key '$prop'")
#  	    if (defined $self->{_classInfo}->{$prop} &&
#  		$self->{_classInfo}->{$prop}->{ISKEY} &&
#  		not defined $keyBindings->{$prop});
#    }
    
    # ignore non key properties and set $self->{_keyBindings}
    $self->{_keyBindings} = {};
    foreach my $prop (keys %$keyBindings) {
	$self->{_keyBindings}->{$prop} = $keyBindings->{$prop}
	    if ($self->{_classInfo}->{$prop} &&
		$self->{_classInfo}->{$prop}->{ISKEY});
    }
    
    # just for testing
#      mark("############ KEYBINDINGS ################");
#      foreach my $prop (keys %{$self->{_keyBindings}}) {
#  	mark("     Keybinding: `$prop' -> '$self->{_keyBindings}->{$prop}'");
#      }
}


sub objectExists {
    my ($self, $keyBindings) = @_;
    
    # an object of a keyless class always exists per definitionem
    return 1 unless defined $keyBindings; 
    
    # get all instances
    my $on = CIM::ObjectName->new(ObjectName  => scalar $self->{_className},
				  KeyBindings => $keyBindings,
				  ConvertType => 'CLASSNAME');
    
    # check if one of the keybindings equals to that asked for
    my @in = $self->EnumerateInstanceNames(ClassName => $on);
    for my $in (@in) {
	if (areEqual($keyBindings, $in->keyBindings)) {
	    magenta("Instance " . present($keyBindings) . " exists.");
	    return 1;
	}
    }
    
    magenta("Instance " . present($keyBindings) . " does not exist.");
    return 0;
}


sub _analyzeObjectName {
    my ($self, $on) = @_;
    
    $self->_setClassInfo($on);
    $self->_setKeyBindings($on->keyBindings);
}


sub invokeObjectMethod {
    my ($self, $methodName, $on, @params) = @_;
    
    my $keyBindings = $on->keyBindings;
    
    # "invalid method name" test
    $self->_setClassInfo($on);
    error(CIM::Error::CIM_ERR_METHOD_NOT_FOUND,
	  "Invalid Extrinsic Method: `$methodName'")
	unless (exists $self->{_classInfoM}{$methodName});

    # TODO: check method parameters (names and order)
    
    # "invalid keybindings" test
    $self->_setKeyBindings($keyBindings);
    
    # "instance not found" test
    error(CIM::Error::CIM_ERR_NOT_FOUND, "Instance does not exist")
	unless $self->objectExists($keyBindings);
    
    # call extrinsic method
    my $func = $prefix_objectmethod . $methodName;
    if ($self->can($func)) {
	return $self->$func($keyBindings, @params);
    }
    else {
	error(CIM::Error::CIM_ERR_METHOD_NOT_AVAILABLE,
	      "Method `$methodName' not found");
    }
}

sub invokeClassMethod {
    my ($self, $methodName, $on, @params) = @_;
    
    # "invalid method name" test
    $self->_setClassInfo($on);
    error(CIM::Error::CIM_ERR_METHOD_NOT_FOUND,
	  "Invalid Extrinsic Method: `$methodName'")
	unless (exists $self->{_classInfoM}{$methodName});
    
    # TODO: check method parameters (names and order)

    # call extrinsic method
    my $func = $prefix_classmethod . $methodName;
    if ($self->can($func)) {
	return $self->$func(@params);
    }
    else {
	error(CIM::Error::CIM_ERR_METHOD_NOT_AVAILABLE,
	      "Method `$methodName' not found");
    }
}



1;


__END__

=head1 NAME

PaulA::ProviderConfig - Base class for a provider for system information



=head1 SYNOPSIS

 (...)


=head1 DESCRIPTION

This Module is the base class for a provider for system information.

To write a new provider you must derive a new class. Have a look at the
following points:

=head2 Namespace and class names

The Perl namespace of this class must start with "PaulA::Provider",
followed by the CIM namespace (without the "root" part). Finally the name
of the provider class must be the same as the name of the corresponding
CIM class.

For example if you habe the CIM class "PaulA_User" in the CIM namespace
"root/PaulA" the name of the provider must be
"PaulA::Provider::PaulA::PaulA_User.

=head2 Placement in the diretory structure

The directory PaulA/lib/PaulA/Provider/ corresponds to the "root" part of
the CIM namespace. The (currently only supported) CIM namespace "root/paula"
will be mapped to the subdirectory PaulA, which is intended to be a symbolic
link to one of the (parallel) directories representing the different
UNIX/Linux distributions.

Each provider consists of a Perl module (.pm) and a XML configuration file
(.xml) whereby the basename of both of them is equivalent to the CIM class
which properties are provided by this provider. For each CIM class both
provider files must lie in each (supported) distribution directory.

For example the provider for the CIM class PaulA_User will be searched
in the directory PaulA/lib/PaulA/Provider/PaulA/. Assume you want to
develope a provider for Red Hat 6.1 and let the propider directory be
PaulA/lib/PaulA/Provider/redhat_61/, then there should be a link from
the first to the second directory.

Further assume you want wo implement a provider for the CIM class PaulA_User.
So you must write two files PaulA_User.pm (Perl module of the derived class)
and PaulA_User.xml (XML configuration file), both lying in the redhat_61/
directory.

=head2 minimal content

Here's an example for a minimal provider class (CIM class PaulA_User):

 -------------8<--------------8<-------------
 package PaulA::Provider::PaulA::PaulA_User;

 use base qw(PaulA::Provider);

 sub new {
     my ($class, %args) = @_;
     my $self = $class->SUPER::new(%args);
     return $self;
 }
 
 1;
 -------------8<--------------8<-------------

=head2 additional contents

A provider can have a lot of additional functions. To map the funcionality
to the corresponding properties the names of the functions all habe the
same structure: prefix_suffix(). The suffix is the name of the property,
denoted my a "*".

=item readProperty_*($string, $keyBindings, $readValues, $handle)

Each of these functions read the property from the given $string.
The return value is the (representation of the) property  as a single
string, eventually transformed later with the system2paula_*() function. 

=item writeProperty_*($string, $section, $keyBindings, $readValue, $newValue,
                      $handle)

(to be documented)

=item writeProperty_*($string, $keyBindings, $readValue, $newValue, $handle)

(to be documented)

=item additionalOutStuff_*()

(to be documented)

=item mapValue_*($newValue)

(to be documented)

=item isValid_*($value)

To check the validity of the property value. $value either is a scalar or
an array reference.
The return value should be B<1> (=valid) or B<0> (=not valid).

=item system2paula_*($string)

Transforms the $string to PaulA representation of the property value. Here
for example you split up arrays or do some other transformations.
The return value either is a scalar or an array reference.

=item paula2system_*($value)

Transforms the $value (scalar or array reference) from the PaulA
representation back to the syntax expected in the "system". Here for
example you join together arrays or do some other transformations.
The return value either is a string.

=item handlename_*($keyBindings, $readValues)

To create dynamical an handle name. Arguments are hash references for the
key bindings and all so far read property values. In case of need you can
do here a sub provider call to get all information you need for creating
the handle name.
The return value is a string.

=item handlePermissions_*($keyBindings)

(to be documented)

=item classMethod_*(@params)

(to be documented)

=item objectMethod_*($keyBindings, @params)

(to be documented)



=head1 CONSTRUCTOR

=over 4

=item new([OPTIONS])

C<OPTIONS> are passed in a hash like fashion, using key and value pairs.
The possible options are:

B<Namespace> - The namespace for an eventual repository call.
This option maybe dropped out in future.



=head1 METHODS

Internal functions will be described later.

The following Intrinsic-Method functions are supported so far:

=item GetProperty()

=item GetInstance()

=item SetProperty()

=item ModifyInstance()

=item EnumerateInstances()

=item EnumerateInstanceNames()




=head1 SEE ALSO

L<PaulA::CIMOM>, L<PaulA::ProviderHandle>, L<PaulA::ProviderIMethods>



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
