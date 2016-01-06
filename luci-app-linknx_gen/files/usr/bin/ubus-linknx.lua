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

local sys = require("luci.sys")
local json = require "luci.json"
local uci = luci.model.uci.cursor()
local uci_state = luci.model.uci.cursor_state()
local nixio = require "nixio"

function logger_err(msg)
	os.execute("logger -p error -t ubus-linknx "..msg)
end

function logger_info(msg)
	os.execute("logger -p info -t ubus-linknx "..msg)
end

function write_uci(txt,varval)
	uci:foreach("linknx_group", "group", function(g)
		uci_state:load("linknx_varlist_"..g.name)
		uci_state:foreach("linknx_varlist_"..g.name, "pvar", function(s)
			if s.name==txt then
				logger_info("uci_state var:"..txt.." val:"..varval.." : "..g.name)
				uci_state:set('linknx_varlist_'..g.name,s[".name"],'value',varval)
			end
		end)
		uci_state:save('linknx_varlist_'..g.name)
	end)
end

function write_uci_group(txt,varval,group)
	uci_state:load("linknx_varlist_"..group)
	uci_state:foreach("linknx_varlist_"..group, "pvar", function(s)
		if s.name==txt then
			logger_info("uci_state var:"..txt.." val:"..varval.." : "..group)
			uci_state:set('linknx_varlist_'..group,s[".name"],'value',varval)
		end
	end)
	uci_state:save('linknx_varlist_'..group)
end

function write_uci_group_alm(name,group,acktime,ack)
	uci_state:load("linknx_varlist_"..group)
	uci_state:foreach("linknx_varlist_"..group, "pvar", function(s)
		if s.name==name then
			if ack=="ack" then
				uci_state:set('linknx_varlist_'..group,s[".name"],'acktime',acktime)
			else
				uci_state:set('linknx_varlist_'..group,s[".name"],'acktime','0')
			end
			uci_state:set('linknx_varlist_'..group,s[".name"],'ack',ack)
		end
	end)
	uci_state:save('linknx_varlist_'..group)
end

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end


function write_linknx(name,value)
	if string.find(name, '_hw_') then
		value = round(value)
	end
	rets=s:send("<write><object id="..name.." value="..value.."/></write>\r\n\4")
end

local argv = {}

local msg_type = arg[1]
local msg = arg[2]

if not msg_type then
	logger_err("no msg_type")
	return
end
if not msg then
	logger_err("no msg")
	return
end

local jmsg = json.decode(msg)
if not jmsg then
	logger_err("no json msg")
	return
end

local name = jmsg.name
local value = jmsg.value
local group = jmsg.group
local tagname = jmsg.tagname
--local comment = 
--local ontime = 
--local offtime = 
local acktime = jmsg.acktime
--local lasttime = 
local ack = jmsg.ack

if name and value and group and tagname then
	if tagname == 'socket' then
		local addr
		local server
		uci_state:foreach("linknx_varlist_"..group, "pvar", function(s)
			if s.name == name then
				addr = uci:get('linknx_varlist_'..group,s[".name"],'addr')
				server = uci:get('linknx_varlist_'..group,s[".name"],'server')
				logger_info("var:"..name.." addr:"..addr.." val:"..value.." group:"..group.."\n")
			end
		end)
		if addr == "medialist.radio" then
			uci:foreach("linknx_medialist", "radio", function(r)
				if r.name == value then
					addr = r.addr
				end
			end)
		else
			addr = addr.." "..value.."%"
		end
		logger_info("nc var:"..name.." addr:"..addr.." val:"..value.." group:"..group.."\n")
		sys.exec("echo '"..addr.."' | nc "..server)
		write_uci_group(name,value,group)
	elseif tagname == 'linknx' then
		logger_info("linknx var:"..name.." val:"..value.." : "..group)
		s = nixio.socket('unix', 'stream', none)
		s:connect('/var/run/linknx.sock')
		write_linknx(name,value)
		s:close()
		if acktime and ack then
			write_uci_group(name,value,group,acktime,ack)
		else
			write_uci_group(name,value,group)
		end
	end
elseif name and group and acktime and ack then
	logger_info("alm var:"..name.." : "..group.." : "..acktime.." : "..ack)
	write_uci_group_alm(name,group,acktime,ack)
end

