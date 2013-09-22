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
require("luci.fs")
local arg1 = arg[1]
local uci = luci.model.uci.cursor()
local uci_state = luci.model.uci.cursor_state()

if not luci.fs.access("/etc/config/bacnet_bi") then
	if not luci.sys.exec("touch /etc/config/bacnet_bi") then
		return
	end
end

local events = {}
events[1] = {0,"Keine Ereignis Behandlung"}
events[2] = {1,"Ereignis"}
events[3] = {2,"Ereignis"}
events[4] = {3,"Ereignis"}
events[5] = {4,"Ereignis"}
events[6] = {5,"Ereignis"}
events[7] = {6,"Ereignis"}
events[8] = {7,"Alle Ereignis behandeln"}

--if arg1 then
--	m = Map("bacnet_av_"..arg1, "Bacnet Analog Value", "Bacnet Analog Value Configuration")
--else
m = Map("bacnet_bi", "Bacnet Binary Input", "Bacnet Binary Input Configuration")
--end

local s = m:section(TypedSection, "bi", arg1 or 'BI Index')
s.addremove = true
s.anonymous = false
s.template = "cbi/tblsection"
s:tab("main","Standard")
s:tab("adv","Erweitert")
s:tab("io","Zugrifsname")

local sva = s:taboption("main", Flag, "disable", "Disable")

local sva = s:taboption("main", Value, "name", "BI Name")

local sva = s:taboption("io", Value, "linknx", "Linknx Zugrifsname")
uci:foreach("linknx", "daemon",
	function (section)
			sva:value(section.tagname)
	end)
local sva = s:taboption("io", Value, "modbus", "Modbus Zugrifsname")
uci:foreach("modbus", "station",
	function (section)
			sva:value(section.tagname)
	end)

local sva = s:taboption("io", Value, "icinga", "Icinga Zugrifsname")
uci:foreach("icinga", "station",
	function (section)
			sva:value(section.tagname)
	end)

local sva = s:taboption("io", Value, "addr", "Addr")

local sva = s:taboption("main", Flag, "value", "Value")
sva.rmempty = false

local sva = s:taboption("adv", Flag, "alarm_value", "Alarm Value")
sva.rmempty = false
for i, v in ipairs(events) do
	if v[1] ~= 0 then
		sva:depends("event",v[1])
	end
end

local sva = s:taboption("main", Value, "group",  "Gruppe")
local uci = luci.model.uci.cursor()
uci:foreach("bacnet_group", "group",
	function (section)
			sva:value(section.name)
	end)

local sva = s:taboption("main", Value, "description", "Anzeige Name")

local sva = s:taboption("adv", Value, "inactive", "Inactive Text")

local sva = s:taboption("adv", Value, "active", "Active Text")

local sva = s:taboption("adv", Flag, "tl", "Trend Log")

local sva = s:taboption("adv", Value, "nc",  "Notification Class")
local uci = luci.model.uci.cursor()
uci:foreach("bacnet_nc", "nc",
	function (section)
			sva:value(section[".name"],section.name)
	end)

local sva = s:taboption("adv", Value, "event",  "BIT1 Alarm,BIT2 Fehler,BIT3 Alarm oder Fehler geht [7]")
for i, v in ipairs(events) do
	sva:value(v[1],v[1]..": "..v[2])
end

local sva = s:taboption("adv", Value, "time_delay",  "Zeitverzoegerung in sec")

return m

