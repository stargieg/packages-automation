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
local alm
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

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

--logger_info(name.." "..value.." "..group)
if string.find(name, '_hw_') then
	if string.find(value, '%.') then
		value = round(value)
	end
end
if string.find(value, 'on') then
	value = '1'
elseif string.find(value, 'off') then
	value = '0'
end
if string.find(name, 'stat_dw_1') then
	local retbit=tonumber(value) or 1
	local ret_text=''
	if retbit >= 128 then
		ret_text=ret_text.." Frostalarm"
		retbit=retbit-128
		alm=1
	end
	if retbit >= 64 then
		ret_text=ret_text.." Totzone"
		retbit=retbit-64
	end
	if retbit >= 32 then
		ret_text=ret_text.." Heizen"
		retbit=retbit-32
	else
		ret_text=ret_text.." Kühlen"
	end
	if retbit >= 16 then
		ret_text=ret_text.." gesperrt"
		retbit=retbit-16
	end
	if retbit >= 8 then
		ret_text=ret_text.." Frost"
		retbit=retbit-8
	end
	if retbit >= 4 then
		ret_text=ret_text.." Nacht"
		retbit=retbit-4
	end
	if retbit >= 2 then
		ret_text=ret_text.." Standby"
		retbit=retbit-2
	end
	if retbit >= 1 then
		ret_text=ret_text.." Komfort"
	end
	value=ret_text
end
if string.find(name, 'stat_dw_2') then
	local retbit=tonumber(value) or 1
	local ret_text=value
	if retbit >= 128 then
		ret_text=ret_text.." Taupunktbetrieb"
		retbit=retbit-128
		alm=1
	end
	if retbit >= 64 then
		ret_text=ret_text.." Hitzeschutz"
		retbit=retbit-64
	end
	if retbit >= 32 then
		ret_text=ret_text.." Zusatzstufe"
		retbit=retbit-32
	end
	if retbit >= 16 then
		ret_text=ret_text.." Fensterkontakt"
		retbit=retbit-16
	end
	if retbit >= 8 then
		ret_text=ret_text.." Präsenztaste"
		retbit=retbit-8
	end
	if retbit >= 4 then
		ret_text=ret_text.." Präsenzmelder"
		retbit=retbit-4
	end
	if retbit >= 2 then
		ret_text=ret_text.." Komfortverlängerung"
		retbit=retbit-2
	end
	if retbit >= 1 then
		ret_text=ret_text.." Normal"
	else
		ret_text=ret_text.." Zwangs-Betriebsmodus"
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

uci_state:load("linknx_varlist_"..group)
uci_state:foreach("linknx_varlist_"..group, "pvar", function(s)
	if s.name == name then
		event = uci:get('linknx_varlist_'..group,s[".name"],'event')
		if event == 'alarm' then
			lastime = tostring(os.time()*1000)
			if value=="1" then
				comment = uci_state:get('linknx_varlist_'..group,s[".name"],'comment')
				ontime = uci_state:get('linknx_varlist_'..group,s[".name"],'ontime')
				offtime = uci_state:get('linknx_varlist_'..group,s[".name"],'offtime')
				acktime = uci_state:get('linknx_varlist_'..group,s[".name"],'acktime')
				if not ontime then
					ontime = lastime
					uci_state:set('linknx_varlist_'..group,s[".name"],'ontime',lastime)
				else
					uci_state:set('linknx_varlist_'..group,s[".name"],'lasttime',lastime)
				end
				ack = uci_state:get('linknx_varlist_'..group,s[".name"],'ack')
				if offtime and ack=='ack' then
					ack = 'unack'
					offtime = 0
					acktime = 0
					uci_state:set('linknx_varlist_'..group,s[".name"],'ack',ack)
					uci_state:set('linknx_varlist_'..group,s[".name"],'acktime',acktime)
					uci_state:set('linknx_varlist_'..group,s[".name"],'offtime',offtime)
				end
				if not ack or acktime then
					ack = "unack"
					acktime = 0
					offtime = 0
					uci_state:set('linknx_varlist_'..group,s[".name"],'ack',ack)
					uci_state:set('linknx_varlist_'..group,s[".name"],'acktime',acktime)
					uci_state:set('linknx_varlist_'..group,s[".name"],'offtime',offtime)
				end
				uci_state:set('linknx_varlist_'..group,s[".name"],'value',value)
				logger_err('ws sm on '..name..','..value..','..group..','..comment..','..ontime..','..offtime..','..acktime..','..lastime..','..ack)
				local el = {}
				el.id=99
				el.name=name
				el.value=value
				el.group=group
				el.comment=comment
				el.ontime=ontime
				el.offtime=offtime
				el.acktime=acktime
				el.lastime=lastime
				el.ack=ack
				os.execute('ubus send linknx \''..json.encode(el)..'\'')
			else
				comment = uci_state:get('linknx_varlist_'..group,s[".name"],'comment')
				ontime = uci_state:get('linknx_varlist_'..group,s[".name"],'ontime')
				if not ontime then
					ontime = lastime
					uci_state:set('linknx_varlist_'..group,s[".name"],'ontime',lastime)
				else
					uci_state:set('linknx_varlist_'..group,s[".name"],'lasttime',lastime)
				end
				offtime = lastime
				acktime = uci_state:get('linknx_varlist_'..group,s[".name"],'acktime') or '0'
				lastime = uci_state:get('linknx_varlist_'..group,s[".name"],'lastime') or '0'
				ack = uci_state:get('linknx_varlist_'..group,s[".name"],'ack') or 'unack'
				uci_state:set('linknx_varlist_'..group,s[".name"],'value',value)
				uci_state:set('linknx_varlist_'..group,s[".name"],'offtime',offtime)
				logger_err('ws sm off '..name..','..value..','..group..','..comment..','..ontime..','..offtime..','..acktime..','..lastime..','..ack)
				local el = {}
				el.id=99
				el.name=name
				el.value=value
				el.group=group
				el.comment=comment
				el.ontime=ontime
				el.offtime=offtime
				el.acktime=acktime
				el.lastime=lastime
				el.ack=ack
				os.execute('ubus send linknx \''..json.encode(el)..'\'')
			end
		else
			uci_state:set('linknx_varlist_'..group,s[".name"],'value',value)
		end
	end
end)
uci_state:save('linknx_varlist_'..group)
nixio.fs.chmod('/var/state/linknx_varlist_'..group,'666')

