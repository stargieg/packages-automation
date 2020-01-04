#!/usr/bin/lua

require "uci"
local argv = {}

function logger_err(msg)
	os.execute("logger -p error -t linknxmapper "..msg)
end

function logger_info(msg)
	os.execute("logger -p info -t linknxmapper "..msg)
end

local name= arg[1]
local value = arg[2]

if not name then
	logger_err("no varname")
	return
end

if not value then
	logger_err(name.." no value")
	return
end

config=string.gsub(name,"^(.-)%..*$","%1")
section=string.gsub(name,"^.*%.(.-)$","%1")

x = uci.cursor()
comment=x:get(config, section, "Name")
maingrp=x:get(config, "main_group", "Name")
middlegrp=x:get(config, "middle_group", "Name")
long=maingrp.."/"..middlegrp.."/"..comment
logger_info(value.." "..name.." comment "..long)

state = uci.cursor(nil, "/var/state")
count = state:get(config, section, "count") or "0"
count = tonumber(count)
count = count + 1
state:set(config, section, "count", count)
state:set(config, section, "value", value)
state:save(config)
