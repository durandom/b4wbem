#!/bin/sh
#
# represents and simulates a dhcpd related call
#

file=`dirname $0`/dhcpd.log

[ $# = 0 ] && echo "error: no option specified" && exit 2


case $1 in
    start|restart)
	touch  $file
	;;
    stop)
	rm -f $file
	;;
    status)
	[ -e $file ] && exit 0 || exit 1
	;;
    *)
	echo "unknown option: $1"
	exit 3;
esac

exit 0;
