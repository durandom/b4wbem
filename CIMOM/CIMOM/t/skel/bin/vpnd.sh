#!/bin/sh
#
# represents and simulates a vpnd related call
#

file=`dirname $0`/vpnd.log

[ $# = 0 ] && echo "error: no option specified" && exit 2


case $1 in
    start|restart)
	touch $file
	;;
    stop)
	rm -f $file
	;;
    status)
	[ -e $file ] && echo "vpnd is running.." || echo "vpnd is stopped"
	;;
    *)
	echo "unknown option: $1"
	exit 3;
esac

exit 0;
