#!/usr/bin/lua

require "uci"
nixio = require "nixio"
mqtt = require "mosquitto"
json = require "luci.jsonc"

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
local homebridge

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
homebridge=x:get(config, section, "homebridge")

state = uci.cursor(nil, "/var/state")
count = state:get(config, section, "count") or "0"
oldvalue = state:get(config, section, "oldvalue")
cfgvalue = state:get(config, section, "value")
count = tonumber(count)
count = count + 1
state:set(config, section, "count", count)
state:set(config, section, "value", value)
state:save(config)
logger_info(name.."/"..value.."/"..topic)

mclient = mqtt.new()

mclient.ON_CONNECT = function()
	local mid
	mid = mclient:publish(topic,value)
end
mclient.ON_PUBLISH = function()
	mclient:disconnect()
end
mclient:connect()
mclient:loop_forever()

if homebridge == "1" then
	local valuejs
	if not valuejs and value == "on" then
		valuejs=json.stringify({ name = name, service_name = topic, characteristic = "On", value = true})
	end
	if not valuejs and value == "off" then
		valuejs=json.stringify({ name = name, service_name = topic, characteristic = "On", value = false})
	end
	if not valuejs and value == "0" then
		valuejs=json.stringify({ name = name, service_name = topic, characteristic = "On", value = false})
	end
	if not valuejs then
		value=math.floor(value + .5)
		valuejs=json.stringify({ name = name, service_name = topic, characteristic = "Brightness", value = value})
	end
	if valuejs then
		mclienthb = mqtt.new()
		mclienthb.ON_CONNECT = function()
			mid = mclienthb:publish("homebridge/to/set",valuejs)
		end
		mclienthb.ON_PUBLISH = function()
			mclienthb:disconnect()
		end
		mclienthb:connect()
		mclienthb:loop_forever()
	end
end

nixio.fs.chmod("/var/state/"..config,644)
