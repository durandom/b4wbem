use strict;

use File::Path;
use Cwd;

unless (-d "conf") {
    mkdir "conf" or die "Cannot create conf/ directory\n";
}

my $cwd = cwd;

# create conf/WebFrontend.conf:

open(WEBCONF, ">conf/WebFrontend.conf");
print WEBCONF <<EOF;
<Location /paul-admin>
  SetHandler perl-script
  PerlHandler Apache::PaulAdmin
</Location>

<Location /paul-getcim>
  SetHandler perl-script
  PerlHandler Apache::PaulGetCim
</Location>

<Location /paul-setcim>
  SetHandler perl-script
  PerlHandler Apache::PaulSetCim
</Location>

<Location /paul-menu>
  SetHandler perl-script
  PerlHandler Apache::PaulMenu
</Location>

<Location /paul-login>
  SetHandler perl-script
  PerlHandler Apache::TicketMaster
</Location>

SetEnv CIM_CLIENT_CONFIG /home/$ENV{USER}/.cimclient.xml
SetEnv WEBFRONTEND_HOME $cwd
SetEnv LINK_NAME WebFrontend 

PerlRequire $cwd/conf/startup.pl
EOF

close WEBCONF;

    
# create conf/startup.pl:

open(STARTUP, ">conf/startup.pl");
print STARTUP <<EOF;
BEGIN {
    use lib "$cwd/mod_perl";
    use lib "$cwd/../libCIM/lib";
}

1;
EOF

close STARTUP;

    
