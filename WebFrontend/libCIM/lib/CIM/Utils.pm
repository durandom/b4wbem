use strict;

###################
package CIM::Utils;
###################

use vars qw(@ISA @EXPORT $verbose);

use Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(pprint prettyXML cpprint
	     bool2string string2bool
	     fatal mark
	     areEqual
	     present
	     red green blue magenta cyan yellow white black
	    );

use Carp;
use Getopt::Long;
use Term::ANSIColor qw(:constants);


$verbose = 1;


sub prettyXML {
    $_ = shift;
    s/></>\n</g;
    
    my $depth = -1;
    my $text_middle = 0;
    my $pretty = "";
    
    foreach $_ (split /\n/) {
	my ($up, $down) = (0, 0);
	my ($text_begin, $text_end) = (0, 0);
	
	# both start and end tag
	# <VALUE>true</VALUE>
	if (/<.*>.*<\/.*>/) {
	    $up = $down = 1;
	}
	# special tags with no indent
	# <?xml ....>
	if (/<\?xml /) {
	    $up = $down = 1;
	}
	# single end tag
	# </VALUE>
	elsif (/<\/.*/) {
	    $down = 1;
	    $text_end = 1;
	}
	# start and end tag as one
	# <VALUE/>
	elsif (/.*\/>/) {
	    $up = $down = 1;
	}
	# single start tag (maybe with arguments)
	# <VALUE>
	elsif (/(<.+>)(.*)/) {
	    $up = 1;
	    $text_begin = 1 if ($2 ne '');
	}
	# simple text
	else {
	    $up = $down = 1;
	}
	
	$depth++ if $up;
	my $space = ($text_middle ? '' : '  ' x $depth);
	$pretty .= "$space$_\n";
	$depth-- if $down;
	$text_middle = 1 if $text_begin;
	$text_middle = 0 if $text_end;
    }

    return $pretty;
}
	


# does a "pretty print" of a XML request
sub pprint {
    my @args = @_;
    
    foreach (@args) {
	print prettyXML($_);
    }
}


# does a colorized "pretty print" of a XML request
sub cpprint {
    my @args = @_;

    foreach (@args) {
	s/></>\n</g;
	
	my $depth = -1;
	my $text_middle = 0;
	
	foreach $_ (split /\n/) {
	    my ($up, $down) = (0, 0);
	    my ($text_begin, $text_end) = (0, 0);
	    my $cstring = $_;
	    
	    # both start and end tag (without attributes)
	    # <VALUE>true</VALUE>
	    if (/(<[^ ]+?>)(.*)(<\/.*?>)/) {  
		$cstring = RED . $1 . RESET . $2 . RESET . GREEN . $3;
		$up = $down = 1;
	    }
	    # both start and end tag (with attributes)
	    # <VALUE NAME="foo">
	    elsif (/(<.*?)( .*?)(>)(.*?)(<\/.*?>)/) {  
		$cstring = RED . $1 . BLUE . $2 . RED . $3 .
		    RESET . $4 . RESET . GREEN . $5;
		$up = 1;
		$text_begin = 1 if ($6 ne '');
	    }
	    # special tags with no indent
	    # <?xml ....>
	    elsif (/(<\?xml )/) {    
		$cstring = BOLD . BLUE . $1;
		$up = $down = 1;
	    }
	    # single end tag
	    # </VALUE>
	    elsif (/(<\/.*>)/) {
		$cstring = GREEN . $1;
		$down = 1;
		$text_end = 1;
	    }
	    # start and end tag as one (without attributes)
	    # <VALUE/>
	    elsif (/(<[^ ]+?)(\/>)/) { 
		$cstring = RED . $1 . GREEN . $2;
		$up = $down = 1;
	    }
	    # start and end tag as one (with attributes)
	    # <VALUE/>
	    elsif (/(<.*?)( .*?)(\/>)/) { 
		$cstring = RED . $1 . BLUE . $2 . GREEN . $3;
		$up = $down = 1;
	    }
	    # single start tag (without attributes)
	    # <VALUE>
	    elsif (/(<[^ ]+>)(.*)/) {
		$cstring = RED . $1 . RESET . $2;
		$up = 1;
		$text_begin = 1 if ($2 ne '');
	    }
	    # single start tag (with attributes)
	    # <VALUE NAME="foo">
	    elsif (/(<.*?)( .*?)(>)(.*)/) {
		$cstring = RED . $1 . BLUE . $2 . RED . $3;
		$up = 1;
		$text_begin = 1 if ($4 ne '');
	    }
	    # simple text
	    else {
		$up = $down = 1;
	    }
	    
	    $depth++ if $up;
	    my $space = ($text_middle ? '' : '  ' x $depth);
	    print RESET, $space, $cstring, RESET, "\n";
	    
	    $depth-- if $down;
	    $text_middle = 1 if $text_begin;
	    $text_middle = 0 if $text_end;
	}
    }
}


sub bool2string {
    my $b = shift;
    
    return ($b ? 'true' : 'false');
}

sub string2bool {
    my $s = shift;
    
    if ($s eq 'true' or $s eq '1') {
	return 1;
    }
    elsif ($s eq 'false' or $s eq '0') {
	return 0;
    }
    else {
	croak "Invalid boolean value";
    }
}


sub fatal {
    my ($msg) = @_;

    my $newline = chomp $msg;
    my $newmsg = $msg;
    
    if ($newline) {
	$newmsg .= "\n";
    }
    else {
	$newmsg .= " at " . (caller)[1] . " line " . (caller)[2] . "\n";
    }
    
    print STDERR $newmsg;
    die "Fatal CIM Error: `$newmsg'";
}


sub mark {
    my @msg = @_;

    return unless $verbose;
    
    my $pm = (caller)[1];
    $pm =~ s|.*/||;

    print STDERR "*** @msg ***" . " at " . $pm .
	" line " . (caller)[2] . "\n";
}

sub red     { print STDERR RED     . "@_" . RESET, "\n" if $verbose; }
sub green   { print STDERR GREEN   . "@_" . RESET, "\n" if $verbose; }
sub blue    { print STDERR BLUE    . "@_" . RESET, "\n" if $verbose; }
sub magenta { print STDERR MAGENTA . "@_" . RESET, "\n" if $verbose; }
sub cyan    { print STDERR CYAN    . "@_" . RESET, "\n" if $verbose; }
sub yellow  { print STDERR YELLOW  . "@_" . RESET, "\n" if $verbose; }
sub white   { print STDERR WHITE   . "@_" . RESET, "\n" if $verbose; }
sub black   { print STDERR BLACK   . "@_" . RESET, "\n" if $verbose; }



sub areEqual {
    my ($lhs, $rhs) = @_;
    
    my ($refl, $refr) = (ref $lhs, ref $rhs);
    #print "REFS: ", $refl, "/", $refr, "\n";
    return 0 if ($refl xor $refr);
    
    # compare two arrays:
    if ($refl eq 'ARRAY') {
	my @lhs = @$lhs;
	my @rhs = @$rhs;
	
	#      print join(', ', @lhs), "\n";
	#      print join(', ', @rhs), "\n";
	
	return 0 unless ($#lhs == $#rhs);
	
	for (my $i = 0; $i <= $#lhs; $i++) {
	    return 0 unless areEqual($lhs[$i], $rhs[$i]);
	}
	
	return 1;
    }
    
    # compare two hashes:
    elsif ($refl eq 'HASH') {
	my %lhs = %$lhs;
	my %rhs = %$rhs;
	
	my (@l, @r);
	foreach (sort keys %lhs) {
	    push @l, $_, $lhs{$_};
	}
	foreach (sort keys %rhs) {
	    push @r, $_, $rhs{$_};
	}
	
	#      print join(', ', @l), "\n";
	#      print join(', ', @r), "\n";
	
	return areEqual(\@l, \@r);
    }
    
    # compare two scalars:
    else {
	return 0 if (defined $lhs xor defined $rhs);
	
	if (defined $lhs and defined $rhs) {
	    
	    my ($refl, $refr) = (ref $lhs, ref $rhs);
	    
	    return 0 if ($refl xor $refr);
	    return 0 unless ($refl ? ($lhs == $rhs) : ($lhs eq $rhs));
	}
	
	return 1;
    }
}


sub present {
    my ($val, $color) = @_;
    my $reset = RESET;
    
    $color = $reset = ''
	unless (defined $color and $color ne '');
    
    my $out;
    ##########################
    if (ref $val eq 'ARRAY') {
	my @a;
	foreach my $arrayval (@$val) {
	    push @a, present($arrayval, $color);
	}
	$out = "[ " . join($reset . ', ' . $color, @a) . " ]";
    }
    ############################
    elsif (ref $val eq 'HASH') {
	my @a;
	foreach my $hashkey (sort keys %$val) {
	    my $hashval = present($val->{$hashkey}, $color);
	    push @a, $hashkey . $reset . " => " . $hashval;
	}
	$out = "{ " . join($reset . ', ' . $color, @a) . " }";
    }
    ######
    else {
	if (defined $val) {
	    $out = "`" . $color . $val . $reset . "'";
	}
	else {
	    $out = "<" . $color . "undef" . $reset . ">";
	}
    }
    
    return $out;
}



1;


__END__

=head1 NAME

CIM::Utils - module with useful utilities 



=head1 SYNOPSIS

 use CIM::Utils;

 pprint $class->toXML->toString;
 cpprint $class->toXML->toString;

 $b = string2bool('true');
 $s = bool2string(1);

 fatal("Some error message");
 fatal("Some other error message\n");

 mark("i = $i");



=head1 DESCRIPTION

This module provides useful utilities.



=head1 METHODS

=over 4

=item pprint($string)

pprint() prints a XML request $string with proper indentation, which makes 
the printout better readable for human eyes. The function requires at least
one string as argument.

=item cpprint($string)

cpprint() does the same as pprint(), just colorizes the XML tags.
Attention: For your own protection you should wear sunglasses. B-)

=item bool2string($int), string2bool($string)

Two functions converting the Perl integer values B<0> and B<1> into the strings
"B<true>" and "B<false>" and vice versa.

=item fatal($string)

Prints out the given error message and quits the running program. If the last
character of the message is no "\n" then some more informations will be
printed, similar to the die() behaviour. You should use fatal() instead of
die() because die() is used for the exception handling.

=item mark($string)

Is used mainly for temporary debugging purposes; it outputs a line
consisting of $string, emphasized with "***" and with additional information
about file name and line number of the caller.

=item red($string), green($string), blue($string), magenta($string), cyan($string), yellow($string), white($string), black($string)

They're just easy and fast to type functions for printing the given string
to STDERR in the corresponding color. (Useful for developement.)

=item areEqual($s1, $s2)

Checks if the given scalars (strings, numbers and instances overloading the
== operator), arrays or hashes are equal or not. The strings
or the entries of the arrays/hashes can be be undef. The comparison
is recursive (i.e. it is valid to compare hashes of arrays of scalars).
Attention: Numbers are treated as strings, i.e. 1.0 and 1 are not equal.

=item present($value [, $color])

Returns the given $value (scalar, array reference or hash reference) nice
presented (with the specified color). (Useful for developement.)



=head1 AUTHORS

 Volker Moell <moell@gmx.de>
 Eva Bolten <bolten@ID-PRO.de>
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
