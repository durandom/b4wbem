use ExtUtils::MakeMaker;

BEGIN { require 5.6.0; }

WriteMakefile(
	      NAME           => 'WebFrontend',
	      VERSION        => '0.5',
	      
	      PREREQ_PM => {
			    'XML::Sablotron'  => 0,
			    'XML::DOM'        => 0,
			   },
	      dist      => {
			    'COMPRESS'  => 'gzip -f --best',
			    'SUFFIX'    => '.gz'
			   },
	     );



sub MY::install {
    package MY;

    #########################################
    # CAUTION: DO NOT CHANGE INDENTATION!!! #
    #########################################
    
    my $text = <<EOF;
install:
	install -d -m 0755 \$(PREFIX)/usr/lib/percimon/WebFrontend
	for i in html images jscript mod_perl styles xml; do \\
	cp -a \$\$i \$(PREFIX)/usr/lib/percimon/WebFrontend; \\
	done
	install -d -m 0755 \$(PREFIX)/etc/httpd/conf
	install -m 644 etc/WebFrontend.conf etc/startup.pl \$(PREFIX)/etc/httpd/conf
EOF
    return $text;
}


sub MY::realclean {
    package MY;
    
    my @removeList = qw(
                        conf/
                       );
    
    my $inherited = shift->SUPER::realclean(@_);

    return $inherited .
        "\n\trm -rf @removeList";
}
