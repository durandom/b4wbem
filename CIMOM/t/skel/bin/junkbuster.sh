#!/bin/sh
#
# represents and simulates a junkbuster daemon related call
#

file=`dirname $0`/junkbuster.log

[ $# = 0 ] && echo "error: no option specified" && exit 2


case $1 in
    start|restart)
	touch  $file
	;;
    stop)
	rm -f $file
	;;
    status)
	[ -e $file ] && echo "junkbuster running..." || echo "junkbuster stopped"
	;;
    weekly)
	echo "executing junkbuster.weekly"
	;;
    *)
	echo "unknown option: $1"
	exit 3;
esac

exit 0;
