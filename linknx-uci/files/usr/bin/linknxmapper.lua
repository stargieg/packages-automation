#!/usr/bin/lua
--[[
LuCI - Lua Configuration Interface

Copyright 2012 Patrick Grimm <patrick@lunatiki.de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

local argv = {}

local io = require "io"
local sys = require("luci.sys")
local uci = luci.model.uci.cursor()
--local uci_state = luci.model.uci.cursor_state()
local nixio = require "nixio"
--local s = nixio.socket('unix', 'stream', none)
local json = require "luci.json"

function logger_err(msg)
	nixio.syslog("err",msg)
end

function logger_info(msg)
	nixio.syslog("info",msg)
end

local name= arg[1]
local value = arg[2]
local group = arg[3]
local dpt = arg[4]
if not name then
	logger_err("no varname")
	return
end
if not value then
	logger_err(name.." no value")
	return
end
if not group then
	logger_err(name..":"..value.." no group")
	return
end

if not dpt then
	logger_err(name..":"..value.." no dpt")
	return
end

--logger_info(name.." "..value.." "..group.." "..dpt)

if dpt == "1.001" then
	if string.find(value, 'on') then
		value = '1'
	else
		value = '0'
	end
elseif dpt == "3.007" then
	if string.find(value, 'up') then
		value = '1'
	elseif string.find(value, 'down') then
		value = '2'
	else
		value = '3'
	end
end

--TODO ubus intergration
--local el = {}
--el.id=99
--el.name=name
--el.group=group
--el.value=value
--logger_info(name.." "..value.." "..group)
--os.execute('ubus send linknx \''..json.encode(el)..'\'')
local uci_commit = 0
uci:load("bacnet_"..group)
uci:foreach("bacnet_"..group, group, function(s)
	if s.name == name then
		uci:set('bacnet_'..group,s[".name"],'value',value)
		uci:set('bacnet_'..group,s[".name"],'Out_Of_Service','0')
		uci:set('bacnet_'..group,s[".name"],'value_time',tostring(os.time()))
		if group == "ao" or group == "bo" or group == "mo" then
			uci:set('bacnet_'..group,s[".name"],'fb_value',value)
		end
		uci:save('bacnet_'..group)
		uci_commit = 1
	end
end)
if uci_commit == 1 then
	uci:commit('bacnet_'..group)
end

--nixio.fs.chmod('/var/state/bacnet_'..group,'666')
