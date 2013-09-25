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
local uci = luci.model.uci.cursor()
local uci_state = luci.model.uci.cursor_state()

if not luci.fs.access("/etc/config/bacnet_dev") then
	if not luci.sys.exec("touch /etc/config/bacnet_dev") then
		return
	end
end

m = Map("bacnet_dev", "Bacnet Device", "Bacnet Device Configuration")

s = m:section(TypedSection, "dev", 'Device Nummer')
s.addremove = true
s.anonymous = false

sva = s:option(Value, "bacdl", "Netzwerk Layer")
sva:value('ip4','BACnet IPv4')
sva:value('ip6','BACnet IPv6')
sva:value('ether','BACnet Ethernet')
sva:value('mstp','BACnet MSTP (RS485/RS232)')

sva = s:option(Value, "iface", "Netzwerk Interface")
uci:foreach("network", "interface",
	function(section)
		sva:value(section[".name"])
	end)

sva = s:option(Value, "port", "UDP Port")
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

