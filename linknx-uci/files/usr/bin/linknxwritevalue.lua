#!/usr/bin/lua

require "uci"
nixio = require "nixio"

function logger_err(msg)
	local pc=io.popen("logger -p error -t linknxwrite "..msg)
	if pc then pc:close() end
end

function logger_info(msg)
	local pc=io.popen("logger -p info -t linknxwrite "..msg)
	if pc then pc:close() end
end

local name = arg[1]
local value = arg[2]
local mid = arg[3]

if not name then
	logger_err("no varname")
	return
end

if not value then
	logger_err(name.." no value")
	return
end

local config=string.gsub(name,"^(.-)%..*$","%1")
local section=string.gsub(name,"^.*%.(.-)$","%1")
local state = uci.cursor(nil, "/var/state")
local cfgvalue = state:get(config, section, "value", value) or ""
if mid and value == cfgvalue then
	logger_info(name.." no change of value "..value.."/"..cfgvalue.."/"..mid)
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
state:save(config)
nixio.fs.chmod("/var/state/"..config,644)
