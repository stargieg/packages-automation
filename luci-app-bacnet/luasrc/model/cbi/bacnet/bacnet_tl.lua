--[[
LuCI - Lua Configuration Interface

Copyright 2012 Patrick Grimm <patrick@lunatiki.de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

require("luci.sys")
require("luci.util")
require("luci.tools.webadmin")
require("nixio.fs")
local arg1 = arg[1]
local uci = luci.model.uci.cursor()
local uci_state = luci.model.uci.cursor_state()

if not nixio.fs.access("/etc/config/bacnet_tl") then
	if not luci.sys.exec("touch /etc/config/bacnet_tl") then
		return
	end
end

--if arg1 then
--	m = Map("bacnet_tl_"..arg1, "Bacnet Trendlog", "Bacnet Trendlog Configuration")
--else
m = Map("bacnet_tl", "Bacnet Trendlog", "Bacnet Trendlog Configuration")
--end

s = m:section(TypedSection, "tl", arg1 or 'TL Index')
s.addremove = true
s.anonymous = false
s.template = "cbi/tblsection"

s:option(Flag, "disable", "Disable")
local sva = s:option(ListValue, "device_type", "Log Device Typ")
sva:value("8","DEV")
sva.rmempty = true

local sva = s:option(ListValue, "object_type", "Log Objekt Typ")
sva:value("0","AI")
sva:value("1","AO")
sva:value("2","AV")
sva:value("3","BI")
sva:value("4","BO")
sva:value("5","BV")
sva:value("13","MI")
sva:value("14","MO")
sva:value("19","MV")

local sva = s:option(Value, "object_instance", "Log Objekt Index/Instance")
sva.datatype = "range(0, 1024)"

local sva = s:option(Value, "interval", "Interval in sekunden")
sva.placeholder = 10
sva.datatype = "range(1, 8640)"
sva.rmempty = true

return m
