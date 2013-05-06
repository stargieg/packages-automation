#!/bin/sh

max=254
export BACNET_BBMD_ADDRESS=127.0.0.1
export BACNET_IP_PORT=47809
export BACNET_BBMD_PORT=47808

wget -O /tmp/host.csv 'http://icingaadmin:icingaadmin@127.0.0.1/icinga/cgi-bin/status.cgi?style=hostdetail&limit=0&start=1&csvoutput'
x=0
while [ $x -le $max ] ; do
    Name=''
    Name=$(uci get "bacnet_mv."$x".name" 2>/dev/null)
    if ! [[ $Name == '' ]] ; then
        line=''
        line=$(egrep "^.$Name" /tmp/host.csv)
        hostname_csv=''
        hostname_csv=$(echo $line | cut -d ';' -f 1)
        value=''
        value=$(echo $line | cut -d ';' -f 2)
        eval value=$value
        case $value in
            UP) 
		bacwp 10001 19 $x 85 3 -1 2 1
		uci set bacnet_mv."$x".value=1
		;;
            DOWN)
		bacwp 10001 19 $x 85 3 -1 2 2
		uci set bacnet_mv."$x".value=2
		;;
            UNREACHABLE)
		bacwp 10001 19 $x 85 3 -1 2 3
		uci set bacnet_mv."$x".value=3
		;;
            FLAPPING)
		bacwp 10001 19 $x 85 3 -1 2 4
		uci set bacnet_mv."$x".value=4
		;;
        esac
    fi
    x=$((x+1))
done

uci commit

