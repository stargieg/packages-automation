#!/bin/sh

. /etc/functions.sh

varname="$1"
val="$2"
config_load linknx_varlist
comment=$(config_foreach searchcomment pvar "$varname")
#val=$(readKnx $varname)
logger -t linkxmail "$varname $comment $val"
CURDATE=`date`
ssmtp -oi eibserver@openwrt << EOF
From: eibserver <eibserver@openwrt>
To: admin@openwrt
Subject: Stoerung $comment

Stoerung $comment
Wert: $val
Variable: $varname

EOF
