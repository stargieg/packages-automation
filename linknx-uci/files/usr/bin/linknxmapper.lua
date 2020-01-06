#!/usr/bin/lua

require "uci"
nixio = require "nixio"
mqtt = require "mosquitto"

function logger_err(msg)
	local pc=io.popen("logger -p error -t linknxmapper "..msg)
	if pc then pc:close() end
end

function logger_info(msg)
	local pc=io.popen("logger -p info -t linknxmapper "..msg)
	if pc then pc:close() end
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
topic=maingrp.."/"..middlegrp.."/"..comment

state = uci.cursor(nil, "/var/state")
count = state:get(config, section, "count") or "0"
count = tonumber(count)
count = count + 1
state:set(config, section, "count", count)
state:set(config, section, "value", value)

mclient = mqtt.new()

mclient.ON_CONNECT = function()
	local mid
	mid = mclient:publish(topic,value)
	logger_info(name.."/"..value.."/"..topic.."/"..mid)
end
mclient.ON_PUBLISH = function()
	mclient:disconnect()
end
mclient:connect()
mclient:loop_forever()

state:save(config)
nixio.fs.chmod("/var/state/"..config,644)
