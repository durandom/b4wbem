#!/bin/sh
#
# represents and simulates a chkconfig call
#

fileD=`dirname $0`/chk_dhcp.log
fileJ=`dirname $0`/chk_junkb.log
fileV=`dirname $0`/chk_vpnd.log

[ $# = 0 ] && echo "error: no option specified" && exit 1


case "$@" in

    ### DHCP
    "dhcpd on")
	touch $fileD
	;;
    "dhcpd off")
	rm -f $fileD
	;;
    "--list dhcpd")
	[ -e $fileD ] && \
	    echo "dhcpd 0:off 1:off 2:off 3:on 4:on 5:on 6:off" || \
	    echo "dhcpd 0:off 1:off 2:off 3:off 4:off 5:off 6:off"
	;;
	
    ### Junkbuster
    "junkbuster on")
	touch $fileJ
	;;
    "junkbuster off")
	rm -f $fileJ
	;;
    "--list junkbuster")
	[ -e $fileJ ] && \
	    echo "junkbuster 0:off 1:off 2:off 3:on 4:on 5:on 6:off" || \
	    echo "junkbuster 0:off 1:off 2:off 3:off 4:off 5:off 6:off"
	;;
	
    ### VPND
    "vpnd on")
	touch $fileV
	;;
    "vpnd off")
	rm -f $fileV
	;;
    "--list vpnd")
	[ -e $fileV ] && \
	    echo "vpnd 0:off 1:off 2:off 3:on 4:on 5:on 6:off" || \
	    echo "vpnd 0:off 1:off 2:off 3:off 4:off 5:off 6:off"
	;;
    *)
	echo "unknown option: $1"
	exit 1;
esac

exit 0;
