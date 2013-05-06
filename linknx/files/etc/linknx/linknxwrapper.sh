#!/bin/sh

. /etc/functions.sh

local rule_id=$1
local object_value=$2

rule_id=$(echo $rule_id | cut -d '_' -f 2- )
logger "linknxwrapper $rule_id $object_value"

#writeLinknx $rule_id $object_value

