#!/bin/sh

. /etc/functions.sh

imglist(){
	local cfg="$1"
	local img=''
	local name=''
	config_get img "$cfg" "img"
	[ -z "$img" ] && return 0
	echo "$img"
	config_get name "$cfg" "name"
	[ -z "$name" ] && return 0
	ln -s "$img" "/www/images/cbid.linknx_group."$name".img"
}
statemode(){
	local cfg="$1"
	local name=''
	config_get name "$cfg" "name"
	[ -z "$name" ] && return 0
	touch /var/state/linknx_varlist_$name
	chmod 777 /var/state/linknx_varlist_$name
}
toggle_state(){
	local cfg="$1"
	local group="$2"
	local option="$3"
	value=$(uci_get_state "linknx_varlist_$group" "$cfg" "$option")
	[ -z "$value" ] && return 0
	uci_toggle_state "linknx_varlist_$group" "$cfg" "$option" "$value"
}
newstate(){
	local cfg="$1"
	local name=''
	local group=''
	local value=''
	config_get name "$cfg" "name"
	[ -z "$name" ] && return 0
	config_get group "$cfg" "group"
	[ -z "$group" ] && return 0
#	value=$(uci_get_state "linknx_varlist_$group" "$cfg" "value")
#	[ -z "$value" ] && return 0
#	uci_toggle_state "linknx_varlist_$group" "$cfg" "value" "$value"
	toggle_state  "$cfg" "$group" "value"
	toggle_state  "$cfg" "$group" "ontime"
	toggle_state  "$cfg" "$group" "offtime"
	toggle_state  "$cfg" "$group" "acktime"
	toggle_state  "$cfg" "$group" "lasttime"
	toggle_state  "$cfg" "$group" "ack"
}

stateclean(){
	local cfg="$1"
	local name=''
	config_get name "$cfg" "name"
	[ -z "$name" ] && return 0
	config_load linknx_varlist_$name
	[ -f /var/state/linknx_varlist_$name ] || return 0
	config_foreach newstate pvar
	chmod 777 /var/state/linknx_varlist_$name
}



if [ -f "/tmp/linknx-uci-event.log" ] ; then
	echo "linknx-uci-event läuft schon oder ist abgestürzt"
	echo "lockfile löschen mit: rm /tmp/linknx-uci-event.log"
	return 0
fi
touch /tmp/linknx-uci-event.log
config_load linknx_group
case $1 in
	clean)
		config_foreach stateclean group
		;;
	*)
		#/usr/bin/linknxwriterule.lua
		#/usr/bin/esf2uci.lua
		mkdir -p /www/images
		rm -f /www/images/cbid.linknx_group.*
		config_foreach imglist group
		config_foreach statemode group
		config_foreach stateclean group
		;;
esac

rm /tmp/linknx-uci-event.log

