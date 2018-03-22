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

if not nixio.fs.access("/etc/config/bacnet_bo") then
	if not luci.sys.exec("touch /etc/config/bacnet_bo") then
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
--	m = Map("bacnet_bo_"..arg1, "Binary Output Value", "Bacnet Binary Output Configuration")
--else
m = Map("bacnet_bo", "Bacnet Binary Ouput", "Bacnet Binary Output Configuration")
--end

local s = m:section(TypedSection, "bo", arg1 or 'Index')
s.addremove = true
s.anonymous = false
--s.template = "cbi/tblsection"
s:tab("main","Standard")
s:tab("adv","Erweitert")
s:tab("io","Zugrifsname")

s:taboption("main", Flag, "disable", "Disable")
s:taboption("main",Flag, "Out_Of_Service", "Out Of Service")
s:taboption("main", Value, "name", "Name")

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

local sva = s:taboption("io", Value, "unit_id", "Unit ID")
sva:value('1')
sva:value('255')
sva.rmempty = true
local sva = s:taboption("io", Value, "addr", "Addr")
local sva = s:taboption("io", Value, "resolution", "Auflösung")
sva:value("dword","1 Bit aus 1 Register")
sva:value("bit","1 Bit")
local sva = s:taboption("io", ListValue, "bit", "Bit 0-15")
sva:depends("resolution","dword")
sva:value("0","Bit 0")
sva:value("1","Bit 1")
sva:value("2","Bit 2")
sva:value("3","Bit 3")
sva:value("4","Bit 4")
sva:value("5","Bit 5")
sva:value("6","Bit 6")
sva:value("7","Bit 7")
sva:value("8","Bit 8")
sva:value("9","Bit 9")
sva:value("10","Bit 10")
sva:value("11","Bit 11")
sva:value("12","Bit 12")
sva:value("13","Bit 13")
sva:value("14","Bit 14")
sva:value("15","Bit 15")

local sva = s:taboption("main", Flag, "value", "Value")
sva.rmempty = false

local sva = s:taboption("main", Flag, "fb_value", "Feedback Value")
sva.rmempty = false

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
local sva = s:taboption("adv", Value, "value_time", "value_time")

return m

