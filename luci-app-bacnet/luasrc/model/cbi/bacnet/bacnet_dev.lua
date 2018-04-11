--[[
LuCI - Lua Configuration Interface

Copyright 2012 Patrick Grimm <patrick@lunatiki.de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

local fs  = require "nixio.fs"
local lfs  = require "nixio.fs"
local uci = require "luci.model.uci".cursor()
local sys = require "luci.sys"
local uci_state = require "luci.model.uci".cursor_state()

if not lfs.access("/etc/config/bacnet_dev") then
	if not sys.exec("touch /etc/config/bacnet_dev") then
		return
	end
end

local m = Map("bacnet_dev", "Bacnet Device", "Bacnet Device Configuration")
m.on_after_commit = function() luci.sys.call("/bin/ubus call uci reload_config") end



local s = m:section(TypedSection, "dev", 'Device Nummer')
s.addremove = true
s.anonymous = false

s:option(DummyValue, "dv1", nil, "supported Netzwerk Layers are:")
s:option(DummyValue, "dv1", nil, "BACnetIPv4 opkg install bacnet-stack-bip")
s:option(DummyValue, "dv1", nil, "BACnetIPv6 opkg #WIP")
s:option(DummyValue, "dv1", nil, "BACnet Ethernet (linklocal and fast) opkg install bacnet-stack-ethernet")
s:option(DummyValue, "dv1", nil, "BACnet MSTP (serial RS485) opkg install bacnet-stack-mstp")

-- local active = s:option(DummyValue, "_active", translate("Started") )
-- function active.cfgvalue(self, section)
-- 	local pid = fs.readfile("/var/run/bacserv-%s.pid" % section)
-- 	if pid and #pid > 0 and tonumber(pid) ~= nil then
-- 		return (sys.process.signal(pid, 0))
-- 			and translatef("yes (%i)", pid)
-- 			or  translate("no")
-- 	end
-- 	return translate("no").." "..section
-- end

-- local updown = s:option(Button, "_updown", translate("Start/Stop") )
-- updown._state = false
-- function updown.cbid(self, section)
-- 	local pid = fs.readfile("/var/run/bacserv-%s.pid" % section)
-- 	self._state = pid and #pid > 0 and sys.process.signal(pid, 0)
-- 	self.option = self._state and "stop" or "start"
-- 	
-- 	return AbstractValue.cbid(self, section)
-- end
-- function updown.cfgvalue(self, section)
-- 	self.title = self._state and "stop" or "start"
-- 	self.inputstyle = self._state and "reset" or "reload"
-- end
-- function updown.write(self, section, value)
-- 	if self.option == "stop" then
-- 		sys.call("/etc/init.d/bacserv stop %s" % section)
-- 	else
-- 		sys.call("/etc/init.d/bacserv start %s" % section)
-- 	end
-- end

s:option(Flag, "enable", "enable")

if lfs.access("/usr/sbin/bacserv-router") then
	s:option(Flag, "enable_rt", "enable_rt","Routing Port")
end

sva = s:option(Value, "bacdl", "Netzwerk Layer")
if lfs.access("/usr/sbin/bacserv-bip") or lfs.access("/usr/sbin/bacserv-router") then
	sva:value('bip','BACnet IPv4')
end
if lfs.access("/usr/sbin/bacserv-bip6") then
	sva:value('bip6','BACnet IPv6')
end
if lfs.access("/usr/sbin/bacserv-ethernet") then
	sva:value('ethernet','BACnet Ethernet')
end
if lfs.access("/usr/sbin/bacserv-mstp") or lfs.access("/usr/sbin/bacserv-router") then
	sva:value('mstp','BACnet MSTP (RS485/RS232)')
end


sva = s:option(Value, "iface", "Netzwerk Interface")
uci:foreach("network", "interface",
	function(section)
		sva:value(section[".name"])
	end)
if lfs.access("/usr/sbin/bacserv-mstp") or lfs.access("/usr/sbin/bacserv-router") then
	for device in nixio.fs.glob("/dev/ttyS[0-9]*") do
		sva:value(device)
	end
	for device in nixio.fs.glob("/dev/ttyUSB[0-9]*") do
		sva:value(device)
	end
end

sva = s:option(Value, "port", "UDP Port")
sva:depends("bacdl","bip")
sva.placeholder = 47808
sva.datatype = "portrange"
sva = s:option(Value, "mac", "MAC Addresse")
sva:depends("bacdl","mstp")
sva.placeholder = 127
sva.datatype = "range(0, 128)"
sva.rmempty = true
sva = s:option(Value, "max_master", "Max Master")
sva:depends("bacdl","mstp")
sva.placeholder = 127
sva.datatype = "range(0, 128)"
sva.rmempty = true
sva = s:option(Value, "max_frames", "Max Frames")
sva:depends("bacdl","mstp")
sva.placeholder = 1
sva.datatype = "range(1, 128)"
sva.rmempty = true
sva = s:option(ListValue, "baud", "Uebertragungsrate")
sva:value("","38400 Default")
sva:value('9600')
sva:value('19200')
sva:value('38400')
sva:value('57600')
sva:value('115200')
sva:depends("bacdl","mstp")
sva.rmempty = true
sva = s:option(ListValue, "parity_bit", "Parity Bit")
sva:value('','None Default')
sva:value('N','None')
sva:value('O','Odd')
sva:value('E','Even')
sva:depends("bacdl","mstp")
sva.rmempty = true
sva = s:option(ListValue, "data_bit", "Data Bit")
sva:value("","8 Default")
sva:value(5)
sva:value(6)
sva:value(7)
sva:value(8)
sva:depends("bacdl","mstp")
sva.rmempty = true
sva = s:option(ListValue, "stop_bit", "Stop Bit")
sva:value("","1 Default")
sva:value(1)
sva:value(2)
sva:depends("bacdl","mstp")
sva.rmempty = true

sva = s:option(Value, "net", "Net")
sva.placeholder = 0
sva.datatype = "portrange"
sva.rmempty = true

sva = s:option(Value, "Id", "Device ID")
sva.placeholder = 4711
sva.datatype = "portrange"
s:option(Value, "app_ver", "Device Version")
s:option(Value, "name", "Device Name")
s:option(Value, "modelname", "Model Name")

s:option(Value, "description", "Anzeige Name")
s:option(Value, "location", "Einbau Ort")

return m
