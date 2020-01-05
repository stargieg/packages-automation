#!/bin/sh

. /lib/functions.sh

HOST="$COLLECTD_HOSTNAME"
INTERVAL=$(echo ${COLLECTD_INTERVAL:-8} | cut -d . -f 1)
sleep_n=$((INTERVAL-5))

var_5xxx=""
var_5001=""
var_5003=""
var_6xxx=""
var_7xxx=""
var_8xxx=""
var_9xxx=""
var_xxxx=""

add_var() {
	local cfg=$1
	local config=$2
	config_get type $cfg type
	case $type in
		5.xxx) var_5xxx=$var_5xxx" $config.$cfg";;
		5.001) var_5001=$var_5001" $config.$cfg";;
		5.003) var_5003=$var_5003" $config.$cfg";;
		6.xxx) var_6xxx=$var_6xxx" $config.$cfg";;
		7.xxx) var_7xxx=$var_7xxx" $config.$cfg";;
		8.xxx) var_8xxx=$var_8xxx" $config.$cfg";;
		9.xxx) var_9xxx=$var_9xxx" $config.$cfg";;
		*) var_xxxx=$var_xxxx" $config.$cfg";;
	esac
}

for i in $(seq 0 31); do
	for j in $(seq 0 7); do
		[ -f /etc/config/knx_"$i"_"$j" ] || continue
		config_load knx_"$i"_"$j"
		config_foreach add_var grp knx_"$i"_"$j"
	done
done

while sleep $sleep_n; do
	for i in $var_5xxx ; do
		value=$(uci -q -p /var/state get $i.value)
		[ -z $value ] && continue
		echo "PUTVAL $HOST/linknx-$i/5xxx interval=$INTERVAL N:$value"
		count=$(uci -q -p /var/state get $i.count)
		[ -z $count ] && continue
		echo "PUTVAL $HOST/linknx-$i/derive interval=$INTERVAL N:$count"
	done
	for i in $var_5001 ; do
		value=$(uci -q -p /var/state get $i.value)
		[ -z $value ] && continue
		echo "PUTVAL $HOST/linknx-$i/5001 interval=$INTERVAL N:$value"
		count=$(uci -q -p /var/state get $i.count)
		[ -z $count ] && continue
		echo "PUTVAL $HOST/linknx-$i/derive interval=$INTERVAL N:$count"
	done
	for i in $var_5003 ; do
		value=$(uci -q -p /var/state get $i.value)
		[ -z $value ] && continue
		echo "PUTVAL $HOST/linknx-$i/5003 interval=$INTERVAL N:$value"
		count=$(uci -q -p /var/state get $i.count)
		[ -z $count ] && continue
		echo "PUTVAL $HOST/linknx-$i/derive interval=$INTERVAL N:$count"
	done
	for i in $var_6xxx ; do
		value=$(uci -q -p /var/state get $i.value)
		[ -z $value ] && continue
		echo "PUTVAL $HOST/linknx-$i/6xxx interval=$INTERVAL N:$value"
		count=$(uci -q -p /var/state get $i.count)
		[ -z $count ] && continue
		echo "PUTVAL $HOST/linknx-$i/derive interval=$INTERVAL N:$count"
	done
	for i in $var_7xxx ; do
		value=$(uci -q -p /var/state get $i.value)
		[ -z $value ] && continue
		echo "PUTVAL $HOST/linknx-$i/7xxx interval=$INTERVAL N:$value"
		count=$(uci -q -p /var/state get $i.count)
		[ -z $count ] && continue
		echo "PUTVAL $HOST/linknx-$i/derive interval=$INTERVAL N:$count"
	done 
	for i in $var_8xxx ; do
		value=$(uci -q -p /var/state get $i.value)
		[ -z $value ] && continue
		echo "PUTVAL $HOST/linknx-$i/8xxx interval=$INTERVAL N:$value"
		count=$(uci -q -p /var/state get $i.count)
		[ -z $count ] && continue
		echo "PUTVAL $HOST/linknx-$i/derive interval=$INTERVAL N:$count"
	done 
	for i in $var_9xxx ; do
		value=$(uci -q -p /var/state get $i.value)
		[ -z $value ] && continue
		echo "PUTVAL $HOST/linknx-$i/9xxx interval=$INTERVAL N:$value"
		count=$(uci -q -p /var/state get $i.count)
		[ -z $count ] && continue
		echo "PUTVAL $HOST/linknx-$i/derive interval=$INTERVAL N:$count"
	done 
	for i in $var_xxxx ; do
		count=$(uci -q -p /var/state get $i.count)
		[ -z $count ] && continue
		echo "PUTVAL $HOST/linknx-$i/derive interval=$INTERVAL N:$count"
	done 
done
