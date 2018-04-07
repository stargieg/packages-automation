#!/bin/sh

. /lib/functions.sh
. /usr/share/libubox/jshn.sh
BIN="/usr/bin/mbus-serial-request-data"
stdout=1
[ "$HOME" == "/" ] && stdout=0

log_mbus() {
	if [ "$stdout" == "1" ] ; then
		logger -s -t mbus $@
	else
		logger -t mbus $@
	fi
}

get_data() {
	local cfg=$1
	local type=$2
	[ "$cfg" == "default" ] && return
	config_get disable $cfg disable "0"
	[ "$disable" == "1" ] && return
	config_get tagname $cfg tagname ""
	[ "$tagname" == "$PROC_TAGNAME" ] || return
	config_get unit_id $cfg unit_id "1"
	[ -d /tmp/mbus-$PROC_TTYDEV-$unit_id ] || mkdir -p /tmp/mbus-$PROC_TTYDEV-$unit_id
	$BIN -b $PROC_BAUD $PROC_TTYDEV $unit_id > /tmp/mbus-$PROC_TTYDEV-$unit_id/current.xml
	config_get addr $cfg addr "0"
	value=$(/usr/bin/xml_parser.sh /tmp/mbus-$PROC_TTYDEV-$unit_id/current.xml $addr "Value")
	#unit=$(/usr/bin/xml_parser.sh /tmp/mbus-$PROC_TTYDEV-$unit_id/current.xml $addr "Unit")
	config_get oldvalue $cfg value
	if [ $value != $oldvalue ] ; then
		log_mbus "loop new value $value"
		uci_set bacnet_$type $cfg value "$value"
		uci_commit bacnet_$type
	fi
}

log_mbus "start $PROC_TAGNAME $PROC_TTYDEV $PROC_BAUD"
while true; do
	#Load config
	obj_types="ai av"
	for type in $obj_types ; do
		config_load bacnet_$type
		config_foreach get_data $type $type
	done
	sleep 3
done
