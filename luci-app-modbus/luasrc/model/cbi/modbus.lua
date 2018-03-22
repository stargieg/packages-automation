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
local uci = luci.model.uci.cursor()
local uci_state = luci.model.uci.cursor_state()

if not nixio.fs.access("/etc/config/modbus") then
	if not luci.sys.exec("touch /etc/config/modbus") then
		return
	end
end

m = Map("modbus", "Modbus Device", "Modbus Device Configuration")

s = m:section(TypedSection, "station", 'Station')
s.addremove = true
s.anonymous = true

s:option(Flag, "enable", "enable")

s:option(Value, "tagname", "Tag Name benutzt in bacnet objects")

sva = s:option(Value, "unit_id", "Standart Unit ID")
sva:value('1')
sva:value('255')

sva = s:option(Value, "mode", "Schnitstellen Modus")
sva:value("tcp","Modbus TCP/IPv4")
sva:value("tcpip","Modbus TCP/IPv6")
sva:value("rtu","Modbus RTU (RS485/RS232)")

sva = s:option(Value, "ip4addr", "IPv4 Adresse")
sva:depends("mode","tcp")

sva = s:option(Value, "ip6addr", "IPv6 Adresse")
sva:depends("mode","tcpip")

sva = s:option(Value, "port", "TCP Port")
sva:value('502')
sva:depends("mode","tcp")
sva:depends("mode","tcpip")

sva = s:option(Value, "ttydev", "Pfad zur tty Geraetedatei")
for device in nixio.fs.glob("/dev/ttyS[0-9]*") do
	svc:value(device)
end
for device in nixio.fs.glob("/dev/ttyUSB[0-9]*") do
	svc:value(device)
end
sva:depends("mode","rtu")
sva = s:option(Value, "baud", "Uebertragungsrate")
sva:value('9600')
sva:value('19200')
sva:value('38400')
sva:value('57600')
sva:value('115200')
sva:depends("mode","rtu")
sva = s:option(Value, "parity_bit", "Parity Bit")
sva:value('N')
sva:value('O')
sva:value('E')
sva:depends("mode","rtu")
sva = s:option(Value, "data_bit", "Data Bit")
sva:value('7')
sva:value('8')
sva:depends("mode","rtu")
sva = s:option(Value, "stop_bit", "Stop Bit")
sva:value('1')
sva:value('1.5')
sva:value('2')
sva:depends("mode","rtu")


s:option(Value, "modelname", "Model Name")

s:option(Value, "description", "Anzeige Name")

s:option(Value, "location", "Einbau Ort")

s:option(FileUpload, "csv", "Datenpunktliste")

return m

