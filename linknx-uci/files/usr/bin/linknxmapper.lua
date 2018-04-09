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

local io	= require "io"
local sys 	= require("luci.sys")
--local ucil       = require "uci"
--local uci_state = ucil.cursor(nil, "/var/state")
--local uci       = ucil.cursor()
--local uci_state = uci.cursor_state()
local uci = luci.model.uci.cursor()
local uci_state = luci.model.uci.cursor_state()
local nixio	= require "nixio"
--local s		= nixio.socket('unix', 'stream', none)
local json = require "luci.json"

function logger_err(msg)
	os.execute("logger -p error -t linknxmapper "..msg)
end

function logger_info(msg)
	os.execute("logger -p info -t linknxmapper "..msg)
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

--function round(num, idp)
--  local mult = 10^(idp or 0)
--  return math.floor(num * mult + 0.5) / mult
--end

logger_info(name.." "..value.." "..group.." "dpt)
--if string.find(name, '_hw_') then
--	if string.find(value, '%.') then
--		value = round(value)
--	end
--end
if string.find(value, 'on') then
	value = '1'
elseif string.find(value, 'off') then
	value = '0'
end
	value=ret_text
end

local el = {}
el.id=99
el.name=name
el.group=group
el.value=value
logger_info(name.." "..value.." "..group)
os.execute('ubus send linknx \''..json.encode(el)..'\'')

uci_state:load("bacnet_"..group)
uci_state:foreach("bacnet_"..group, group, function(s)
	if s.name == name then
		else
			uci_state:set('bacnet_'..group,s[".name"],'value',value)
		end
	end
end)
uci_state:save('bacnet_'..group)
nixio.fs.chmod('/var/state/bacnet_'..group,'666')
