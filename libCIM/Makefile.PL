use ExtUtils::MakeMaker;

BEGIN { require 5.6.0; }

WriteMakefile(
	      NAME           => 'libCIM',
	      VERSION_FROM   => 'lib/CIM.pm',
	      
	      PREREQ_PM => {
			    'HTTP::Request'   => 0,
			    'Term::ANSIColor' => 0,
			    'Tie::SecureHash' => 0,
			    'XML::DOM'        => 0,
			    'XML::Simple'     => 0,
			    'Carp::Assert'    => 0,
			    'MIME::Base64'    => 0,
			   },
	      dist      => {
			    'COMPRESS'  => 'gzip -f --best',
			    'SUFFIX'    => '.gz'
			   },
	     );
