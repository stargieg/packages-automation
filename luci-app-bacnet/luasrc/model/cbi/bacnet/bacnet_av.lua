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

if not nixio.fs.access("/etc/config/bacnet_av") then
	if not luci.sys.exec("touch /etc/config/bacnet_av") then
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

local limits = {}
limits[1] = {0,"Keine Limits"}
limits[2] = {1,"Low"}
limits[3] = {2,"High"}
limits[4] = {3,"Low High"}

--if arg1 then
--	m = Map("bacnet_av_"..arg1, "Bacnet Analog Value", "Bacnet Analog Value Configuration")
--else
m = Map("bacnet_av", "Bacnet Analog Value", "Bacnet Analog Value Configuration")
--end
m.on_after_commit = function() luci.sys.call("/bin/ubus call uci reload_config") end

local s = m:section(TypedSection, "av", arg1 or 'Index')
s.addremove = true
s.anonymous = false
--s.template = "cbi/tblsection"
s:tab("main","Standard")
s:tab("adv","Erweitert")
s:tab("io","Zugrifsname")

s:taboption("main",Flag, "disable", "Disable")
s:taboption("main",Flag, "Out_Of_Service", "Out Of Service")
s:taboption("main",Value, "name", "Name")

local sva = s:taboption("io", Value, "tagname", "Zugrifsname")
uci:foreach("linknx", "station",
	function (section)
			sva:value(section.tagname)
	end)
uci:foreach("modbus", "station",
	function (section)
			sva:value(section.tagname)
	end)
uci:foreach("mbus", "station",
	function (section)
			sva:value(section.tagname)
	end)

local sva = s:taboption("main", Value, "min_value", "Min Present Value")
sva.placeholder = 0
local sva = s:taboption("main", Value, "max_value", "Max Present Value")
sva.placeholder = 100

local sva = s:taboption("io", Value, "unit_id", "Unit ID")
sva.placeholder = 1
sva.datatype = "range(1, 255)"
sva.rmempty = true
local sva = s:taboption("io", ListValue, "func", "Funktions Code")
sva:value('',"Halteregister (Holding Register) Default")
sva:value('1',"Spulen (Coils)")
sva:value('2',"Diskrete Eingäng (Disc Inputs)")
sva:value('3',"Halteregister (Holding Register)")
sva:value('4',"Eingaberegister (Input Register)")
sva.rmempty = true
local sva = s:taboption("io", Value, "addr", "Addr")
sva.placeholder = 1
sva.datatype = "string"
sva:value("","1 Register * 1 Default")
sva:value("doublefloat","2 Register zu Fliesspunkt")
sva:value("float","1 Register zu Fliesspunkt")
sva:value("bit","1 Bit aus 1 Register")
sva:value("0.1","1 Register * 0.1")
sva:value("1","1 Register * 1")
sva:value("10","1 Register * 10")
sva.rmempty = true
local sva = s:taboption("io", ListValue, "dpt", "Datapoint Types defined in KNX standard")
sva:value("","none")
sva:value("1.001","1.001 switching (on/off) (EIS1)")
sva:value("3.007","3.007 dimming (control of dimmer using up/down/stop) (EIS2)")
sva:value("3.008","3.008 blinds (control of blinds using close/open/stop)")
sva:value("5.xxx","5.xxx 8bit unsigned integer (from 0 to 255) (EIS6)")
sva:value("5.001","5.001 scaling (from 0 to 100%)")
sva:value("5.003","5.003 angle (from 0 to 360°)")
sva:value("6.xxx","6.xxx 8bit signed integer (EIS14)")
sva:value("7.xxx","7.xxx 16bit unsigned integer (EIS10)")
sva:value("8.xxx","8.xxx 16bit signed integer")
sva:value("9.xxx","9.xxx 16 bit floating point number (EIS5)")
sva:value("10.001","10.001 time (EIS3)")
sva:value("11.001","11.001 date (EIS4)")
sva:value("12.xxx","12.xxx 32bit unsigned integer (EIS11)")
sva:value("13.xxx","13.xxx 32bit signed integer")
sva:value("14.xxx","14.xxx 32 bit IEEE 754 floating point number")
sva:value("16.000","16.000 string (max 14 ASCII chars restricted to ASCII codes 0..127) (EIS15)")
sva:value("16.001","16.001 string (max 14 ASCII chars in range 0..255)")
sva:value("20.102","20.102 heating mode (auto/comfort/standby/night/frost)")
sva:value("28.001","28.001 variable length string object")
sva:value("29.xxx","29.xxx signed 64bit value")
sva.rmempty = true

local sva = s:taboption("io", Flag, "unsigned", "Ohne Vorzeichen (z.B. Zähler)")


local sva = s:taboption("main", Value, "value", "Value")
sva.rmempty = false

local sva = s:taboption("main", Value, "si_unit", "Einheit")
sva:value("95","Keine Einheit")
sva:value("98","Prozent")
sva:value("62","Grad Celsius")
sva:value("63","Grad Kelvin")
sva:value("53","Pascal")
sva:value("134","mbar")
sva:value("27","Hz")


local sva = s:taboption("main", ListValue, "group",  "Gruppe")
local uci = luci.model.uci.cursor()
uci:foreach("bacnet_group", "group",
	function (section)
			sva:value(section.name)
	end)

s:taboption("main", Value, "description", "Anzeige Name")
s:taboption("adv", Flag, "tl", "Trend Log")
local sva = s:taboption("adv", Value, "nc",  "Notification Class")
sva.rmempty = true
local uci = luci.model.uci.cursor()
uci:foreach("bacnet_nc", "nc",
	function (section)
			sva:value(section[".name"],section.name)
	end)
local sva = s:taboption("adv", Value, "event",  "BIT1 Alarm,BIT2 Fehler,BIT3 Alarm oder Fehler geht [7]")
for i, v in ipairs(events) do
	sva:value(v[1],v[1]..": "..v[2])
end

local sva = s:taboption("adv", Value, "cov_increment", "cov_increment")
sva:value("0.1")
local sva = s:taboption("adv", Value, "limit", "limit")
for i, v in ipairs(limits) do
	sva:value(v[1],v[1]..": "..v[2])
end
local sva = s:taboption("adv", Value, "low_limit", "low_limit")
sva:value("0")
local sva = s:taboption("adv", Value, "high_limit", "high_limit")
sva:value("40")
local sva = s:taboption("adv", Value, "dead_limit", "dead_limit")
sva:value("0")
local sva = s:taboption("adv", Value, "value_time", "value_time")

return m

