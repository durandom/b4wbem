package Apache::TicketAccess;

use strict;
use Apache::Constants qw(OK FORBIDDEN REDIRECT);
use Apache::TicketTool ();

sub handler {
    my $r = shift;
    my $ticketTool = Apache::TicketTool->new($r);
    my($result, $msg) = $ticketTool->verify_ticket($r);
    unless ($result) {
	$r->log_reason($msg, $r->filename);
	return FORBIDDEN;
    }
    
    return OK;
}

1;
__END__
