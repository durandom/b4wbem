use ExtUtils::MakeMaker;
use lib "../libCIM/lib";

BEGIN { require 5.6.0; }


# We want to influence the order of the tests.
# The first test shall start the cimom, then the "normal" tests follow,
# and the last test shall stop the cimom.

opendir(DIR, 't') || die "can't opendir t: $!";
my @tests = grep {
    /\.t$/ && !/^cimomstart/ && !/^cimomstop/
} sort readdir(DIR);

# Add first and last test to list:
unshift @tests, 'cimomstart.t';
push    @tests, 'cimomstop.t';

@tests = map { "t/$_" } @tests;


WriteMakefile(
	      NAME           => 'PaulA',
	      VERSION_FROM   => 'lib/PaulA.pm',
	      
	      PREREQ_PM => {
			    'CIM'             => 0,
			    'Term::ANSIColor' => 0,
			    'Tie::SecureHash' => 0,
			    'XML::DOM'        => 0,
			    'XML::Simple'     => 0,
			    'Carp::Assert'    => 0,
			   },
	      dist      => {
			    'COMPRESS'  => 'gzip -f --best',
			    'SUFFIX'    => '.gz'
			   },
	      test      => { TESTS => "@tests"  },
	     );

sub MY::install {
    package MY;

    #########################################
    # CAUTION: DO NOT CHANGE INDENTATION!!! #
    #########################################
    
    my $text = <<EOF;
install:
	install -d -m 0755 \$(PREFIX)/etc/percimon
	install -m 0644 etc/cimserver.xml etc/cimclient.xml \$(PREFIX)/etc/percimon
	install -m 0600 etc/cim*-secrets.xml \$(PREFIX)/etc/percimon
	install -d -m 0755 \$(PREFIX)/usr/sbin
	install -m 0755 bin/cimom \$(PREFIX)/usr/sbin
	install -d -m 0755 \$(PREFIX)/var/lib/percimon/repository/xmlRoot/PaulA
	install -m 0644 repository/xmlRoot/PaulA/S-CIM_Schema23.xml \$(PREFIX)/var/lib/percimon/repository/xmlRoot/PaulA
	install -m 0644 repository/xmlRoot/PaulA/C-PaulA_*.xml \$(PREFIX)/var/lib/percimon/repository/xmlRoot/PaulA
	install -d -m 0755 \$(PREFIX)/usr/lib/percimon/PaulA
	cp -a lib \$(PREFIX)/usr/lib/percimon/PaulA

	install -d -m 0755 \$(PREFIX)/etc/percimon/PaulA
	install -m 0644 t/skel/files/groups.paula \$(PREFIX)/etc/percimon/PaulA

EOF
    return $text;
}


#  sub MY::test_via_harness{
#      package MY;
#      my $inherited = shift->SUPER::test_via_harness(@_);

#      $inherited =~ s/^\t//;
#      "\tCIM_CLIENT_CONFIG=t/cimclient.xml " . $inherited;
#  }


sub MY::realclean {
    package MY;
    
    my @removeList = qw(
			lib/PaulA/Provider/PaulA
			t/cimserver.xml
			t/cimclient.xml
		       );
    
    my @removeDirList = qw(
			   t/sandbox
			   t/cimom/
			  );
    
    # Determine the files that splitCIMSchema.pl will create:
    my $dir = "repository/xmlRoot/PaulA";
    my $schema = "$dir/S-CIM_Schema23.xml";
    open SCHEMA, "$schema" or die "Cannot read $schema: $!";

    my @files;
    while (<SCHEMA>) {
	next unless /CLASS NAME="(.*?)"/;
	push @files, "$dir/C-$1.xml";
    }
    close SCHEMA;
    push @removeList, @files;
    
    
    my $inherited = shift->SUPER::realclean(@_);

    return $inherited .
	"\n\trm -f @removeList" . "\n\trm -rf @removeDirList";
}
