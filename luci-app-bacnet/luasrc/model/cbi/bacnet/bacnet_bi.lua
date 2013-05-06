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

if not luci.fs.access("/etc/config/bacnet_av") then
	if not luci.sys.exec("touch /etc/config/bacnet_av") then
		return
	end
end

--if arg1 then
--	m = Map("bacnet_av_"..arg1, "Bacnet Analog Value", "Bacnet Analog Value Configuration")
--else
m = Map("bacnet_bi", "Bacnet Binary Input", "Bacnet Binary Input Configuration")
--end

s = m:section(TypedSection, "bi", arg1 or 'BI Index')
s.addremove = true
s.anonymous = false
s.template = "cbi/tblsection"

s:option(Flag, "disable", "Disable")
s:option(Value, "name", "BI Name")

sva = s:option(Value, "tagname",  "Zugrifsname")
uci:foreach("linknx", "daemon",
	function (section)
			sva:value(section.tagname)
	end)
uci:foreach("modbus", "station",
	function (section)
			sva:value(section.tagname)
	end)
sva:value("icinga")

s:option(Value, "addr", "Addr")
s:option(Flag, "value", "Value")

s:option(Flag, "alarm_value", "Alarm Value")

sva = s:option(ListValue, "group",  "Gruppe")
local uci = luci.model.uci.cursor()
uci:foreach("bacnet_group", "group",
	function (section)
			sva:value(section.name)
	end)

s:option(Value, "description", "Anzeige Name")
sva = s:option(Value, "inactive", "Inactive Text")
sva.value = "inactive"
sva = s:option(Value, "active", "Active Text")
sva.value = "active"
s:option(Flag, "tl", "Trend Log")
sva = s:option(Value, "nc",  "Notification Class")
sva.rmempty = true
local uci = luci.model.uci.cursor()
uci:foreach("bacnet_nc", "nc",
	function (section)
			sva:value(section[".name"],section.name)
	end)
sva = s:option(Value, "event",  "BIT1 Alarm,BIT2 Fehler,BIT3 Alarm oder Fehler geht [7]")
sva:value(0,"0 Keine Ereignis Behandlung")
sva:value(7,"7 Alle Ereignis behandeln")
sva = s:option(Value, "time_delay",  "Zeitverzoegerung in sec")

return m

