#!/bin/sh

. /lib/functions.sh
. /usr/share/libubox/jshn.sh
BIN="/usr/bin/mbus-serial-request-data"

log_mbus() {
	logger -s -t mbus $@
}

#PROC_TAGNAME
#PROC_TTYDEV
#PROC_BAUD
unit_id=1

mkdir -p /tmp/mbus-$PROC_TTYDEV-$unit_id

get_data() {
	local cfg=$1
	config_get enable $cfg enable "0"
	[ "$enable" == "1" ] || return
	config_get tagname $cfg tagname ""
	[ "$tagname" == "$PROC_TAGNAME" ] || return
	config_get unit_id $cfg unit_id "1"
	$BIN -b $PROC_BAUD $PROC_TTYDEV $unit_id > /tmp/mbus-$PROC_TTYDEV-$unit_id/current.xml
	config_get addr $cfg addr "0"
	value=$(/usr/bin/xml_parser.sh /tmp/mbus-$PROC_TTYDEV-$unit_id/current.xml $addr "Value")
	#unit=$(/usr/bin/xml_parser.sh /tmp/mbus-$PROC_TTYDEV-$unit_id/current.xml $addr "Unit")
	uci_set bacnet_$file $cfg value "$value"
	uci_commit bacnet_$file
}

while true; do
	#Load config
	config_files="ai av"
	for file in $config_files ; do
		config_load bacnet_$file
		config_foreach get_data $file
	done
	sleep 3
done
