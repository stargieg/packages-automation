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
local lfs  = require "luci.fs"
local uci = require "luci.model.uci".cursor()
local sys = require "luci.sys"
local uci_state = require "luci.model.uci".cursor_state()

if not lfs.access("/etc/config/bacnet_dev") then
	if not sys.exec("touch /etc/config/bacnet_dev") then
		return
	end
end

local m = Map("bacnet_dev", "Bacnet Device", "Bacnet Device Configuration")

local s = m:section(TypedSection, "dev", 'Device Nummer')
s.addremove = true
s.anonymous = false

local active = s:option(DummyValue, "_active", translate("Started") )
function active.cfgvalue(self, section)
	local pid = fs.readfile("/var/run/bacserv-%s.pid" % section)
	if pid and #pid > 0 and tonumber(pid) ~= nil then
		return (sys.process.signal(pid, 0))
			and translatef("yes (%i)", pid)
			or  translate("no")
	end
	return translate("no").." "..section
end

local updown = s:option(Button, "_updown", translate("Start/Stop") )
updown._state = false
function updown.cbid(self, section)
	local pid = fs.readfile("/var/run/bacserv-%s.pid" % section)
	self._state = pid and #pid > 0 and sys.process.signal(pid, 0)
	self.option = self._state and "stop" or "start"
	
	return AbstractValue.cbid(self, section)
end
function updown.cfgvalue(self, section)
	self.title = self._state and "stop" or "start"
	self.inputstyle = self._state and "reset" or "reload"
end
function updown.write(self, section, value)
	if self.option == "stop" then
		sys.call("/etc/init.d/bacserv stop %s" % section)
	else
		sys.call("/etc/init.d/bacserv start %s" % section)
	end
end

s:option(Flag, "enable", "enable")

sva = s:option(Value, "bacdl", "Netzwerk Layer")
sva:value('bip','BACnet IPv4')
sva:value('bip6','BACnet IPv6')
sva:value('ethernet','BACnet Ethernet')
sva:value('mstp','BACnet MSTP (RS485/RS232)')

sva = s:option(Value, "iface", "Netzwerk Interface")
uci:foreach("network", "interface",
	function(section)
		sva:value(section[".name"])
	end)

sva = s:option(Value, "port", "UDP Port")
sva:depends("bacdl","bip")
sva:value('47808')
sva:value('47809')
sva:value('47810')

sva = s:option(Value, "net", "Net")
sva:value('0','BAC0')
sva:value('1','BAC1')
sva:value('2','BAC2')

s:option(Value, "id", "Device ID")
s:option(Value, "app_ver", "Device Version")
s:option(Value, "name", "Device Name")
s:option(Value, "modelname", "Model Name")

s:option(Value, "description", "Anzeige Name")
s:option(Value, "location", "Einbau Ort")

return m

