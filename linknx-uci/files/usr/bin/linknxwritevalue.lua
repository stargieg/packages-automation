#!/usr/bin/lua

require "uci"
nixio = require "nixio"

function linknxwrite_logger_err(msg)
	local pc=io.popen("logger -p error -t linknxwrite "..msg)
	if pc then pc:close() end
end

function linknxwrite_logger_info(msg)
	local pc=io.popen("logger -p info -t linknxwrite "..msg)
	if pc then pc:close() end
end

local name = arg[1]
local value = arg[2]

if not name then
	linknxwrite_logger_err("no varname")
	return
end

if not value then
	linknxwrite_logger_err(name.." no value")
	return
end

local config=string.gsub(name,"^(.-)%..*$","%1")
local section=string.gsub(name,"^.*%.(.-)$","%1")
local state = uci.cursor(nil, "/var/state")
local cfgvalue = state:get(config, section, "value") or "0"
local type = state:get(config, section, "type")
local oldvalue
if type and type ~= "1.001" and ( value == "on" or value == "off" ) then
	if value == "off" then
		value = 0
		oldvalue = cfgvalue
	else
		if cfgvalue == "0" then
			value = state:get(config, section, "oldvalue") or "100"
			if value == "0" then value = "100" end
		else
			value = cfgvalue
		end
	end
end
if value == cfgvalue then
	linknxwrite_logger_info(name.." no change of value "..value.."/"..cfgvalue)
	return
end
local s = nixio.socket('inet', 'stream', none)
s:connect('localhost','1028')
--s = nixio.socket('unix', 'stream', none)
--s:connect('/var/run/linknx')
s:send("<write><object id="..name.." value="..value.."/></write>\r\n\4")
s:close()

local x = uci.cursor()
local comment=x:get(config, section, "Name")
local maingrp=x:get(config, "main_group", "Name")
local middlegrp=x:get(config, "middle_group", "Name")
local topic=maingrp.."/"..middlegrp.."/"..comment

local state = uci.cursor(nil, "/var/state")
state:set(config, section, "value", value)
if oldvalue then
	state:set(config, section, "oldvalue", oldvalue)
end
state:save(config)
nixio.fs.chmod("/var/state/"..config,644)
