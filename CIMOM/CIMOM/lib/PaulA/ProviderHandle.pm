use strict;

##############################
package PaulA::ProviderHandle;
##############################
use Carp;
use File::Copy;
use Term::ANSIColor qw(:constants);;
use Cwd;

use Tie::SecureHash;
use CIM::Utils;

my $verbose = 1;

my @validHandleTypes = ( qw(FILE COMMAND DUMMY) );


sub new {
    my ($class, %args) = @_;
    
    my $self = Tie::SecureHash->new($class);
    
    $self->{'PaulA::ProviderHandle::_id'} = $args{ID};
    
    $self->{'PaulA::ProviderHandle::_number'} = undef;
    $self->{'PaulA::ProviderHandle::_type'} = undef;
    $self->{'PaulA::ProviderHandle::_access'} = undef;
    $self->{'PaulA::ProviderHandle::_name'} = undef;
    $self->{'PaulA::ProviderHandle::_whitespace_read'} = undef;
    $self->{'PaulA::ProviderHandle::_whitespace_write'} = undef;
    $self->{'PaulA::ProviderHandle::_comment_line_read'} = undef;
    $self->{'PaulA::ProviderHandle::_comment_line_write'} = undef;
    
    $self->{'PaulA::ProviderHandle::_orig'} = undef;
    $self->{'PaulA::ProviderHandle::_complete'} = undef;
    $self->{'PaulA::ProviderHandle::_nocomments'} = undef;
    $self->{'PaulA::ProviderHandle::_section'} = undef;
    
    $self->{'PaulA::ProviderHandle::_info_handle'} = undef;
    $self->{'PaulA::ProviderHandle::_info_section'} = undef;
    
    $self->{'PaulA::ProviderHandle::_error_onread'} = 1;
    $self->{'PaulA::ProviderHandle::_error_onwrite'} = 1;
    $self->{'PaulA::ProviderHandle::_exitcode'} = undef;
    
    $self->{'PaulA::ProviderHandle::_remove_atwriting'} = 0;
    $self->{'PaulA::ProviderHandle::_remove_ifempty'} = 0;
    
    $self->{'PaulA::ProviderHandle::_force_write'} = 0;
    
    $self->{'PaulA::ProviderHandle::_uid'} = undef;
    $self->{'PaulA::ProviderHandle::_gid'} = undef;
    $self->{'PaulA::ProviderHandle::_umask'} = undef;
    
    $self->{'PaulA::ProviderHandle::_commandlineOpts'} = '';
    
    $self->{'PaulA::ProviderHandle::_CIMOMHandle'} = $args{CIMOMHandle};
    $self->{'PaulA::ProviderHandle::_namespacePath'} = $args{NamespacePath};
    
    $self->init($args{Config})
	if defined $args{Config};
    
    return $self;
}


sub init {
    my ($self, $config) = @_;

    $self->{_access} = $config->{ACCESS};
    $self->{_number} = $config->{NO};
    $self->{_name} = $config->{NAME};

    # Type
    $self->{_type} = $config->{TYPE};
    die "Invalid handle type: `$config->{TYPE}'\n"
	unless (scalar grep /^$config->{TYPE}$/, @validHandleTypes);
    
    # Whitespaces
    my $ws = $config->{WHITESPACE}->{READ};
    $ws = ' ' unless defined $ws;
    $self->{_whitespace_read} = $ws;
    
    $self->{_whitespace_write} = $config->{WHITESPACE}->{WRITE};
    
    # Comments
    $self->{_comment_line_read} = $config->{COMMENTS}->{'READ.LINE'};
    $self->{_comment_line_write} = $config->{COMMENTS}->{'WRITE.LINE'};
    
    # Errors
    $self->{_error_onread} = 1;
    $self->{_error_onwrite} = 1;
    {
	my $c = $config->{ERROR};
	if (defined $c) {
	    $self->{_error_onread} = 0
		if (defined $c->{ONREAD} && $c->{ONREAD} =~ /^false$/i);
	    $self->{_error_onwrite} = 0
		if (defined $c->{ONWRITE} && $c->{ONWRITE} =~ /^false$/i);
	}
    }
    
    # Permissions
    undef $self->{_uid};
    undef $self->{_gid};
    undef $self->{_umask};
    {
	my $c = $config->{PERMISSIONS};
	if (defined $c) {
	    $self->{_umask} = $c->{UMASK};
	    $self->{_uid} = $c->{UID};
	    $self->{_gid} = $c->{GID};
	}
    }
    
    # Remove
    $self->{_remove_atwriting} = 0;
    $self->{_remove_ifempty} = 0;
    {
	my $c = $config->{REMOVE};
	if (defined $c) {
	    $self->{_remove_ifempty} = 1
		if (defined $c->{IF_EMPTY} && $c->{IF_EMPTY} =~ /^true$/i);
	}
    }
    
    # internal
    undef $self->{_orig};
    undef $self->{_complete};
    undef $self->{_nocomments};
    undef $self->{_info_handle};
    undef $self->{_info_section};
}


sub id {
    my $self = shift;
    return $self->{_id};
}

sub number {
    my $self = shift;
    return $self->{_number};
}

sub name {
    my $self = shift;
    $self->{_name} = $_[0] if defined $_[0];
    return $self->{_name};
}



sub type {
    my $self = shift;
    return $self->{_type};
}

sub isFile {
    my $self = shift;
    return $self->{_type} eq 'FILE' ? 1 : 0;
}

sub isCommand {
    my $self = shift;
    return $self->{_type} eq 'COMMAND' ? 1 : 0;
}

sub isDummy {
    my $self = shift;
    return $self->{_type} eq 'DUMMY' ? 1 : 0;
}



sub whitespaceRead {
    my $self = shift;
    return $self->{_whitespace_read};
}

sub whitespaceWrite{
    my $self = shift;
    return $self->{_whitespace_write};
}

sub commentLineRead {
    my $self = shift;
    return $self->{_comment_line_read};
}

sub commentLineWrite{
    my $self = shift;
    return $self->{_comment_line_write};
}



sub isReadable {
    my $self = shift;
    return $self->{_access} =~ /R/i ? 1 : 0;
}

sub isWriteable {
    my $self = shift;
    return $self->{_access} =~ /W/i ? 1 : 0;
}



sub removeAtWriting {
    my $self = shift;
    return $self->{_remove_atwriting} = 1;
}

sub forceWrite {
    my $self = shift;
    $self->{_force_write} = 1;
}




sub commandlineOpts {
    my $self = shift;
    return $self->{_commandlineOpts};
}

sub addCommandlineOpt {
    my $self = shift;
    
    if (defined $_[0]) {
	$self->{_commandlineOpts} .= " " . $_[0];
	$self->forceWrite();
    }
    
    return $self->{_commandlineOpts};
}



sub exitCode {
    my $self = shift;
    return $self->{_exitcode};
}



sub orig {
    my $self = shift;
    return $self->{_orig};
}

sub complete {
    my $self = shift;
    return $self->{_complete};
}

sub nocomments {
    my $self = shift;
    return $self->{_nocomments};
}

sub section {
    my $self = shift;
    return $self->{_section};
}

sub setPermissions {
    my ($self, $uid, $gid, $umask) = @_;
    $self->{_uid}   = $uid   if defined $uid;
    $self->{_gid}   = $gid   if defined $gid;
    $self->{_umask} = $umask if defined $umask;
}


#############################################################################


sub search {
    my ($self, $where, $regexp, $mods, $type) = @_;

    blue("/----------------- search in $where ($self->{_id})---------------\\");
    
    my ($base, $infoKey, $info);
    if ($where eq 'HANDLE') {
	$base = '_nocomments';
	$infoKey = '_info_handle';
    }
    else {
	$base = '_section';
	$infoKey = '_info_section';
    }
    
    if (defined $regexp) {
	
	my $text = $self->{$base};
	
	$mods = "s" unless defined $mods;
	$mods .= "g";   # important for repeated search!
	
#  	mark("Text: $text");
#  	mark("RegExp: $regexp");
#  	mark("Mods: $mods");
	
	# set default value
	$info = {
		 Count    => 0,      # the total number of the mappings
		 Start    => [ ],    # start byte of each mapping
		 End      => [ ],    # end byte of each mapping
		 StartSub => [ ],    # start byte of each submapping
		 EndSub   => [ ],    # end byte of each submapping
		 Read     => [ ],    # each mapping as a string
		 Value    => [ ],    # each mapping as a string
		 Write    => undef,  # string to replace mapping, else undef
		 Append   => undef,  # in case of need append this string
		};
	
	unless (defined $text) {
	    red("Warning: \$text is undefined in search()");
	    return $info;
	}
	
	# modify regexp
	if (defined $type and $type eq 'OPTIONAL_ASSIGNMENT') {
	    #magenta("  regexp (before) = " . $regexp);
	    
	    $regexp =~ s/^
			 (.*?)           # Pre-Mapping
			 \(
			 (.*?)           # Mapping left
			 \(
			 (.*?)           # Submapping
			 \)
			 (.*?)           # Mapping right
			 \)
			 /($1)(($2)($3)($4))/x;
	    
	    #magenta("  regexp (after)  = " . $regexp);
	}
	
	magenta("  regexp = " . $regexp);
	magenta("  mods   = " . $mods);
	
	my $max_counter = 20000;  # maximal mappings to avoid endless loop
	my $counter = $max_counter;
	my $offset = 0;
	
	while ($counter > 0) {
	    $counter--;
	    
	    # set search positions
	    my ($pos_pre, $pos_map, $pos_sub) = (1, 2, 2);
	    my ($pos_left, $pos_right) = (1, 1);   # TODO
	    if (defined $type and $type eq 'OPTIONAL_ASSIGNMENT') {
		$pos_sub = 3;
		($pos_pre, $pos_map, $pos_sub) = (1, 2, 4);
		($pos_left, $pos_right) = (3, 5);
	    }
	    
	    # map RegExp
	    my ($pre_mapping, $mapping, $sub_mapping);
	    my ($mapping_left, $mapping_right);
	    pos($text) = $offset;
	    
	    magenta("  counter/offset = " . RESET . 
		    present($counter) . "/" . present($offset));
#  	    black("  regexp = " . $regexp);
#  	    black("  mods   = " . $mods);
#  	    black("`$text');
	    
 	    eval "\$text =~ m~${regexp}~${mods};
                  \$pre_mapping   = \$$pos_pre;
                  \$mapping       = \$$pos_map;
                  \$sub_mapping   = \$$pos_sub;
                  \$mapping_left  = \$$pos_left;
                  \$mapping_right = \$$pos_right;
                  ";
	    
	    # just for testing
	    if ($verbose) {
		black("  /-------------- nach dem Suchen ------------------\\");
		#black("Text: `$text'");
		black("   Pre-Mapping:   " . present($pre_mapping));
		black("   Mapping:       " . present($mapping));
		black("   Mapping left:  " . present($mapping_left));
		black("   Sub-Mapping:   " . present($sub_mapping));
		black("   Mapping right: " . present($mapping_right));
		black("   pos(text):     " .
		      present(pos($text)), " / ", length($text));
		black("  \\-------------------------------------------------/");
	    }
	    
	    #if (defined pos($text)) {  # VM: hmmm....
	    if (defined $mapping) {
		my $startMap = $offset   + length($pre_mapping);
		my $endMap   = $startMap + length($mapping);
		
		my $startSub = $startMap + length($mapping_left);
		my $endSub   = $startSub + length($sub_mapping);
		
		#blue(" -- $startMap $startSub $endSub $endMap --");
		
		# fill info hash
		$info->{Count}++;
		push @{$info->{Start}},    $startMap;
		push @{$info->{End}},      $endMap;
		push @{$info->{StartSub}}, $startSub;
		push @{$info->{EndSub}},   $endSub;
		push @{$info->{Read}},     $mapping;
		push @{$info->{Value}},    $sub_mapping;
		
		# search again from previous mapping
		{
		    my $old_offset = $offset;
		    $offset = $endMap;
		    
		    if ($offset >= length($text)) {
			$counter = -1;  # i.e. end of loop
		    }
		    elsif ($offset == $old_offset) {
			die "Maybe endless loop in mapping RegExp in $where " .
			    "(offset hasn't changed (== $offset)).";
		    }
		}
	    }
	    else {
		$counter = -1;  # i.e. end of loop
	    }
	}
	
	die "Maybe endless loop in mapping RegExp in $where " .
	    "(after $max_counter loops)."
	    if $counter == 0;
    }
    else {
	# (it's faster than regexp mapping)
	$info = {
		 Count  => 1,
		 Start  => [ 0 ],
		 End    => [ defined $self->{$base}
			     ? length($self->{$base})
			     : 0 ],
		 Read   => [ $self->{$base} ],
		 Write  => undef,
		 Append => undef,
		};
    }
    
    mark(present($info, BOLD)) if $verbose;
    
    if ($where eq 'HANDLE') {
#	mark(present($info, BOLD));
	die "Found $info->{Count} Sections, but expected exactly 1."
	    unless ($info->{Count} == 1);
	
	$self->{_section} = $info->{Read}->[0];
    }
    else {
	# nothing??
    }
    
    $self->{$infoKey} = $info;
    
    blue("\\----------------- end of search ---------------------/");
    return $info;
}



sub replace {
    my ($self, $where, $newInfo) = @_;
    
    blue("/----------------- replace $where ($self->{_id}) ----------------\\");
    my ($base, $info);
    if ($where eq 'HANDLE') {
	red("Kommt replace(HANDLE) wueberhaupt vor? Bitte VM bescheid geben!");
	$base = $self->{_nocomments};
	#$info = $self->{_info_handle};
    }
    else {
	$base = $self->{_section};
	#$info = $self->{_info_section};
    }
    
    return unless defined $newInfo;
    
    if (ref $newInfo eq '') {
	$info = {
		 Count  => 1,
		 Start  => [ 0 ],
		 End    => [ defined $base ? length($base) : 0 ],
		 Read   => [ $base ],
		 Write  => [ $newInfo ],
		 Append => undef,
		};
    }
    elsif (ref $newInfo eq 'HASH') {
	$info = $newInfo;
    }
    else {
	die "[replace] newInfo is invalid";
    }
    
    #$info->{Write} = $newInfo->{Write};
    mark(present($info, BOLD)) if $verbose;
    
    #green(scalar $self->{_complete});
    $self->{_complete} = '' unless defined $self->{_complete}; # hmmm...
    
    # append 'Append' string
    if (defined $info->{Append}) {
	if ($where eq 'SECTION') {
	    # append at the end of the *section*
	    my $endSection = $self->{_info_handle}->{End}->[0];
	    if (defined $self->{_complete}) {
		$self->{_complete} = substr($self->{_complete}, 0, $endSection).
		                     $info->{Append} .
				     substr($self->{_complete}, $endSection);
	    }
	    else {
		$self->{_complete} = $info->{Append};
	    }
	}
	else {
	    # append at the end of the *file*
	    $self->{_complete} .= $info->{Append};
	}
    }
    
    # Flag if I should to replace the *mapping* or the *submapping*
    my $replaceSubmapping = 0;
    if (defined $info->{ReplaceSubmapping}) {
	$replaceSubmapping = $info->{ReplaceSubmapping};
    }
    #green("replaceSubmapping = $replaceSubmapping");
    
    # replace all mappings (if needed)
    # (important: from the end of _complete to the beginning!)
    for (my $pos = $info->{Count}-1; $pos >= 0; $pos--) {
	next unless defined $info->{Write}->[$pos];
	
	#mark("------ replace ------ pos = $pos ---------");
	
	my $start = ($replaceSubmapping
		     ? $info->{StartSub}->[$pos]
		     : $info->{Start}->[$pos]);
	my $end = ($replaceSubmapping
		   ? $info->{EndSub}->[$pos]
		   : $info->{End}->[$pos]);
	#blue("  start/end: " . present($start) . " " . present($end));
	
	if ($where eq 'SECTION'
#  	    and
#  	    defined $self->{_info_handle} and
#  	    $self->{_info_handle}->{Count} > 0
 	   ) {
	    my $offset = $self->{_info_handle}->{Start}->[0];
	    #blue("  offset: ". present($offset));
	    $start += $offset;
	    $end   += $offset;
	}
	#blue("  start/end: " . present($start) . " " . present($end));
	
	my $newText = $info->{Write}->[$pos];
	#blue("newText = `$newText'");
	$self->{_complete} = substr($self->{_complete}, 0, $start) .
	                     $newText .
			     substr($self->{_complete}, $end);
    }
    
    $self->_updateNoComments;
    #green(scalar $self->{_complete});
    
    $self->forceWrite();
    
    blue("\\----------------- end of replace -----------------------/");
}




#############################################################################


sub restoreOrigValues {
    my $self = shift;
    
    $self->{_complete} = $self->{_orig};
    $self->_updateNoComments;
}


sub _updateNoComments {
    my $self = shift;
    
    $self->{_nocomments} = $self->{_complete};
    
    if (defined $self->commentLineRead) {
	my $linecomment = $self->commentLineRead;
	my $whitespace = $self->whitespaceWrite;
	
	# line for line delete comments and replace them with whitespaces
	while ($self->{_nocomments} =~ /($linecomment.*?)$/m) {
	    my $replace = $whitespace x length($1);
	    $self->{_nocomments} =~ s/($linecomment.*?)$/$replace/m;
	}
	#black($self->{_nocomments} . "-" x 77);
    }
}


sub read {
    my $self = shift;
    
    return if $self->isDummy();
    
    my $name = $self->name;
    
    # If a system file name doesn't begin with a '/', it is
    # one of the test files. Prepend full path in this case:
    # (TODO: hier nach "_namespacePath = root/test" testen statt nach m|/|)
    if ($self->{_namespacePath}->namespace eq 'root/test') {
	my $sandbox = $self->{_CIMOMHandle}->config->sandbox;
	
	if ($self->isFile) {
	    $name = "$sandbox/$name";
	}
  	if ($self->isCommand) {
	    unless ($ENV{PATH} =~ /^$sandbox/) {
		$ENV{PATH} = "$sandbox/bin/:$ENV{PATH}";
	    }
  	}
    }
    
    black("  read or call `$name' (Handle-ID: " .
	  present(scalar $self->{_id}) . ")");
    
    # open handle
    unless (open HANDLE, "$name") {
	my $exitcode = $? >> 8;
	if ($self->{_error_onread}) {
	    die "Error in opening handle `$name' on read() " .
		"(got exit code $exitcode)";
	}
	else {
	    return;
	}
    }
    
    # read handle
    local $/ = undef;
    $self->{_complete} = $self->{_orig} = <HANDLE>;
    
    # close handle
    unless (close HANDLE) {
	$self->{_exitcode} = $? >> 8;
	if ($self->{_error_onread}) {
	    die "Error in closing handle `$name' on read() (got exit code " .
		$self->{_exitcode} . ")";
	}
    }
    else {
	$self->{_exitcode} = $? >> 8;
    }
    
    #black($self->{_complete} . "-" x 77);
    
    die "Error in reading handle ($name)"
	if not defined $self->{_complete} and $self->{_error_onread};
    
    $self->_updateNoComments;
}


sub write {
    my $self = shift;
    
    return if $self->isDummy();
    
    unless ($self->{_force_write}) {
	red("Warning: Skipping writing/calling of handle `$self->{_id}'. " .
	    "Maybe you should use FORCE_WRITE=\"true\".");
	return;
    }
    
    my $name = $self->name;
    
    # If a system file name doesn't begin with a '/', it is
    # one of the test files. Prepend full path in this case:
    # (TODO: hier nach "_namespacePath = root/test" testen statt nach m|/|)
    if ($self->{_namespacePath}->namespace eq 'root/test') {
	my $sandbox = $self->{_CIMOMHandle}->config->sandbox;
	
	if ($self->isFile) {
	    $name = "$sandbox/$name";
	}
  	if ($self->isCommand) {
	    unless ($ENV{PATH} =~ /^$sandbox/) {
		$ENV{PATH} = "$sandbox/bin/:$ENV{PATH}";
	    }
  	}
    }
    
    ########## FILE ##########
    if ($self->isFile) {
	
	# in isFile() I think I should ignore $self->{_error_onwrite}
	red("Warning: Ignoring \$self->{_error_onwrite} on FILE OUT handles")
	    if $self->{_error_onwrite};
	
	# just for testing
	{
	    my $text = $self->complete();
	    chomp $text;
	    $self->{_CIMOMHandle}->log->info("writing handle `$name'");
	    #black("writing handle `$name'");
	    black("/----------------file content:------------\\");
	    #black($self->complete);
	    black($text);
	    black("\\-----------------------------------------/");
	}
	
	# in case of need remove file
	if ($self->{_remove_atwriting} or
	    ($self->{_remove_ifempty} and $self->{_complete} eq '')) {
	    if (-e $name) {
		red("removing $name");
		unlink($name) or die "Error while removing `$name'";
	    }
	}
	
	# create the new file
	else {
	    my $origsuff = '.paulasave';
	    #
	    # Simple strategy (to be improved!!!):
	    #
	    # 1. Rename original file into $name.$origsuff
	    # 2. Create $name
	    # 3. If everything went well, delete the backup.
	    #
	    my $backup = "$name.$origsuff";
	    my $origExists = (-e $name ? 0 : 1);
	    
	    # create backup file
	    unless ($origExists) {
		move($name, $backup) or
		    die "Couldn't make backup of `$name': $!";
	    }
	    
	    # write new content to the file
	    open HANDLE, "> $name" or
		die "Error in writing new content of `$name': $!";
	    print HANDLE $self->{_complete};
	    close HANDLE or die "Error while closing `$name': $!";
	    
	    # chmod file
	    my $umask = $self->{_umask};
	    if (defined $umask) {
		#black("chmod $umask $name");
		# maybe better: "chmod(oct($umask), $name)
		system("chmod $umask $name") == 0 or
		    die "Error in chmod-ing file `$name' to `$umask'";
	    }
	    
	    # chown file
	    my $chmodmask;
	    $chmodmask = $self->{_uid} if defined $self->{_uid};
	    $chmodmask .= ':' . $self->{_gid} if defined $self->{_gid};
	    if (defined $chmodmask) {
		#black("chown $chmodmask $name");
		system("chown $chmodmask $name") == 0 or
		    die "Error in chown-ing file `$name' to `$chmodmask'";
	    }
	    
	    # remove backup file
	    unless ($origExists) {
		unlink($backup) or die "Error while removing `$backup'";
	    }
	}
    }
    ########## COMMAND ##########
    elsif ($self->isCommand) {
	my $commandline = $self->{_name}; 
	$commandline .= " " . $self->{_commandlineOpts} 
	    if defined $self->{_commandlineOpts} && 
		$self->{_commandlineOpts} ne "";
	
	black("calling '$commandline'...");
	
	# open handle
	unless (open HANDLE, "$commandline") {
	    my $exitcode = $? >> 8;
	    if ($self->{_error_onwrite}) {
		die "Error in opening handle `$commandline' on write() " .
		    "(got exit code $exitcode)";
	    }
	    else {
		return;
	    }
	}
	
	# evtl. hier noch ein "print HANDLE"...
	
	# close handle
	unless (close HANDLE) {
	    $self->{_exitcode} = $? >> 8;
	    if ($self->{_error_onwrite}) {
		die "Error in closing handle `$commandline' on write() " .
		    "(got exit code $self->{_exitcode})";
	    }
	}
	else {
	    $self->{_exitcode} = $? >> 8;
	}
    }
    ########## (else) ##########
    else {
	die "unknown or not implemented output handle type";
    }
}


1;


__END__

=head1 NAME

PaulA::ProviderHandle - Represents a provider handle (file or command)



=head1 SYNOPSIS

 (only for internal use in Provider.pm and ProviderConfig.pm)



=head1 DESCRIPTION

This module represents a Provider handle, i.e. a file or a command. 
With it you can read, write or call this handle (to administrate the Linux
system).

The general workflow is the following:

=item 1. init()

Initialize the handle with its XML configuration.

=item 2. name()

In case of need specify the handle name.

=item 3. read()

If it's an input handle: Read the handle from the system.
This means a file will be read or a command will be called. The output
is stored in the variable _complete, the modified output with no comments
(for easier parsing) is stord in _nocomments.

=item 4a. replace()

If it's a file handle: Modify its content.

=item 4b. addCommandlineOpt()

If it's a command handle: Set commandline options.

=item 5. write()

If it's an output handle: Write its content back into the system, which
means write the file or call the handle (eventually with the given
commandline options).

=item 6. restoreOrigValues() / write()

In case of need (e.g. if anywhere else some error occured) reset to the
state before any changes were made and write again.



=head1 CONSTRUCTOR

=over 4

=item new([OPTIONS])


C<OPTIONS> are passed in a hash like fashion, using key and value pairs.
The possible options are:

B<ID> - The ID string for the handle.

B<Config> - An hash reference representing the XML description of an handle.
This option is optional.



=head1 METHODS

=item init($config)

To initialize the handle with an hash reference $config representing the
XML description.

=item id()

Returns the ID string of the handle.

=item number()

Returns the number of the handle.

=item name([$name])

Get/set accessor for the the name of the handle. This is either the file
name or the name of the command (in case of need with commandline arguments).
The function returns the name of the handle.

=item type()

Returns the type of the handle. Valid values are 'FILE' if the handle
represents a file or 'COMMAND' it corresponds with a command.

=item isFile()

Returns B<1> if the handle type is 'FILE', or B<0> else.

=item isCommand()

Returns B<1> if the handle type is 'COMMAND', or B<0> else.

=item isDummy()

Returns B<1> if the handle type is 'DUMMY', or B<0> else.

=item whitespaceRead()

Returns the RegExp to detect whitespaces in the handle output (i.e. the
content of the file or the output of the command).
Default is the space character.

=item whitespaceWrite()

Returns a (single) character which should be written when want to write
a whitespace.

=item commentLineRead()

Returns the string for detection line comments, i.e. comments which start
with this string and end at the end of the line.

=item commentLineWrite()

Returns the string which should be written when you want to write a
line comment.

=item isReadable()

Returns B<1> if the handle is intended to be readable, or B<0> else.

=item isWriteable()

Returns B<1> if the handle is intended to be writeable, or B<0> else.

=item removeAtWriting()

Call this function if you want to remove the corresponding file instead of
writing it.
Only useful on FILE handles.

=item forceWriting()

Call this function if you want to force writing an handle.

=item commandlineOpts()

Returns the commandline options for the handle.
Only useful when handle is a command.

=item addCommandlineOpt($string)

Adds the specified string to the commandline options.
Only useful when handle is a command.

=item exitCode()

Returns the exit code returned by closing the handle.
Only useful on COMMAND handles.

=item complete()

Returns the complete output of the handle (file content or output of the
command).

=item nocomments()

Returns the output of the handle without comments.

=item _updateNoComments()

Internal routine to set the variable _nocomments.
It replaces all comments with whitespaces of the same length.

=item restoreOrigValues()

Resets the contents of the variable _complete to the state before any
changes were made.

=item setPermissions($uid, $gid, $umask)

To specify the permissions of the file when writing it. Each parameter can
be undef.

=item search(...)

...

=item replace([ $info | $newText ])

...

=item read()

Reads the handle. This means thar either a file is read or the a command
is called.

=item write()

Writes the handle. In case of a file the modified content will be written,
in the other case a command will be called (eventually with the specified
commandline options).



=head1 SEE ALSO

L<PaulA::Provider>, L<PaulA::ProviderConfig>



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
