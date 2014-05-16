#!/bin/sh
hostname=$1
state=$2
max=254
export BACNET_BBMD_ADDRESS=127.0.0.1
export BACNET_IP_PORT=47809
export BACNET_BBMD_PORT=47808
x=0

(
while [ $x -le $max ]
do
  Name=$(uci get "bacnet_mv."$x".name" 2>/dev/null)
  if [ "$Name" == "$hostname" ] ; then
    case "${state}" in
      UP)
          bacwp 10001 19 $x 85 16 -1 2 1
          uci set "bacnet_mv."$x".value=1" 2>/dev/null
          ;;
      DOWN)
          bacwp 10001 19 $x 85 16 -1 2 2
          uci set "bacnet_mv."$x".value=2" 2>/dev/null
          ;;
      UNREACHABLE)
          bacwp 10001 19 $x 85 16 -1 2 3
          uci set "bacnet_mv."$x".value=3" 2>/dev/null
          ;;
      FLAPPING)
          bacwp 10001 19 $x 85 16 -1 2 4
          uci set "bacnet_mv."$x".value=4" 2>/dev/null
          ;;
    esac
  fi
  x=$(( $x + 1 ))
done
) >>/dev/null 2>&1
